import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tcp/pages/Login_Page.dart';

import 'package:tcp/widgets/showSnackbar.dart';
import 'package:tcp/widgets/widgets.dart';

class PerfilPage extends StatefulWidget {
  static String routeName = '/perfil';
  const PerfilPage({super.key});

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? correoAutenticado;
  String? nombreUsuario;
  bool _isAdmin = false;
  bool _showProgress = false;
  bool _isConnected = true;
  bool _isLoading = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _startConnectionCheckTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startConnectionCheckTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkInternetConnection();
    });
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
    } else {
      setState(() {
        _isConnected = true;
      });
      await _initUserData();
    }
  }

  Future<void> _initUserData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([_fetchUserData(), _checkUserRole()]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchUserData() async {
    try {
      User? usuarioActual = _auth.currentUser;

      if (usuarioActual != null) {
        setState(() {
          correoAutenticado = usuarioActual.email;
        });

        DocumentSnapshot documentSnapshot = await _firestore
            .collection('empleados')
            .doc(usuarioActual.uid)
            .get();

        if (documentSnapshot.exists) {
          setState(() {
            nombreUsuario = documentSnapshot.get('nombres');
            String materno = documentSnapshot.get('materno');
            String paterno = documentSnapshot.get('paterno');

            // Concatenar nombres y apellidos para las iniciales
            nombreUsuario = '$nombreUsuario $materno $paterno';
          });
        }
      }
    } catch (error) {
      MostrarSnackBar3(
          context, 'Error al obtener información del usuario: $error');
    }
  }

  Future<void> _checkUserRole() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData =
            await _firestore.collection('choffer').doc(user.uid).get();
        if (userData.exists) {
          setState(() {
            _isAdmin = userData['rol'] == 'admin';
          });
        }
      }
    } catch (e) {
      print('Error al obtener información del usuario: $e');
    }
  }

  Future<void> _updateUser(String newUsername, String password) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _auth.signInWithEmailAndPassword(
          email: currentUser.email!,
          password: password,
        );

        await _firestore.collection('choffer').doc(currentUser.uid).update({
          'nombres': newUsername,
        });

        await _auth.signOut();
      } else {
        throw Exception('No se pudo obtener la referencia del usuario actual.');
      }
    } catch (error) {
      throw Exception('Error al actualizar el usuario: $error');
    }
  }

  Future<void> _updateUserActiveStatus(bool isActive) async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        await _firestore.collection('empleados').doc(currentUser.uid).update({
          'isActive': isActive,
        });
      } else {
        throw Exception('No se pudo obtener la referencia del usuario actual.');
      }
    } catch (error) {
      throw Exception('Error al actualizar el estado de usuario: $error');
    }
  }

  Future<void> _signOut(BuildContext context) async {
    setState(() {
      _showProgress = true;
    });

    try {
      await _updateUserActiveStatus(false);
      await _auth.signOut();

      if (mounted) {
        pushWithoutNavBar(context, const LoginPage());
      }
    } catch (e) {
      MostrarSnackBar3(context, 'Error al cerrar sesión: $e');
    }

    if (mounted) {
      setState(() {
        _showProgress = false;
      });
    }
  }

  String _getInitials(String fullName) {
    List<String> names = fullName.split(' ');
    String initials = '';
    for (var name in names) {
      if (name.isNotEmpty) {
        initials += name[0].toUpperCase();
      }
    }
    return initials;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          if (_isLoading)
            Skeletonizer(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: colorPrincipal,
                            child: Text(
                              'TCP',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Cargando...',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Cargando...',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app),
                      title: const Text('Cerrar Sesión'),
                      onTap: () {},
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.directions_bus),
                      title: const Text('Agregar un Camionero'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: const Icon(Icons.supervised_user_circle_sharp),
                      title: const Text('Lista de Choferes'),
                      onTap: () {},
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Ayuda'),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          if (!_isLoading && _isConnected)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: colorPrincipal,
                          child: Text(
                            _getInitials(nombreUsuario ?? 'TCP'),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 24),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nombreUsuario ?? 'Cargando...',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          correoAutenticado ?? 'Cargando...',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Cambiar Contraseña'),
                    onTap: () {
                      pushWithoutNavBar(context, Container());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text('Cerrar Sesión'),
                    onTap: () async {
                      await _signOut(context);
                    },
                  ),
                  const Divider(),
                  if (_isAdmin)
                    ListTile(
                      leading: const Icon(Icons.directions_bus),
                      title: const Text('Agregar un Camionero'),
                      onTap: () {
                        pushWithoutNavBar(context, Container());
                      },
                    ),
                  if (_isAdmin)
                    ListTile(
                      leading: const Icon(Icons.supervised_user_circle_sharp),
                      title: const Text('Lista de Choferes'),
                      onTap: () {
                        pushWithoutNavBar(context, Container());
                      },
                    ),
                ],
              ),
            ),
          if (!_isConnected)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'Sin conexión a Internet',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          if (_showProgress)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

void pushWithoutNavBar(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}
