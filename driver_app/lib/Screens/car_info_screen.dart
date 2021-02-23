 import 'package:driver_app/Screens/home.dart';
import 'package:driver_app/configMaps.dart';
import 'package:driver_app/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// ignore: must_be_immutable
class CarInfoScreen extends StatelessWidget {
  static const String idScreen="carinfo";

  TextEditingController carModeltextEditingController= TextEditingController();
  TextEditingController carNumbertextEditingController= TextEditingController();
  TextEditingController carColortextEditingController= TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height:22),

              Image.asset("images/logo.png",width:390,height: 250,),

              Padding(
                padding: EdgeInsets.fromLTRB(22, 22, 22, 32),
                child: Column(
                  children: [
                    SizedBox(height: 12,),

                    Text("Enter Car Details",style: TextStyle(fontFamily: "Brand Bold",fontSize: 24),),

                    SizedBox(height: 26,),

                    _textField("Car Model", carModeltextEditingController),

                      SizedBox(height: 10,),

                    _textField("Car Number", carNumbertextEditingController),

                      SizedBox(height: 10,),

                    _textField("Car Color", carColortextEditingController),

                     SizedBox(height: 42,),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: RaisedButton(
                          onPressed: () {
                            if(carModeltextEditingController.text.isEmpty){
                              Fluttertoast.showToast(msg: "Please enter car model");
                            }

                            else if(carNumbertextEditingController.text.isEmpty){
                              Fluttertoast.showToast(msg: "Please enter car number");
                            }

                           else  if(carColortextEditingController.text.isEmpty){
                              Fluttertoast.showToast(msg: "Please enter car color");
                            }

                            else{
                              _saveDriverCarInfo(context);
                            }
                          },
                          color: Theme.of(context).accentColor,
                          child: Padding(
                            padding: EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "NEXT",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                  size: 26,
                                )
                              ],
                            ),
                          ),
                        ),
                      )



                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(String label,TextEditingController controller){

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintStyle: TextStyle(color: Colors.grey,fontSize: 10),
        
      ),
      style: TextStyle(fontSize: 15),
    );
  }

  void _saveDriverCarInfo(context){

    String userId= currentfirebaseUser.uid;

    Map carInfoMap={
      "car_color":carColortextEditingController.text,
      "car_number":carNumbertextEditingController.text,
      "car_model":carModeltextEditingController.text,

    };

    driversRef.child(userId).child("car_details").set(carInfoMap);

    Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);


  }
}