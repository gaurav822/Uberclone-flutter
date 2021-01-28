import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/DataHandler/appData.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController pickuptextEditingController=TextEditingController();
  TextEditingController dropofftextEditingController=TextEditingController();
  @override
  Widget build(BuildContext context) {

    String placeAddress=Provider.of<AppData>(context).pickupLocation.placeName ??"";
    pickuptextEditingController.text=placeAddress;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 215,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6,
                  spreadRadius: 0.5,
                  offset: Offset(0.7,0.7)
                )
              ]

              
            ),

            child: Padding(
              padding: EdgeInsets.only(left: 25,top: 25,right: 25,bottom: 20),
              child: Column(
                children: [
                SizedBox(height: 5),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back)),

                    Center(
                      child: Text("Set Drop Off", style: TextStyle(fontSize: 18,fontFamily: "Brand Bold"),),
                    )

                  ],
                ),

                SizedBox(height: 16,),

                Row(
                  children: [
                    Image.asset("images/pickicon.png",height: 16,width: 16,),
                    SizedBox(
                      width: 18,
                    ),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[400],
                          borderRadius: BorderRadius.circular(5),
                        
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(3),
                          child: TextField(
                            controller: pickuptextEditingController,
                            decoration: InputDecoration(
                              hintText: "PickUp Location",
                              fillColor:  Colors.green[400],
                              filled: true,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(left: 11,top: 8,bottom: 8)
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),

                SizedBox(height: 10,),

                Row(
                  children: [
                    Image.asset("images/desticon.png",height: 16,width: 16,),
                    SizedBox(
                      width: 18,
                    ),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[400],
                          borderRadius: BorderRadius.circular(5),
                        
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(3),
                          child: TextField(
                            controller: dropofftextEditingController,
                            decoration: InputDecoration(
                              hintText: "Where to ?",
                              fillColor:  Colors.green[400],
                              filled: true,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(left: 11,top: 8,bottom: 8)
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),

              ],),
            ),
          )
        ],
      ),
      
    );
  }
}