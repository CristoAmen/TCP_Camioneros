import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart'; // Paquete para el indicador de carga

class LoginPage extends StatelessWidget {
  static const String routeName = '/login';

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    bool _isPasswordObscure = true; // Controla la visibilidad de la contraseña
    bool _showProgress =
        false; // Controla la visibilidad del indicador de carga
    bool _isConnected = true; // Simula el estado de conectividad

    return Stack(
      children: [
        Scaffold(
          body: SingleChildScrollView(
            child: Container(
              height: screenSize.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 4, 56, 99), Colors.blue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(height: screenSize.height * 0.1),
                      // Logo o imagen en la parte superior
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
                      const SizedBox(
                        height: 20.0,
                      ),
                      // Campo de correo electrónico
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.white),
                          labelText: 'Correo electrónico',
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white24,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20.0),
                      // Campo de contraseña
                      StatefulBuilder(
                        builder: (context, setState) => TextFormField(
                          obscureText: _isPasswordObscure,
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.white),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordObscure = !_isPasswordObscure;
                                });
                              },
                            ),
                            labelText: 'Contraseña',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white24,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      // Botón de inicio de sesión
                      ElevatedButton(
                        onPressed: (_isConnected && !_showProgress)
                            ? () {
                                // Acción de inicio de sesión simulada
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 4, 56, 99),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            color: Color.fromARGB(255, 4, 56, 99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      // Enlaces de "Crear una cuenta" y "Olvidar contraseña"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/registro");
                            },
                            child: const Text(
                              'Crear una cuenta',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/olvidar_contra");
                            },
                            child: const Text(
                              'Se me olvidó la contraseña',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Indicador de carga
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
}
