import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProveedorUsuario with ChangeNotifier {
  // Variables privadas para almacenar los datos del usuario y su estado
  String _nombreUsuario = ''; // Almacena el nombre completo del usuario
  String _rolUsuario = ''; // Almacena el rol del usuario (ej. admin, usuario)
  bool _cargando = false; // Indica si se está cargando la información
  bool _esAdmin = false; // Indica si el usuario es administrador
  String _correoAutenticado =
      ''; // Almacena el correo electrónico del usuario autenticado

  // Getters para acceder a las variables de manera externa
  String get nombreUsuario => _nombreUsuario;
  String get rolUsuario => _rolUsuario;
  bool get cargando => _cargando;
  bool get esAdmin => _esAdmin;
  String get correoAutenticado => _correoAutenticado;

  final FirebaseAuth _autenticacion =
      FirebaseAuth.instance; // Instancia de FirebaseAuth
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Instancia de Firestore

  // Función para obtener los datos del usuario autenticado
  Future<void> obtenerDatosUsuario() async {
    try {
      _cargando = true; // Indicar que se está cargando la información
      notifyListeners(); // Notificar a los widgets que el estado ha cambiado

      User? usuario =
          _autenticacion.currentUser; // Obtener el usuario autenticado
      if (usuario != null) {
        // Consultar los datos del usuario desde Firestore
        DocumentSnapshot<Map<String, dynamic>> datosUsuario =
            await _firestore.collection('empleados').doc(usuario.uid).get();

        // Verificar si el documento existe
        if (datosUsuario.exists) {
          // Asignar los datos obtenidos
          _nombreUsuario = datosUsuario.data()?['nombres'] ?? '';
          _rolUsuario = datosUsuario.data()?['rol'] ?? '';
        } else {
          print("Documento no encontrado.");
        }
      } else {
        print("Usuario no autenticado.");
      }
    } catch (e) {
      print("Error al obtener el usuario: $e");
    } finally {
      _cargando = false; // Indicar que la carga ha terminado
      notifyListeners(); // Notificar a los widgets cuando la operación finaliza
    }
  }

  // Función para obtener y concatenar el nombre completo del usuario
  Future<void> obtenerNombreCompleto() async {
    try {
      User? usuarioActual = _autenticacion.currentUser;

      if (usuarioActual != null) {
        // Guardar el correo electrónico del usuario autenticado
        _correoAutenticado = usuarioActual.email ?? '';

        // Consultar los datos del usuario desde Firestore
        DocumentSnapshot documento = await _firestore
            .collection('empleados')
            .doc(usuarioActual.uid)
            .get();

        if (documento.exists) {
          // Obtener nombres y apellidos y concatenarlos
          String nombres = documento.get('nombres');
          String apellidoMaterno = documento.get('materno');
          String apellidoPaterno = documento.get('paterno');

          _nombreUsuario = '$nombres $apellidoMaterno $apellidoPaterno';
          notifyListeners(); // Notificar a los widgets que el estado ha cambiado
        }
      }
    } catch (error) {
      print('Error al obtener información del usuario: $error');
    }
  }

  // Función para verificar si el usuario es administrador
  Future<void> verificarRolUsuario() async {
    try {
      User? usuario = _autenticacion.currentUser;
      if (usuario != null) {
        // Consultar el rol del usuario desde Firestore
        DocumentSnapshot datosUsuario =
            await _firestore.collection('choffer').doc(usuario.uid).get();
        if (datosUsuario.exists) {
          // Verificar si el rol es 'admin'
          _esAdmin = datosUsuario['rol'] == 'admin';
          notifyListeners(); // Notificar a los widgets que el estado ha cambiado
        }
      }
    } catch (e) {
      print('Error al obtener información del usuario: $e');
    }
  }

  // Otras funciones relacionadas con la lógica de usuario pueden ir aquí
}
