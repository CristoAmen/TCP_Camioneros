import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tcp/widgets/showSnackbar.dart';
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

  bool _showProgress = false;
  bool _mostrarContra = true;
  String? _currentUserId;

  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _showProgress = true;
    });

    if (_formKey.currentState!.validate()) {
      try {
        final UserCredential userCredential =
            await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (userCredential.user != null) {
          setState(() {});
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'wrong-password':
            errorMessage = 'La contraseña es incorrecta';
            break;
          case 'user-not-found':
            errorMessage =
                'No se encontró una cuenta con este correo electrónico';
            break;
          case 'too-many-requests':
            errorMessage =
                'Demasiados intentos de inicio de sesión. Por favor intenta nuevamente más tarde.';
            break;
          case 'network-request-failed':
            SnackNoConexion(context,
                'Error de red. Por favor verifica tu conexión a Internet.');
            return;
          default:
            errorMessage =
                'Error al iniciar sesión. Por favor intenta nuevamente.';
        }
        showSnackBar(errorMessage);
      } catch (e) {
        showSnackBar('Error al iniciar sesión. Por favor intenta nuevamente.');
      }
    }

    setState(() {
      _showProgress = false;
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const Color colorPrincipal = Color.fromARGB(255, 1, 31, 10);

    return Stack(
      children: [
        Scaffold(
          body: SingleChildScrollView(
            child: Container(
              height: screenSize.height,
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
                      SizedBox(height: screenSize.height * 0.1),
                      const Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            'TCP',
                            style: TextStyle(
                                color: Color.fromARGB(255, 4, 56, 99),
                                fontSize: 32),
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
                      Login()
                          .txtCorreoElectronico(controller: _emailController),
                      const SizedBox(height: 20.0),
                      Login().txtContra(_mostrarContra, (value) {
                        setState(() {
                          _mostrarContra = value;
                        });
                      }, controller: _passwordController),
                      const SizedBox(height: 30.0),
                      ElevatedButton(
                        onPressed:
                            _showProgress ? null : _signInWithEmailAndPassword,
                        child: Text(_showProgress
                            ? 'Iniciando sesión...'
                            : 'Iniciar Sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_showProgress)
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
