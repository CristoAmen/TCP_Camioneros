import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tcp/pages/Login_Page.dart';

class ProveedorUsuario with ChangeNotifier {
  String _nombreUsuario = '';
  String _rolUsuario = '';
  bool _cargando = false;
  bool _esAdmin = false;
  String _correoAutenticado = '';
  bool activos = false;

  String get nombreUsuario => _nombreUsuario;
  String get rolUsuario => _rolUsuario;
  bool get cargando => _cargando;
  bool get esAdmin => _esAdmin;
  String get correoAutenticado => _correoAutenticado;

  final FirebaseAuth _autenticacion = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> obtenerDatosUsuario() async {
    try {
      _cargando = true;
      notifyListeners();

      User? usuario = _autenticacion.currentUser;
      if (usuario != null) {
        DocumentSnapshot<Map<String, dynamic>> datosUsuario =
            await _firestore.collection('empleados').doc(usuario.uid).get();

        if (datosUsuario.exists) {
          _nombreUsuario = datosUsuario.data()?['nombres'] ?? '';
          _rolUsuario = datosUsuario.data()?['rol'] ?? '';
          _esAdmin = _rolUsuario == 'admin';
          _correoAutenticado = usuario.email ?? '';
        } else {
          print("Documento no encontrado.");
        }
      } else {
        print("Usuario no autenticado.");
      }
    } catch (e) {
      print("Error al obtener el usuario: $e");
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> obtenerNombreCompleto() async {
    try {
      User? usuarioActual = _autenticacion.currentUser;

      if (usuarioActual != null) {
        _correoAutenticado = usuarioActual.email ?? '';

        DocumentSnapshot documento = await _firestore
            .collection('empleados')
            .doc(usuarioActual.uid)
            .get();

        if (documento.exists) {
          String nombres = documento.get('nombres');
          String apellidoMaterno = documento.get('materno');
          String apellidoPaterno = documento.get('paterno');

          _nombreUsuario = '$nombres';
          notifyListeners();
        }
      }
    } catch (error) {
      print('Error al obtener información del usuario: $error');
    }
  }

  Future<void> checarRol() async {
    try {
      User? usuario = _autenticacion.currentUser;
      if (usuario != null) {
        DocumentSnapshot datosUsuario =
            await _firestore.collection('choffer').doc(usuario.uid).get();
        if (datosUsuario.exists) {
          _rolUsuario = datosUsuario['rol'] ?? '';
          _esAdmin = _rolUsuario == 'admin';
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error al verificar el rol del usuario: $e');
    }
  }

  Future<void> inicializarDatosUsuario() async {
    _cargando = true;
    notifyListeners();

    await obtenerDatosUsuario();
    await obtenerNombreCompleto();
    await checarRol();

    _cargando = false;
    notifyListeners();
  }

// Método para cerrar sesión
  Future<void> cerrarSesion(BuildContext context) async {
    try {
      _cargando = true;
      notifyListeners();

      // Cambia el estado de actividad del usuario a inactivo (si es necesario)
      await _firestore
          .collection('empleados')
          .doc(_autenticacion.currentUser?.uid)
          .update({'activo': false});

      // Cierra sesión de Firebase Auth
      await _autenticacion.signOut();

      // Limpia los datos del usuario en la aplicación
      _nombreUsuario = '';
      _rolUsuario = '';
      _correoAutenticado = '';
      _esAdmin = false;

      // Navegar a la página de login y eliminar el historial de navegación
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) =>
                LoginPage()), // Asegúrate de que LoginPage sea el widget correcto
        (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
      );
    } catch (e) {
      print('Error al cerrar sesión: $e');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // Aquí muevo la función ActualizarStatus al provider
  Future<void> actualizarStatus(bool activo) async {
    try {
      User? user = _autenticacion.currentUser;
      if (user != null) {
        await _firestore.collection('empleados').doc(user.uid).update({
          'activo': activo,
        });

        // Actualiza el estado local después de la actualización en Firestore
        activos = activo;
        notifyListeners(); // Notifica a los widgets que consumen este estado
      }
    } catch (e) {
      print('Error al actualizar el estado del usuario: $e');
    }
  }
}
