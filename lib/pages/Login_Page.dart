import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tcp/widgets/widgets.dart'; // Asumiendo que validaciones está en otro archivo

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
                      Login()
                          .txtCorreoElectronico(controller: _emailController),
                      const SizedBox(height: 20.0),
                      PasswordField(
                        isPasswordObscure: _mostrarContra,
                        onVisibilityChanged: (bool value) {
                          setState(() {
                            _mostrarContra = value;
                          });
                        },
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 30.0),
                      Login().btnInicioSesion(
                        true,
                        _mostrarProgreso,
                        _formKey,
                        _emailController,
                        _passwordController,
                        _auth,
                        context,
                        () => setState(() => _mostrarProgreso = true),
                        () => setState(() => _mostrarProgreso = false),
                        showSnackBar,
                      ),
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

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
