import 'package:flutter/material.dart';

class User with ChangeNotifier{
  String id;
  String displayName;
  String email;

  User({
    required this.id,
    required this.displayName,
    required this.email
});
}