// ignore: file_names
import 'dart:async';
import 'dart:convert' show json;
//import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/google_identity_services_web.dart' as gis;

/// The scopes required by this application.
const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

void handleCredentialResponse(CredentialResponse response) {
    // Maneja la respuesta de las credenciales aquí
    if (response.credential != null) {
      print('Credential received: ${response.credential}');
      // Aquí puedes almacenar el token o manejar la autenticación
    } else {
      print('No credential received.');
    }
  }

class SignInService {
  final GoogleSignIn _googleSignIn;



  final IdConfiguration idConfiguration = IdConfiguration(
    client_id: '435863540335-3edtkmprvlpkb3j4ea522cvndn8mc7mr.apps.googleusercontent.com',
    callback: handleCredentialResponse, // Define el callback aquí
    use_fedcm_for_prompt: true,
  );

  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?
  String _contactText = '';

  SignInService({required String clientId})
      : _googleSignIn = GoogleSignIn(
          clientId: '435863540335-3edtkmprvlpkb3j4ea522cvndn8mc7mr.apps.googleusercontent.com',
          scopes: ['email', 'profile'],
        );

  GoogleSignInAccount? get currentUser => _currentUser;
  bool get isAuthorized => _isAuthorized;
  String get contactText => _contactText;

  Stream<GoogleSignInAccount?> get onCurrentUserChanged =>
      _googleSignIn.onCurrentUserChanged;

  Future<void> signInSilently() => _googleSignIn.signInSilently();

  

  Future<void> handleSignIn() async {
    try {
await gis.loadWebSdk();

  id.initialize(idConfiguration);
      //await _googleSignIn.signIn();
      id.setLogLevel('debug');
  id.prompt();
    } catch (error) {
      print(error);
    }
  }

  

  Future<void> handleSignOut() => _googleSignIn.disconnect();

  Future<void> handleAuthorizeScopes() async {
    final bool isAuthorized = await _googleSignIn.requestScopes(scopes);
    _isAuthorized = isAuthorized;
    if (isAuthorized) {
      await handleGetContact(_currentUser!);
    }
  }

  Future<void> handleGetContact(GoogleSignInAccount user) async {
    _contactText = 'Loading contact info...';
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      _contactText = 'People API gave a ${response.statusCode} '
          'response. Check logs for details.';
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data =
        json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    _contactText = namedContact != null
        ? 'I see you know $namedContact!'
        : 'No contacts to display.';
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => (contact as Map<Object?, dynamic>)['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final List<dynamic> names = contact['names'] as List<dynamic>;
      final Map<String, dynamic>? name = names.firstWhere(
        (dynamic name) =>
            (name as Map<Object?, dynamic>)['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }
}
