import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'AdminHomePage.dart';
import '../notification.dart';
import '../PersonalPage.dart';

class AdminPage extends StatefulWidget {
  AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final NotchBottomBarController _controller = NotchBottomBarController(
    index: 1,
  );
  int _currentIndex = 1; // Default index

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current index
          });
          debugPrint("Tab $index selected");
        },
        bottomBarHeight: screenheight * 0.08,
        bottomBarWidth: screenwidth,
        showLabel: false,
        kIconSize: 24.0,
        kBottomRadius: 5.0,
        removeMargins: true,
        textOverflow: TextOverflow.ellipsis,
        maxLine: 2,
        bottomBarItems: [
          const BottomBarItem(
            inActiveItem: Icon(
              Icons.notifications_on_outlined,
              color: Colors.blueGrey,
            ),
            activeItem: Icon(
              Icons.notifications_on_outlined,
              color: Colors.blueAccent,
            ),
          ),
          const BottomBarItem(
            inActiveItem: Icon(Icons.home, color: Colors.blueGrey),
            activeItem: Icon(Icons.home, color: Colors.blueAccent),
          ),
          const BottomBarItem(
            inActiveItem: Icon(Icons.person, color: Colors.blueGrey),
            activeItem: Icon(Icons.person, color: Colors.blueAccent),
          ),
        ],
      ),
      body: Center(
        child:
            _currentIndex == 0
                ? NotificationPage() // Show Text when index is 0
                : _currentIndex == 1
                ? AdminHomePage()
                : _currentIndex == 2
                ? PersonalPage() // Show Index3Page when index is 3
                : Text("Other Content"), // Default content for other indices
      ),
    );
  }
}
