// ignore_for_file: unused_local_variable, file_names, avoid_print, non_constant_identifier_names, duplicate_ignore

import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  var showSnackBar = ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      elevation: 6.0, // Set elevation for floating effect
      backgroundColor: const Color.fromARGB(
          255, 98, 0, 255), // Customize snackbar color (optional)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Set rounded corners
      ),
      padding:
          const EdgeInsets.all(6.0), // Add padding around the entire SnackBar
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(text),
      ),
    ),
  );
}

// Snackbar Tradicional de Material 3
// ignore: non_constant_identifier_names
void MostrarSnackBar3(BuildContext context, String message,
    {Color backgroundColor = Colors.blue}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Action',
        textColor: Theme.of(context).colorScheme.onSecondaryContainer,
        onPressed: () {
          print('Snackbar action pressed');
        },
      ),
    ),
  );
}

void MostrarSnackBarAccion(BuildContext context, String message,
    {Color backgroundColor = Colors.blue}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void SnackNoConexion(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(color: Colors.white),
              maxLines:
                  2, // Limita el número de líneas para evitar desbordamiento
              overflow: TextOverflow
                  .ellipsis, // Maneja el desbordamiento con puntos suspensivos
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red,
      elevation: 6, // Agrega elevación para resaltar el Snackbar
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      margin: const EdgeInsets.fromLTRB(
          16, 16, 16, 0), // Posiciona el Snackbar en la parte superior
      padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16), // Agrega relleno para el contenido del Snackbar
      duration: const Duration(seconds: 3),
    ),
  );
}
