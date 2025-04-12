import 'package:flutter/material.dart';

class viewUserPage extends StatefulWidget {
  const viewUserPage({super.key});

  @override
  _viewUserPageState createState() => _viewUserPageState();
}

class _viewUserPageState extends State<viewUserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View User")),
      body: Center(child: Text("View User Page")),
    );
  }
}
