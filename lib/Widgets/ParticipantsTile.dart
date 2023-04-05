import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ftest/Data/Colour.dart';

class ParticipantsTile extends StatefulWidget {
  String participantID, takenTime, eventID;
  ParticipantsTile({super.key, required this.participantID, required this.takenTime, this.eventID=""});

  @override
  _ParticipantsTileState createState() => _ParticipantsTileState();
}

class _ParticipantsTileState extends State<ParticipantsTile> {

  @override
  Widget build(BuildContext context) {
    if(widget.eventID==""){
      return ListTile(
        title: Text(widget.participantID),
        subtitle: Text(widget.takenTime),
      );
    } else {
      return ListTile(
        tileColor: Colour.tileColor,
        title: Text(widget.participantID),
        subtitle: Text(widget.takenTime),
        trailing: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                        "Are you sure you want to delete ?"),
                    //content: Text("Dialog Content"),
                    actions: [
                      TextButton(
                        child: const Text("Yes"),
                        onPressed: () {
                          FirebaseFirestore
                              .instance
                              .collection('Event')
                              .doc(widget.eventID)
                              .collection('Participants')
                              .doc(widget.participantID)
                              .delete()
                              .then((_) => print('Deleted'))
                              .catchError((error) => print(
                              'Delete failed: $error'));
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text("No"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(
              Icons.delete,
              color: Colors.red,
            )),
      );
    }
  }
}