import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Screens/home.dart';
import 'package:rider_app/Screens/loginscreen.dart';
import 'package:rider_app/Screens/registrationScreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference usersRef= FirebaseDatabase.instance.reference().child("Users");

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

  
    return ChangeNotifierProvider(  //wrapping mateerialapp with Change notfier so that data can be retrieve in all screens
      create: (context)=>AppData(),
          child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
      
        theme: ThemeData(
          // fontFamily: "Signatra",
          primarySwatch: Colors.blue,

          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: MainScreen.idScreen,
        routes: {
          RegistrationScreen.idScreen :(context)=> RegistrationScreen(),
          LoginScreen.idScreen :(context)=> LoginScreen(),
          MainScreen.idScreen :(context)=> MainScreen(),
        },
      ),
    );
  }
}

