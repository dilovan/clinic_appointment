import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminNotifications extends StatefulWidget {
  const AdminNotifications({Key? key}) : super(key: key);

  @override
  State<AdminNotifications> createState() => _AdminNotificationsState();
}

class _AdminNotificationsState extends State<AdminNotifications> {
  //user info
  String? name, phone, rule, uid, email, address;
  bool? isActive;
  bool isInfoLoaded = false;
  Future<void> getUserInfo() async {
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
          nameController.text = name!;
          addressController.text = address!;
          phoneController.text = phone!;
        });
      });
    });
  }

  //controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
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
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 30),
        centerTitle: true,
        title: Text(
          "Notofocations",
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Icon(
            Icons.notification_important_outlined,
            color: Colors.white,
          ),
        ],
      ),
      body:
          //====
          !isInfoLoaded
              ? Center(
                  child: CircularProgressIndicator(),
                )
              :
              //====
              SingleChildScrollView(
                  child: Column(
                    children: [
                      Divider(
                        height: 3,
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              // height: 400,
                              child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("notifications")
                                    .where("to", isEqualTo: uid)
                                    // .orderBy("date")
                                    .snapshots(),
                                builder: (BuildContext context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data!.docs.isNotEmpty) {
                                      return ListView.separated(
                                        scrollDirection: Axis.vertical,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          var note = snapshot.data!.docs[index];
                                          StatelessWidget action;
                                          //Check Actions of Notifications
                                          if (note['action'] == "activation") {
                                            action = InkWell(
                                              onTap: note['seen']
                                                  ? null
                                                  : () {
                                                      //activate user
                                                      FirebaseFirestore.instance
                                                          .collection("users")
                                                          .where("uid",
                                                              isEqualTo:
                                                                  note['from'])
                                                          .limit(1)
                                                          .get()
                                                          .then((QuerySnapshot
                                                              snapshot) {
                                                        //Here we get the document reference and return to the this instance.to update field
                                                        //get users collection
                                                        return snapshot
                                                            .docs[0].reference
                                                            .update({
                                                          "isActive": true,
                                                        });
                                                      }).then((value) {
                                                        note.reference.update(
                                                            {"seen": true});
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                              "User ${note['sender']} has been activated"),
                                                        ));
                                                      });
                                                    },
                                              child: Icon(
                                                Icons.privacy_tip_rounded,
                                                color: note['seen']
                                                    ? Colors.grey
                                                    : Colors.cyan,
                                                size: 30,
                                              ),
                                            );
                                          } else {
                                            action =
                                                Icon(Icons.no_cell_outlined);
                                          }
                                          DateTime dt =
                                              (note['date'] as Timestamp)
                                                  .toDate();
                                          return ListTile(
                                            //seen or not
                                            leading: Icon(
                                              note['seen'] == true
                                                  ? Icons.notifications
                                                  : Icons.notifications_active,
                                              color: note['seen'] == true
                                                  ? Colors.cyan
                                                  : Colors.grey,
                                            ),
                                            //sender
                                            title: Text(
                                              note['sender'],
                                              textScaleFactor: 1.4,
                                            ),
                                            //message
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  note['message'],
                                                  textScaleFactor: 1.1,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      dt
                                                          .toString()
                                                          .split(" ")[0]
                                                          .toString(),
                                                      textScaleFactor: 1,
                                                    ),
                                                    Text(
                                                      dt
                                                          .toString()
                                                          .split(" ")[1]
                                                          .toString()
                                                          .split(".")[0],
                                                      textScaleFactor: 1,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            //action if required
                                            trailing: action,
                                          );
                                          //
                                        },
                                        itemCount: snapshot.data!.docs.length,
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return Divider(
                                            color: Colors.cyan,
                                          );
                                        },
                                      );
                                    } else {
                                      return Center(
                                        child: Text(
                                          "No Notifications",
                                          textScaleFactor: 1.4,
                                        ),
                                        // LinearProgressIndicator(),
                                      );
                                    }
                                  }
                                  return Center(
                                    child: LinearProgressIndicator(),
                                    // LinearProgressIndicator(),
                                  );
                                },
                              ),
                            ),
                            // Divider(
                            //   height: 20,
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
