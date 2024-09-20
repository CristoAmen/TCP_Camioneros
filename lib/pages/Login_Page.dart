import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tcp/pages/validator/validator.dart';
import 'package:tcp/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';

  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _mostrarProgreso = false;
  bool _mostrarContra = true;

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _inicioSesion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _mostrarProgreso = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'El formato del correo electrónico no es válido.';
          break;
        case 'user-disabled':
          errorMessage = 'Esta cuenta de usuario ha sido deshabilitada.';
          break;
        case 'user-not-found':
          errorMessage =
              'No se encontró ningún usuario con este correo electrónico.';
          break;
        case 'wrong-password':
          errorMessage = 'La contraseña es incorrecta.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Demasiados intentos fallidos. Por favor, intente más tarde.';
          break;
        case 'network-request-failed':
          errorMessage = 'Error de red. Verifique su conexión a Internet.';
          break;
        default:
          errorMessage =
              'Ocurrió un error durante el inicio de sesión: ${e.message}';
      }
      showSnackBar(errorMessage);
    } catch (e) {
      showSnackBar(
          'Ocurrió un error inesperado. Por favor, intente nuevamente.');
    } finally {
      setState(() {
        _mostrarProgreso = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size tamaPantalla = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
          body: SingleChildScrollView(
            child: Container(
              height: tamaPantalla.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorPrincipal, Colors.green],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: tamaPantalla.height * 0.1),
                      const Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            'TCP',
                            style:
                                TextStyle(color: colorPrincipal, fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      const Text(
                        'Iniciar Sesión',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                            labelText: 'Correo Electrónico'),
                        validator: validaciones.validarCorreo,
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          suffixIcon: IconButton(
                            icon: Icon(_mostrarContra
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _mostrarContra = !_mostrarContra;
                              });
                            },
                          ),
                        ),
                        obscureText: _mostrarContra,
                        validator: validaciones.validarContra,
                      ),
                      const SizedBox(height: 30.0),
                      ElevatedButton(
                        onPressed: _mostrarProgreso ? null : _inicioSesion,
                        child: Text(_mostrarProgreso
                            ? 'Iniciando sesión...'
                            : 'Iniciar Sesión'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed('/registro');
                        },
                        child: const Text('¿No tienes una cuenta? Regístrate'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_mostrarProgreso)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballTrianglePathColoredFilled,
                  colors: [Colors.white],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
