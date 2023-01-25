import 'package:flutter/material.dart';

class AdminAppointments extends StatefulWidget {
  const AdminAppointments({super.key});

  @override
  State<AdminAppointments> createState() => _AdminAppointmentsState();
}

class _AdminAppointmentsState extends State<AdminAppointments> {
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
          "Appointments",
          textScaleFactor: 1.4,
        )),
      ),
    );
  }
}
