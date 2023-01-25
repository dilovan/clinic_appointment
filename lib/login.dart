import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hestinn/screens/patient/home.dart';
import 'package:hestinn/signup.dart';
import 'package:hestinn/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //is password visible
  bool passHidden = true;
  String message = "";
  bool isError = false;
  bool isSinging = false;
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
          padding: const EdgeInsets.all(30.0),
          child: Column(
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
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 20,
              ),
              isSinging
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isSinging = true;
                        });
                        try {
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          )
                              .then((user) async {
                            await SharedPreferences.getInstance().then((auth) {
                              auth.setBool('auth', true);
                              auth.setString('uid', user.user!.uid);
                              //navigate to home page
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WelcomeScreen(),
                                ),
                              );
                            });
                          });
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            setState(() {
                              message = 'No user found for that email.';
                            });
                          } else if (e.code == 'wrong-password') {
                            setState(() {
                              message = 'Wrong password provided.';
                            });
                          } else if (e.code == 'network-request-failed') {
                            message = "network request failed";
                          } else {
                            message = "Uknown Error";
                          }
                          setState(() {
                            isSinging = false;
                            isError = true;
                          });
                          if (message.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 60,
                        child: const Center(
                          child: Text(
                            "Sign",
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
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen()));
                    },
                    child: const Text(
                      "Signup",
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
