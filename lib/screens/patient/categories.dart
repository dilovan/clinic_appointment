import 'package:flutter/material.dart';
import 'package:hestinn/helpers/constants.dart';
import 'package:hestinn/screens/patient/doctor_detail.dart';
import 'package:hestinn/screens/patient/home.dart';

class CategoriesScreen extends StatefulWidget {
  CategoriesScreen({super.key, required this.categoryID});

  String categoryID;
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white, size: 30),
          title: Text(
            "Doctors",
            textScaleFactor: 1.4,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0, left: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "List of Doctors",
                          textScaleFactor: 1.4,
                        ),
                        Icon(Icons.list_alt)
                      ],
                    ),
                    Divider(
                      height: 20,
                    ),
                    Text(
                      "Dentist Specialist",
                      textScaleFactor: 1.4,
                      softWrap: true,
                    ),
                    //spacer
                    SizedBox(
                      height: 20,
                    ),
                    //doctor card list
                    Column(
                      children: Doctors.where(
                          (cat) => cat['category'] == widget.categoryID).map(
                        (doctor) {
                          return Card(
                            margin: EdgeInsets.only(
                                bottom: 10, right: 10, left: 10),
                            child: InkWell(
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => DoctorDetail(
                                //               doctor: doctor,
                                //             )));
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  //doctor image
                                  Image(
                                    width: 80,
                                    image: AssetImage(doctor['img']),
                                  ),
                                  //doctor info
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //doctor name
                                        Text(
                                          doctor['doctorName']
                                              .toString()
                                              .toUpperCase(),
                                          softWrap: false,
                                          overflow: TextOverflow.fade,
                                          textScaleFactor: 1.4,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        //doctor specialist
                                        Text(
                                          doctor['doctorTitle'],
                                          textScaleFactor: 1.4,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        //reviews
                                        Row(
                                          children: [
                                            //review
                                            Text(
                                              "${doctor['reviews']!.toString()} Reviews  ",
                                              textScaleFactor: 1,
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
                                                  textScaleFactor: 1,
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
