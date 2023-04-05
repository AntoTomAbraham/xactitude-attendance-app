import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:ftest/Widgets/ParticipantsTile.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Participants extends StatefulWidget {
  String? eventID;
  Participants({super.key, required this.eventID});

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

    getCSV() async {
      String csvData = const ListToCsvConverter().convert(items);
      print(csvData);
      try {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
        final String directory = (await getApplicationDocumentsDirectory())
            .path;
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(
          Icons.menu,
          color: Colors.black,
        ),
        elevation: 0,
        title: const Text("Participants"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                showSearchBar = !showSearchBar;
                number = "";
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => getCSV(),
        child: const Icon(Icons.download),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Visibility(
                visible : showSearchBar,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 7,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search,color: Colors.black,),
                          labelText: 'Roll No.',
                          labelStyle: TextStyle(color: Colors.black,),
                          enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white, width: 0.0)),
                          disabledBorder:OutlineInputBorder(borderSide: const BorderSide(color: Colors.white, width: 0.0)),
                          focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white, width: 0.0),)
                        ),
                        onChanged: (roll) => setState(() => number = roll),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.8,
                child: Padding(
                  padding: const EdgeInsets.only(left: 21.0, right: 21.0),
                  child: StreamBuilder(
                    stream: participants.orderBy('takenTime', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      return (snapshot.connectionState == ConnectionState.waiting)
                          ? const Center(child: CircularProgressIndicator())
                          : ListView(
                          children: snapshot.data!.docs.map((e) {
                            var time = (e["takenTime"] as Timestamp)
                                .toDate()
                                .toString();
                            items.add([
                              e['participantID'],
                              e["takenBy"],
                              time,
                              e["isPresent"].toString()
                            ]);
                            if (number == "") {
                              return ParticipantsTile(
                                  participantID: e['participantID'],
                                  takenTime: time);
                            } else if (e['participantID'].toString()
                                .toUpperCase()
                                .contains(number.toString().toUpperCase())) {
                              return ParticipantsTile(
                                  participantID: e['participantID'],
                                  takenTime: time);
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
      ),
    );
  }
}

