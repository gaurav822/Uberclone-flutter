import 'package:flutter/cupertino.dart';
import 'package:rider_app/Models/address.dart';

class AppData extends ChangeNotifier
{

  Address pickupLocation;
  

  void updatePickupLocationAddres(Address pickupAddres){

    pickupLocation=pickupAddres;
    notifyListeners();
  }

}