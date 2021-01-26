import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: Column(
          children: [
            SizedBox(
              // height: 45,
              height: 35
            ),

            Image(
              image: AssetImage("images/logo.png"),
              height: Get.height*.38,
                width: Get.height*.4,
                alignment: Alignment.center,
            ),

            Text(
              "Login as a Rider",
              style: TextStyle(fontSize: 24.0,fontFamily: "Brand Bold"),
              
            ),

            SizedBox(
              height: 1.0,
            ),

            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(
                  fontSize: 14.0,

                ),
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 10.0
                )
              ),
              style: TextStyle(
                fontSize: 14
              ),
              
            )
           
          ],
        ),
      ),
    );
  }
}