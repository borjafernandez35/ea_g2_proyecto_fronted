import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Widgets/button_sign_in.dart';
import 'package:spotfinder/Widgets/paramTextBox.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Resources/sign_in_button.dart';
import 'package:spotfinder/Services/SignInService.dart';

late UserService userService;
late SignInService signInService;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreen createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final Controller controller = Get.put(Controller());
  bool _obscureText = true;
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
     signInService = SignInService(clientId: '435863540335-3edtkmprvlpkb3j4ea522cvndn8mc7mr.apps.googleusercontent.com');
    userService = UserService();
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

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpotFinder'),
      ),
      body: Stack(
        children: [
          // Fondo de pantalla
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido de la pantalla
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo de la empresa
              Image.asset(
                'assets/spotfinder.png',
                height: 150,
                width: 150,
              ),
              const SizedBox(
                  height: 20), // Separación entre el logo y el cuadro negro
              // Cuadro negro con el formulario de inicio de sesión
              Container(
                margin: const EdgeInsets.all(
                    20), // Ajusta el margen del cuadro negro aquí
                padding: const EdgeInsets.all(
                    20), // Ajusta el padding del cuadro negro aquí
                decoration: BoxDecoration(
                  color: Colors.black
                      .withOpacity(0.7), // Color del cuadro negro con opacidad
                  borderRadius: BorderRadius.circular(
                      20), // Bordes redondeados del cuadro
                ),
                child: Column(
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ParamTextBox(
                        controller: controller.mailController, text: 'e-mail'),
                    const SizedBox(height: 10),
                    ParamTextBox(
                      controller: controller.contrasenaController,
                      text: 'Password',
                      obscureText: _obscureText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SignInButton(
                        onPressed: () => controller.logIn(), text: 'Sign in'),
                    const SizedBox(height: 10),
                    // Nuevo texto para olvidar la contraseña
                    GestureDetector(
                      onTap: () {
                        // Aquí puedes agregar la acción para olvidar la contraseña
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.white,
                             decoration: TextDecoration.underline,
                        ),
                      ),
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

class Controller extends GetxController {
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController mailController = TextEditingController();

  bool invalid = false;
  bool parameters = false;

  void logIn() {
    if (contrasenaController.text.isEmpty || mailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Campos vacios',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      if (GetUtils.isEmail(mailController.text) == true) {
        final logIn = (
          email: mailController.text,
          password: contrasenaController.text,
        );
        userService.logIn(logIn).then((statusCode) {
          // La solicitud se completó exitosamente, puedes realizar acciones adicionales si es necesario
          print('Usuario logeado exitosamente');
          Get.to(() => HomePage());
        }).catchError((error) {
          // Manejar errores de solicitud HTTP
          Get.snackbar(
            'Error',
            'Los datos introducidos son incorrectos. Prueba otra vez.',
            snackPosition: SnackPosition.BOTTOM,
          );
          print('Error al enviar log in al backend: $error');
        });
      } else {
        Get.snackbar(
          'Error',
          'e-mail no valido',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}
