// ignore: file_names
import 'dart:async';
import 'dart:convert' show base64Url, json, jsonDecode;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
//import 'package:get/get.dart'; Node Response, FormData, MultipartFile;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/google_identity_services_web.dart'
    as gis;
import 'package:spotfinder/Resources/jwt.dart' as jwt;
import 'dart:math';
import 'package:google_identity_services_web/oauth2.dart';

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
      saveToken(response.credential);
      print("este si toca:${_token}");

      // Aquí puedes manejar el ID Token utilizando GoogleSignInAuthentication

      print("ID Token from GoogleSignInAuthentication: ${_idToken}");
    } else {
      print('Could not decode ${response.credential}');
    }
  }

  Future<bool> checkIfRegistered(String email) async {
    try {
      final response = await Dio().get('$baseUrl/user/check-email/$email');

      print(
          'La respuesta es: $response, status code: ${response.statusCode}, datos: ${response.data}');

      if (response.statusCode == 200) {
        // Parsea la respuesta como un objeto JSON
        final dynamic responseData = response.data;

        if (responseData is Map<String, dynamic>) {
          print('Los datos: $responseData');

          if (responseData.containsKey('isEmailRegistered')) {
            final bool isRegistered = responseData['isEmailRegistered'];
            print('Registrado? $isRegistered');
            return isRegistered;
          } else {
            print(
                'La clave "isEmailRegistered" está ausente en los datos de la respuesta.');
            throw Exception(
                'Datos de respuesta inválidos: falta "isEmailRegistered"');
          }
        } else {
          print('La respuesta no es un mapa válido.');
          throw Exception('Datos de respuesta inválidos');
        }
      } else {
        throw Exception(
            'No se pudo verificar el estado de registro: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al verificar el estado de registro: $e');
      throw e;
    }
  }

  void saveId(String id) {
    final box = GetStorage();
    box.write('id', id);
  }

  void saveToken(String? token) {
    final box = GetStorage();
    box.write('token', token);
  }

   String? getId() {
    final box = GetStorage();
    return box.read('id');
  }

  String? getToken() {
    final box = GetStorage();
    return box.read('token');
  }

  Future<int> logIn(String email) async {
    print('LogIn');

    // Aquí podrías implementar lógica adicional si necesitas algún tipo de preparación antes de hacer la solicitud

    try {
      Response response = await dio.post(
          '$baseUrl/signin/google/$email'); // Aquí ajusta según la ruta y datos que necesites enviar

      var data = response.data.toString();
      print('Data: $data');

      var statusCode = response.statusCode;
      print('Status code: $statusCode');

      if (statusCode == 200 || statusCode == 201) {
        // Aquí manejas la respuesta exitosa según el código que esperas
        //var token = response.data['token'];
        //var refreshToken = response.data['refreshToken'];
        var id = response.data['id'];

        //saveToken(token, refreshToken);
        saveId(id);
        if(statusCode ==201){
          return 201;
        }
        return 200 ;
      } else if (statusCode == 400) {
      // Si hay campos faltantes, retornamos el código 400
      print('400');

      return 400;
    } else if (statusCode == 500) {
      // Si hay un error interno del servidor, retornamos el código 500
      print('500');

      return 500;
    }else {
      // En caso de otros códigos de estado no manejados explícitamente, puedes lanzar una excepción o devolver un valor adecuado.
      return -1; // O cualquier otro valor que refleje un estado no manejado
    }
    } catch (e) {
      // Manejo de errores, como problemas de conexión, etc.
      print('Error: $e');
      return -1; // Puedes definir otro código de error si es necesario
    }
  }
}
