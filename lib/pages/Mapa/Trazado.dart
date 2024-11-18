import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrazarLinea {
  Location location = Location();

  // Método para cargar una ruta KML y obtener las coordenadas
  Future<void> cargarRutaKml(
      List<LatLng> kmlCoordinates, String filePath) async {
    try {
      // Cargar el contenido del archivo KML
      final kmlString = await rootBundle.loadString(filePath);
      final kmlDocument = xml.XmlDocument.parse(kmlString);

      // Encontrar todos los nodos 'Folder' en el documento KML
      final folderNodes = kmlDocument.findAllElements('Folder');
      kmlCoordinates.clear(); // Limpiar la lista de coordenadas

      // Iterar sobre cada nodo 'Folder'
      for (final folderNode in folderNodes) {
        // Encontrar todos los nodos 'Placemark' dentro de cada 'Folder'
        final placemarkNodes = folderNode.findElements('Placemark');

        // Iterar sobre cada nodo 'Placemark'
        for (final placemarkNode in placemarkNodes) {
          // Encontrar el nodo 'LineString' dentro de cada 'Placemark'
          final lineStringNode =
              placemarkNode.findElements('LineString').single;
          // Encontrar el nodo 'coordinates' dentro de cada 'LineString'
          final coordinatesNode =
              lineStringNode.findElements('coordinates').single;
          final coordinates = coordinatesNode.text.trim().split('\n');

          // Iterar sobre cada coordenada y agregarla a la lista de coordenadas
          for (final coordStr in coordinates) {
            final coords = coordStr.trim().split(',');
            if (coords.length >= 2) {
              kmlCoordinates.add(
                  LatLng(double.parse(coords[1]), double.parse(coords[0])));
            }
          }
        }
      }
    } catch (e) {
      // Manejar el error en caso de que ocurra algún problema al cargar el archivo KML
      print('Error al cargar la ruta KML desde $filePath: $e');
    }
  }

  // Método para obtener datos de tráfico en tiempo real para las coordenadas KML
  Future<List<Polyline>> obtenerDatosDeTrafico(
      List<LatLng> kmlCoordinates, String apiKey) async {
    List<Polyline> polylines = [];

    try {
      if (kmlCoordinates.isEmpty) return polylines;

      // Crear una cadena de coordenadas para la solicitud a la API de Directions
      String coordinatesString = kmlCoordinates
          .map((coord) => '${coord.latitude},${coord.longitude}')
          .join('|');

      final response = await http.get(
        Uri.parse(
            'https://maps.googleapis.com/maps/api/directions/json?origin=${kmlCoordinates.first.latitude},${kmlCoordinates.first.longitude}&destination=${kmlCoordinates.last.latitude},${kmlCoordinates.last.longitude}&waypoints=$coordinatesString&departure_time=now&key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final legs = route['legs'][0];
        final steps = legs['steps'];

        for (var step in steps) {
          final polylinePoints = step['polyline']['points'];
          final decodedPoints = _decodePolyline(polylinePoints);
          final trafficSpeed =
              step['traffic_speed_entry'][0]['speed']; // Nivel de tráfico

          final polyline = Polyline(
            polylineId: PolylineId(step['start_location']['lat'].toString()),
            points: decodedPoints,
            color: _getColorBasedOnTraffic(trafficSpeed),
            width: 5,
          );

          polylines.add(polyline);
        }
      }
    } catch (e) {
      print('Error al obtener datos de tráfico: $e');
    }

    return polylines;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Color _getColorBasedOnTraffic(int speed) {
    if (speed < 20) {
      return Colors.red;
    } else if (speed < 40) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
