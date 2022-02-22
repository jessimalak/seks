import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './user.dart';

enum AuthStatus {
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated
}

class AuthService with ChangeNotifier {
  late GoogleSignInAccount _googleUser;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _userFromAuth(auth.User? user) {
    if (user == null) {
      return null;
    }
    return User(
        id: user.uid,
        displayName: user.displayName ?? '',
        email: user.email ?? '');
  }

  Stream<User?>? get user {
    return _auth.authStateChanges().map(_userFromAuth);
  }

  Future<User?> googleSignIn() async{
    try{
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      _googleUser = googleUser;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      await _auth.signInWithCredential(credential);
      notifyListeners();
      return _userFromAuth(_auth.currentUser);
    }catch(e){
      print(e);
      return null;
    }
  }

  Future<void> signOut() async{
    return await _auth.signOut();
  }
}
