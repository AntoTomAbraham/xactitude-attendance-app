import 'dart:async';
import 'dart:math';
import 'package:ftest/Widgets/ParticipantsTile.dart';
import 'package:ftest/Data/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Presentation/Home/HomePage.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// ignore: must_be_immutable
class Scanner extends StatefulWidget {
  String? eventID;
  bool isOpenForall;
  Scanner({super.key, required this.eventID, required this.isOpenForall});
  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final ScrollController scrollControl = ScrollController();
  final GlobalKey globalKey = GlobalKey();
  QRViewController? qrViewController;
  bool correctScan = false;
  bool vibrate = false;
  bool isFlash = false;
  String? result;
  Color? scanStatus;
  int totalCount = 0;
  String status = "";

  @override
  void initState() {
    status = "Scan the QR to mark Attendance";
    scanStatus = primaryBlue;
    super.initState();
  }

  @override
  void dispose() {
    qrViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(555, 1200),
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            backgroundColor: pageHeaderBgColor,
            centerTitle: true,
            title: const Text(
              'QR Scan',
              style: TextStyle(color: pageHeaderTextColor),
            ),
            iconTheme: const IconThemeData(color: pageHeaderTextColor),
          ),
          body: Column(
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: <Widget>[
                  SizedBox(
                    height: 450.h,
                    child: QRView(
                      key: globalKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        cutOutHeight: 350.h,
                        cutOutWidth: 350.w,
                        borderColor: scanStatus ?? Colors.red,
                        borderRadius: 15,
                        borderLength: min(350.h, 350.w) / 2 + 12.w * 2,
                        borderWidth: 15.w,
                      ),
                      onPermissionSet: (ctrl, p) =>
                          _onPermissionSet(context, ctrl, p),
                    ),
                  ),
                  Positioned(
                    bottom: 8.w,
                    right: 8.w,
                    child: SizedBox(
                        child: IconButton(
                      icon: isFlash
                          ? Icon(Icons.flash_on_rounded,
                              color: Colors.white, size: 35.w)
                          : Icon(Icons.flash_off_rounded,
                              color: Colors.white, size: 35.w),
                      onPressed: () {
                        setState(() {
                          qrViewController?.toggleFlash();
                          isFlash = !isFlash;
                        });
                      },
                    )),
                  )
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                padding: EdgeInsets.all(10.h),
                decoration: BoxDecoration(
                    color: scanStatus, borderRadius: BorderRadius.circular(5)),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 20.sp, color: Colors.white),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Flexible(
                flex: 10,
                child: Padding(
                  padding: EdgeInsets.only(left: 15.w, right: 15.w),
                  child: SizedBox(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('events')
                          .doc(widget.eventID)
                          .collection('Participants')
                          .orderBy('takenTime', descending: false)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        // Camera pausing ..
                        if (correctScan == true) {
                          Vibration.vibrate(duration: 100);
                          correctScan = false;
                          Timer(const Duration(seconds: 1), () {
                            scrollLatest();
                          });
                        } // Data Processing ..
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Text("Loading.."),
                          );
                        } else if (!snapshot.hasData) {
                          return Container();
                        } else if (snapshot.hasData) {
                          return ListView(
                              controller: scrollControl,
                              physics: const BouncingScrollPhysics(),
                              children: snapshot.data!.docs.map((e) {
                                var itemTime =
                                    (DateTime.fromMillisecondsSinceEpoch(
                                                e["takenTime"] >= 1000000000
                                                    ? e["takenTime"]
                                                    : e["takenTime"] * 1000)
                                            .toString())
                                        .substring(0, 16);
                                return ParticipantsTile(
                                  isOpenForall: widget.isOpenForall,
                                  isPresent: e['isPresent'],
                                  participantID: e['participantID'],
                                  takenTime: itemTime,
                                  eventID: widget.eventID.toString(),
                                );
                              }).toList());
                        } else {
                          return const Center(
                            child: Column(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red),
                                Text("There was a problem in loading data..")
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              // qrViewController.
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  fixedSize: Size(500.w, 60.h),
                ),
                onPressed: () {
                  qrViewController?.dispose();
                  Navigator.of(context).pop(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                },
                child: Text(
                  'Finish',
                  style: GoogleFonts.inter(
                      fontSize: 25.sp, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 30.h,
              )
            ],
          ),
        );
      },
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    qrViewController!.resumeCamera();
    //print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('no Permission'),
        ),
      );
    }
  }

  void scrollLatest() {
    scrollControl.jumpTo(scrollControl.position.maxScrollExtent);
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() => qrViewController = controller);
    controller.scannedDataStream.listen(
      (scanData) async {
        //print("ITs sancnning");
        qrViewController?.stopCamera();
        try {
          if (scanData.code != null) {
            setState(() => result = scanData.code);
            if (!widget.isOpenForall) {
              var sc = FirebaseFirestore.instance
                  .collection("events")
                  .doc(widget.eventID)
                  .collection("Participants")
                  .doc(scanData.code);
              if ((await FirebaseFirestore.instance
                      .collection("events")
                      .doc(widget.eventID)
                      .collection("Participants")
                      .doc(scanData.code)
                      .get())
                  .exists) {
                sc.update({
                  'takenTime': DateTime.now().millisecondsSinceEpoch,
                  'isPresent': true,
                  'takenBy': FirebaseAuth.instance.currentUser!.email,
                  'participantID': scanData.code
                });
                setState(() {
                  scanStatus = Colors.green;
                  status = "$result Attendance Marked";
                  correctScan = true;
                });
                qrViewController?.resumeCamera();
              } else {
                setState(() {
                  scanStatus = Colors.red;
                  status = "$result is not eligible for this exam";
                });
                qrViewController?.resumeCamera();
              }
              //if the event is open for all
            } else {
              var a = await FirebaseFirestore.instance
                  .collection("events")
                  .doc(widget.eventID)
                  .collection("Participants")
                  .doc(scanData.code)
                  .get();

              if ((await FirebaseFirestore.instance
                      .collection("events")
                      .doc(widget.eventID)
                      .collection("Participants")
                      .doc(scanData.code)
                      .get())
                  .exists) {
                setState(() {
                  scanStatus = Colors.orange;
                  status = "$result Attendance Marked already";
                });
                qrViewController?.resumeCamera();
              } else {
                setState(() {
                  status = "Some problem occured";
                  scanStatus = Colors.red;
                });
              }

              if (scanData.code != null && !a.exists) {
                var participantref = FirebaseFirestore.instance
                    .collection("events")
                    .doc(widget.eventID)
                    .collection("Participants")
                    .doc(scanData.code);
                participantref.set(
                  {
                    'takenTime': DateTime.now().millisecondsSinceEpoch,
                    'isPresent': true,
                    'takenBy': FirebaseAuth.instance.currentUser!.email,
                    'participantID': scanData.code
                  },
                );
                setState(() {
                  scanStatus = Colors.green;
                  status = "$result Attendance Marked";
                  correctScan = true;
                });
                qrViewController?.resumeCamera();
              }
            }
          }
        } catch (e) {
          //print("### Exception occured ###$e");
          setState(() {
            status = "INVALID QR";
            scanStatus = Colors.red;
          });
          qrViewController?.resumeCamera();
        }
      },
    );
  }
}
