import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:tcp/config/Metodos_Firebase.dart';
import 'package:tcp/pages/Perfil_Page.dart';
import 'package:tcp/widgets/connection_status_widget.dart';
import 'package:tcp/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  static String routeName = '/home';

  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late AuthenticationMethods _auth;
  String _username = '';
  String _userRol = ''; // Nuevo campo para el rol
  int _selectedItemPosition = 0;
  bool _isActive = false;

  final List<Widget> _screens = [
    Container(),
    PerfilPage(),
    Container(), // Reemplaza este contenedor con la pantalla de Anuncios cuando esté disponible
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auth = AuthenticationMethods(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    );
    _initUser();
  }

  @override
  void dispose() {
    _updateUserActiveStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (mounted) {
          _updateUserActiveStatus(false);
        }
        break;
      case AppLifecycleState.resumed:
        if (mounted) {
          _updateUserActiveStatus(true);
        }
        break;
      default:
        break;
    }
  }

  Future<void> _initUser() async {
    await _obtenerDatosUsuario(); // Cambiado para obtener más datos
    await _updateUserActiveStatus(true);
  }

  Future<void> _obtenerDatosUsuario() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print("UID del usuario: ${user.uid}");
        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('empleados') // Cambiado a la colección 'empleados'
                .doc(user.uid)
                .get();
        if (userData.exists) {
          print("Documento encontrado: ${userData.data()}");
          setState(() {
            _username = userData['nombres'] ?? '';
            _userRol = userData['rol'] ?? ''; // Añadir rol
          });
        } else {
          print("Documento no encontrado.");
        }
      } else {
        print("Usuario no autenticado.");
      }
    } catch (e) {
      print("Error al obtener el usuario: $e");
      _handleError(e);
    }
  }

  Future<void> _updateUserActiveStatus(bool isActive) async {
    if (_isActive == isActive || !mounted) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection(
                'empleados') // Asegúrate de que esta colección es la correcta
            .doc(user.uid)
            .update({'isActive': isActive});
        if (mounted) {
          setState(() {
            _isActive = isActive;
          });
        }
      }
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(dynamic error) {
    final errorMessage = 'Ocurrió un error: $error';
    print('Error: $errorMessage');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConnectionStatusWidget(
        child: _screens[_selectedItemPosition],
      ),
      bottomNavigationBar: _buildSnakeNavigationBar(),
    );
  }

  Widget _buildSnakeNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 5),
          ),
        ],
      ),
      margin: const EdgeInsets.all(12),
      child: SnakeNavigationBar.color(
        behaviour: SnakeBarBehaviour.floating,
        snakeShape: SnakeShape.indicator,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.all(12),
        snakeViewColor: colorPrincipal,
        selectedItemColor: SnakeShape.indicator == SnakeShape.indicator
            ? colorPrincipal
            : null,
        unselectedItemColor: CupertinoColors.systemGrey,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        currentIndex: _selectedItemPosition,
        onTap: (index) {
          setState(() {
            _selectedItemPosition = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.mapLocationDot),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.userGear),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.comment),
            label: 'Anuncios',
          ),
        ],
      ),
    );
  }
}
