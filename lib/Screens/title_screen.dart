import 'package:flutter/gestures.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Widgets/button_sign_in.dart';
import 'package:spotfinder/Screens/login_screen.dart';
import 'package:spotfinder/Screens/register_screen.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Resources/sign_in_button.dart';
import 'package:spotfinder/Services/SignInService.dart';

late SignInService signInService;

class TitleScreen extends StatefulWidget {
  @override
  _TitleScreenState createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  late SignInService signInService;
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
     signInService = SignInService(clientId: '435863540335-3edtkmprvlpkb3j4ea522cvndn8mc7mr.apps.googleusercontent.com');
    signInService.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
        _isAuthorized = signInService.isAuthorized;
      });
      if (_currentUser != null && _isAuthorized) {
        _handleGetContact(_currentUser!);
      }
    });

    signInService.signInSilently();
  }

 
 Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = 'Loading contact info...';
    });

    try {
      await signInService.handleGetContact(user);
      setState(() {
        _contactText = signInService.contactText;
      });
    } catch (error) {
      setState(() {
        _contactText = 'Failed to load contacts.';
      });
    }
  }

  Future<void> _handleAuthorizeScopes() async {
    try {
      await signInService.handleAuthorizeScopes();
      setState(() {
        _isAuthorized = signInService.isAuthorized;
      });
      if (_currentUser != null && _isAuthorized) {
        _handleGetContact(_currentUser!);
      }
    } catch (error) {
      print('Error authorizing scopes: $error');
    }
  }

  Future<void> _handleSignIn() async {
    try {
      await signInService.handleSignIn();
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  Future<void> _handleSignOut() async {
    await signInService.handleSignOut();
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
            subtitle: Text(user.email),
          ),
          const Text('Signed in successfully.'),
          if (_isAuthorized) ...<Widget>[
            // The user has Authorized all required scopes
            Text(_contactText),
            ElevatedButton(
              child: const Text('REFRESH'),
              onPressed: () => _handleGetContact(user),
            ),
          ],
          if (!_isAuthorized) ...<Widget>[
            // The user has NOT Authorized all required scopes.
            const Text('Additional permissions needed to read your contacts.'),
            ElevatedButton(
              onPressed: _handleAuthorizeScopes,
              child: const Text('REQUEST PERMISSIONS'),
            ),
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
          const Text('You are not currently signed in.'),
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
                    Get.toNamed('/login',  arguments: {'id' : id});
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ElevatedButton.icon(
                  onPressed: _handleSignIn,
                  icon: Image.asset('assets/google-logo.png', height: 24, width: 24), // Icono de Google
                  label: const Text(
                    'Sign in with Google',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white, // Color del texto negro
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Bordes redondeados
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
                      style: const TextStyle(
                        color: Pallete
                            .salmonColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline, // Subraya el texto "Sign up"
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                           Get.toNamed('/register',  arguments: {'id' : id});
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildBody(),
            ],
          ),
        ],
      ),
    );
  }
}