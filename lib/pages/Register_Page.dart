import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tcp/widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  static const String routeName = '/registro';

  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _maternoController = TextEditingController();
  final TextEditingController _paternoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _repeatEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  final PageController _pageController = PageController();
  bool _isPasswordObscure = true;
  bool _isPasswordObscureRepeat = true;
  bool _acceptTerms = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _showProgress = false;
  int _currentPage = 0;

  // DECLARO MI CLASE COMO VARIABLE
  final Register _registroWidgets = Register();

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _maternoController.dispose();
    _paternoController.dispose();
    _emailController.dispose();
    _repeatEmailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _registerWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _repeatPasswordController.text) {
      _showSnackBar(
          'Las contraseñas no coinciden. Por favor intenta nuevamente.');
      return;
    }

    if (_emailController.text != _repeatEmailController.text) {
      _showSnackBar(
          'Los correos electrónicos no coinciden. Por favor intenta nuevamente.');
      return;
    }

    setState(() {
      _showProgress = true;
    });

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _firestore
          .collection('empleados')
          .doc(userCredential.user!.uid)
          .set({
        'nombres': _nombreController.text.trim(),
        'materno': _maternoController.text.trim(),
        'paterno': _paternoController.text.trim(),
        'correo': _emailController.text.trim(),
        'rol': 'choffer',
      });

      _clearControllers();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      print('Error al registrarse: ${e.toString()}');
      _showSnackBar('Error al registrarse: ${e.toString()}');
    } finally {
      setState(() {
        _showProgress = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  void _clearControllers() {
    _nombreController.clear();
    _maternoController.clear();
    _paternoController.clear();
    _emailController.clear();
    _repeatEmailController.clear();
    _passwordController.clear();
    _repeatPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: screenSize.height * 0.1),
                      const Text(
                        'Introduzca los siguientes datos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 90.0),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          children: [
                            // LLAMO A LA CLASE
                            _registroWidgets.buildNamePage(
                              _nombreController,
                              _maternoController,
                              _paternoController,
                            ),
                            // LLAMO A LA CLASE
                            _registroWidgets.buildEmailPage(
                              _emailController,
                              _repeatEmailController,
                            ),
                            // LLAMO A LA CLASE
                            _registroWidgets.buildPasswordPage(
                              _passwordController,
                              _repeatPasswordController,
                              _isPasswordObscure,
                              _isPasswordObscureRepeat,
                              () => setState(() =>
                                  _isPasswordObscure = !_isPasswordObscure),
                              () => setState(() => _isPasswordObscureRepeat =
                                  !_isPasswordObscureRepeat),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: 3,
                          effect: const ExpandingDotsEffect(
                            activeDotColor: Colors.white,
                            dotColor: Colors.white24,
                            dotHeight: 8.0,
                            dotWidth: 8.0,
                            spacing: 16.0,
                            expansionFactor: 4.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      CustomButton(
                        onTap: () {
                          if (_currentPage == 2) {
                            _registerWithEmailAndPassword();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        text: _currentPage == 2 ? 'Registrarme' : 'Siguiente',
                      ),
                      const SizedBox(height: 20.0),
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

  Widget _buildTermsAndConditionsDialog() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Términos y Condiciones',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: Markdown(
              data: _getTermsAndConditions(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  String _getTermsAndConditions() {
    // Agregar los términos y condiciones reales aquí
    return '''
## Términos y Condiciones

1. **Uso del Servicio:** Al utilizar este servicio, aceptas cumplir con todos los términos y condiciones aquí descritos.
2. **Privacidad:** Tu privacidad es importante para nosotros. Nos comprometemos a proteger tus datos personales.
3. **Contenido:** El contenido proporcionado es solo para fines informativos y no debe considerarse como asesoramiento profesional.
4. **Cambios en los Términos:** Nos reservamos el derecho de modificar estos términos en cualquier momento sin previo aviso.
    ''';
  }
}
