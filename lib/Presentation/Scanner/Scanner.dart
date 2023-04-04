// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Presentation/Home/HomePage.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Scanner extends StatefulWidget {
  String? eventID;
  Scanner({super.key, required this.eventID});
  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final GlobalKey globalKey = GlobalKey();
  late QRViewController qrViewController;
  bool correctScan = false;
  bool vibrate = false;
  String? result;
  Color? scanStatus;
  int totalCount = 0;
  String status = "";

  Future<int> countProducts() async {
    print("count products");
    final CollectionReference<Map<String, dynamic>> productList =
        FirebaseFirestore.instance
            .collection('Event')
            .doc(widget.eventID)
            .collection("Participants");
    AggregateQuerySnapshot query = await productList.count().get();
    print('The number of products: ${query.count}');
    setState(() {
      totalCount = query.count;
    });
    print(query.count);
    return query.count;
  }

  @override
  void initState() {
    //countProducts();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(555, 1200),
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            centerTitle: true,
            title: const Text('Scanner'),
          ),
          body: Column(
            children: [
              SizedBox(
                height: 60.h,
              ),
              SizedBox(
                height: 450.h,
                width: 450.w,
                child: QRView(
                  key: globalKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    cutOutHeight: 350.h,
                    cutOutWidth: 350.w,
                    borderColor: scanStatus ?? Colors.red,
                    borderRadius: 10,
                    borderLength: min(350.h, 350.w) / 2 + 12.w * 2,
                    borderWidth: 12.w,
                  ),
                  onPermissionSet: (ctrl, p) =>
                      _onPermissionSet(context, ctrl, p),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: scanStatus, borderRadius: BorderRadius.circular(5)),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 15.sp),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 45.w, right: 45.w),
                child: SizedBox(
                  height: 350.h,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Event')
                        .doc(widget.eventID)
                        .collection('Participants')
                        .orderBy('takenTime', descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      // Camera pausing ..
                      if (correctScan == true) {
                        //qrViewController.pauseCamera();
                        Vibration.vibrate(duration: 50);
                        Timer(const Duration(seconds: 1), () {
                          qrViewController.resumeCamera();
                          correctScan = false;
                        });
                      } // Data Processing ..
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Text("Loading.."),
                        );
                      } else if (!snapshot.hasData) {
                        return Container();
                      } else if (snapshot.hasData) {
                        return ListView(
                            physics: const BouncingScrollPhysics(),
                            children: snapshot.data!.docs.map((e) {
                              var itemTime = (e["takenTime"] as Timestamp)
                                  .toDate()
                                  .toString()
                                  .substring(0, 16);
                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2)),
                                shadowColor: Colors.transparent,
                                color: Colors.grey.shade300,
                                child: ListTile(
                                  dense: true,
                                  subtitle: Text(itemTime),
                                  iconColor: Colors.black45,
                                  title: Text(
                                    e['participantID'],
                                    style: TextStyle(fontSize: 16.sp),
                                  ),
                                  leading: Icon(Icons.account_circle_outlined,
                                      size: 40.h),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      var item = e['participantID'];
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Delete Entry"),
                                            content: Text(
                                                "Do you want to Delete $item ?"),
                                            actions: [
                                              Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      child: const Text(
                                                        "Yes",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                      onPressed: () {
                                                        final collection =
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Event')
                                                                .doc(widget
                                                                    .eventID)
                                                                .collection(
                                                                    'Participants');
                                                        collection
                                                            .doc(e[
                                                                'participantID']) // <-- Doc ID to be deleted.
                                                            .delete() // <-- Delete
                                                            .then(
                                                              (_) => print(
                                                                  'Deleted'),
                                                            )
                                                            .catchError(
                                                              (error) => print(
                                                                  'Delete failed: $error'),
                                                            );
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: const Text(
                                                        "No",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.remove_circle_outline,
                                      size: 30.h,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              );
                            }).toList());
                      } else {
                        return Center(
                          child: Column(
                            children: const [
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
              SizedBox(
                height: 50.h,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  fixedSize: Size(450.w, 70.h),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                  qrViewController.dispose();
                },
                child: Text(
                  'Finish',
                  style: TextStyle(fontSize: 18.sp),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    //print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('no Permission'),
        ),
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    qrViewController = controller;
    controller.scannedDataStream.listen(
      (scanData) async {
        qrViewController.pauseCamera();
        //print("ITs sancnning");
        if (scanData.code != null) {
          result = scanData.code;

          var a = await FirebaseFirestore.instance
              .collection("Event")
              .doc(widget.eventID)
              .collection("Participants")
              .doc(scanData.code)
              .get();

          if ((await FirebaseFirestore.instance
                  .collection("Event")
                  .doc(widget.eventID)
                  .collection("Participants")
                  .doc(scanData.code)
                  .get())
              .exists) {
            scanStatus = Colors.orange;
            status = "$result Attendance Marked already";
          } else {
            status = "Some problem occured";
            scanStatus = Colors.red;
          }

          if (scanData.code != null && !a.exists) {
            var participantref = FirebaseFirestore.instance
                .collection("Event")
                .doc(widget.eventID)
                .collection("Participants")
                .doc(scanData.code);
            participantref.set(
              {
                'takenTime': DateTime.now(),
                'isPresent': true,
                'takenBy': FirebaseAuth.instance.currentUser!.email,
                'participantID': scanData.code
              },
            );
            vibrate = true;
            scanStatus = Colors.green;
            status = "$result Attendance Marked";
            correctScan = true;
          }

          //setState(() {});
        }
      },
    );
  }
}
