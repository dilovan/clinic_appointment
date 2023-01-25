import 'package:flutter/material.dart';

class AdminPatients extends StatefulWidget {
  const AdminPatients({super.key});

  @override
  State<AdminPatients> createState() => _AdminPatientsState();
}

class _AdminPatientsState extends State<AdminPatients> {
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
        appBar: AppBar(),
        body: Center(
          child: Text(
            "Patients",
            textScaleFactor: 1.4,
          ),
        ),
      ),
    );
  }
}
