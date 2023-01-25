import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hestinn/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //user info
  String? name,
      phone,
      rule,
      uid,
      email,
      address,
      specialistName,
      specialistIcon,
      picture,
      userDocID;
  final _firebaseStorage = FirebaseStorage.instance;
  XFile? image;
  File? file;
  XFile? pickedImage;
  final picker = ImagePicker();
  browseImage() async {
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      pickedImage =
          await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920);
      //select image
      file = File(pickedImage!.path);

      if (pickedImage != null) {
        //upload picture to firebase storage and get download url
        await _firebaseStorage
            .ref()
            .child("doctors/$email")
            .putFile(
              file!,
              SettableMetadata(
                customMetadata: {'name': email!},
              ),
            )
            .then((imageUploaded) {
          //get download image url = img
          imageUploaded.ref.getDownloadURL().then((img) {
            var map = {
              "picture": img,
            };
            //add user picture to firebase database
            FirebaseFirestore.instance
                .collection("users")
                .doc(userDocID)
                .update(map)
                .then((done) {
              //show snake bar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("User Picture  has been uploaded"),
                ),
              );
              setState(() {});
            });
          });
        });
      } else {
        print("select image");
      }
    } else {
      print("no image permisssion");
    }
  }

  var certifications = [];
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
        specialistName = u.docs.first.data()['rule'] == "doctor"
            ? u.docs.first.data()['specialist']['name']
            : " ";
        specialistIcon = u.docs.first.data()['rule'] == "doctor"
            ? u.docs.first.data()['specialist']['icon']
            : " ";
        certifications = u.docs.first.data()['rule'] == "doctor"
            ? u.docs.first.data()['certifications']
            : [];
        picture = u.docs.first.data()['picture'] ?? " ";
        userDocID = u.docs.first.id;
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white, size: 30),
          title: Text(
            "Profile",
            textScaleFactor: 1.4,
            style: TextStyle(color: Colors.white),
          ),
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
                        //image update
                        Stack(children: [
                          //if  has been browsed for upload show it here
                          file != null
                              ? Image.file(
                                  file!,
                                )
                              // if image  exists upload it
                              : picture!.isEmpty
                                  ? Container(
                                      color: Colors.cyan,
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.30,
                                      child: Center(
                                          child: Text(
                                        "No Image",
                                        textScaleFactor: 1.4,
                                        style: TextStyle(color: Colors.white),
                                      )),
                                    )
                                  //if picture exists in firebase database show it
                                  : Container(
                                      color: Colors.cyan,
                                      child: Image.network(picture.toString()),
                                    ),
                          Container(
                            margin: const EdgeInsets.all(50.0),
                            child: InkWell(
                              onTap: () {
                                //update picture
                                browseImage();
                              },
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Colors.white,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                                size: 40,
                              ),
                            ),
                          )
                        ]),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Edite profile
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "User Profile",
                                    textScaleFactor: 2,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        isDismissible: false,
                                        isScrollControlled: true,
                                        enableDrag: false,
                                        context: context,
                                        builder: (context) {
                                          return SingleChildScrollView(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Column(
                                                children: [
                                                  //close button sheet
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 30),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        IconButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                          icon: const Icon(
                                                              Icons.close),
                                                        ),
                                                        Text(
                                                          "Update your information",
                                                          textScaleFactor: 1.4,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        color: Colors.white),
                                                    child: Column(
                                                      children: [
                                                        //name
                                                        TextField(
                                                          controller:
                                                              nameController,
                                                          decoration: InputDecoration(
                                                              hintText:
                                                                  'Enter Full Name',
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          15.0,
                                                                      top:
                                                                          15.0),
                                                              prefixIcon:
                                                                  const Icon(Icons
                                                                      .location_history_rounded)),
                                                        ),
                                                        Divider(
                                                          height: 10,
                                                        ),
                                                        //address
                                                        TextField(
                                                            controller:
                                                                addressController,
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  'Enter Address',
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          15.0,
                                                                      top:
                                                                          15.0),
                                                              prefixIcon: Icon(Icons
                                                                  .edit_location_alt_rounded),
                                                            )),
                                                        Divider(
                                                          height: 10,
                                                        ),
                                                        //phone
                                                        TextField(
                                                          controller:
                                                              phoneController,
                                                          keyboardType:
                                                              TextInputType
                                                                  .phone,
                                                          decoration: InputDecoration(
                                                              hintText:
                                                                  'Enter Phone Number',
                                                              border:
                                                                  InputBorder
                                                                      .none,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          15.0,
                                                                      top:
                                                                          15.0),
                                                              prefixIcon:
                                                                  const Icon(Icons
                                                                      .phone_android)),
                                                        ),
                                                        Divider(
                                                          height: 30,
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            30.0),
                                                    child: FilledButton.icon(
                                                      onPressed: () async {
                                                        //try update user information
                                                        try {
                                                          final account =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .where('uid',
                                                                      isEqualTo:
                                                                          uid)
                                                                  .limit(1)
                                                                  .get()
                                                                  .then((QuerySnapshot
                                                                      snapshot) {
                                                            //Here we get the document reference and return to the account variable.
                                                            return snapshot
                                                                .docs[0]
                                                                .reference;
                                                          });
                                                          var batch =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .batch();
                                                          //Updates the field value, using account as document reference
                                                          batch
                                                              .update(account, {
                                                            'name':
                                                                nameController
                                                                    .text,
                                                            'address':
                                                                addressController
                                                                    .text,
                                                            'phone':
                                                                phoneController
                                                                    .text,
                                                          });
                                                          batch
                                                              .commit()
                                                              .whenComplete(() =>
                                                                  Navigator.pop(
                                                                      context));
                                                          setState(() {
                                                            getUserInfo();
                                                          });
                                                        } catch (e) {
                                                          print(e);
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons.save,
                                                        color: Colors.white,
                                                      ),
                                                      label: Text(
                                                        "Update",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: Colors.cyan,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(50),
                                          )),
                                      child: Icon(
                                        Icons.history_edu_outlined,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                height: 20,
                              ),
                              //email
                              ListTile(
                                leading: Icon(
                                  Icons.email,
                                  size: 20,
                                ),
                                subtitle: Text("Email"),
                                title: Text(
                                  email!,
                                  textScaleFactor: 1.4,
                                ),
                              ),
                              Divider(
                                height: 20,
                              ),
                              //user name
                              ListTile(
                                leading: Icon(
                                  Icons.history_edu_outlined,
                                  size: 20,
                                ),
                                subtitle: Text("Full Name"),
                                title: Text(
                                  name!,
                                  textScaleFactor: 1.4,
                                ),
                              ),
                              Divider(
                                height: 20,
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.phone_android,
                                  size: 20,
                                ),
                                subtitle: Text("Phone Number"),
                                title: Text(
                                  phone!,
                                  textScaleFactor: 1.4,
                                ),
                              ),
                              Divider(
                                height: 20,
                              ),
                              //user address and rule
                              ListTile(
                                leading: Icon(
                                  Icons.edit_location_alt,
                                  size: 20,
                                ),
                                subtitle: Text("Address "),
                                title: Text(
                                  address!,
                                  textScaleFactor: 1.4,
                                ),
                              ),
                              Divider(
                                height: 20,
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.roundabout_left,
                                  size: 20,
                                ),
                                subtitle: Text("Rule"),
                                title: Text(
                                  rule!.toString().toUpperCase(),
                                  textScaleFactor: 1.4,
                                ),
                              ),
                              Divider(
                                height: 20,
                              ),

                              //doctor spesification and description
                              rule == "doctor"
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Edit Specification ",
                                          textScaleFactor: 2,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                              isDismissible: false,
                                              isScrollControlled: true,
                                              enableDrag: false,
                                              context: context,
                                              builder: (context) {
                                                return SingleChildScrollView(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    child: Column(
                                                      children: [
                                                        //close button sheet
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  bottom: 30),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              IconButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .close),
                                                              ),
                                                              Text(
                                                                "Update your information",
                                                                textScaleFactor:
                                                                    1.4,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              color:
                                                                  Colors.white),
                                                          child: Column(
                                                            children: [
                                                              //name
                                                              TextField(
                                                                controller:
                                                                    nameController,
                                                                decoration: InputDecoration(
                                                                    hintText:
                                                                        'Enter Full Name',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    contentPadding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            15.0,
                                                                        top:
                                                                            15.0),
                                                                    prefixIcon:
                                                                        const Icon(
                                                                            Icons.location_history_rounded)),
                                                              ),
                                                              Divider(
                                                                height: 10,
                                                              ),
                                                              //address
                                                              TextField(
                                                                  controller:
                                                                      addressController,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    hintText:
                                                                        'Enter Address',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    contentPadding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            15.0,
                                                                        top:
                                                                            15.0),
                                                                    prefixIcon:
                                                                        Icon(Icons
                                                                            .edit_location_alt_rounded),
                                                                  )),
                                                              Divider(
                                                                height: 10,
                                                              ),
                                                              //phone
                                                              TextField(
                                                                controller:
                                                                    phoneController,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .phone,
                                                                decoration: InputDecoration(
                                                                    hintText:
                                                                        'Enter Phone Number',
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    contentPadding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            15.0,
                                                                        top:
                                                                            15.0),
                                                                    prefixIcon:
                                                                        const Icon(
                                                                            Icons.phone_android)),
                                                              ),
                                                              Divider(
                                                                height: 30,
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(30.0),
                                                          child:
                                                              FilledButton.icon(
                                                            onPressed:
                                                                () async {
                                                              var search = [];
                                                              var str =
                                                                  nameController
                                                                      .text;
                                                              int j = 1;
                                                              for (int i = 0;
                                                                  i < str.length;
                                                                  i++) {
                                                                search.add(str
                                                                    .substring(
                                                                        0, j));
                                                                j++;
                                                              }
                                                              //try update user information
                                                              try {
                                                                final account = await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'users')
                                                                    .where(
                                                                        'uid',
                                                                        isEqualTo:
                                                                            uid)
                                                                    .limit(1)
                                                                    .get()
                                                                    .then((QuerySnapshot
                                                                        snapshot) {
                                                                  //Here we get the document reference and return to the post variable.
                                                                  return snapshot
                                                                      .docs[0]
                                                                      .reference;
                                                                });
                                                                var batch =
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .batch();
                                                                //Updates the field value, using account as document reference
                                                                batch.update(
                                                                    account, {
                                                                  'name':
                                                                      nameController
                                                                          .text,
                                                                  'address':
                                                                      addressController
                                                                          .text,
                                                                  'phone':
                                                                      phoneController
                                                                          .text,
                                                                  "search":
                                                                      search
                                                                });
                                                                batch
                                                                    .commit()
                                                                    .whenComplete(() =>
                                                                        Navigator.pop(
                                                                            context));
                                                                setState(() {
                                                                  getUserInfo();
                                                                });
                                                              } catch (e) {
                                                                print(e);
                                                              }
                                                            },
                                                            icon: Icon(
                                                              Icons.save,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            label: Text(
                                                              "Update",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: Colors.cyan,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(50),
                                                )),
                                            child: Icon(
                                              Icons.history_edu_outlined,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  :
                                  //patient section
                                  Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
        floatingActionButton: FloatingActionButton(
            child: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) async {
                await SharedPreferences.getInstance().then((auth) {
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
            }),
      ),
    );
  }
}
