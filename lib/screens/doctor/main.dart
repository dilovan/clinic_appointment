import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hestinn/screens/admin/notifications.dart';
import 'package:hestinn/screens/admin/profile.dart';
import 'package:hestinn/login.dart';
import 'package:hestinn/screens/doctor/appointments.dart';
import 'package:hestinn/screens/doctor/homeTab.dart';
import 'package:hestinn/screens/doctor/notifications.dart';
import 'package:hestinn/screens/doctor/profile.dart';
import 'package:hestinn/screens/patient/notifications.dart';
import 'package:hestinn/screens/patient/profile.dart';
import 'package:hestinn/screens/patient/HomeTab.dart';
import 'package:hestinn/screens/patient/ScheduleTab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorHome extends StatefulWidget {
  const DoctorHome({Key? key}) : super(key: key);

  @override
  _DoctorHomeState createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> {
  //navbar menu
  List<Map> navigationBarItems = [
    {'icon': Icons.home, 'index': 0, 'name': 'Home'},
    {'icon': Icons.calendar_today, 'index': 1, 'name': 'Appointments'},
    {'icon': Icons.location_history_rounded, 'index': 2, 'name': 'Profile'},
    {'icon': Icons.notifications_active, 'index': 3, 'name': 'Notifications'},
  ];

  String? name, phone, rule, uid, email, address;
  bool? isActive;
  bool disAbleVerify = false;
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

  int selectedIndex = 0;

  @override
  void initState() {
    getuserInfo();
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
    List<Widget> screens = [
      DoctorHomeTab(),
      DoctorAppointments(),
      rule == "admin" ? AdminProfile() : DoctorProfileScreen(),
      rule == "admin" ? AdminNotifications() : DoctorNotificationScreen(),
    ];
    //if user info not loaded
    return !isInfoLoaded
        ? SafeArea(
            child: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          )
        //if user is doctor and not active
        : rule == "doctor" && isActive == false
            ? SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.cyan,
                  body: SingleChildScrollView(
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //logo
                          SizedBox(
                            width: 280,
                            height: 280,
                            child: Image.asset(
                              "assets/logo.png",
                              width: 250,
                              height: 250,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          //alert text
                          Text(
                            "Your account has not been activated yet.Please, Visit us later!"
                                .toUpperCase(),
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            textScaleFactor: 1.5,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          //action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              //signout button
                              ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                ),
                                onPressed: () async {
                                  //signout
                                  await FirebaseAuth.instance
                                      .signOut()
                                      .then((value) {
                                    SharedPreferences.getInstance()
                                        .then((auth) {
                                      auth.setBool("auth", false);
                                      auth.remove("uid");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginScreen(),
                                        ),
                                      );
                                    });
                                  });
                                },
                                icon: Icon(
                                  Icons.lock_clock,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "Signout".toUpperCase(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              //notify button
                              ElevatedButton.icon(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.amber),
                                ),
                                onPressed: disAbleVerify
                                    ? null
                                    : () {
                                        //verify admins
                                        FirebaseFirestore.instance
                                            .collection("users")
                                            .where("rule", isEqualTo: "admin")
                                            .snapshots()
                                            .forEach((documents) {
                                          documents.docs.forEach((fields) {
                                            Map<String, dynamic> note = {
                                              "action": "activation",
                                              "date": DateTime.now(),
                                              "from": uid,
                                              "to": fields['uid'],
                                              "sender": name,
                                              "seen": false,
                                              "rule": rule,
                                              "message":
                                                  "Please,Activate my account!"
                                            };
                                            FirebaseFirestore.instance
                                                .collection("notifications")
                                                .add(note)
                                                .then((doc) {
                                              setState(() {
                                                disAbleVerify = true;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      "Notification has been sent to Admin.Please,Wait for response."),
                                                ),
                                              );
                                            });
                                          });
                                        });
                                      },
                                icon: Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "Verify Me".toUpperCase(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            //otherwise show
            : SafeArea(
                child: Scaffold(
                  body: screens[selectedIndex],
                  bottomNavigationBar: BottomNavigationBar(
                    showUnselectedLabels: true,
                    elevation: 3,
                    items: [
                      BottomNavigationBarItem(
                        backgroundColor: Colors.cyan,
                        icon: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            border: Border(
                              top: selectedIndex ==
                                      navigationBarItems[0]['index']
                                  ? BorderSide(color: Colors.white, width: 5)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Icon(
                            navigationBarItems[0]['icon'],
                          ),
                        ),
                        label: navigationBarItems[0]['name'],
                      ),
                      BottomNavigationBarItem(
                        backgroundColor: Colors.cyan,
                        icon: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            border: Border(
                              top: selectedIndex ==
                                      navigationBarItems[1]['index']
                                  ? BorderSide(color: Colors.white, width: 5)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Icon(
                            navigationBarItems[1]['icon'],
                          ),
                        ),
                        label: navigationBarItems[1]['name'],
                      ),
                      BottomNavigationBarItem(
                        backgroundColor: Colors.cyan,
                        icon: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            border: Border(
                              top: selectedIndex ==
                                      navigationBarItems[2]['index']
                                  ? BorderSide(color: Colors.white, width: 5)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Icon(
                            navigationBarItems[2]['icon'],
                          ),
                        ),
                        label: navigationBarItems[2]['name'],
                      ),
                      BottomNavigationBarItem(
                        backgroundColor: Colors.cyan,
                        icon: Stack(children: [
                          Container(
                            alignment: Alignment.center,
                            height: 55,
                            decoration: BoxDecoration(
                              border: Border(
                                top: selectedIndex ==
                                        navigationBarItems[3]['index']
                                    ? BorderSide(color: Colors.white, width: 5)
                                    : BorderSide.none,
                              ),
                            ),
                            child: Icon(
                              navigationBarItems[3]['icon'],
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 55,
                            child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("notifications")
                                  .where("to", isEqualTo: uid)
                                  .snapshots(),
                              builder: (BuildContext context, snapshot) {
                                if (snapshot.hasData) {
                                  var notes = snapshot.data!.docs.length;
                                  return Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    child: Text(
                                      notes.toString(),
                                      textScaleFactor: 1.4,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 8),
                                    ),
                                  );
                                }
                                return Container();
                              },
                            ),
                          )
                        ]),
                        label: navigationBarItems[3]['name'],
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) => setState(() {
                      selectedIndex = value;
                    }),
                  ),
                ),
              );
  }
}
