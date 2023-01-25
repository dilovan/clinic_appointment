import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hestinn/screens/patient/home.dart';
import 'package:intl/intl.dart';

class DoctorDetail extends StatefulWidget {
  DoctorDetail({Key? key, required this.doctor}) : super(key: key);
  DocumentSnapshot doctor;

  @override
  State<DoctorDetail> createState() => _DoctorDetailState();
}

class _DoctorDetailState extends State<DoctorDetail> {
  //
  List certifications = [];
  String selectedDate = "";
  String selectedTime = "";
  bool isBooking = false;
  // Map<String, dynamic> information = {};
  @override
  void initState() {
    print(widget.doctor.id);
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    //get certification if exists make it list form array in firebase
    if (widget.doctor.data().toString().contains("certifications")) {
      certifications = widget.doctor['certifications'] as List;
    }
    //
    int r = 0;
    int l = 0;

    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              shadowColor: Colors.black12,
              pinned: true,
              expandedHeight: 300,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: "doc_${widget.doctor['uid']}",
                  child: widget.doctor['picture'].toString().isEmpty
                      ? Container(
                          child: Center(
                              child: Icon(
                            Icons.perm_media_sharp,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width / 2,
                          )),
                          color: Colors.cyan,
                          margin: const EdgeInsets.all(3),
                        )
                      : Image(
                          image:
                              NetworkImage(widget.doctor['picture'].toString()),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.only(bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      margin: EdgeInsets.all(2),
                      child: InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //doctor picture
                              widget.doctor['picture'].toString().isEmpty
                                  ? Container(
                                      width: 80,
                                      height: 80,
                                      child: Center(
                                          child: Icon(
                                        Icons.perm_media_sharp,
                                        color: Colors.grey,
                                      )),
                                      color: Colors.black12,
                                      margin: const EdgeInsets.all(3),
                                    )
                                  : Container(
                                      margin: const EdgeInsets.all(3),
                                      child: Image.network(
                                        widget.doctor['picture'],
                                        width: 80,
                                      ),
                                    ),

                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    //doctor info
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //name
                                        Text(
                                          widget.doctor['name']
                                              .toString()
                                              .toUpperCase(),
                                          softWrap: true,
                                          textScaleFactor: 1.4,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        //spacer
                                        SizedBox(
                                          height: 5,
                                        ),
                                        //specialisr
                                        widget.doctor
                                                .data()
                                                .toString()
                                                .contains("specialist")
                                            //check if specialist exist
                                            ? Text(
                                                widget.doctor['specialist']
                                                        ['name']
                                                    .toString()
                                                    .toUpperCase(),
                                                textScaleFactor: 1.4,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            : Container(
                                                color: Colors.black12,
                                                width: 120,
                                                height: 26,
                                              ),
                                        //spacer
                                        SizedBox(
                                          height: 5,
                                        ),
                                        //reviews
                                        StreamBuilder(
                                          stream: widget.doctor.reference
                                              .collection("reviews")
                                              .snapshots(),
                                          builder:
                                              (BuildContext context, review) {
                                            if (review.hasData) {
                                              //calculate rating from five stars
                                              int sum = 0;
                                              double avg = 0.0;
                                              //get sum of rates to calculate avg
                                              if (review
                                                  .data!.docs.isNotEmpty) {
                                                review.data!.docs.forEach(
                                                  (rate) {
                                                    sum += rate['rate'] as int;
                                                  },
                                                );
                                              }
                                              avg = sum /
                                                  review.data!.docs.length;
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  //review
                                                  Text(
                                                    "${review.data!.docs.length.toString()} Reviews  ",
                                                    textScaleFactor: 1.2,
                                                  ),
                                                  //rate
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        size: 18,
                                                        color: Colors.orange,
                                                      ),
                                                      avg.isNaN
                                                          ? Text("0")
                                                          : Text(
                                                              (avg.toString()),
                                                              textScaleFactor:
                                                                  1.2,
                                                            ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            }
                                            return Text("");
                                          },
                                        ),
                                      ],
                                    ),
                                    //doctor specialist icon
                                    widget.doctor
                                            .data()
                                            .toString()
                                            .contains("specialist")
                                        ? Image.network(
                                            widget.doctor['specialist']['icon'],
                                            width: 32,
                                            height: 32,
                                          )
                                        : Container(
                                            color: Colors.black12,
                                            width: 32,
                                            height: 32,
                                          ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    //doctor info

                    Row(
                      children: [
                        widget.doctor.data().toString().contains("patients")
                            ? NumberCard(
                                label: 'Patients',
                                value: widget.doctor['patients'].toString(),
                              )
                            : Container(),
                        SizedBox(width: 8),
                        widget.doctor.data().toString().contains("experience")
                            ? NumberCard(
                                label: 'Experiences',
                                value:
                                    '${(DateTime.now().difference((widget.doctor['experience'] as Timestamp).toDate()).inDays / 365).floor()} Years',
                              )
                            : Container(),
                        SizedBox(width: 8),
                        widget.doctor.data().toString().contains("fees")
                            ? NumberCard(
                                label: 'Fees',
                                value:
                                    "${NumberFormat('#,###', "en_US").format(int.parse(widget.doctor['fees']))} IQD",
                              )
                            : Container(),
                        SizedBox(width: 8),
                        StreamBuilder(
                          stream: widget.doctor.reference
                              .collection("reviews")
                              .snapshots()
                              .map((event) {
                            l = event.size;
                            for (var element in event.docs) {
                              r += element.data()['rate'] as int;
                            }
                          }),
                          builder: (BuildContext context, snapshot) {
                            return r <= 0
                                ? Container()
                                : NumberCard(
                                    label: 'Rating',
                                    value: (r / l).toString(),
                                  );
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    //about doctor
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //about
                        Text(
                          'About Doctor',
                          textScaleFactor: 1.4,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decorationStyle: TextDecorationStyle.dashed),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        //description
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: widget.doctor
                                  .data()
                                  .toString()
                                  .contains("about")
                              ? Text(
                                  widget.doctor['about'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 10,
                                      color: Colors.black12,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.52,
                                      height: 10,
                                      color: Colors.black12,
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        //certifications
                        Text(
                          'Certifications',
                          textScaleFactor: 1.4,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decorationStyle: TextDecorationStyle.dashed),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        //list of certifications
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 35,
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: certifications.isNotEmpty
                              ? ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: certifications.map((e) {
                                    return Container(
                                      margin: const EdgeInsets.all(4),
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          color: Colors.cyan,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5),
                                          )),
                                      child: Text(
                                        e.toString().toUpperCase(),
                                        style: TextStyle(color: Colors.white),
                                        textScaleFactor: 1.3,
                                      ),
                                    );
                                  }).toList(),
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 45,
                                      height: 30,
                                      color: Colors.black12,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      width: 45,
                                      height: 30,
                                      color: Colors.black12,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      width: 45,
                                      height: 30,
                                      color: Colors.black12,
                                    ),
                                  ],
                                ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    //book appointment
                    ElevatedButton(
                      style: ButtonStyle(
                          padding:
                              MaterialStatePropertyAll(EdgeInsets.all(20))),
                      child: Text(
                        'Book Appointment',
                        style: TextStyle(color: Colors.white),
                        textScaleFactor: 1.5,
                      ),
                      onPressed: () async {
                        //show Date dialoge
                        await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          cancelText: 'Not now',
                          confirmText: 'Select',
                          errorFormatText: 'Enter valid date',
                          errorInvalidText: 'Enter date in valid range',
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 7)),
                          initialDatePickerMode: DatePickerMode.day,
                          // selectableDayPredicate: (DateTime val) {
                          //   return [
                          //     "2023, 01, 14",
                          //     "2023, 01, 15",
                          //     DateTime(2023, 01, 16),
                          //   ].contains((val) =>
                          //       // ? true
                          //       // : false;
                          //       val.weekday == 5 || val.weekday == 6
                          //           ? false
                          //           : true);
                          // },
                          // selectableDayPredicate: (DateTime val) =>
                          //     val.weekday == 5 || val.weekday == 6 ? false : true,
                        ).then((selectDate) async {
                          if (selectDate != null) {
                            //show time dialoge
                            await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            ).then((time) {
                              if (time != null) {
                                setState(() {
                                  String formatDate =
                                      selectDate.toString().split(" ")[0];
                                  selectedDate = formatDate;
                                  selectedTime = time.format(context);
                                  //show date and time results
                                  showDialog(
                                    useSafeArea: false,
                                    useRootNavigator: false,
                                    context: context,
                                    builder: (context) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        return SafeArea(
                                          child: Scaffold(
                                            restorationId: "sdsd",
                                            appBar: AppBar(
                                              automaticallyImplyLeading: false,
                                              title: Text(
                                                "Appointment confirmation",
                                                textScaleFactor: 1.2,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              centerTitle: true,
                                            ),
                                            body: SingleChildScrollView(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "Appointment well booking at",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w200),
                                                      textScaleFactor: 1.7,
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    //date
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      color: Colors.cyan,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .calendar_month_outlined,
                                                            color: Colors.white,
                                                          ),
                                                          Text(
                                                            selectedDate
                                                                .toString()
                                                                .padLeft(
                                                                    2, '0'),
                                                            textScaleFactor:
                                                                1.4,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    //time
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                      margin:
                                                          const EdgeInsets.all(
                                                              5),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      color: Colors.cyan,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.timer,
                                                            color: Colors.white,
                                                          ),
                                                          Text(
                                                            selectedTime
                                                                .toString()
                                                                .padLeft(
                                                                    2, '0'),
                                                            textScaleFactor:
                                                                1.4,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    //success icon
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Icon(
                                                        Icons.stream_sharp,
                                                        shadows: const [
                                                          Shadow(
                                                            color: Colors.cyan,
                                                            blurRadius: 8,
                                                            offset:
                                                                Offset(0, 1),
                                                          )
                                                        ],
                                                        size: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2,
                                                        color: Colors.cyan,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 20,
                                                    ),
                                                    //su
                                                    Text(
                                                      widget.doctor['name']
                                                          .toString()
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                          color: Colors.cyan,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                      textAlign:
                                                          TextAlign.center,
                                                      textScaleFactor: 1.8,
                                                    ),
                                                    Text(
                                                      "Well be wating for you to cancel or accept your appointment.",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w300),
                                                      textAlign:
                                                          TextAlign.center,
                                                      textScaleFactor: 1.6,
                                                    ),

                                                    //button actions
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          //accept button
                                                          isBooking
                                                              ? CircularProgressIndicator()
                                                              : ElevatedButton.icon(
                                                                  onPressed: isBooking
                                                                      ? () {}
                                                                      : () async {
                                                                          setState(
                                                                              () {
                                                                            isBooking =
                                                                                true;
                                                                          });
                                                                          await Future.delayed(
                                                                              Duration(seconds: 3),
                                                                              () {
                                                                            setState(() {
                                                                              isBooking = false;
                                                                            });
                                                                          }).then(
                                                                              (value) {
                                                                            //Todo
                                                                            //save to firebase
                                                                            Navigator.pushReplacement(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                builder: (context) => Home(),
                                                                              ),
                                                                            );
                                                                          });
                                                                        },
                                                                  icon: Icon(
                                                                    Icons
                                                                        .check_box,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  label: Text(
                                                                    "CONFIRM",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  )),
                                                          //cancell button
                                                          OutlinedButton.icon(
                                                            onPressed: isBooking
                                                                ? () {}
                                                                : () {
                                                                    //save to firebase
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                            icon: Icon(
                                                              Icons
                                                                  .cancel_presentation,
                                                              color:
                                                                  Colors.cyan,
                                                            ),
                                                            label: Text(
                                                              "CANCEL",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .cyan),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                  );
                                });
                              }
                            });
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NumberCard extends StatelessWidget {
  final String label;
  final String value;

  const NumberCard({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              label,
              textScaleFactor: 1.4,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
