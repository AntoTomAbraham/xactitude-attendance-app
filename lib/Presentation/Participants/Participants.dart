import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ftest/Widgets/ParticipantsTile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Widgets/AppDrawer.dart';

class Participants extends StatefulWidget {
  String? eventID;
  bool isOpenForall;
  Participants({super.key, required this.eventID,required this.isOpenForall});

  @override
  State<Participants> createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {
  String number = "";
  List<List<String>> items = [];
  bool showSearchBar = false;

  @override
  void initState() {
    items = [
      <String>["participantID", "takenBy", "takenTime", "isPresent"]
    ];
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference<Map<String, dynamic>> participants = FirebaseFirestore
        .instance
        .collection('Event')
        .doc(widget.eventID)
        .collection('Participants');
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      drawer: Drawer(
        child:  AppDrawer(fAuth: FirebaseAuth.instance, pageTitle: "Participants",),
      ),
      appBar: AppBar(
        title: Text(
            "Participants",
          style: GoogleFonts.inter(color: Color(0xff404040),fontWeight: FontWeight.w500),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                showSearchBar = !showSearchBar;
                number = "";
              });
            },
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //  backgroundColor: Color(0xff1D4ED8),
      //   onPressed: () => getCSV(),
      //   child: const Icon(Icons.download),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Visibility(
              visible : showSearchBar,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 7,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Roll No.'
                  ),
                    onChanged: (roll) => setState(() => number = roll),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Padding(
                padding: const EdgeInsets.only(left: 21.0, right: 21.0),
                child: StreamBuilder(
                  stream: participants.orderBy('takenTime', descending: false).snapshots(),
                  builder: (context, snapshot) {
                    return (snapshot.connectionState == ConnectionState.waiting)
                        ? const Center(child: CircularProgressIndicator())
                        : ListView(
                            children: snapshot.data!.docs.map((e) {
                            var time = DateTime.fromMillisecondsSinceEpoch(e["takenTime"]>= 1000000000 ?e["takenTime"]:e["takenTime"]*1000 ).toString();
                            items.add([e['participantID'], e["takenBy"], time, e["isPresent"].toString()]);
                            if (number == "") {
                              return ParticipantsTile(participantID: e['participantID'], takenTime: time,isPresent: e['isPresent'],isOpenForall: widget.isOpenForall);
                            } else if (e['participantID'].toString().toUpperCase().contains(number.toString().toUpperCase())) {
                              return ParticipantsTile(participantID: e['participantID'], takenTime: time,isPresent: e['isPresent'],isOpenForall:widget.isOpenForall,);
                            } else {
                              return Container();
                            }
                          }).toList()
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getCSV() async {
    String csvData = const ListToCsvConverter().convert(items);
    print(csvData);
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      final String directory = (await getApplicationDocumentsDirectory()).path;
      final String path = "$directory/ams${widget.eventID}.csv";
      final File file = File(path);
      dynamic data = await file.writeAsString(csvData);
      print(data);
      print(path);
      try {
        await OpenFilex.open(file.path);
      } catch (e) {
        print(e);
      }
    } catch (e) {
      print(e);
    }
  }
}