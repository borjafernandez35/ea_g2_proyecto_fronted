// ignore: file_names
import 'dart:async';
import 'dart:convert' show base64Url, json, jsonDecode;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:http/http.dart' as http;
import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/google_identity_services_web.dart'
    as gis;
import 'package:spotfinder/Resources/jwt.dart';
import '../Resources/jwt.dart' as jwt;
import 'dart:math';
import 'package:google_identity_services_web/oauth2.dart';

import '../Resources/jwt.dart';
import 'package:dio/dio.dart';

/// The scopes required by this application.
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

String generateState() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  return base64Url.encode(values);
}

String? storedState;

class SignInService {
  final GoogleSignIn _googleSignIn;
  late final IdConfiguration idConfiguration;
  final Dio dio = Dio();
  final String baseUrl = 'http://127.0.0.1:3000';

  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?
  String _contactText = '';
  String _token = '';
  String? _idToken;
  String? _accessToken;
  bool _isRegistered = false;
  //GoogleSignInAuthentication? _auth;
  // GoogleAccountsId _accountsId;

  SignInService({required String clientId})
      : _googleSignIn = GoogleSignIn(
          clientId: clientId,
          scopes: scopes,
        ) {
    idConfiguration = IdConfiguration(
      client_id: clientId,
      callback: (CredentialResponse response) {
        onCredentialResponse(response);
        _idToken = response.credential;
        print(
            "Credential!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!.........................................:${_idToken}");
      },
      use_fedcm_for_prompt: true,
    );
  }

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isAuthorized => _isAuthorized;
  String get contactText => _contactText;
  String get token => _token;
  String? get idToken => _idToken;
  String? get accessToken => _accessToken;
  bool get isRegistered => _isRegistered;

  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  Future<void> signInSilently() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();

      print("silently:${_currentUser}");
      if (_currentUser != null) {
        _isAuthorized = true;
        _updateIdToken();
      }
      print("User after silent sign-in: $_currentUser");
    } catch (e) {
      print("Error in signInSilently: $e");
    }
  }

  Future<void> onError(GoogleIdentityServicesError? error) async {
    print('Error! ${error?.type} (${error?.message})');
  }

  Future<void> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        _isAuthorized = true;
        _updateIdToken();
      }
      print("User after sign-in: $_currentUser");
    } catch (e) {
      print("Error in signIn: $e");
    }
  }

  void onTokenResponse(TokenResponse response) {
    _accessToken = response.access_token;
    print("Access Token: $_accessToken");
  }

  void _updateIdToken() async {
    if (_currentUser != null) {
      try {
        final auth = await _currentUser!.authentication;
        _idToken = auth.idToken;
      } catch (e) {
        print("Error getting idToken: $e");
      }
    }
  }

  Future<void> handleSignIn() async {
    print("handle alla vamoosss!!!");
    _idToken = accessToken ?? (await _currentUser?.authentication)?.accessToken;
    print("rellenarTOOOOOOOKKKEEEEEENNNNNN: ${_idToken}");
    try {
      if (kIsWeb) {
        print("Loading GIS SDK for web...");
        await gis.loadWebSdk();
        print("GIS SDK loaded.");
        //id.setLogLevel('debug');
        id.initialize(idConfiguration);
        //_auth = _currentUser!.authentication as GoogleSignInAuthentication?;
        //_idToken = _auth!.idToken;

        //print("Que es TokenClient: ${tokenClient}");

        print(
            "iniciiiiiaaaaaaaaaaaaaaaaa el putoooooooooo TOOOOOOOOKKKEEEEENNNNNNNN!!!!!!${_idToken}");

        id.prompt(onPromptMoment);

        // print("que me vas a decir si yo acabo de llegar: ${call}");

        final state = generateState();
        storedState = state;
        print("Generated state: $state");

        print(
            "iiiiiiidddddddddttttttooooooookkkkkkeeeeeeeeennnnnnnnn:${_idToken}");
        // print("esto es el id ${id}, esto es el idConfigutarion ${idConfiguration}");
        print("IdConfiguration initialized.");
        print("HANDLE SIGNINSERVICE: el token es ${_token}");
      } else {
        await signIn();
      }
    } catch (error) {
      print("Error in handleSignIn: $error");
    }
  }

  void onPromptMoment(PromptMomentNotification o) {
    final MomentType type = o.getMomentType();
    print("Prompt moment: ${type}");
  }

  Future<void> handleSignOut() => _googleSignIn.disconnect();

  void onCredentialResponse(CredentialResponse response) {
    final Map<String, dynamic>? payload =
        jwt.decodePayload(response.credential);
    if (payload != null) {
      _token = response.credential!;
      print("este si toca:${_token}");

      // Aquí puedes manejar el ID Token utilizando GoogleSignInAuthentication

      print("ID Token from GoogleSignInAuthentication: ${_idToken}");
    } else {
      print('Could not decode ${response.credential}');
    }
  }

  Future<bool> checkIfRegistered(String email) async {
    try {
      final response = await dio.get('$baseUrl/user/check-email/$email');

      print(
          'laaaaa rrrrrreeeeeeeesssspuesta eeeeesssssss :~$response, ye status code!!!!!${response.statusCode}, lleeeeevvvaaa estos datos: ${response.data}');

      if (response.statusCode == 200) {
        print("Response data type: ${response.data.runtimeType}");
        final Map<String, dynamic> data = response.data;
        print(
            'lllllllllllllllllllllloooooooooooooooooooooosssssssss daaaaaaaattttoooooooooossssss: $data');
        final bool isRegistered = data['isRegistered'];
        print(
            'RRRREEEEEEEEGGGGGGGIIIIIIISSSSSTTTTTRRRRRRRAAAAADDDDOOOOOO?????? $isRegistered');
        return isRegistered;
      } else {
        throw Exception(
            'Failed to check registration status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking registration status: $e');
      throw e;
    }
  }
}
