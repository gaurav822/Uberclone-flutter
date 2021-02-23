import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:driver_app/Assistants/requestAssistant.dart';
import 'package:driver_app/DataHandler/appData.dart';
import 'package:driver_app/Models/address.dart';
import 'package:driver_app/Models/allUsers.dart';
import 'package:driver_app/Models/directionDetails.dart';
import 'package:driver_app/configMaps.dart';

class AssistantMethods{

  static Future<String> searchCoordinateAddress(Position position,context) async{

    String placeAddress="";

    String url= "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";

    var response= await RequestAssistant.getRequest(url);

    if(response!="failed"){

      placeAddress = response["results"][0]["formatted_address"]; 

      // st1=response["results"][0]["address_components"][3]["long_name"];
      // st2=response["results"][0]["address_components"][4]["long_name"];
      // st3=response["results"][0]["address_components"][5]["long_name"];
      // st4=response["results"][0]["address_components"][6]["long_name"];

      // placeAddress=st1+", "+st2+", "+st3+ ", "+st4;

      Address userPickAddress = new Address();

      userPickAddress.longitude=position.longitude;
      userPickAddress.laltitude=position.latitude;
      userPickAddress.placeName=placeAddress;

      Provider.of<AppData>(context,listen: false).updatePickupLocationAddres(userPickAddress);
    }

    return placeAddress;


  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(LatLng initialPosition,LatLng finalPostion)async{
    String directionUrl= "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPostion.latitude},${finalPostion.longitude}&key=$mapKey";

    var res= await RequestAssistant.getRequest(directionUrl);

    if(res=="failed"){

      return null;
    }

    DirectionDetails directionDetails= DirectionDetails();

    directionDetails.encodedPoints=res["routes"][0]["overview_polyline"]["points"];

    directionDetails.distanceText=res["routes"][0]["legs"][0]["distance"]["text"];

    directionDetails.distanceValue=res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText=res["routes"][0]["legs"][0]["duration"]["text"];

    directionDetails.durationValue=res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;


  }

  static int calculateFares(DirectionDetails directionDetails){
    // interms of USD
    double timeTravelFare=(directionDetails.durationValue/60) * 0.20;

    double distanceTravelFare=(directionDetails.distanceValue/1000) * 0.20;

    double totalFareAmount= timeTravelFare+distanceTravelFare;

    // 1$ = 116

    double totalLocalAmount=totalFareAmount*40;  //converting to Indian currency

    return totalLocalAmount.truncate();


  }

  static void getCurrentOnlineUserInfo() async{

    firebaseUser =  FirebaseAuth.instance.currentUser;
    String userId=firebaseUser.uid;
    DatabaseReference reference= FirebaseDatabase.instance.reference().child("Users").child(userId);

    reference.once().then((DataSnapshot dataSnapShot){
      if(dataSnapShot.value!=null){
        userCurrentInfo= Users.fromSnapshots(dataSnapShot);
      }
    });
  }
}