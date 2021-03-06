import 'package:driver_app/configMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:driver_app/DataHandler/appData.dart';
import 'package:driver_app/Screens/home.dart';
import 'package:driver_app/Screens/loginscreen.dart';
import 'package:driver_app/Screens/car_info_screen.dart';
import 'package:driver_app/Screens/registrationScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  currentfirebaseUser=FirebaseAuth.instance.currentUser;
  runApp(MyApp());
}

DatabaseReference usersRef= FirebaseDatabase.instance.reference().child("Users");
DatabaseReference driversRef= FirebaseDatabase.instance.reference().child("Drivers");
DatabaseReference rideRequestRef= FirebaseDatabase.instance.reference().child("Drivers").child(currentfirebaseUser.uid).child("newRide");

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

  
    return ChangeNotifierProvider(  //wrapping mateerialapp with Change notfier so that data can be retrieve in all screens
      create: (context)=>AppData(),
          child: MaterialApp(
        title: 'Taxi Driver App',
        debugShowCheckedModeBanner: false,
      
        theme: ThemeData(
          // fontFamily: "Signatra",
          primarySwatch: Colors.blue,

          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute:FirebaseAuth.instance.currentUser==null? LoginScreen.idScreen: MainScreen.idScreen,
        routes: {
          RegistrationScreen.idScreen :(context)=> RegistrationScreen(),
          LoginScreen.idScreen :(context)=> LoginScreen(),
          MainScreen.idScreen :(context)=> MainScreen(),
          CarInfoScreen.idScreen :(context)=> CarInfoScreen(),
        },
      ),
    );
  }
}

