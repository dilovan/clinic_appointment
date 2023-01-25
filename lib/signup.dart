import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hestinn/screens/patient/home.dart';
import 'package:hestinn/login.dart';
import 'package:hestinn/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Rule { admin, doctor, patient }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  //is password visible
  bool passHidden = true;
  String message = "";
  bool isError = false;
  bool isSinging = false;
  Rule? rule = Rule.patient;
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
    const String logo = 'assets/logo.png';
    return Scaffold(
      backgroundColor: Colors.cyan,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: Image.asset(
                  logo,
                  width: 200,
                  height: 250,
                ),
              ),
              //spacer
              const SizedBox(
                height: 20,
              ),
              //name
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                decoration: const InputDecoration(
                    prefixIconColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.person,
                      size: 30,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    hintStyle: TextStyle(color: Colors.white),
                    hintText: "USER NAME",
                    labelStyle: TextStyle(fontSize: 50),
                    helperStyle: TextStyle(color: Colors.white),
                    contentPadding: EdgeInsets.all(20)),
              ),
              //spacer
              const SizedBox(
                height: 20,
              ),
              //phone
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                decoration: const InputDecoration(
                    prefixIconColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.phone,
                      size: 30,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    hintStyle: TextStyle(color: Colors.white),
                    hintText: "PHONE NUMBER",
                    labelStyle: TextStyle(fontSize: 50),
                    helperStyle: TextStyle(color: Colors.white),
                    contentPadding: EdgeInsets.all(20)),
              ),
              //spacer
              const SizedBox(
                height: 20,
              ),
              //email
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                decoration: const InputDecoration(
                    prefixIconColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.person,
                      size: 30,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    hintStyle: TextStyle(color: Colors.white),
                    hintText: "EMAIL",
                    labelStyle: TextStyle(fontSize: 50),
                    helperStyle: TextStyle(color: Colors.white),
                    contentPadding: EdgeInsets.all(20)),
              ),
              //spacer
              const SizedBox(
                height: 20,
              ),
              //password
              TextField(
                controller: passwordController,
                style: const TextStyle(color: Colors.white, fontSize: 25),
                keyboardType: TextInputType.visiblePassword,
                obscureText: passHidden,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                    suffixIconColor: Colors.white,
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          passHidden = !passHidden;
                        });
                      },
                      child: Icon(
                        passHidden ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                    prefixIconColor: Colors.white,
                    prefixIcon: const Icon(
                      Icons.lock,
                      size: 30,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    hintStyle: const TextStyle(color: Colors.white),
                    hintText: "PASSWORD",
                    labelStyle: const TextStyle(fontSize: 50),
                    helperStyle: const TextStyle(color: Colors.white),
                    contentPadding: const EdgeInsets.all(20)),
              ),
              //spacer
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Radio<Rule>(
                        activeColor: Colors.white,
                        value: Rule.doctor,
                        groupValue: rule,
                        onChanged: (value) {
                          setState(() {
                            rule = value;
                          });
                        },
                      ),
                      Text(
                        "Doctor",
                        textScaleFactor: 1.4,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  //spacer
                  SizedBox(
                    width: 10,
                  ),
                  Row(
                    children: [
                      Radio<Rule>(
                        activeColor: Colors.white,
                        value: Rule.patient,
                        groupValue: rule,
                        onChanged: (value) {
                          setState(() {
                            rule = value;
                          });
                        },
                      ),
                      Text(
                        "Patient",
                        textScaleFactor: 1.4,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
              //spacer
              const SizedBox(
                height: 20,
              ),

              isSinging
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        var search = [];
                        var str = nameController.text;
                        int j = 1;
                        for (int i = 0; i < str.length; i++) {
                          search.add(str.substring(0, j));
                          j++;
                        }
                        setState(() {
                          isSinging = true;
                        });
                        try {
                          //register with google email and password provider
                          await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          )
                              .then((user) {
                            var uid = user.user!.uid;
                            //create user object
                            String whichRule =
                                rule == Rule.doctor ? "doctor" : "patient";
                            var userInfo = {
                              "name": nameController.text.trim(),
                              "phone": phoneController.text.trim(),
                              "email": emailController.text.trim(),
                              "uid": uid,
                              "isActive": rule == Rule.doctor ? false : true,
                              "rule": whichRule,
                              "address": "",
                              "picture": "",
                              "search": search
                            };
                            //add to firebase database
                            FirebaseFirestore.instance
                                .collection("users")
                                .add(userInfo)
                                .then((value) async {
                              //user added
                              await SharedPreferences.getInstance()
                                  .then((auth) {
                                auth.setBool('auth', true);
                                auth.setString(
                                    'uid', user.user!.uid.toString());
                              }).then(
                                (value) => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WelcomeScreen()),
                                ),
                              );
                            });
                          });
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            setState(() {
                              message = 'The password provided is too weak.';
                            });
                          } else if (e.code == 'email-already-in-use') {
                            setState(() {
                              message =
                                  'The account already exists for that email.';
                            });
                          } else if (e.code == 'network-request-failed') {
                            setState(() {
                              message = 'Network request failed.';
                            });
                          } else if (e.code == 'No user found for that email') {
                            setState(() {
                              message = 'No user found for that email.';
                            });
                          }
                          setState(() {
                            isSinging = false;
                          });
                        } catch (e) {
                          setState(() {
                            message = "error $e";
                            isSinging = false;
                          });
                        }
                        //show message
                        if (message.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                            ),
                          );
                        }
                        //
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        child: const Center(
                          child: Text(
                            "SignUp",
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Need an account? ",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()));
                    },
                    child: const Text(
                      "Signin",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
