import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:seks/classes/encounter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './user.dart';

class AuthService with ChangeNotifier {
  late GoogleSignInAccount _googleUser;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _userFromAuth(auth.User? user) {
    if (user == null) {
      return null;
    }
    return User(id: user.uid, displayName: user.displayName ?? '', email: user.email ?? '');
  }

  Stream<User?>? get user {
    return _auth.authStateChanges().map(_userFromAuth);
  }

  Future<User?> googleSignIn() async {
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      _googleUser = googleUser;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      await _auth.signInWithCredential(credential);
      notifyListeners();
      return _userFromAuth(_auth.currentUser);
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  List<Encounter> encountersList = [];
  Map<String, List<Encounter>> encounterMap = {};

  void calendarData() {
    Map<String, List<Encounter>> dates_ = {};
    for (Encounter item in encountersList) {
      String date = formatDate(item.date, formatType: dateFormatType.moment);
      if (dates_[date] == null) {
        dates_[date] = [item];
      } else {
        dates_[date]?.add(item);
      }
    }
    encounterMap = dates_;
    notifyListeners();
  }

  void setEncounters(List<Encounter> initialEncounters){
    encountersList = initialEncounters;
    encountersList.sort((a, b) => a.date < b.date ? 1 : 0);
    notifyListeners();
    calendarData();
  }

  void addEncounter(Encounter newEncounter) {
    encountersList.add(newEncounter);
    encountersList.sort((a, b) => a.date < b.date ? 1 : 0);
    notifyListeners();
    calendarData();
  }

  Future deleteEncounter(String id, int index) async {
    var user_ = auth.FirebaseAuth.instance.currentUser;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (user_ != null) {
      var dbData = FirebaseFirestore.instance.collection('users').doc(user_.uid);
      await dbData.collection('encounters').doc('encounter_$id').delete();
    }
    encountersList.removeAt(index);
    await preferences.remove('encounter_$id');
    notifyListeners();
    calendarData();
  }

  Future editEncounter(int index, Encounter newEncounter)async{
    encountersList[index] = newEncounter;
    notifyListeners();
    calendarData();
  }

  void clearEncounters() {
    encountersList = [];
    encounterMap = {};
    notifyListeners();
  }
}
