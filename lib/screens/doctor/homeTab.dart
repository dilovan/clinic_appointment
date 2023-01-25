import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hestinn/screens/admin/home.dart';
import 'package:hestinn/screens/patient/categories.dart';
import 'package:hestinn/screens/patient/all_doctors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hestinn/screens/patient/doctor_detail.dart';

class DoctorHomeTab extends StatefulWidget {
  const DoctorHomeTab({
    Key? key,
  }) : super(key: key);

  @override
  State<DoctorHomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<DoctorHomeTab>
    with SingleTickerProviderStateMixin {
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

                    //spacer
                    SizedBox(
                      height: 20,
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
