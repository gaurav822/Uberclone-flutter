import 'dart:math';

import 'package:rider_app/Models/nearby_available_drivers.dart';

class GeoFireAssistant{

  static List<NearbyAvailableDrivers> nearbyAvailableDriversList=[];

  static void removeDriverfromList(String key){
    int index= nearbyAvailableDriversList.indexWhere((element) => element.key==key);

    nearbyAvailableDriversList.removeAt(index);
  }

  static void updateDriverNearbyLocation(NearbyAvailableDrivers driver){
    int index= nearbyAvailableDriversList.indexWhere((element) => element.key==driver.key);

    nearbyAvailableDriversList[index].latitude=driver.latitude;
    nearbyAvailableDriversList[index].longitude=driver.longitude;
  }


  
}