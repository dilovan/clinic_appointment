import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hestinn/screens/admin/home.dart';
import 'package:hestinn/screens/doctor/main.dart';
import 'package:hestinn/screens/patient/home.dart';
import 'package:hestinn/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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
        print(error);
      });
    });
  }

  @override
  void initState() {
    getuserInfo().then((u) async {
      Future.delayed(Duration(seconds: 3), () async {
        await SharedPreferences.getInstance().then((auth) {
          if (auth.getBool('auth') == true) {
            if (rule == "admin") {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => AdminHome()));
            } else if (rule == "doctor") {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => DoctorHome()));
            } else if (rule == "patient") {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Home()));
            }
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => LoginScreen()));
          }
        });
      });
    });
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
    const String logo = 'assets/logo.png';
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 280,
                height: 280,
                child: Image.asset(
                  logo,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height: 1,
              ),
              Text(
                "HESTIN",
                textScaleFactor: 1.4,
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "Welcome To".toUpperCase(),
                textScaleFactor: 1.4,
                style: TextStyle(fontSize: 6),
              ),
              Text(
                "Online Clinic Appointment".toUpperCase(),
                textScaleFactor: 1.4,
                style: TextStyle(fontSize: 6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
