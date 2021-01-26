import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
   static const String idScreen="mainScreen"; 
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: _appBar(),
      
    );
  }

  Widget _appBar(){
    return AppBar(
      title: Text("Rider App"),
      centerTitle: true,
    );
  }
}