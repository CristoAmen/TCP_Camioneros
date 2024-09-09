// ignore_for_file: use_build_context_synchronously, file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tcp/pages/Login_Page.dart';
import 'package:tcp/widgets/showAlert.dart';
import 'package:tcp/widgets/showSnackbar.dart';

class AuthenticationMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthenticationMethods(FirebaseAuth instance, FirebaseFirestore instance2);

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // Stream para escuchar cambios en la autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Método para enviar correo de verificación
  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      await currentUser?.sendEmailVerification();
      showAlert(
        context,
        'Verificación',
        'Le hemos enviado un correo de verificación.',
        [
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, LoginPage.routeName);
            },
            child: const Text('OK'),
          ),
        ],
      );
    } catch (e) {
      handleAuthException(context, e);
    }
  }

  // Método para cerrar sesión
  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    } catch (e) {
      handleAuthException(context, e);
    }
  }

  // Método para eliminar la cuenta de usuario
  Future<void> deleteAccount(BuildContext context) async {
    try {
      await currentUser?.delete();
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    } catch (e) {
      handleAuthException(context, e);
    }
  }

  // Método para manejar excepciones de autenticación
  void handleAuthException(BuildContext context, dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          showSnackBar(
            context,
            'La contraseña proporcionada es demasiado débil',
          );
          break;
        case 'email-already-in-use':
          showSnackBar(
            context,
            'El correo electrónico ya está en uso por otra cuenta',
          );
          break;
        case 'user-not-found':
          showSnackBar(
            context,
            'No se encontró ningún usuario con ese nombre de usuario.',
          );
          break;
        case 'wrong-password':
          showSnackBar(
            context,
            'La contraseña proporcionada es incorrecta.',
          );
          break;
        case 'invalid-credential':
          showSnackBar(
            context,
            'Las credenciales proporcionadas son incorrectas o han caducado.',
          );
          break;
        default:
          showSnackBar(
            context,
            e.message ?? 'Error desconocido',
          );
          break;
      }
    } else {
      showSnackBar(context, e.toString());
    }
  }
}
