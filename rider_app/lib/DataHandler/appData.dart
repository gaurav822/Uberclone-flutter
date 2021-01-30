import 'package:flutter/cupertino.dart';
import 'package:rider_app/Models/address.dart';

class AppData extends ChangeNotifier
{

  Address pickupLocation, dropoffLocation;
  

  void updatePickupLocationAddres(Address pickupAddres){

    pickupLocation=pickupAddres;
    notifyListeners();
  }

   void updatedropoffLocationAddres(Address dropoffAddress){

    dropoffLocation=dropoffAddress;
    notifyListeners();
  }

}