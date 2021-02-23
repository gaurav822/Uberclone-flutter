import 'package:driver_app/configMaps.dart';
import 'package:driver_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

// ignore: must_be_immutable
class HomeTabPage extends StatefulWidget {
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController newGoogleMapController;

  Position currentPosition;

  Geolocator geoLocator = Geolocator();

  String driverStatusText = "Offline Now Go - Online  ";

  Color driverStatusColor = Colors.black;

  bool isDriverAvailable = false;

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // String address =
    //     await AssistantMethods.searchCoordinateAddress(position, context);
    // print("This is your address" + address);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GoogleMap(
        myLocationEnabled: true,
        // zoomGesturesEnabled: true,
        // zoomControlsEnabled: true,

        mapType: MapType.normal,
        myLocationButtonEnabled: true,
        initialCameraPosition: HomeTabPage._kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controllerGoogleMap.complete(controller);
          newGoogleMapController = controller;

          locatePosition();
        },
      ),

      // online offline driver container

      Container(
        height: 140,
        width: double.infinity,
        color: Colors.black54,
      ),

      Positioned(
        top: 60,
        left: 0,
        right: 0,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: RaisedButton(
              onPressed: () {
                if (isDriverAvailable == false) {
                  makeDriverOnlineNow();
                  getLocationLiveUpdates();
                  setState(() {
                    driverStatusColor = Colors.green;
                    driverStatusText = "Online Now";
                    isDriverAvailable = true;
                  });

                  Fluttertoast.showToast(
                      msg: "You are online now", backgroundColor: Colors.blue);
                } else {
                  setState(() {
                    driverStatusColor = Colors.black;
                    driverStatusText = "Offline Now Go - Online  ";
                    isDriverAvailable = false;
                  });
                  makeDriverOffline();
                  Fluttertoast.showToast(
                      msg: "You are Offline now", backgroundColor: Colors.blue);
                }
              },
              color: driverStatusColor,
              child: Padding(
                padding: EdgeInsets.all(17.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      driverStatusText,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Icon(
                      Icons.phone_android,
                      color: Colors.white,
                      size: 26,
                    )
                  ],
                ),
              ),
            ),
          ),
        ]),
      )
    ]);
  }

  void makeDriverOnlineNow() async {
    Position position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    Geofire.initialize("availableDrivers");
    Geofire.setLocation(currentfirebaseUser.uid, currentPosition.latitude,
        currentPosition.longitude);

    rideRequestRef.onValue.listen((event) {
      
    });
  }

  void getLocationLiveUpdates() {
    homeTabPageStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;

      if (isDriverAvailable == true) {
        Geofire.setLocation(
            currentfirebaseUser.uid, position.latitude, position.longitude);
      }

      LatLng latLng = LatLng(position.latitude, position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  void makeDriverOffline() {
    if(isDriverAvailable==true){
      Geofire.removeLocation(currentfirebaseUser.uid);
      rideRequestRef.onDisconnect();
      rideRequestRef.remove();
      rideRequestRef = null;
    }
  }
}
