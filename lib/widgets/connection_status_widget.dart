// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionStatusWidget extends StatefulWidget {
  final Widget child;

  const ConnectionStatusWidget({super.key, required this.child});

  @override
  _ConnectionStatusWidgetState createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  late Stream<ConnectivityResult> _connectivityStream;
  bool _isConnected = true;
  bool _isUnstable = false;

  @override
  void initState() {
    super.initState();
    _connectivityStream =
        Connectivity().onConnectivityChanged as Stream<ConnectivityResult>;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: _connectivityStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data == ConnectivityResult.none) {
            _isConnected = false;
            _isUnstable = false; // Sin conexión
          } else if (snapshot.data == ConnectivityResult.mobile ||
              snapshot.data == ConnectivityResult.wifi) {
            _isConnected = true;
            _isUnstable = false; // Conexión estable
          } else {
            _isConnected = true;
            _isUnstable =
                true; // Aquí puedes añadir lógica adicional si es necesario
          }
        }

        return Stack(
          children: [
            widget.child,
            if (!_isConnected)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.all(8.0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, color: Colors.white),
                      SizedBox(width: 8.0),
                      Text('Sin conexión',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            if (_isUnstable)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.orange, // Color para conexión inestable
                  padding: const EdgeInsets.all(8.0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, color: Colors.white),
                      SizedBox(width: 8.0),
                      Text('Conexión inestable',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ejemplo de Widget de Estado de Conexión"),
      ),
      body: const ConnectionStatusWidget(
        child: Center(
          child: Text("Contenido de la aplicación"),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MyHomePage(),
  ));
}
