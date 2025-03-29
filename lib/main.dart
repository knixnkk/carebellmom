import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:group_button/group_button.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner globally
      home: IntroPage(),
    );
  }
}

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Spacer(), // Pushes the content below to the bottom
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to",
                  style: TextStyle(
                    fontSize: screenHeight * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Image.asset(
                  'assets/intro_page/nurse.png',
                  height: screenHeight * 0.6, // 30% of the screen height
                  width: screenWidth * 0.7, // 50% of the screen width
                  fit:
                      BoxFit.contain, // Ensures the image scales proportionally
                ),
                SizedBox(height: 20),
                Text(
                  "Carebell Mom",
                  style: TextStyle(
                    fontSize: screenHeight * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Spacer(), // Pushes the button to the bottom
          Padding(
            padding: const EdgeInsets.all(
              16.0,
            ), // Add padding around the button
            child: SizedBox(
              width: double.infinity, // Full width of the screen
              height: 50, // Height of the button
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Square edges
                  ),
                  backgroundColor: Colors.blue,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainApp()),
                  );
                },
                child: Text('Next', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: FadeInLoginForm()));
  }
}

class FadeInLoginForm extends StatefulWidget {
  @override
  _FadeInLoginFormState createState() => _FadeInLoginFormState();
}

class _FadeInLoginFormState extends State<FadeInLoginForm> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0; // Start fade-in animation
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(seconds: 2), // Duration of fade-in
      child: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _showPassword = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  Future<void> _login() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both username and password")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(
          'http://localhost:3000/api/login',
        ), // Replace with your API URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful! Welcome ${data['name']}")),
        );

        // Navigate based on the user's role
        if (data['role'] == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()),
          );
        } else if (data['role'] == 'user') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unknown role: ${data['role']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        SizedBox(height: 20),
        Center(
          child: Text(
            "Login",
            style: TextStyle(
              fontSize: screenwidth * 0.075,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 20),
        Image(image: AssetImage("assets/login_page/logo.gif")),
        SizedBox(height: 20),
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(labelText: "Username"),
        ),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: "Password"),
          obscureText: !_showPassword,
        ),
        Row(
          children: [
            Checkbox(
              value: _showPassword,
              onChanged: (bool? value) {
                _togglePasswordVisibility();
              },
            ),
            Text("Show Password"),
          ],
        ),
        ElevatedButton(
          onPressed: _login, // Call the login function on button press
          child: Text("Login"),
        ),
      ],
    );
  }
}

class UserPage extends StatelessWidget {
  final NotchBottomBarController _controller = NotchBottomBarController(
    index: 1,
  ); // Set default page to Page 2
  UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        onTap: (index) {
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
      body: Column(
        children: [
          const SizedBox(height: 50), // Add this SizedBox before the Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  debugPrint("Image 1 pressed");
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FittedBox(
                    fit:
                        BoxFit
                            .contain, // Ensures the image scales proportionally
                    child: Image.asset(
                      'assets/index_page/loading.gif',
                      width: 50, // Adjust the width as needed
                      height: 50, // Adjust the height as needed
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 100), // Add spacing between images
              GestureDetector(
                onTap: () {
                  debugPrint("Image 2 pressed");
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/index_page/wrong.gif',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              const SizedBox(width: 100), // Add spacing between images
              GestureDetector(
                onTap: () {
                  debugPrint("Image 3 pressed");
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/index_page/check.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ImageSlideshow(
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
              Image.asset('assets/jk/2.jpg', fit: BoxFit.contain),
              Image.asset('assets/jk/3.jpg', fit: BoxFit.contain),
            ],
          ),
        ],
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Page")),
      body: Center(child: Text("Welcome, Admin!")),
    );
  }
}

class NursePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nurse Page")),
      body: Center(child: Text("Welcome, Nurse!")),
    );
  }
}
