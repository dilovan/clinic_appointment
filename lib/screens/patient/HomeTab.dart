import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hestinn/screens/admin/home.dart';
import 'package:hestinn/screens/patient/categories.dart';
import 'package:hestinn/screens/patient/all_doctors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hestinn/screens/patient/doctor_detail.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  String? name, phone, rule, uid, email, address;
  bool? isActive;
  bool isInfoLoaded = false;
  Future<void> getuserInfo() async {
    await SharedPreferences.getInstance().then((pref) {
      FirebaseFirestore.instance
          .collection("users")
          .where("uid", isEqualTo: pref.getString('uid'))
          .get()
          .then((u) {
        name = u.docs.first.data()['name'];
        phone = u.docs.first.data()['phone'];
        rule = u.docs.first.data()['rule'];
        email = u.docs.first.data()['email'];
        isActive = u.docs.first.data()['isActive'];
        uid = u.docs.first.data()['uid'];
        address = u.docs.first.data()['address'];
        setState(() {
          isInfoLoaded = true;
        });
      }).onError((error, stackTrace) {
        print(error.toString());
      });
    });
  }

  late Stream<QuerySnapshot<Map<String, dynamic>>> doctorStreen;
  @override
  void initState() {
    getuserInfo();
    //get doctors

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )
      ..forward()
      ..repeat(reverse: true);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  TextEditingController searchText = TextEditingController();
  @override
  Widget build(BuildContext context) {
    doctorStreen = FirebaseFirestore.instance
        .collection("users")
        .where("rule", isEqualTo: "doctor")
        .where("isActive", isEqualTo: true)
        .snapshots();
    return
        //if data is not loaded
        //====
        !isInfoLoaded
            ? Center(
                child: CircularProgressIndicator(),
              )
            :
            //====
            Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.03),
                child: ListView(
                  children: [
                    //spacer
                    SizedBox(
                      height: 20,
                    ),
                    // user info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //welcome text and name
                              Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name!.toString().toUpperCase(),
                                        textScaleFactor: 1.4,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      Text(
                                        'YOU WELCOME TO HESTIN!',
                                        textScaleFactor: 1.4,
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              //
                            ],
                          ),
                        ),
                        //logo
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerRight,
                            children: [
                              Positioned(
                                child: InkWell(
                                  onTap: rule == "admin"
                                      ? () {
                                          //if admin
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AdminHome(),
                                            ),
                                          );
                                        }
                                      : () {},
                                  child: Image.asset(
                                    "assets/logo.png",
                                    height: 50,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    //search area
                    Padding(
                      padding: const EdgeInsets.only(left: 1.0, right: 1.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchText,
                              decoration: InputDecoration(
                                suffixIcon: InkWell(
                                  onTap: () {
                                    //search by clicking search icon
                                    doctorStreen = FirebaseFirestore.instance
                                        .collection("users")
                                        .where("search",
                                            arrayContains: searchText.text)
                                        .where("specialist", isNotEqualTo: null)
                                        .snapshots();
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.cyan,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                hintText: 'Search a doctor',
                                hintStyle:
                                    TextStyle(fontWeight: FontWeight.w700),
                              ),
                              onChanged: (value) {
                                //search by input change
                                doctorStreen = FirebaseFirestore.instance
                                    .collection("users")
                                    .where("search", arrayContains: value)
                                    .where("specialist", isNotEqualTo: null)
                                    .snapshots();
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        'Specialists'.toUpperCase(),
                        textScaleFactor: 1.4,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    //category list
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("categories")
                          .snapshots(),
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.hasData) {
                          //specialist icon with name
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: 120,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List.generate(
                                  snapshot.data!.docs.length, (index) {
                                final DocumentSnapshot documentSnapshot =
                                    snapshot.data!.docs[index];
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CategoriesScreen(
                                            categoryID: documentSnapshot.id),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.black12, width: 1),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(5),
                                      ),
                                    ),
                                    width: 120.0,
                                    padding: EdgeInsets.all(3),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Hero(
                                          tag:
                                              "cat_${documentSnapshot['icon']}",
                                          child: Image.network(
                                            documentSnapshot['icon'],
                                            width: 32,
                                            height: 32,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(documentSnapshot['name']
                                            .toString()
                                            .toUpperCase()),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }
                        return Text("loading..");
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    //top doctors
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Top Doctor'.toUpperCase(),
                          textScaleFactor: 1.4,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => allDoctors(),
                              ),
                            );
                          },
                          child: Text(
                            'All Doctors',
                            textScaleFactor: 1.1,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.cyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                    //spacer
                    SizedBox(
                      height: 20,
                    ),
                    //doctor card list
                    StreamBuilder(
                      stream: doctorStreen,
                      builder: (BuildContext context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            children: List.generate(snapshot.data!.docs.length,
                                (index) {
                              final DocumentSnapshot doctors =
                                  snapshot.data!.docs[index];
                              return
                                  //
                                  Card(
                                margin: EdgeInsets.all(5),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DoctorDetail(
                                                  doctor: doctors,
                                                )));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //doctor picture
                                        doctors['picture'].toString().isEmpty
                                            ? Container(
                                                width: 80,
                                                height: 80,
                                                child: Center(
                                                    child: Icon(
                                                  Icons.perm_media_sharp,
                                                  color: Colors.black26,
                                                )),
                                                color: Colors.black12,
                                                margin: const EdgeInsets.all(3),
                                              )
                                            : Container(
                                                margin: const EdgeInsets.all(3),
                                                child: Image.network(
                                                  doctors['picture'],
                                                  width: 80,
                                                ),
                                              ),

                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              //doctor info
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  //name
                                                  Text(
                                                    doctors['name']
                                                        .toString()
                                                        .toUpperCase(),
                                                    softWrap: true,
                                                    textScaleFactor: 1.4,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  //spacer
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  //specialisr
                                                  snapshot.data!.docs[index]
                                                          .data()
                                                          .containsKey(
                                                              "specialist") //check if specialist exist
                                                      ? Text(
                                                          doctors['specialist']
                                                                  ['name']
                                                              .toString()
                                                              .toUpperCase(),
                                                          textScaleFactor: 1.4,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        )
                                                      : Container(
                                                          color: Colors.black12,
                                                          width: 120,
                                                          height: 24,
                                                        ),
                                                  //spacer
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  //reviews
                                                  StreamBuilder(
                                                    stream: doctors.reference
                                                        .collection("reviews")
                                                        .snapshots(),
                                                    builder:
                                                        (BuildContext context,
                                                            review) {
                                                      if (review.hasData) {
                                                        //calculate rating from five stars
                                                        int sum = 0;
                                                        var avg = 0.0;
                                                        //get sum of rates to calculate avg
                                                        if (review.data!.docs
                                                            .isNotEmpty) {
                                                          review.data!.docs
                                                              .forEach(
                                                            (element) {
                                                              sum += element[
                                                                      'rate']
                                                                  as int;
                                                            },
                                                          );
                                                          avg = sum /
                                                              review.data!.docs
                                                                  .length;
                                                        }
                                                        return Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            //review
                                                            Text(
                                                              "${review.data!.docs.length.toString()} Reviews  ",
                                                              textScaleFactor:
                                                                  1.2,
                                                              style: TextStyle(
                                                                  color: avg ==
                                                                          0
                                                                      ? Colors
                                                                          .black12
                                                                      : Colors
                                                                          .black),
                                                            ),
                                                            //rate
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.star,
                                                                  size: 18,
                                                                  color: avg ==
                                                                          0
                                                                      ? Colors
                                                                          .black12
                                                                      : Colors
                                                                          .orange,
                                                                ),
                                                                Text(
                                                                  avg.toString(),
                                                                  textScaleFactor:
                                                                      1.2,
                                                                  style: TextStyle(
                                                                      color: avg == 0
                                                                          ? Colors
                                                                              .black12
                                                                          : Colors
                                                                              .black),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                        // }
                                                      }
                                                      return Text("");
                                                    },
                                                  ),
                                                ],
                                              ),
                                              //doctor specialist icon
                                              snapshot.data!.docs[index]
                                                      .data()
                                                      .containsKey("specialist")
                                                  ? Image.network(
                                                      doctors['specialist']
                                                          ['icon'],
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
                              );
                            }),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: LinearProgressIndicator(),
                        );
                      },
                    ),
                    //app version
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Version"),
                          Text("1.0"),
                        ],
                      ),
                    )
                  ],
                ),
              );
  }
}
