library iflabapi;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureRequestResponse {
  // ignore: non_constant_identifier_names
  Map<String, dynamic> Meta;

  // ignore: non_constant_identifier_names
  Map<String, dynamic> Data;
  int statusCode;

  SecureRequestResponse({meta, data, sc}) {
    Meta = meta;
    Data = data;
    statusCode = sc;
  }

  Iterable<String> getMetaKey() {
    return Meta.keys;
  }

  Iterable<String> getDataKey() {
    return Data.keys;
  }
}

///This class is purposed to Make Request using
///Secure Auth From Auth Class, you must do Auth before using this
class SecureRequest {
  String _resourceURL;
  final _sk = '__api-auth-q';
  final _storage = new FlutterSecureStorage();

  SecureRequest({String url = 'http://api.infotech.umm.ac.id/api/v1/'}) {
    _resourceURL = url;
  }

  ///Secure HTTP Request to our Endpoint, use method(["path1", "path2"])
  ///instead of making new variable
  Future<SecureRequestResponse> get(List<String> path) async {
    var response = await http.get(_resourceURL + parsePath(path),
        headers: {'cookie': await _storage.read(key: _sk)});

    return _parseResponse(response);
  }

  ///Secure HTTP Request to our Endpoint, use method(["path1", "path2"])
  ///instead of making new variable
  Future<SecureRequestResponse> post(List<String> path, {body}) async {
    var response = await http.post(_resourceURL + parsePath(path),
        body: body, headers: {'cookie': await _storage.read(key: _sk)});

    return _parseResponse(response);
  }

  ///Secure HTTP Request to our Endpoint, use method(["path1", "path2"])
  ///instead of making new variable
  Future<SecureRequestResponse> put(List<String> path, {body}) async {
    var response = await http.put(_resourceURL + parsePath(path),
        body: body, headers: {'cookie': await _storage.read(key: _sk)});

    return _parseResponse(response);
  }

  ///Secure HTTP Request to our Endpoint, use method(["path1", "path2"])
  ///instead of making new variable
  Future<SecureRequestResponse> delete(List<String> path, {body}) async {
    var response = await http.delete(_resourceURL + parsePath(path),
        headers: {'cookie': await _storage.read(key: _sk)});

    return _parseResponse(response);
  }

  String parsePath(List<String> path) {
    String realPath = "";
    path.forEach((element) {
      realPath += element + "/";
    });

    return realPath;
  }

  SecureRequestResponse _parseResponse(http.Response response) {
    var dec = json.decode(response.body);

    return new SecureRequestResponse(
      meta: dec["Meta"],
      data: dec["Data"],
      sc: response.statusCode,
    );
  }
}

///Auth Class purposed to Get Auth-Token which can used for All Infotech API
///you can change the URL for make debug or hit to demo Infotech API URLs
class Auth {
  String _client;
  String _clientSecret;
  String _username;
  String _password;
  String _url;

  String _message;

  final _sk = '__api-auth-q';
  final _storage = new FlutterSecureStorage();

  Auth({
    @required String client,
    @required String secret,
    @required String username,
    @required String password,
    String url = 'http://api.infotech.umm.ac.id/auth/',
  }) {
    _client = client;
    _clientSecret = secret;
    _username = username;
    _password = password;
    _url = url;
  }

  ///This method will return false if no user logged and vice versa,
  ///you can parse message for make sure is user present or not
  Future<bool> checkAuth() async {
    String value = await _storage.read(key: _sk);
    _message = "user credential is not present, please re-auth";
    if (value.isEmpty) {
      return false;
    }

    _message = "user credential is present";
    return true;
  }

  ///Method for get Auth-Token and Save to Secure Storage
  ///you can call this method after go with Auth Constructor
  ///This will return true if authorized and vice versa
  Future<bool> authorize() async {
    var response = await http.post(
      _url,
      body: json.encode({
        "UserName": _username,
        "Password": _password,
      }),
      headers: {
        "IFX-CLIENT": _client,
        "IFX-SECRET": _clientSecret,
      },
    );

    _message = response.body;
    if (response.statusCode != 200) {
      return false;
    }

    if (response.headers['set-cookie'].isNotEmpty) {
      final storage = new FlutterSecureStorage();
      await storage.write(
        key: _sk,
        value: _parseToRequestCookie(response),
      );
    }

    return true;
  }

  ///Method for parsing set-cookie response header from server and
  ///serve to cookie at request header
  String _parseToRequestCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    var c = rawCookie.split(",");
    var s = "";

    c.forEach((el) {
      if (el != null) {
        int index = rawCookie.indexOf(';');
        s += (index == -1) ? el : el.substring(0, index) + ";";
      }
    });

    return s;
  }

  ///Method for get Message from Server after Request
  String getMessage() {
    return _message;
  }
}
