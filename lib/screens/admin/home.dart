import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hestinn/screens/admin/appointments.dart';
import 'package:hestinn/screens/admin/doctors.dart';
import 'package:hestinn/screens/admin/patients.dart';
import 'package:hestinn/screens/patient/home.dart';
import 'package:hestinn/screens/admin/specialist.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  var sections = [
    {
      "id": 1,
      "name": "Manage Doctors",
      "icon": Icon(
        Icons.manage_accounts,
        size: 30,
        color: Colors.cyan,
      ),
      "screen": AdminDoctors(),
      "description": "manage doctors, activation and his/her profile ",
    },
    {
      "id": 2,
      "name": "Manage Patients",
      "icon": Icon(
        Icons.personal_injury,
        size: 30,
        color: Colors.cyan,
      ),
      "screen": AdminPatients(),
      "description": "",
    },
    {
      "id": 3,
      "name": "Manage Appointments",
      "icon": Icon(
        Icons.calendar_month_outlined,
        size: 30,
        color: Colors.cyan,
      ),
      "screen": AdminAppointments(),
      "description": "",
    },
    {
      "id": 4,
      "name": "Manage Specialists",
      "icon": Icon(
        Icons.create_new_folder_rounded,
        size: 30,
        color: Colors.cyan,
      ),
      "screen": AdminSpecialist(),
      "description":
          "Manage Sepcialists. Update,delete and adding new specialists",
    },
  ];

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
          iconTheme: IconThemeData(
            color: Colors.white,
            size: 30,
          ),
          title: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ),
                  );
                },
                child: Icon(
                  Icons.segment_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Admin Area".toUpperCase(),
                textScaleFactor: 1.3,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //sections
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: List.generate(sections.length, (index) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.cyan,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              //op tap navigate to screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        sections[index]['screen'] as Widget),
                              );
                            },
                            title: Text(
                              sections[index]['name'].toString(),
                              textScaleFactor: 1.4,
                            ),
                            subtitle: Text(
                              sections[index]['description'].toString(),
                              textScaleFactor: 1.4,
                            ),
                            leading: sections[index]['icon'] as Widget,
                          ),
                        );
                      }).toList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Doctors InActive",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textScaleFactor: 1.4,
                              ),
                              Icon(Icons.desktop_access_disabled_outlined)
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("users")
                                .where("isActive", isEqualTo: false)
                                .where("rule", isEqualTo: "doctor")
                                .snapshots(),
                            builder: (BuildContext context, snapshot) {
                              if (snapshot.hasData) {
                                var doctors = snapshot.data!.docs.length;
                                if (doctors <= 0) {
                                  return Center(
                                    child: Text(
                                      "No inactive doctors",
                                      textScaleFactor: 1.2,
                                    ),
                                  );
                                }
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                      snapshot.data!.docs.length, (index) {
                                    var doctor = snapshot.data!.docs[index];
                                    return ListTile(
                                      trailing: InkWell(
                                        onTap: () {
                                          //active doctor
                                          doctor.reference
                                              .update({"isActive": true});
                                        },
                                        child: Icon(
                                          Icons.check_box_outlined,
                                          size: 30,
                                          color: Colors.cyan,
                                        ),
                                      ),
                                      title: Text(doctor['name']),
                                      leading: doctor['picture']
                                              .toString()
                                              .isEmpty
                                          ? Icon(
                                              Icons.markunread_mailbox_outlined,
                                              size: 50,
                                            )
                                          : Image.network(
                                              doctor['picture'],
                                              width: 50,
                                              height: 50,
                                            ),
                                    );
                                  }).toList(),
                                );
                              }
                              return LinearProgressIndicator();
                            },
                          )
                        ],
                      ),
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
