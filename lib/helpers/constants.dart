import 'package:flutter/material.dart';

//doctor list
List<Map<String, dynamic>> Doctors = [
  {
    'id': 1,
    'img': 'assets/doctor01.jpeg',
    'doctorName': 'Dr. Haval Esmaeel',
    'doctorTitle': 'Heart Specialist',
    'rate': 3.5,
    'category': 1,
    'reviews': 55,
    "information": {
      "Patients": 45,
      "Experiences": DateTime(1999, 03, 01),
      "Fee": 20000,
    },
  },
  {
    'id': 2,
    'img': 'assets/doctor02.png',
    'doctorName': 'Dr. Essa Abdulla',
    'doctorTitle': 'Heart Specialist',
    'rate': 5.0,
    'category': 1,
    'reviews': 43,
    "information": {
      "Patients": 44,
      "Experiences": DateTime(1996, 11, 02),
      "Fee": 22000,
    },
  },
  {
    'id': 3,
    'img': 'assets/doctor03.jpeg',
    'doctorName': 'Dr.Arshad Drbas Ali',
    'doctorTitle': 'Brain Specialist',
    'rate': 3.0,
    'category': 2,
    'reviews': 36,
    "information": {
      "Patients": 67,
      "Experiences": DateTime(1990, 03, 01),
      "Fee": 20000,
    },
  },
  {
    'id': 4,
    'img': 'assets/doctor04.jpeg',
    'doctorName': 'Dr. Haifa Ahmad',
    'doctorTitle': 'Eye Specialist',
    'rate': 3.2,
    'category': 3,
    'reviews': 49,
    "information": {
      "Patients": 67,
      "Experiences": DateTime(2001, 12, 15),
      "Fee": 21000,
    },
  },
  {
    'id': 5,
    'img': 'assets/doctor05.jpeg',
    'doctorName': 'Dr. Kani Ali',
    'doctorTitle': 'Diabets Specialist',
    'rate': 4.2,
    'category': 5,
    'reviews': 44,
    "information": {
      "Patients": 67,
      "Experiences": DateTime(2002, 10, 23),
      "Fee": 15000,
    },
  },
  {
    'id': 6,
    'img': 'assets/doctor01.jpeg',
    'doctorName': 'Dr. Sami Salim',
    'doctorTitle': 'Eye Specialist',
    'rate': 5,
    'category': 3,
    'reviews': 88,
    "information": {
      "Patients": 67,
      "Experiences": DateTime(2000, 08, 08),
      "Fee": 20000,
    },
  },
  {
    'id': 7,
    'img': 'assets/doctor06.jpg',
    'doctorName': 'Dr. Sleman Shahin',
    'doctorTitle': 'Dentist Specialist',
    'rate': 4.5,
    'category': 4,
    'reviews': 78,
    "information": {
      "Patients": 67,
      "Experiences": DateTime(2006, 09, 09),
      "Fee": 25000,
    },
  },
];
//categories list
List<Map> categories = [
  {'id': 1, 'icon': "assets/cats/heart.png", 'text': 'Heart'},
  {'id': 2, 'icon': "assets/cats/brain.png", 'text': 'Brain'},
  {'id': 3, 'icon': "assets/cats/eye.png", 'text': 'Eyes'},
  {'id': 4, 'icon': "assets/cats/dentist.png", 'text': 'Dentist'},
  {'id': 5, 'icon': "assets/cats/diabets.png", 'text': 'Diabets'},
];

//schedule headings
enum FilterStatus { Upcoming, Complete, Cancel }

//schedule list
List<Map> schedules = [
  {
    'id': 1, //doctor id
    'reservedDate': 'Satuday, Jun 14',
    'reservedTime': '10:00 - 10:30',
    'status': FilterStatus.Upcoming
  },
  {
    'id': 2,
    'reservedDate': 'Sunday, Jun 15',
    'reservedTime': '11:00 - 11:30',
    'status': FilterStatus.Upcoming
  },
  {
    'id': 3,
    'reservedDate': 'Sunday, Jun 15',
    'reservedTime': '12:00 - 12:30',
    'status': FilterStatus.Upcoming
  },
  {
    'id': 4,
    'reservedDate': 'Monday, Jun 16',
    'reservedTime': '13:00 - 13:30',
    'status': FilterStatus.Complete
  },
  {
    'id': 5,
    'reservedDate': 'Monday, Jun 16',
    'reservedTime': '15:00 - 15:30',
    'status': FilterStatus.Cancel
  },
];
