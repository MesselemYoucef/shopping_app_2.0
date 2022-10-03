import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;

  Future<void> signup(String email, String password) async {
    var url = Uri.https(
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCH4Z2ZLDia-6ETltU-mOXECPBOCxSQv8c");
    http.post(url);
  }
}
