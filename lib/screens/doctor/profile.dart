import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hestinn/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({Key? key}) : super(key: key);

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  //user info
  String? name,
      phone,
      rule,
      uid,
      email,
      address,
      specialistID,
      specialistName,
      specialistIcon,
      picture,
      userDocID,
      about;

  Timestamp? experience;
  List certifications = [];
  final _firebaseStorage = FirebaseStorage.instance;
  XFile? image;
  File? file;
  XFile? pickedImage;
  final picker = ImagePicker();
  DateTime? selectedExperience;
  browseImage() async {
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted) {
      pickedImage =
          await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920);
      if (pickedImage != null) {
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
      }
    } else {
      print("no image permisssion");
    }
  }

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
        specialistName = u.docs.first.data().containsKey('specialist')
            ? u.docs.first.data()['specialist']['name']
            : " ";
        specialistIcon = u.docs.first.data().containsKey('specialist')
            ? u.docs.first.data()['specialist']['icon']
            : " ";
        certifications = u.docs.first.data()['certifications'] ?? [];
        about = u.docs.first.data().containsKey('about')
            ? u.docs.first.data()['about']
            : "";
        picture = u.docs.first.data()['picture'] ?? "N/A";
        userDocID = u.docs.first.id;
        experience = u.docs.first.data().containsKey('experience')
            ? u.docs.first.data()['experience']
            : "";
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
  TextEditingController certificationsController = TextEditingController();
  TextEditingController aboutController = TextEditingController();

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
    certificationsController.dispose();
    aboutController.dispose();
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
                                      child: Image.network(
                                        picture.toString(),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        fit: BoxFit.cover,
                                      ),
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
                                  size: 30,
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
                                  size: 30,
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
                              //phone
                              ListTile(
                                leading: Icon(
                                  Icons.phone_android,
                                  size: 30,
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
                                  size: 30,
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
                              //rule
                              ListTile(
                                leading: Icon(
                                  Icons.roundabout_left,
                                  size: 30,
                                ),
                                subtitle: Text("Rule"),
                                title: Text(
                                  rule!.toString().toUpperCase(),
                                  textScaleFactor: 1.4,
                                ),
                              ),
                              // Divider(
                              //   height: 20,
                              // ),
                              Divider(
                                height: 50,
                                color: Colors.cyan,
                              ),
                              //doctor spesification and description
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Edit Details ",
                                    textScaleFactor: 2,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  //all edit fields to update in Modal bottom sheet
                                  InkWell(
                                    onTap: () {
                                      showModalBottomSheet(
                                        isDismissible: false,
                                        isScrollControlled: true,
                                        enableDrag: false,
                                        context: context,
                                        builder: (context) {
                                          return StatefulBuilder(builder:
                                              (BuildContext context, setState) {
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
                                                              bottom: 20),
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
                                                            "Update details",
                                                            textScaleFactor:
                                                                1.4,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    //content of update details
                                                    Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          color: Colors.white),
                                                      child: Column(
                                                        children: [
                                                          //Specialist
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10.0),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Column(
                                                                  children: [
                                                                    Text(
                                                                      "Choose Specialist",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.grey),
                                                                      textScaleFactor:
                                                                          1.2,
                                                                    ),
                                                                    Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Image
                                                                            .network(
                                                                          specialistIcon!,
                                                                          width:
                                                                              32,
                                                                          height:
                                                                              32,
                                                                        ),
                                                                        Text(
                                                                            specialistName!),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    //show specialist list
                                                                    await showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return StatefulBuilder(builder:
                                                                            (BuildContext context,
                                                                                setState) {
                                                                          return SafeArea(
                                                                            child:
                                                                                Scaffold(
                                                                              appBar: AppBar(
                                                                                iconTheme: IconThemeData(color: Colors.white, size: 30),
                                                                                title: Text(
                                                                                  "Choose Specialist",
                                                                                  textScaleFactor: 1.4,
                                                                                  style: TextStyle(color: Colors.white),
                                                                                ),
                                                                              ),
                                                                              body: StreamBuilder(
                                                                                stream: FirebaseFirestore.instance.collection("categories").snapshots(),
                                                                                builder: (BuildContext context, snapshot) {
                                                                                  if (snapshot.hasData) {
                                                                                    return ListView(
                                                                                      children: List.generate(snapshot.data!.docs.length, (index) {
                                                                                        final DocumentSnapshot specialists = snapshot.data!.docs[index];
                                                                                        return Container(
                                                                                          margin: const EdgeInsets.only(bottom: 5),
                                                                                          decoration: BoxDecoration(
                                                                                            border: Border(
                                                                                              bottom: BorderSide(width: 0.4, color: Colors.cyan),
                                                                                            ),
                                                                                          ),
                                                                                          child: ListTile(
                                                                                            selectedColor: Colors.blue,
                                                                                            leading: Image.network(
                                                                                              specialists['icon'].toString(),
                                                                                              width: 32,
                                                                                              height: 32,
                                                                                            ),
                                                                                            trailing: InkWell(
                                                                                              onTap: () {
                                                                                                setState(() {
                                                                                                  specialistID = specialists.id;
                                                                                                  specialistName = specialists['name'];
                                                                                                  specialistIcon = specialists['icon'];
                                                                                                });
                                                                                                // try {
                                                                                                //   //delete specialist
                                                                                                //   //      &
                                                                                                //   //image from storage
                                                                                                //   await _firebaseStorage.refFromURL(specialists['icon']).delete().then((value) {
                                                                                                //     try {
                                                                                                //       FirebaseFirestore.instance.collection("categories").doc(specialists.id).delete();
                                                                                                //     } on FirebaseException catch (e) {
                                                                                                //       print('Failed with error code: ${e.code}');
                                                                                                //       print(e.message);
                                                                                                //     }
                                                                                                //   });
                                                                                                //   //update doctors has this specialist deleted to unknown
                                                                                                //   //if it deleted then it make doctor info error
                                                                                                //   FirebaseFirestore.instance.collection("doctors").where("specialist", isEqualTo: specialists.id).get().then((docs) {
                                                                                                //     docs.docs.forEach((element) {
                                                                                                //       element.reference.update({
                                                                                                //         "specialist": 'unknown'
                                                                                                //       });
                                                                                                //     });
                                                                                                //   });
                                                                                                // } on FirebaseException catch (e) {
                                                                                                //   print('Failed with error code: ${e.code}');
                                                                                                //   print(e.message);
                                                                                                // }
                                                                                              },
                                                                                              child: Icon(
                                                                                                specialists.id == specialistID ? Icons.check_box : Icons.check_box_outline_blank,
                                                                                                color: Colors.cyan,
                                                                                                size: 30,
                                                                                              ),
                                                                                            ),
                                                                                            title: Text(specialists['name']),
                                                                                            onTap: () {
                                                                                              setState(() {
                                                                                                specialistID = specialists.id;
                                                                                                specialistName = specialists['name'];
                                                                                                specialistIcon = specialists['icon'];
                                                                                                // print(specialists['name']);
                                                                                                // print(specialists['icon']);
                                                                                                // print(specialists.id);
                                                                                              });
                                                                                            },
                                                                                          ),
                                                                                        );
                                                                                      }),
                                                                                    );
                                                                                  }
                                                                                  return Center(
                                                                                    child: Container(
                                                                                      padding: const EdgeInsets.all(20),
                                                                                      child: const LinearProgressIndicator(),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                          );
                                                                        });
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Icon(
                                                                    Icons
                                                                        .category,
                                                                    color: Colors
                                                                        .cyan,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 10,
                                                          ),
                                                          //Certifications
                                                          TextField(
                                                            controller:
                                                                certificationsController,
                                                            decoration:
                                                                InputDecoration(
                                                              helperText:
                                                                  "Enter certifications sperated with comma ,",
                                                              hintText:
                                                                  'Enter certification',
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
                                                                  .credit_score_outlined),
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 10,
                                                          ),
                                                          //Experience
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      "Choose Experience date",
                                                                      textScaleFactor:
                                                                          1.2,
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        //show Date dialog
                                                                        showDatePicker(
                                                                          context:
                                                                              context,
                                                                          initialDate:
                                                                              DateTime.now(),
                                                                          firstDate:
                                                                              DateTime(1970),
                                                                          lastDate:
                                                                              DateTime.now(),
                                                                          helpText:
                                                                              "Select Experience date",
                                                                          builder:
                                                                              (context, child) {
                                                                            return Theme(
                                                                              data: ThemeData.light().copyWith(
                                                                                colorScheme: ColorScheme.light(
                                                                                  primary: Colors.cyan,
                                                                                ),
                                                                              ),
                                                                              child: child!,
                                                                            );
                                                                          },
                                                                        ).then(
                                                                            (experienceSelected) {
                                                                          if (experienceSelected !=
                                                                              null) {
                                                                            setState(() {
                                                                              selectedExperience = experienceSelected;
                                                                            });
                                                                            print(experienceSelected.toString());
                                                                          }
                                                                        });
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .calendar_month_outlined,
                                                                        color: Colors
                                                                            .cyan,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Text(
                                                                  selectedExperience !=
                                                                          null
                                                                      ? selectedExperience
                                                                          .toString()
                                                                          .split(
                                                                              " ")[0]
                                                                      : " ",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .cyan),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Divider(
                                                            height: 30,
                                                          ),
                                                          //About
                                                          TextField(
                                                            controller:
                                                                aboutController,
                                                            maxLines: 3,
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            decoration: InputDecoration(
                                                                hintText:
                                                                    'Enter about you',
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
                                                                        .document_scanner_outlined)),
                                                          ),
                                                          Divider(
                                                            height: 30,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    //button to update
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              30.0),
                                                      child: FilledButton.icon(
                                                        onPressed: () async {
                                                          Timestamp exp =
                                                              Timestamp.fromDate(
                                                                  selectedExperience!);
                                                          //try update user information
                                                          try {
                                                            final account =
                                                                await FirebaseFirestore
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
                                                              'specialist': {
                                                                'icon':
                                                                    specialistIcon,
                                                                'id':
                                                                    specialistID,
                                                                'name':
                                                                    specialistName
                                                              },
                                                              'certifications':
                                                                  certificationsController
                                                                      .text
                                                                      .split(
                                                                          ","),
                                                              'about':
                                                                  aboutController
                                                                      .text,
                                                              'experience': exp,
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
                                                          "Update details",
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
                                          });
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
                              //details
                              Column(
                                children: [
                                  //Specialist
                                  ListTile(
                                    leading: Image.network(
                                      specialistIcon!.toString(),
                                      width: 32,
                                      height: 32,
                                    ),
                                    subtitle: Text("Specialist"),
                                    title: Text(
                                      specialistName!.toString(),
                                      textScaleFactor: 1.4,
                                    ),
                                  ),
                                  Divider(
                                    height: 30,
                                  ),
                                  //Certifications
                                  ListTile(
                                    leading: Icon(
                                      Icons.document_scanner_rounded,
                                      size: 30,
                                    ),
                                    subtitle: Text("Your Certifications"),
                                    title: Text(
                                      certifications.isEmpty
                                          ? "N/A"
                                          : certifications
                                              .toList()
                                              .join(",")
                                              .toUpperCase(),
                                      textScaleFactor: 1.4,
                                    ),
                                  ),
                                  Divider(
                                    height: 20,
                                  ),
                                  //About
                                  ListTile(
                                    leading: Icon(
                                      Icons.abc_outlined,
                                      size: 30,
                                    ),
                                    subtitle: Text("About You or Bio"),
                                    title: Text(
                                      about!.isEmpty ? "N/A" : about!,
                                      textScaleFactor: 1.4,
                                    ),
                                  ),
                                  Divider(
                                    height: 20,
                                  ),
                                  //Experience
                                  ListTile(
                                    leading: Icon(
                                      Icons.event,
                                      size: 30,
                                    ),
                                    subtitle: Text("Start Experience Date"),
                                    title: Text(
                                      experience == null
                                          ? "N/A"
                                          : experience!
                                              .toDate()
                                              .toString()
                                              .split(" ")[0],
                                      textScaleFactor: 1.4,
                                    ),
                                  ),
                                  Divider(
                                    height: 50,
                                    color: Colors.cyan,
                                  ),
                                  //Signout
                                  ListTile(
                                    onTap: () {
                                      showDialog(
                                        // barrierColor: Colors.amber,
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return SafeArea(
                                            child: Dialog(
                                              shape: BeveledRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(30),
                                                  bottomRight:
                                                      Radius.circular(30),
                                                ),
                                              ),
                                              child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.30,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              "Signout !",
                                                              textScaleFactor:
                                                                  1.4,
                                                            ),
                                                            InkWell(
                                                                onTap: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                                child: Icon(Icons
                                                                    .close)),
                                                          ],
                                                        ),
                                                      ),
                                                      Divider(),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        child: Text(
                                                            "Are you sure to Signout from application ?"),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          ElevatedButton.icon(
                                                            onPressed: () {
                                                              FirebaseAuth
                                                                  .instance
                                                                  .signOut()
                                                                  .then(
                                                                      (value) async {
                                                                await SharedPreferences
                                                                        .getInstance()
                                                                    .then(
                                                                        (auth) {
                                                                  auth.setBool(
                                                                      "auth",
                                                                      false);
                                                                  auth.remove(
                                                                      "uid");
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              LoginScreen(),
                                                                    ),
                                                                  );
                                                                });
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            label: Text(
                                                              "Yes",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                          ElevatedButton.icon(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            icon: Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            label: Text(
                                                              "No",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    leading: Icon(
                                      Icons.exit_to_app,
                                      size: 20,
                                    ),
                                    subtitle: Text("SIgnout from your account"),
                                    title: Text(
                                      "Signout",
                                      textScaleFactor: 1.4,
                                    ),
                                  ),
                                  Divider(
                                    height: 20,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
