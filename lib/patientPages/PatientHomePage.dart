import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:carebellmom/patient_management/patients_management.dart';
import '../nursePages/AddNurse.dart';
import '../notification.dart';
import 'package:carebellmom/patientPages/viewDetails.dart';

class PatientHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: ImageSlideshow(
              width: double.infinity,
              initialPage: 0,
              indicatorColor: const Color.fromARGB(255, 147, 255, 150),
              indicatorBackgroundColor: const Color.fromARGB(
                255,
                180,
                180,
                180,
              ),
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

          SizedBox(
            height: 20,
          ), // This spacer will push the button down, without affecting the slideshow

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  backgroundColor: Color(0xffE6A4B4),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewDetails(),
                    ),
                  );
                },
                child: Text(
                  'ดูรายละเอียด',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
