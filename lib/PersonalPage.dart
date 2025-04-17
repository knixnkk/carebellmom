import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'main.dart';
import 'dart:math';

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
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
    print(userJson.toString()); // Log the userJson for debugging
    print(
      pow(2, (userJson?.length ?? 0)).toString(),
    ); // Log the calculated height for debugging
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => IntroPage()), // or LoginPage()
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
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (userJson == null) {
      return const Center(child: Text("User data not found."));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 35.0),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          flex: 100,
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  String key = userJson!.keys.elementAt(index);
                  String titleText = "";
                  String bodyText = userJson![key]?.toString() ?? '';
                  if (bodyText == "") {
                    return SizedBox.shrink();
                  }
                  if (key == "username") {
                    titleText = "ชื่อผู้ใช้ (Username)";
                  } else if (key == "display_name") {
                    return SizedBox.shrink(); // Skip "display_name"
                  } else if (key == "lastNotify") {
                    return SizedBox.shrink(); // Skip "lastNotify"
                  } else if (key == "action") {
                    return SizedBox.shrink();
                  } else if (key == "GA") {
                    titleText = "อายุครรภ์ (Gestational Age)";
                    int totalDays =
                        int.tryParse(userJson![key]?.toString() ?? '0') ?? 0;
                    int weeks = totalDays ~/ 7;
                    int days = totalDays % 7;
                    bodyText = "$weeks สัปดาห์ $days วัน";
                  } else if (key == "EDC") {
                    titleText = "วันครบกำหนดคลอด (Due Date)";
                  } else if (key == "lastMenstrualPeriod") {
                    titleText = "วันแรกของประจำเดือน (LMP)";
                    DateTime lmpDate = DateTime.parse(userJson![key]);
                    bodyText =
                        "${lmpDate.day}/${lmpDate.month}/${lmpDate.year}";
                  } else if (key == "trimester") {
                    titleText = "Trimester";
                  } else if (key == "childDate") {
                    titleText = "วันคลอด (Delivery Date)";
                    DateTime childDate = DateTime.parse(userJson![key]);
                    bodyText =
                        "${childDate.day}/${childDate.month}/${childDate.year}";
                  } else {
                    titleText = key;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 10.0,
                        ),
                        child: Text(
                          titleText,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 10.0,
                        ),
                        child: Text(
                          " $bodyText",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                        ),
                      ),
                      const Divider(thickness: 1.0, indent: 15, endIndent: 15),
                    ],
                  );
                }, childCount: userJson?.length ?? 0),
              ),
            ],
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
