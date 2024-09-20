import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Variable para almacenar la ubicación actual
LatLng? ubicacionActual;

// Método para obtener la ubicación actual
Future<void> obtenerUbicacionActual(GoogleMapController controladorMapa) async {
  try {
    // Verifica si se permite el acceso a la ubicación
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator
          .requestPermission(); // Solicita permiso si no está concedido
    }

    if (permiso == LocationPermission.whileInUse ||
        permiso == LocationPermission.always) {
      // Obtiene la ubicación actual
      Position posicion = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      ubicacionActual = LatLng(posicion.latitude, posicion.longitude);
      // Mueve la cámara a la ubicación actual
      controladorMapa.animateCamera(CameraUpdate.newLatLng(ubicacionActual!));
    }
  } catch (e) {
    print(
        "Error al obtener la ubicación: $e"); // Maneja errores al obtener la ubicación
  }
}
