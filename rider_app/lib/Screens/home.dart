import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/Assistants/assistantMethods.dart';
import 'package:rider_app/Custom_Widgets/Divider.dart';
import 'package:rider_app/Custom_Widgets/progressdialog.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/directionDetails.dart';
import 'package:rider_app/Screens/loginscreen.dart';
import 'package:rider_app/Screens/searchScreen.dart';
import 'package:rider_app/configMaps.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  DirectionDetails tripdirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Position currentPosition;
  Geolocator geoLocator = Geolocator();

  double bottomPaddingofMap = 0;

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  double rideDetailsContainerHeight = 0;
  double requestrideContainerHeight = 0;
  double searchContainerHeight = 300.0;

  bool drawerOpen = true;

  DatabaseReference rideRequestReference;

  @override
  void initState() {
    
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest() {
    rideRequestReference =
        FirebaseDatabase.instance.reference().child("Ride Requests").push();

    var pickUp = Provider.of<AppData>(context, listen: false).pickupLocation;
    var dropOff = Provider.of<AppData>(context, listen: false).dropoffLocation;

    Map pickupLocationMap = {
      "latitude": pickUp.laltitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };

    Map dropoffLocationMap = {
      "latitude": dropOff.laltitude.toString(),
      "longitude": dropOff.longitude.toString(),
    };

    Map rideinfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickupLocationMap,
      "dropoff": dropoffLocationMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo.name,
      "rider_phone": userCurrentInfo.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropOff.placeName
    };

    rideRequestReference.set(rideinfoMap);
  }

  void cancelRideRequest() {
    rideRequestReference.remove();
  }

  void displayRequestRideContainer() {
    setState(() {
      requestrideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingofMap = 230.0;
      drawerOpen = true;
    });

    saveRideRequest();
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingofMap = 230.0;
      requestrideContainerHeight = 0;
      polylineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      pLineCoordinates.clear();
    });

    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 240.0;
      bottomPaddingofMap = 230.0;
      drawerOpen = false;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("This is your address" + address);
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
            top: 38.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                if (drawerOpen) {
                  scaffoldKey.currentState.openDrawer();
                } else {
                  resetApp();
                }
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
                          offset: Offset(0.7, 0.7))
                    ]),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    (drawerOpen) ? Icons.menu : Icons.close,
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),

          bottomContainer(),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: AnimatedSize(
              vsync: this,
              curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(
                height: rideDetailsContainerHeight,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 17),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.tealAccent[100],
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Image.asset(
                                "images/taxi.png",
                                height: 70.0,
                                width: 80.0,
                              ),
                              SizedBox(
                                width: 16.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Car",
                                    style: TextStyle(
                                        fontSize: 18, fontFamily: "Brand Bold"),
                                  ),
                                  Text(
                                    ((tripdirectionDetails != null)
                                        ? tripdirectionDetails.distanceText
                                        : ''),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Brand Bold",
                                        color: Colors.grey),
                                  )
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                ((tripdirectionDetails != null)
                                    ? '\Rs.${AssistantMethods.calculateFares(tripdirectionDetails)}'
                                    : ''),
                                style: TextStyle(fontFamily: "Brand Bold"),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.moneyCheckAlt,
                                size: 18, color: Colors.black54),
                            SizedBox(
                              width: 16,
                            ),
                            Text("Cash"),
                            SizedBox(
                              width: 6,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black54,
                              size: 16,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: RaisedButton(
                          onPressed: () {
                            displayRequestRideContainer();
                          },
                          color: Theme.of(context).accentColor,
                          child: Padding(
                            padding: EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Request",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Icon(
                                  FontAwesomeIcons.taxi,
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
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 0.5,
                        blurRadius: 16,
                        color: Colors.black54,
                        offset: Offset(0.7, 0.7))
                  ]),
              height: requestrideContainerHeight,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ColorizeAnimatedTextKit(
                        onTap: () {
                          print("Tap Event");
                        },
                        text: [
                          "Requesting a Ride",
                          "Please wait...",
                          "Finding a Driver",
                        ],
                        textStyle:
                            TextStyle(fontSize: 55.0, fontFamily: "Signatra"),
                        colors: [
                          Colors.green,
                          Colors.purple,
                          Colors.pink,
                          Colors.blue,
                          Colors.yellow,
                          Colors.red,
                        ],
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 22),
                    GestureDetector(
                      onTap: () {
                        cancelRideRequest();
                        resetApp();
                      },
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(width: 2, color: Colors.grey[300]),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 26,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      child: Text(
                        "Cancel Ride",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _myDrawer() {
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
                    Image.asset(
                      "images/user_icon.png",
                      height: 65,
                      width: 65,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Profile Name",
                          style:
                              TextStyle(fontSize: 16, fontFamily: "Brand Bold"),
                        ),
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
              title: Text(
                "History",
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                "Visit Profile",
                style: TextStyle(fontSize: 16),
              ),
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text(
                "About",
                style: TextStyle(fontSize: 16),
              ),
            ),

            GestureDetector(
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                    context, LoginScreen.idScreen, (route) => false);
                Fluttertoast.showToast(msg: "Logged out Successfully!");
              },
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text(
                  "Sign Out",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget googleMapViewer() {
    return GoogleMap(
      padding: EdgeInsets.only(bottom: bottomPaddingofMap),
      myLocationEnabled: true,
      zoomGesturesEnabled: true,
      zoomControlsEnabled: true,
      polylines: polylineSet,
      markers: markersSet,
      circles: circlesSet,
      mapType: MapType.normal,
      myLocationButtonEnabled: true,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controllerGoogleMap.complete(controller);
        newGoogleMapController = controller;
        setState(() {
          bottomPaddingofMap = 300;
        });
        locatePosition();
      },
    );
  }

  Widget bottomContainer() {
    BoxDecoration boxDecoration = BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18), topRight: Radius.circular(18)),
        boxShadow: [
          BoxShadow(
              color: Colors.black,
              blurRadius: 16.0,
              spreadRadius: 0.5,
              offset: Offset(0.7, 0.7))
        ]);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedSize(
        vsync: this,
        curve: Curves.bounceIn,
        duration: new Duration(milliseconds: 160),
        child: Container(
          height: searchContainerHeight,
          decoration: boxDecoration,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 6,
                ),
                Text(
                  "Hi there, ",
                  style: TextStyle(fontSize: 12.0),
                ),
                Text(
                  "Where to? ",
                  style: TextStyle(fontSize: 20.0, fontFamily: "Brand Bold"),
                ),
                SizedBox(
                  height: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    // print("Hello");
                    var res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchScreen()));

                    if (res == "obtainDirection") {
                      displayRideDetailsContainer();
                    }
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
                              offset: Offset(0.7, 0.7))
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.blueAccent,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Search Drop Off")
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 24,
                ),
                Row(
                  children: [
                    Icon(Icons.home, color: Colors.grey),
                    SizedBox(
                      width: 12.0,
                    ),
                    Flexible(
                                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              Provider.of<AppData>(context).pickupLocation != null
                                  ? Provider.of<AppData>(context)
                                      .pickupLocation
                                      .placeName
                                  : "Add Home"),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "Your living home address",
                            style: TextStyle(color: Colors.black54, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                DividerWidget(),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Icon(Icons.work, color: Colors.grey),
                    SizedBox(
                      width: 12.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Add Work"),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          "Your office address",
                          style: TextStyle(color: Colors.black54, fontSize: 12),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return AppBar(
      title: Text("Rider App"),
      centerTitle: true,
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickupLocation;

    var finalPos = Provider.of<AppData>(context, listen: false).dropoffLocation;

    var pickLatLong = LatLng(initialPos.laltitude, initialPos.longitude);

    var dropoffLatLong = LatLng(finalPos.laltitude, finalPos.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: "Please wait...",
            ));

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickLatLong, dropoffLatLong);

    setState(() {
      tripdirectionDetails = details;
    });

    Navigator.pop(context);

    print("This is encoded points");

    print(details.encodedPoints);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);

    pLineCoordinates.clear();

    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
          color: Colors.pink,
          polylineId: PolylineId("PolylineId"),
          jointType: JointType.round,
          points: pLineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true);

      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;

    if (pickLatLong.latitude > dropoffLatLong.latitude &&
        pickLatLong.longitude > dropoffLatLong.longitude) {
      latLngBounds =
          LatLngBounds(southwest: dropoffLatLong, northeast: pickLatLong);
    } else if (pickLatLong.longitude > dropoffLatLong.longitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(pickLatLong.latitude, dropoffLatLong.longitude),
          northeast: LatLng(dropoffLatLong.latitude, pickLatLong.longitude));
    } else if (pickLatLong.latitude > dropoffLatLong.latitude) {
      latLngBounds = LatLngBounds(
          southwest: LatLng(dropoffLatLong.latitude, pickLatLong.longitude),
          northeast: LatLng(pickLatLong.latitude, dropoffLatLong.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: pickLatLong, northeast: dropoffLatLong);
    }

    newGoogleMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker pickupLocmarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "my Location"),
      position: pickLatLong,
      markerId: MarkerId("pickUpId"),
    );

    Marker dropoffLocmarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: finalPos.placeName, snippet: "Drop Off Location"),
      position: dropoffLatLong,
      markerId: MarkerId("dropOffId"),
    );

    setState(() {
      markersSet.add(pickupLocmarker);
      markersSet.add(dropoffLocmarker);
    });

    Circle pickUpLocCircle = Circle(
        fillColor: Colors.blueAccent,
        center: pickLatLong,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.blueAccent,
        circleId: CircleId("pickUpId"));

    Circle dropOffLocCircle = Circle(
        fillColor: Colors.deepPurple,
        center: dropoffLatLong,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.deepPurple,
        circleId: CircleId("dropOffId"));

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });
  }
}
