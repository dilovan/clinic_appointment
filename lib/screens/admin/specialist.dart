import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AdminSpecialist extends StatefulWidget {
  const AdminSpecialist({super.key});

  @override
  State<AdminSpecialist> createState() => _AdminSpecialistState();
}

class _AdminSpecialistState extends State<AdminSpecialist> {
  TextEditingController categoryNameController = TextEditingController();
  String? imageUrl;
  final _firebaseStorage = FirebaseStorage.instance;
  XFile? image;
  File? file;
  XFile? pickedImage;

  bool disabled = true;
  bool canUpdate = false;

  final picker = ImagePicker();
  browseImage() async {
    await Permission.photos.request();
    // var permissionStatus = await Permission.photos.status;
    // if (permissionStatus.isGranted) {
    pickedImage =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 1920);
    //select image
    file = File(pickedImage!.path);
    if (pickedImage != null) {
      //image url
      setState(() {
        imageUrl = pickedImage!.path;
      });
    } else {
      print("select image");
    }
    // } else {
    //   print("no image permisssion");
    // }
  }

  //save to firebase and storage
  saveToFirebase() async {
    setState(() {
      disabled = true;
    });
    await _firebaseStorage
        .ref()
        .child("categories/${categoryNameController.text}")
        .putFile(
          file!,
          SettableMetadata(
            customMetadata: {'name': categoryNameController.text},
          ),
        )
        .then((imageUploaded) {
      //get download image url = img
      imageUploaded.ref.getDownloadURL().then((img) {
        var map = {
          "icon": img,
          "name": categoryNameController.text.trim(),
        };
        //add specialist to firebase database
        FirebaseFirestore.instance
            .collection("categories")
            .add(map)
            .then((done) {
          //show snake bar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Specialist has been added"),
            ),
          );
          //clear text box for soecialist and enable buttons
          categoryNameController.clear();
          setState(() {
            disabled = false;
            file = null;
          });
        });
      });
    });
  }

  int selectedCategory = -1;
  String specialistDocID = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    categoryNameController.dispose();
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
          title: Text(
            "Manage Specialists",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          primary: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                //title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Specialist List",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textScaleFactor: 1.4,
                    ),
                    Icon(Icons.grid_view_outlined)
                  ],
                ),
                //list of specialist
                Container(
                  margin: const EdgeInsets.only(bottom: 20, top: 20),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.cyan),
                  ),
                  height: MediaQuery.of(context).size.height * 0.40,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("categories")
                        .snapshots(),
                    builder: (BuildContext context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView(
                          children: List.generate(snapshot.data!.docs.length,
                              (index) {
                            final DocumentSnapshot specialists =
                                snapshot.data!.docs[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 0.4, color: Colors.cyan),
                                ),
                              ),
                              child: ListTile(
                                // tileColor: Colors.cyanAccent,
                                selected:
                                    selectedCategory == index ? true : false,
                                selectedColor: Colors.blue,
                                leading: Image.network(
                                  specialists['icon'].toString(),
                                  width: 32,
                                  height: 32,
                                ),
                                trailing: InkWell(
                                  onTap: () async {
                                    try {
                                      //delete category
                                      //      &
                                      //image from storage
                                      await _firebaseStorage
                                          .refFromURL(specialists['icon'])
                                          .delete()
                                          .then((value) {
                                        try {
                                          FirebaseFirestore.instance
                                              .collection("categories")
                                              .doc(specialists.id)
                                              .delete();
                                        } on FirebaseException catch (e) {
                                          print(
                                              'Failed with error code: ${e.code}');
                                          print(e.message);
                                        }
                                      });
                                      //update doctors has this specialist deleted to unknown
                                      //if it deleted then it make doctor info error
                                      FirebaseFirestore.instance
                                          .collection("doctors")
                                          .where("specialist",
                                              isEqualTo: specialists.id)
                                          .get()
                                          .then((docs) {
                                        docs.docs.forEach((element) {
                                          element.reference.update(
                                              {"specialist": 'unknown'});
                                        });
                                      });
                                    } on FirebaseException catch (e) {
                                      print(
                                          'Failed with error code: ${e.code}');
                                      print(e.message);
                                    }
                                  },
                                  child: Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                                title: Text(specialists['name']),
                                onTap: () {
                                  setState(() {
                                    canUpdate = true;
                                    selectedCategory = index;
                                    specialistDocID = specialists.id;
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
                //new Specialist
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "New Specialist",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textScaleFactor: 1.4,
                    ),
                    Padding(
                        padding: EdgeInsets.all(5),
                        child: file != null
                            ? InkWell(
                                onTap: () {
                                  browseImage();
                                },
                                child: Image.file(
                                  file!,
                                  width: 64,
                                  height: 64,
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  //choose image
                                  browseImage();
                                },
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 30,
                                  color: Colors.cyan,
                                ),
                              )),
                  ],
                ),
                //category name
                TextField(
                  controller: categoryNameController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.app_registration_rounded,
                      size: 30,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.cyan),
                      // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.cyan),
                    ),
                    hintText: "Specialist Name",
                    errorBorder: InputBorder.none,
                    labelStyle: TextStyle(fontSize: 20),
                    contentPadding: EdgeInsets.all(5),
                  ),
                  onChanged: (name) {
                    if (categoryNameController.text.isNotEmpty &&
                        categoryNameController.text.length > 2) {
                      setState(() {
                        disabled = false;
                      });
                    } else {
                      setState(() {
                        disabled = true;
                      });
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                //add and update specialists
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //add button function
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: Text("Add",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                      onPressed: (disabled || file == null)
                          ? null
                          : () {
                              //add
                              saveToFirebase();
                            },
                    ),
                    //update button
                    ElevatedButton.icon(
                      icon: Icon(
                        Icons.edit_note_outlined,
                        color: Colors.white,
                      ),
                      label: Text("Update",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                      onPressed: (disabled || !canUpdate) //|| file == null
                          ? null
                          : () {
                              //update name
                              print(specialistDocID);
                              try {
                                FirebaseFirestore.instance
                                    .collection("categories")
                                    .doc(specialistDocID)
                                    .update(
                                        {"name": categoryNameController.text});
                              } on FirebaseException catch (e) {
                                print('Failed with error code: ${e.code}');
                                print(e.message);
                              }
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
