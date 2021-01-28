import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/Assistants/assistantMethods.dart';
import 'package:rider_app/Custom_Widgets/Divider.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Screens/searchScreen.dart';

class MainScreen extends StatefulWidget {
   static const String idScreen="mainScreen"; 
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldKey= new GlobalKey<ScaffoldState>();

  Position currentPosition;
  Geolocator geoLocator = Geolocator();

  double bottomPaddingofMap=0;


  void locatePosition() async{
    Position position= await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition= position;

    LatLng latLngPosition =LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition= new CameraPosition(target: latLngPosition,zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address= await AssistantMethods.searchCoordinateAddress(position,context);
    print("This is your address"+address);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: _appBar(),

      drawer: _myDrawer(),

      body: Stack(
        children: [
         

          googleMapViewer(),

          //hamburgerButton for Drawer

          Positioned(
              top: 45.0,
              left: 22.0,
              child: GestureDetector(
                onTap: (){
                  scaffoldKey.currentState.openDrawer();
                },
                              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6,
                      spreadRadius: 0.5,
                      offset: Offset(0.7,0.7)
                    )
                  ]
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.menu,color: Colors.black,),
                  radius: 20.0,
                ),
            ),
              ),
          ),

          bottomContainer(),

          
        ],
      ),
      
    );
  }

  Widget _myDrawer(){
    return Container(
      color: Colors.white,
      child: Drawer(
        child: ListView(
          children: [
            Container(
              color: Colors.white,
              height: 165.0,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Image.asset("images/user_icon.png",height: 65,width: 65,),
                    SizedBox(width: 16,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Profile Name",style: TextStyle(fontSize: 16,fontFamily: "Brand Bold"),),
                        SizedBox(
                          height: 6,
                        ),

                        Text("Visit Profile"),
                      ],
                    )
                  ],
                ),
              ),

            ),

            Divider(),

            SizedBox(
              height: 12.0,
            ),

            //Drawer body Controller

            ListTile(
              leading: Icon(Icons.history),
              title: Text("History",style: TextStyle(fontSize: 16),),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Visit Profile",style: TextStyle(fontSize: 16),),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("About",style: TextStyle(fontSize: 16),),
            ),
           
          ],
        ),
      ),
    );
  }

    Widget googleMapViewer(){
     return GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingofMap),
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            mapType: MapType.normal,myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller){
              _controllerGoogleMap.complete(controller);
              newGoogleMapController=controller;
              setState(() {
                bottomPaddingofMap=300;
              });
              locatePosition();
            },
          );
  }

  Widget bottomContainer(){
    BoxDecoration boxDecoration = BoxDecoration(
      color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(18),topRight: Radius.circular(18)),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7,0.7)
                  )
                ]
    );
          return Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(

              height: 300.0,
              decoration: boxDecoration, 
              
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6,),
                    Text("Hi there, ",style: TextStyle(fontSize: 12.0),),
                    Text("Where to? ",style: TextStyle(fontSize: 20.0,fontFamily: "Brand Bold"),),
                    SizedBox(height: 20,),
                    GestureDetector(
                          onTap: (){
                            // print("Hello");
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchScreen()));
                          },
                          child: Container(
                        decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0),

                        boxShadow: [
                         BoxShadow(
                         color: Colors.black54,
                          blurRadius: 6.0,
                          spreadRadius: 0.5,
                          offset: Offset(0.7,0.7)
                  )
                ] 
              ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.search,color: Colors.blueAccent,),
                              SizedBox(width: 10,),
                              Text("Search Drop Off")
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox( height: 24,),

                    Row(
                      children: [
                        Icon(Icons.home,color: Colors.grey),
                        SizedBox(width: 12.0,), 

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(
                                Provider.of<AppData>(context).pickupLocation != null ?
                                Provider.of<AppData>(context).pickupLocation.placeName:

                                "Add Home"

                              ),
                              SizedBox(height: 4,),
                              Text("Your living home address",style: TextStyle(color: Colors.black54,fontSize: 12),),
                          ],
                        )
                      ],
                    ),

                    SizedBox( height: 10,),

                    DividerWidget(),

                    SizedBox(
                      height: 16,
                    ),

                    Row(
                      children: [
                        Icon(Icons.work,color: Colors.grey),
                        SizedBox(width: 12.0,),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text("Add Work"),
                              SizedBox(height: 4,),
                              Text("Your office address",style: TextStyle(color: Colors.black54,fontSize: 12),),
                              
                          ],
                        )
                      ],
                    ),


                  ],
                ),
              ),
              
            ),
          );
  }

  Widget _appBar(){
    return AppBar(
      title: Text("Rider App"),
      centerTitle: true,
    );
  }
}