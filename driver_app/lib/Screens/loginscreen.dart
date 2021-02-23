import 'package:driver_app/configMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:driver_app/Custom_Widgets/progressdialog.dart';
import 'package:driver_app/Screens/home.dart';
import 'package:driver_app/Screens/registrationScreen.dart';
import 'package:driver_app/main.dart';

// ignore: must_be_immutable
class LoginScreen extends StatelessWidget {
    static const String idScreen="login";
      TextEditingController emailTextEditingController= TextEditingController();
      TextEditingController passwordTextEditingController= TextEditingController();

  FToast fToast;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,

      body: Center(
        child: SingleChildScrollView(
            child: Padding(
            padding:  EdgeInsets.all(8.0),
            child: Column(
              children: [
                

                Image(
                  image: AssetImage("images/logo.png"),
                  height: Get.height*.38,
                    width: Get.height*.4,
                    alignment: Alignment.center,
                ),

                Text(
                  "Login as a Driver",
                  style: TextStyle(fontSize: 24.0,fontFamily: "Brand Bold"),
                  
                ),

                

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 1.0,
                       ),
                      _formField(
                        labeltext: "Email",
                        obsecure: false,
                        tit: TextInputType.emailAddress,
                        controller: emailTextEditingController
                      ),
                      SizedBox(
                      height: 10.0,
                      ),
                      _formField(
                         labeltext: "Password",
                         obsecure: true,
                         controller: passwordTextEditingController

                      ),

                      SizedBox(
                        height: Get.height*.05,
                      ),

                      RaisedButton(
                        color: Colors.yellow.shade600,
                        textColor: Colors.white,
                        child: Container(
                          height: 50.0,
                          child: Center(child: Text("Login",style: TextStyle(fontSize: 18,fontFamily: "Brand Bold "),)),
                        ),

                        shape: new RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)
                        ),

                        onPressed: (){
                          if(!emailTextEditingController.text.contains("@")){
                            showCustomToast("Invalid email address", context, Icons.error, Colors.red);
                          }
                          else if(passwordTextEditingController.text.isEmpty){
                            showCustomToast("Password is Required", context, Icons.error, Colors.red);
                          }

                          else{
                            loginandAuthenticateUser(context);
                          }
                          
                        },
                      ),
                    ],
                  ),
                ),

                FlatButton(
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, RegistrationScreen.idScreen, (route) => false);
                  },
                  child: Text("Do not have an Account? Register here"),
                ), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formField({String labeltext, bool obsecure, TextInputType tit, TextEditingController controller}){

        return TextField(
          controller: controller,
              obscureText: obsecure,
              keyboardType: tit,
              decoration: InputDecoration(
              labelText: labeltext,
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
              
            );
  }

  void loginandAuthenticateUser(BuildContext context)async{
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)
      {
        return ProgressDialog(message:"Authenticating, Please wait...");
      }

    );
    final User firebaseUser = (await _firebaseAuth
     .signInWithEmailAndPassword( 
       email: emailTextEditingController.text, 
       password: passwordTextEditingController.text
    ).catchError((errorMsg) async{
      Navigator.pop(context);
      showCustomToast("Error"+errorMsg.toString(), context, Icons.error, Colors.red);
    })).user;

    if(firebaseUser!=null){

      
      driversRef.child(firebaseUser.uid).once().then((DataSnapshot snap) async{
        if(snap.value!=null){
          currentfirebaseUser=firebaseUser;
          Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
          Fluttertoast.showToast(msg: "Logged in Successful");
        }

        else{
           Navigator.pop(context);
          _firebaseAuth.signOut();
          Fluttertoast.showToast(msg: "No Record ! Please create new account");
        }
      });
    
      
    }

    else{
      //display error message
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error occoured! Cannot Sign in");
    }
  }


  showCustomToast(String customToast, BuildContext context, IconData icon, Color color) {
    fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
        ),
        child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
            Icon(icon),
            SizedBox(
            width: 12.0,
            ),
            Flexible(child: Text(customToast,style: TextStyle(color: Colors.white,))),
        ],
        ),

        
    );


    fToast.showToast(
        child: toast,
        gravity: ToastGravity.BOTTOM,
        toastDuration: Duration(seconds: 2),
    );
  
}


}