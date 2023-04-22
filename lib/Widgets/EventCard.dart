import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/main.dart';
import '../Presentation/Participants/Participants.dart';
import '../Presentation/Scanner/Scanner.dart';

// ignore: must_be_immutable
class EventCard extends StatefulWidget {
  String imageUrl, eventName, departName, date, venue, time, description, id;
  bool button, isOpenForall;
  EventCard(
      {super.key,
      required this.imageUrl,
      required this.eventName,
      required this.departName,
      required this.date,
      required this.time,
      required this.venue,
      required this.description,
      required this.button,
      required this.id,
      required this.isOpenForall});
  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  var divider = Padding(
    padding: EdgeInsets.only(left: 30.w, right: 30.w),
    child: const Divider(
      color: Color.fromRGBO(192, 192, 192, 1),
      height: 10,
    ),
  );

  var Leftspacer = SizedBox(
    width: 30.w,
  );

  var sizedbox10 = SizedBox(height: 10.h);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 950.h,
      child: Padding(
        padding: EdgeInsets.all(15.w),
        child: Card(
          shadowColor: Colors.grey.shade100,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          color: Colors.white,
          child: Column(
            children: [
              ClipRRect(
                // Backdrop image
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                child: Image.network(widget.imageUrl),
              ),
              SizedBox(
                height: 30.h,
              ),
              Row(
                //Event Name row
                children: [
                  Leftspacer,
                  Text(
                    widget.eventName,
                    style: TextStyle(
                        color: const Color.fromRGBO(58, 58, 58, 1),
                        fontFamily: 'Inter',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                // Department Row
                children: [
                  Leftspacer,
                  Text(
                    "Department of ${widget.departName}",
                    style: TextStyle(
                        color: const Color.fromRGBO(90, 90, 90, 1),
                        fontFamily: 'Inter',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              sizedbox10,
              divider,
              sizedbox10,
              Row(
                // Date Row
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30.w),
                        child: Text(
                          'Date ',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: const Color.fromRGBO(90, 90, 90, 1),
                              fontFamily: 'Inter',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 30.w),
                        child: Text(
                          widget.date,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: const Color.fromRGBO(90, 90, 90, 1),
                              fontFamily: 'Inter',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              sizedbox10,
              divider,
              sizedbox10,
              Row(
                // Venue Row
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30.w),
                        child: Text(
                          'Venue ',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: const Color.fromRGBO(90, 90, 90, 1),
                              fontFamily: 'Inter',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 30.w),
                        child: Text(
                          widget.venue,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: const Color.fromRGBO(90, 90, 90, 1),
                              fontFamily: 'Inter',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              sizedbox10,
              divider,
              sizedbox10,
              Row(
                // Time Row
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30.w),
                        child: Text(
                          'Time ',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: const Color.fromRGBO(90, 90, 90, 1),
                              fontFamily: 'Inter',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 30.w),
                        child: Text(
                          widget.time,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: const Color.fromRGBO(90, 90, 90, 1),
                              fontFamily: 'Inter',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              sizedbox10,
              divider,
              sizedbox10,
              Row(
                //Event Name row
                children: [
                  Leftspacer,
                  Text(
                    "Description",
                    style: TextStyle(
                        color: const Color.fromRGBO(58, 58, 58, 1),
                        fontFamily: 'Inter',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              sizedbox10,
              Row(
                //Event Name row
                children: [
                  Leftspacer,
                  SizedBox(
                    width: 450.w,
                    height: 100.h,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        widget.description,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            color: const Color.fromRGBO(58, 58, 58, 1),
                            fontFamily: 'Inter',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50.h,
              ),
              Row(
                // Time Row
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.only(left: 30.w),
                          child: ElevatedButton(
                            onPressed: widget.button
                                ? () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => Scanner(
                                          eventID: widget.id,
                                          isOpenForall: widget.isOpenForall),
                                    ));
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size(200.w, 50.h),
                                backgroundColor:
                                    const Color.fromRGBO(29, 78, 216, 1)),
                            child: Text(
                              'Open Scanner',
                              style: TextStyle(
                                  color: const Color.fromRGBO(255, 255, 255, 1),
                                  fontFamily: 'Inter',
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w400),
                            ),
                          )),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 30.w),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Participants(
                                  eventID: widget.id,
                                  isOpenForall: widget.isOpenForall),
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                              fixedSize: Size(200.w, 50.h),
                              backgroundColor:
                                  const Color.fromRGBO(29, 78, 216, 1)),
                          child: Text(
                            'View Participants',
                            style: TextStyle(
                                color: const Color.fromRGBO(255, 255, 255, 1),
                                fontFamily: 'Inter',
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
