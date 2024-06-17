import 'package:flutter/gestures.dart';
import 'package:google_identity_services_web/oauth2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Resources/jwt.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Widgets/button_sign_in.dart';
import 'package:spotfinder/Screens/login_screen.dart';
import 'package:spotfinder/Screens/register_screen.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Resources/sign_in_button.dart';
import 'package:spotfinder/Services/SignInService.dart';
import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/google_identity_services_web.dart'
    as gis;
import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/id.dart' as gis_id;
import 'package:google_identity_services_web/oauth2.dart';

late SignInService _signInService;

const List<String> scopes = <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
];

class TitleScreen extends StatefulWidget {
  @override
  _TitleScreenState createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  // late SignInService signInService;
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _contactText = '';
  String _token = '';
  late TokenClient tokenClient;
  late TokenClientConfig config;

  String idClient =
      '125785942229-p83mg0gugi4cebkqos62m6q2l86jabkc.apps.googleusercontent.com';

  @override
  void initState() {
    print("^*******************************************************");
    super.initState();

    _signInService = SignInService(
      clientId: idClient,
    );
    /* config = TokenClientConfig(
      client_id: idClient,
      scope: scopes,
      callback: signInService.onTokenResponse,
      error_callback: signInService.onError,
    );
 */

    _signInService.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        gis_id.id.setLogLevel('debug');
        gis_id.id.initialize(_signInService.idConfiguration);

        //print("Que es TokenClient: ${tokenClient}");

        print(
            "iniciiiiiaaaaaaaaaaaaaaaaa el putoooooooooo TOOOOOOOOKKKEEEEENNNNNNNN!!!!!!${_signInService.idToken}");

        gis_id.id.prompt(_signInService.onPromptMoment);

        //_handleSignIn();

        print("Sirve para algo?????, ${account}");

        _currentUser = account;
        
        
        // idToken=accessToken ?? (await _currentUser?.authentication)?.accessToken;;
        _isAuthorized = _signInService.isAuthorized;
        print("ojala funcione el token:${_signInService.idToken}");
        //Get.toNamed('/home');
      });
    });
    print("He salido!!");

    _signInService.signInSilently();

    //signInService.signIn();
  }

  Future<void> _handleSignIn() async {
    try {
      
      await _signInService.handleSignIn();
      //oauth2.initTokenClient(config);
      //Get.toNamed('/home');

      //tokenClient.requestAccessToken();
      if (_signInService.token.isNotEmpty) {
        setState(() {
          _token = _signInService.idToken ?? '';
          print("que te voy a decir si yo acabo de llegar: ${_token}");
        });
        // Navigate to HomePage after successful sign-in
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  Future<void> _handleSignOut() async {
    await _signInService.handleSignOut();
   // Get.toNamed('/');
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      // The user is Authenticated
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(identity: user),
            title: Text(user.displayName ?? ''),
            subtitle: Text('Token: ${_signInService.idToken}'),
            trailing: Text(user.email),
          ),
          const Text('Signed in successfully.'),
          if (_isAuthorized) ...<Widget>[
            // The user has Authorized all required scopes
            Text(_contactText),
            /* ElevatedButton(
              child: const Text('REFRESH'),
              onPressed: () => _handleGetContact(user),
            ), */
          ],
          if (!_isAuthorized) ...<Widget>[
            // The user has NOT Authorized all required scopes.
            const Text('Additional permissions needed to read your contacts.'),
            /* ElevatedButton(
              onPressed: _handleAuthorizeScopes,
              child: const Text('REQUEST PERMISSIONS'),
            ), */
          ],
          ElevatedButton(
            onPressed: _handleSignOut,
            child: const Text('SIGN OUT'),
          ),
        ],
      );
    } else {
      // The user is NOT Authenticated
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Google sign in.'),
          // This method is used to separate mobile from web code with conditional exports.
          // See: src/sign_in_button.dart
          buildSignInButton(
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? id = Get.arguments?['id'];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Fondo de pantalla
          Image.asset(
            'assets/background.png',
            fit: BoxFit.cover,
          ),
          // Contenido de la pantalla
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Logo de SpotFinder
              Image.asset(
                'assets/spotfinder.png',
                height: 200,
                width: 200,
              ),
              Container(
                margin: const EdgeInsets.all(
                  20,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Acción al presionar el botón
                    Get.toNamed('/login', arguments: {'id': id});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete
                        .salmonColor, // Cambia el color del botón a salmón
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 26, // Ajusta el tamaño del texto aquí
                      color: Colors.white, // Cambia el color del texto a blanco
                    ),
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                  children: [
                    const TextSpan(
                      text: "Don't have an account? ",
                    ),
                    TextSpan(
                      text: "Sign up",
                      style:  TextStyle(
                        color: Pallete.salmonColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration
                            .underline, // Subraya el texto "Sign up"
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.toNamed('/register', arguments: {'id': id});
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildBody(),
            ],
          ),
        ],
      ),
    );
  }
}
