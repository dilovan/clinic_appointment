import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminDoctors extends StatefulWidget {
  const AdminDoctors({super.key});

  @override
  State<AdminDoctors> createState() => _AdminDoctorsState();
}

class _AdminDoctorsState extends State<AdminDoctors> {
  TextEditingController searchText = TextEditingController();
  //
  Stream<QuerySnapshot<Map<String, dynamic>>>? doctors;

  @override
  void initState() {
    doctors = FirebaseFirestore.instance
        .collection("users")
        .where("rule", isEqualTo: "doctor")
        .snapshots();
    super.initState();
  }

  @override
  void dispose() {
    searchText.dispose();
    super.dispose();
  }

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
            iconTheme: IconThemeData(color: Colors.white, size: 30),
            centerTitle: true,
            title: Text(
              "Manage Doctors",
              textScaleFactor: 1.4,
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  //search area
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
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
                                  doctors = FirebaseFirestore.instance
                                      .collection("users")
                                      .where("search",
                                          arrayContains: searchText.text)
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
                              hintStyle: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            onChanged: (value) {
                              //search by input change
                              doctors = FirebaseFirestore.instance
                                  .collection("users")
                                  .where("search", arrayContains: value)
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
                  //list of doctors
                  StreamBuilder(
                    stream: doctors,
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
                          children: List.generate(snapshot.data!.docs.length,
                              (index) {
                            var doctor = snapshot.data!.docs[index];
                            return Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.cyan, width: 0.5))),
                              child: ListTile(
                                trailing: InkWell(
                                  onTap: () {
                                    //active button
                                    bool isActive = !(doctor['isActive']);
                                    doctor.reference
                                        .update({"isActive": isActive});
                                  },
                                  child: Icon(
                                    doctor['isActive'] == true
                                        ? Icons.check_box_outlined
                                        : Icons.check_box_outline_blank,
                                    size: 35,
                                    color: Colors.cyan,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor['email'],
                                      textScaleFactor: 1.4,
                                    ),
                                    Text(
                                      doctor['phone'],
                                      textScaleFactor: 1.4,
                                    ),
                                  ],
                                ),
                                title: Text(
                                  doctor['name'],
                                  textScaleFactor: 1.4,
                                ),
                                leading: doctor['picture'].toString().isEmpty
                                    ? Icon(
                                        Icons.markunread_mailbox_outlined,
                                        size: 50,
                                      )
                                    : Image.network(
                                        doctor['picture'],
                                        width: 50,
                                        height: 50,
                                      ),
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
          )),
    );
  }
}
