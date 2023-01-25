import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hestinn/welcome.dart';
import 'helpers/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

var direction = "rtl";

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
      color: Colors.cyan,
    );
  }
}
