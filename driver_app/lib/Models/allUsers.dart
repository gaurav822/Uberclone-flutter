import 'package:firebase_database/firebase_database.dart';

class Users{

  String id;
  String email;
  String name;
  String phone;

  Users({this.id,this.email,this.name,this.phone});

  Users.fromSnapshots(DataSnapshot dataSnapshot)
  {

    id= dataSnapshot.key;
    // ignore: unnecessary_statements
    dataSnapshot.value["email"];
    // ignore: unnecessary_statements
    dataSnapshot.value["name"];
    // ignore: unnecessary_statements
    dataSnapshot.value["phone"];

  }

}