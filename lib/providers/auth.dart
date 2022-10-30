import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;

  bool get isAuth{
    return token != null;
  }


  String? get token{
    if(_expiryDate != null && _expiryDate!.isAfter(DateTime.now()) && _token != null){
      return _token!;
    }
    return null;
  }

  String? get userID{
    return _userId;
  }
  Future<void> _authenticate(
      String email, String password, String UrlSegment) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:${UrlSegment}?key=AIzaSyCH4Z2ZLDia-6ETltU-mOXECPBOCxSQv8c");
    try {
      final response = await http.post(url,
          body: json.encode({
            "email": email,
            "password": password,
            "returnSecureToken": true,
          }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null){
        throw HttpException(responseData['error']['message']);
      }
        _token = responseData['idToken'];
        _userId = responseData['localId'];
        _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
        notifyListeners();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, "signUp");
  }

  Future<void> singin(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }
}
