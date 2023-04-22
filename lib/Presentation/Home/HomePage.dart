// ignore_for_file: avoid_print
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Presentation/Participants/Participants.dart';
import 'package:ftest/Presentation/Scanner/Scanner.dart';
import 'package:ftest/Widgets/EventCard.dart';
import '../../Widgets/AppDrawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //Navigator.pop(context);
    return ScreenUtilInit(
      designSize: const Size(555, 1200),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Home',
              style: TextStyle(color: Colors.black),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          drawer: Drawer(
            backgroundColor: Colors.black,
            child: AppDrawer(
              fAuth: FirebaseAuth.instance,
              pageTitle: "Home",
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(2),
            child: SizedBox(
              height: double.infinity,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Event')
                    .where('coordinators',
                        arrayContains: FirebaseAuth.instance.currentUser!.email)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData) {
                    return Container();
                  } else if (snapshot.hasData) {
                    bool button;
                    return ListView(
                        physics: const BouncingScrollPhysics(),
                        children: snapshot.data!.docs.map((e) {
                          print(e);
                          String eventTense = checkDate(e['eventDate']);
                          if (!DateTime.fromMillisecondsSinceEpoch(
                                  e["endTime"] >= 1000000000
                                      ? e["endTime"]
                                      : e["endTime"] * 1000)
                              .isBefore(DateTime.now())) {
                            //if (eventTense != "past"){
                            print(eventTense);
                            List l = checkTime(e['startTime'], e['endTime']);
                            if ((eventTense == "today" && l[1] == "over") ==
                                false) {
                              if (eventTense == "future") {
                                button = false;
                              } else if (l[1] == "pending") {
                                button = false;
                              } else {
                                button = true;
                              }
                              return EventCard(
                                  isOpenForall: e['openForAll'],
                                  imageUrl: e['backDrop'],
                                  eventName: e['eventName'],
                                  departName: e['deptName'],
                                  date: e['eventDate'],
                                  venue: e['venue'],
                                  time: l[1],
                                  description: e['description'],
                                  button: DateTime.fromMillisecondsSinceEpoch(
                                              e['startTime'])
                                          .isBefore(DateTime.now()) &&
                                      DateTime.fromMillisecondsSinceEpoch(
                                              e['endTime'])
                                          .isAfter(DateTime.now()),
                                  id: e.id);
                            }
                          }
                          return const SizedBox();
                        }).toList());
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
          //)
        );
      },
    );
  }

  String checkDate(String eventDate) {
    DateTime today = DateTime.now();
    int eventYear = int.parse(eventDate.substring(0, 4));
    int eventMonth = int.parse(eventDate.substring(5, 7));
    int eventDay = int.parse(eventDate.substring(8));
    if (today.year > eventYear) {
      return "past";
    } else if ((today.year == eventYear) && (today.month > eventMonth)) {
      return "past";
    } else if ((today.year == eventYear) &&
        (today.month == eventMonth) &&
        (today.day > eventDay)) {
      return "past";
    } else if ((today.year == eventYear) &&
        (today.month == eventMonth) &&
        (today.day == eventDay)) {
      return "today";
    } else {
      return "future";
    }
  }

  List checkTime(int startTime, int endTime) {
    DateTime today = DateTime.now();
    DateTime start = DateTime.fromMillisecondsSinceEpoch(
        startTime >= 1000000000 ? startTime : startTime * 1000);
    DateTime end = DateTime.fromMillisecondsSinceEpoch(
        endTime >= 1000000000 ? endTime : startTime * 1000);
    String eventTime =
        '${start.hour % 12 == 0 ? 12 : start.hour % 12}:${start.minute < 10 ? '0' : ''}${start.minute} ${start.hour < 12 ? 'AM' : 'PM'}';

    if ((today.hour < start.hour) ||
        (today.hour == start.hour && today.minute < start.minute)) {
      return ["pending", eventTime];
    } else if ((today.hour == start.hour && today.minute > start.minute) ||
        (today.hour > start.hour && today.hour < end.hour) ||
        (today.hour == end.hour && today.minute < end.minute)) {
      return ["running", eventTime];
    } else {
      return ["over", eventTime];
    }
  }
}
