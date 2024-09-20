import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tcp/pages/Mapa/provider.dart';
import 'package:tcp/pages/Mapa/ubicacionActual.dart';
import 'package:tcp/widgets/widgets.dart';
import 'package:geolocator/geolocator.dart'; // Importa Geolocator

class MapPage extends StatefulWidget {
  static String routeName = '/mapa';
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController controladorMapa; // Controlador del mapa
  LatLng? _ubicacionActual; // Variable para almacenar la ubicación actual

  final LatLng _centro = const LatLng(
      23.256177357367125, -106.41026703151338); // Ubicación central inicial

  // Método que se llama cuando el mapa se ha creado
  void _onMapCreated(GoogleMapController controlador) {
    controladorMapa = controlador;
    // Se encuentra en el archivo "ubicacionActual"
    obtenerUbicacionActual(controlador); // Llama al método desde el helper
  }

  // Método para construir el contenido del BottomSheet
  Widget _vistaHojaInferior(BuildContext context) {
    final proveedorUsuario = Provider.of<ProveedorUsuario>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.bus, color: Colors.green),
                onPressed: () {},
              ),
              Text(
                proveedorUsuario.cargando
                    ? 'Cargando...'
                    : 'Bienvenido ${proveedorUsuario.nombreUsuario}', // Mensaje de bienvenida
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.maxFinite,
            child: Estilos()._botonIniciarRuta(), // Botón para iniciar la ruta
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Estilos().botonEstado(context)), // Botón de estado
              const SizedBox(width: 8),
              Expanded(
                  child:
                      Estilos().botonCerrarSesion()), // Botón de cerrar sesión
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.maxFinite,
            child: Estilos().rutaSeleccionada(
                context), // Información de la ruta seleccionada
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: GoogleMap(
            onMapCreated: _onMapCreated, // Método que se llama al crear el mapa
            initialCameraPosition: CameraPosition(
              target: _centro, // Posición inicial de la cámara
              zoom: 11.0, // Nivel de zoom inicial
            ),
            zoomControlsEnabled: false,
            myLocationEnabled: true, // Habilita el botón de mi ubicación
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
            child: FloatingActionButton(
              onPressed: () {
                // Mostrar el BottomSheet al presionar el botón
                showModalBottomSheet(
                  context: context,
                  isScrollControlled:
                      true, // Permite que el BottomSheet ocupe más espacio
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (BuildContext context) {
                    return _vistaHojaInferior(context);
                  },
                );
              },
              backgroundColor: colorPrincipal, // Color del botón
              heroTag: "config",
              child: const FaIcon(
                FontAwesomeIcons.bus,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Definición de la clase Estilos
class Estilos {
  Widget _contenedorBoton(Color colorFondo, Color colorBorde, String titulo,
      String subtitulo, Color colorTexto) {
    return Container(
      decoration: BoxDecoration(
        color: colorFondo,
        border: Border.all(color: colorBorde, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorBorde.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
      child: Column(
        children: [
          Text(
            titulo,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: colorTexto),
          ),
          const SizedBox(height: 4),
          Text(subtitulo, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _botonIniciarRuta() {
    return ElevatedButton(
      onPressed: () {
        // Lógica para iniciar la ruta
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: colorPrincipal, // Color del botón
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: const Text(
        'Iniciar la ruta',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget botonEstado(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('¿Está seguro?',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text('¿Quiere cerrar sesión?',
                  style: TextStyle(fontSize: 16)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Sí',
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
      child: _contenedorBoton(
        Colors.blue.shade50,
        Colors.blue,
        'Cerrar Sesión:',
        '2 años',
        Colors.blue,
      ),
    );
  }

  Widget botonCerrarSesion() {
    return _contenedorBoton(
      Colors.red.shade50,
      Colors.red,
      'Estado:',
      'Activo',
      Colors.red,
    );
  }

  Widget rutaSeleccionada(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
      child: Column(
        children: const [
          Text(
            'Ruta Seleccionada:',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          SizedBox(height: 4),
          Text('Prados del Sol', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
