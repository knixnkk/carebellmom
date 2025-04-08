import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_fast_forms/flutter_fast_forms.dart';
import 'dart:developer';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

String baseUrl =
    "https://f069-2403-6200-8833-84e8-7c39-5473-e6b9-abd4.ngrok-free.app";
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
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await prefs.setString('role', data['role']);
        await prefs.setString('name', data['name']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login successful! Welcome ${data['name']}")),
        );

        // Navigate based on the role
        if (data['role'] == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()),
          );
        } else if (data['role'] == 'nurse') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NursePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UserPage()),
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
              Image.asset('assets/jk/2.png', fit: BoxFit.contain),
              Image.asset('assets/jk/3.jpg', fit: BoxFit.contain),
            ],
          ),
        ],
      ),
    );
  }
}

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

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  String? username;
  String? role;
  String? name;
  Map<String, dynamic>? userJson;
  bool isLoading = true;

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    username = prefs.getString('username');
    role = prefs.getString('role');
    if (username == null || role == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/get_user_data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'role': role}),
      );

      if (response.statusCode == 200) {
        setState(() {
          userJson = json.decode(response.body);
          name = userJson?['name'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      log("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
    log("User data: $userJson");
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userJson == null) {
      return const Center(child: Text("User data not found."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Center(
            child: ClipOval(
              child: Image.asset(
                "assets/personal_page/profile.png",
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          userJson!['display_name'] ?? "Unknown",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Card(
          margin: const EdgeInsets.all(5.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.white,
          child: SizedBox(
            height: screenheight * 0.6,
            child: ListView.builder(
              itemCount: userJson?.length ?? 0,
              itemBuilder: (context, index) {
                String key = userJson!.keys.elementAt(index);
                String title_text = "";
                if (key == "display_name")
                  return SizedBox.shrink(); // Do nothing
                if (key == "username") title_text = "User ID";
                if (title_text == "") title_text = key;
                String value = userJson![key]?.toString() ?? '-';
                return Column(
                  children: [
                    ListTile(title: Text(title_text), subtitle: Text(value)),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ),
        Spacer(),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                logout();
              },
              child: Text(
                'Logout',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenheight = MediaQuery.of(context).size.height;
    return ListView(
      children: [
        SizedBox(height: 20),
        Card(
          margin: EdgeInsets.all(5.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.white,
          child: SizedBox(
            height: screenheight * 0.8,
            child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text('Title'),
                  subtitle: Text('Subtitle'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.notifications_active_outlined),
                  title: Text('Title'),
                  subtitle: Text('Subtitle'),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.notifications_outlined),
                  title: Text('Title'),
                  subtitle: Text('Subtitle'),
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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
                MaterialPageRoute(builder: (context) => AddUser()),
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

class UserHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Home Page")),
      body: Center(child: Text("Welcome, User!")),
    );
  }
}

class NursePage extends StatefulWidget {
  NursePage({super.key});

  @override
  _NursePageState createState() => _NursePageState();
}

class _NursePageState extends State<NursePage> {
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

class AddNurse extends StatefulWidget {
  const AddNurse({super.key});

  @override
  _AddNurseState createState() => _AddNurseState();
}

class _AddNurseState extends State<AddNurse> {
  final TextEditingController _nurseIDController = TextEditingController();
  final TextEditingController _nursePasswordController =
      TextEditingController();
  final TextEditingController _nurseNameController = TextEditingController();
  final TextEditingController _telephoneNumberController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Nurse")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "Nurse ID",
                border: OutlineInputBorder(),
              ),
              controller: _nurseIDController,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Nurse Password",
                border: OutlineInputBorder(),
              ),
              controller: _nursePasswordController,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Nurse Name",
                border: OutlineInputBorder(),
              ),
              controller: _nurseNameController,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Telephone Number",
                border: OutlineInputBorder(),
              ),
              controller: _telephoneNumberController,
            ),
            SizedBox(height: 16),
            Spacer(), // Pushes the button to the bottom
            Padding(
              padding: const EdgeInsets.all(
                10.0,
              ), // Add padding around the button
              child: SizedBox(
                width: double.infinity, // Full width of the screen
                height: 50, // Height of the button
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded edges
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    final nurseData = {
                      'username': _nurseIDController.text,
                      'password': _nursePasswordController.text,
                      'name': _nurseNameController.text,
                      'role': 'nurse',
                      'telephone': _telephoneNumberController.text,
                    };
                    // Simulate saving user details via an HTTP request
                    try {
                      final response = await http.post(
                        Uri.parse(
                          '$baseUrl/api/register',
                        ), // Replace with your API URL
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode(nurseData),
                      );

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("User details saved successfully!"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to save user details"),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("An error occurred: $e")),
                      );
                    }
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  _AddUserState createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final TextEditingController _lmpDateController = TextEditingController();
  final TextEditingController _edcDateController = TextEditingController();
  final TextEditingController _gaController = TextEditingController();
  final TextEditingController _gaManualController = TextEditingController();
  final TextEditingController _edcManualController = TextEditingController();
  final TextEditingController _ultrasoundDateController =
      TextEditingController();
  final TextEditingController _ultrasoundGAController = TextEditingController();

  final TextEditingController _userNationalIDController =
      TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userPasswordController = TextEditingController();
  final TextEditingController _telephoneNumberController =
      TextEditingController();
  String _selectedOption = ""; // Default selected option

  void _calculateEDCAndGA() {
    if (_lmpDateController.text.isNotEmpty) {
      try {
        final lmpDateParts = _lmpDateController.text.split('/');
        final lmpDate = DateTime(
          int.parse(lmpDateParts[2]),
          int.parse(lmpDateParts[1]),
          int.parse(lmpDateParts[0]),
        );

        final edcDate = lmpDate.add(
          Duration(days: 280),
        ); // Add 280 days (40 weeks)
        final currentDate = DateTime.now();
        final gaDays = currentDate.difference(lmpDate).inDays;
        final gaWeeks = gaDays ~/ 7;
        final gaRemainingDays = gaDays % 7;

        setState(() {
          _edcDateController.text =
              "${edcDate.day}/${edcDate.month}/${edcDate.year}";
          _gaController.text = "$gaWeeks weeks $gaRemainingDays days";
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Invalid LMP date format")));
      }
    }
  }

  int convertGAtodays(String gaText) {
    debugPrint("GA Text: $gaText");
    final gaMatch = RegExp(
      r'^\s*(\d+)\s*weeks?\s*(\d+)\s*days?\s*$',
      caseSensitive: false,
    ).firstMatch(gaText);
    if (gaMatch == null) {
      return 0; // Invalid GA format
    }
    final weeks = int.tryParse(gaMatch.group(1)!);
    final days = int.tryParse(gaMatch.group(2)!);
    print('weeks: $weeks, days: $days, gaText: $gaText');
    if (weeks == null || days == null || days < 0 || days > 6) {
      return 0; // Invalid GA values
    }
    return (weeks * 7) + days;
  }

  void _calculateFromUltrasound() {
    final usDateText = _ultrasoundDateController.text.trim();
    final gaText = _ultrasoundGAController.text.trim();

    try {
      final usDateParts = usDateText.split('/');
      final usDate = DateTime(
        int.parse(usDateParts[2]),
        int.parse(usDateParts[1]),
        int.parse(usDateParts[0]),
      );

      final gaMatch = RegExp(r'^\s*(\d+)\s*\+\s*(\d+)\s*$').firstMatch(gaText);

      if (gaMatch == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid GA format. Use like 8+2")),
        );
        return;
      }

      final weeks = int.tryParse(gaMatch.group(1)!);
      final days = int.tryParse(gaMatch.group(2)!);

      if (weeks == null || days == null || days < 0 || days > 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid GA values. Days should be 0–6")),
        );
        return;
      }

      final totalDays = (weeks * 7) + days;
      final lmpDate = usDate.subtract(Duration(days: totalDays));
      final edcDate = lmpDate.add(Duration(days: 280));

      setState(() {
        _gaManualController.text = "$weeks weeks $days days";
        _edcManualController.text =
            "${edcDate.day}/${edcDate.month}/${edcDate.year}";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error processing ultrasound data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add User")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "User National ID",
                border: OutlineInputBorder(),
              ),
              controller: _userNationalIDController,
              obscureText: false,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "User Password",
                border: OutlineInputBorder(),
              ),
              controller: _userPasswordController,
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "User Name",
                border: OutlineInputBorder(),
              ),
              controller: _userNameController,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Telephone Number",
                border: OutlineInputBorder(),
              ),
              controller: _telephoneNumberController,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text("LMP"),
                    value: "LMP",
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value ?? '';
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text("Ultrasound"),
                    value: "Ultrasound",
                    groupValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value ?? '';
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_selectedOption == "LMP")
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _lmpDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "LMP Date",
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                _lmpDateController.text =
                                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                              });
                              _calculateEDCAndGA(); // Automatically calculate EDC and GA
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _lmpDateController.clear();
                            _edcDateController.clear();
                            _gaController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _edcDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "EDC Date",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _gaController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Gestational Age (GA)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            if (_selectedOption == "Ultrasound")
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ultrasoundDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Ultrasound Date",
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (selectedDate != null) {
                              setState(() {
                                _ultrasoundDateController.text =
                                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                              });
                              _calculateFromUltrasound();
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _ultrasoundDateController.clear();
                            _ultrasoundGAController.clear();
                            _gaManualController.clear();
                            _edcManualController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _ultrasoundGAController,
                    decoration: InputDecoration(
                      labelText: "Gestational Age (e.g. 8+2)",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    onChanged: (value) => _calculateFromUltrasound(),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _gaManualController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Gestational Age (GA)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _edcManualController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "EDC Date",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: () async {
                    final userData = {
                      'username': _userNationalIDController.text,
                      'password': _userPasswordController.text,
                      'name': _userNameController.text,
                      'role': 'patient',
                      'telephone': _telephoneNumberController.text,
                    };

                    if (_selectedOption == "LMP") {
                      userData['EDC'] = _edcDateController.text;
                      userData['LMP'] = _lmpDateController.text;
                      userData['GA'] =
                          convertGAtodays(_gaController.text).toString();
                    } else if (_selectedOption == "Ultrasound") {
                      userData['EDC'] = _edcManualController.text;
                      userData['US'] = _ultrasoundDateController.text;
                      userData['GA'] =
                          convertGAtodays(_gaManualController.text).toString();
                    }
                    // Simulate saving user details via an HTTP request
                    try {
                      final response = await http.post(
                        Uri.parse(
                          '$baseUrl/api/register',
                        ), // Replace with your API URL
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode(userData),
                      );

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("User details saved successfully!"),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to save user details"),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("An error occurred: $e")),
                      );
                    }
                  },
                  child: Text(
                    'Save User',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------- User Model ----------
class User {
  final String id;
  final String username;
  final String displayname;

  User({required this.id, required this.username, required this.displayname});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      displayname: json['display_name'],
    );
  }
}

// --------- Fetch Users ----------
Future<List<User>> fetchUsers() async {
  final response = await http.get(Uri.parse('$baseUrl/api/users'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((userJson) => User.fromJson(userJson)).toList();
  } else {
    throw Exception('Failed to load users');
  }
}

// --------- UI ----------
class sendNotification extends StatefulWidget {
  const sendNotification({super.key});

  @override
  State<sendNotification> createState() => _SendNotificationState();
}

class _SendNotificationState extends State<sendNotification> {
  User? selectedUser;
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  void sendNotification() async {
    if (selectedUser == null ||
        _titleController.text.isEmpty ||
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please complete all fields")));
      return;
    }
    final notificationData = {
      'username': selectedUser!.username,
      'title': _titleController.text,
      'body': _messageController.text,
      'timestamp': DateTime.now().toIso8601String(),
    };
    // Here you can send the notification via HTTP POST using selectedUser.username, etc.
    //print("Sending notification to: ${selectedUser!.username}");
    //print("Title: ${_titleController.text}");
    //print("Message: ${_messageController.text}");
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/send_notification',
        ), // Replace with your API URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(notificationData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User details saved successfully!")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to save user details")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sending notification")));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Notification sent successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Send Notification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownSearch<User>(
              selectedItem: selectedUser,
              items: (String filter, LoadProps? props) async {
                final users = await fetchUsers(); // your API call
                if (filter.isEmpty) return users;
                // Optional: basic local filtering
                return users
                    .where(
                      (u) => u.displayname.toLowerCase().contains(
                        filter.toLowerCase(),
                      ),
                    )
                    .toList();
              },
              itemAsString: (User u) => u.displayname,
              onChanged: (User? user) {
                setState(() => selectedUser = user);
              },
              compareFn: (a, b) => a.username == b.username,
              dropdownBuilder:
                  (context, selectedItem) => Text(
                    selectedItem?.displayname ?? "Select user",
                    style: TextStyle(fontSize: 16),
                  ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Search user...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Notification Title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: "Notification Message",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    sendNotification();
                  },
                  child: Text(
                    'Send',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
