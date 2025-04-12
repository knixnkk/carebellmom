import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:carebellmom/patient_management/patients_management.dart';
import '../nursePages/AddNurse.dart';
import '../notification.dart';

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ImageSlideshow(
          width: 500,
          height: 500,
          initialPage: 0,
          indicatorColor: const Color.fromARGB(255, 147, 255, 150),
          indicatorBackgroundColor: const Color.fromARGB(255, 180, 180, 180),
          onPageChanged: (value) {},
          autoPlayInterval: 5000,
          isLoop: true,
          indicatorRadius: 5,
          disableUserScrolling: true,
          children: [
            Image.asset('assets/jk/1.jpg', fit: BoxFit.contain),
            Image.asset('assets/jk/2.png', fit: BoxFit.contain),
            Image.asset('assets/jk/3.jpg', fit: BoxFit.contain),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        overlayColor: Colors.white,
        buttonSize: const Size(65, 65),
        childrenButtonSize: const Size(60, 60),
        spacing: 10,
        overlayOpacity: 0.5,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: Icon(FontAwesomeIcons.userNurse, color: Colors.white),
            label: 'Nurse',
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddNurse()),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(FontAwesomeIcons.user, color: Colors.white),
            label: 'User',
            backgroundColor: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserManagementPage()),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(FontAwesomeIcons.message, color: Colors.white),
            label: 'Notification',
            backgroundColor: Colors.red,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => sendNotification()),
              );
            },
          ),
        ],
      ),
    );
  }
}
