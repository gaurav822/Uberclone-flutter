import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/Assistants/requestAssistant.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/address.dart';
import 'package:rider_app/configMaps.dart';

class AssistantMethods{

  static Future<String> searchCoordinateAddress(Position position,context) async{

    String placeAddress="";

    String st1,st2,st3,st4;

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
}