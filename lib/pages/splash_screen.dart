import 'dart:async';
import 'package:flutter/material.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tcp/pages/Login_Page.dart';
import 'package:tcp/widgets/widgets.dart';

class SplashPage extends StatefulWidget {
  static String routeName = '/splash';
  const SplashPage({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (!mounted) return;
      PanaraInfoDialog.show(
        context,
        title: "Sin conexión a Internet",
        message: "No tienes conexión a Internet. ¿Quieres reintentar?",
        buttonText: "Reintentar",
        onTapDismiss: () {
          Navigator.of(context).pop();
          _checkInternetConnection();
        },
        panaraDialogType: PanaraDialogType.error,
        barrierDismissible: false,
      );
    } else {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green,
              colorPrincipal,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/src/img/imfine.png', // Update with your logo asset path
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'TCP',
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: 'Sans', // Update with your font
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Transporte Cultural Publico',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.0),
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    backgroundColor: Colors.white24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
