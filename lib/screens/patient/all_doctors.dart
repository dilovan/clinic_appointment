import 'package:flutter/material.dart';
import 'package:hestinn/helpers/constants.dart';
import 'package:hestinn/screens/patient/doctor_detail.dart';
import 'package:hestinn/screens/patient/home.dart';

class allDoctors extends StatefulWidget {
  const allDoctors({super.key});

  @override
  State<allDoctors> createState() => _allDoctorsState();
}

class _allDoctorsState extends State<allDoctors> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: Column(
          children: [
            //page back
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 40,
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        //fliter
                      },
                      child: Icon(
                        Icons.filter_list_rounded,
                        size: 40,
                      )),
                ],
              ),
            ),
            Divider(height: 3),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                //all doctors
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: const [
                //     Text(
                //       'Doctors',
                //       textScaleFactor: 1.4,
                //       style:
                //           TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                //     ),

                //   ],
                // ),
                //spacer
                SizedBox(
                  height: 20,
                ),
                //doctor card list
                for (var doctor in Doctors)
                  Card(
                    margin: EdgeInsets.all(5),
                    child: InkWell(
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => DoctorDetail(
                        //               doctor: doctor,
                        //             )));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: "doc_${doctor['id']}",
                              child: Image(
                                width: 100,
                                image: AssetImage(doctor['img']),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //name
                                Text(
                                  doctor['doctorName'].toString().toUpperCase(),
                                  textScaleFactor: 1.4,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                //spacer
                                SizedBox(
                                  height: 5,
                                ),
                                //specialist and icon
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                      categories[doctor['category'] - 1]['icon']
                                          .toString(),
                                      width: 32,
                                      height: 32,
                                    ),
                                    Text(
                                      doctor['doctorTitle']
                                          .toString()
                                          .toUpperCase(),
                                      textScaleFactor: 1.4,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                //spacer
                                SizedBox(
                                  height: 5,
                                ),
                                //reviews
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    //review
                                    Text(
                                      "${doctor['reviews']!.toString()} Reviews  ",
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
                                        Text(
                                          doctor['rate'].toString(),
                                          textScaleFactor: 1.2,
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ],
        ),
      )),
    );
  }
}
