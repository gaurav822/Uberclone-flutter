import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rider_app/Custom_Widgets/progressdialog.dart';
import 'package:rider_app/Screens/home.dart';
import 'package:rider_app/Screens/loginscreen.dart';
import 'package:rider_app/main.dart';

// ignore: must_be_immutable
class RegistrationScreen extends StatelessWidget {
  static const String idScreen="register";
  TextEditingController nameTextEditingController= TextEditingController();
  TextEditingController emailTextEditingController= TextEditingController();
  TextEditingController phoneTextEditingController= TextEditingController();
  TextEditingController passwordTextEditingController= TextEditingController();

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
                  "Register as a Rider",
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
                        labeltext: "Name",
                        obsecure: false,
                        tit: TextInputType.text,
                        controller: nameTextEditingController
                      ),
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
                        height: 1.0,
                       ),
                      _formField(
                        labeltext: "Phone",
                        obsecure: false,
                        tit: TextInputType.phone,
                        controller: phoneTextEditingController
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
                          child: Center(child: Text("Create Account",style: TextStyle(fontSize: 18,fontFamily: "Brand Bold "),)),
                        ),

                        shape: new RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)
                        ),

                        onPressed: (){
                          if(nameTextEditingController.text.length<6){
                            showCustomToast("Name must be at least 5 Characters",context, Icons.error, Colors.red);
                          }

                          else if(!emailTextEditingController.text.contains("@")){
                            showCustomToast("Email address is Invalid", context,Icons.error, Colors.red);
                          }

                          else if(phoneTextEditingController.text.length!=10){
                            showCustomToast("Invalid Phone Number", context,Icons.error, Colors.red);
                          }

                           else if(passwordTextEditingController.text.length<7){
                            showCustomToast("Password must be at least 6 Characters", context,Icons.error, Colors.red);
                          }

                          else{
                            _createnewUser(context);
                          }
                          
                        },
                      ),
                    ],
                  ),
                ),

                FlatButton(
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.idScreen, (route) => false);
                  },
                  child: Text("Already have an Account? Login here"),
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

   void _createnewUser(BuildContext context) async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context)
      {
        return ProgressDialog(message:"Registering, Please wait...");
      }

    );
     final User firebaseUser = (await _firebaseAuth
     .createUserWithEmailAndPassword(
       email: emailTextEditingController.text, 
       password: passwordTextEditingController.text
    ).catchError((errorMsg){
      Navigator.pop(context);
      showCustomToast("Error: "+errorMsg.toString(), context, Icons.error,Colors.red);
    })).user;

    if(firebaseUser!=null){

      Map userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "phone": phoneTextEditingController.text.trim(),
      };
      usersRef.child(firebaseUser.uid).set(userDataMap);
      showCustomToast("Account Created Successfully", context, Icons.check,Colors.blue);
  
      Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
    }

    else{
      //display error message
      Navigator.pop(context);
      showCustomToast("New User has not been created", context, Icons.error, Colors.red);
    }
  }



  showCustomToast(String customToast, BuildContext context, IconData icon, Color color) {
    FToast fToast = FToast();
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
            Text(customToast,style: TextStyle(color: Colors.white,)),
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