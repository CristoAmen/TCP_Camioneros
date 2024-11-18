import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tcp/pages/Mapa/Admin/asignarRuta.dart';
import 'package:tcp/pages/Mapa/Admin/eliminarCamionero.dart';
import 'package:tcp/pages/Mapa/Trazado.dart';
import 'package:tcp/provider/provider.dart';
import 'package:tcp/pages/Mapa/ubicacionActual.dart';
import 'package:tcp/pages/Register_Page.dart';
import 'package:tcp/widgets/widgets.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class MapPage extends StatefulWidget {
  static String routeName = '/mapa';
  const MapPage({super.key});

  @override
  _EstadoPaginaMapa createState() => _EstadoPaginaMapa();
}

class _EstadoPaginaMapa extends State<MapPage> with WidgetsBindingObserver {
  late GoogleMapController controladorMapa;
  final LatLng _centro = const LatLng(23.256177357367125, -106.41026703151338);
  late BuildContext _contexto;
  final Estilos2 _estilos = Estilos2();
  // Llamamos a la clase con esta variable
  final deleteCamion _delete = deleteCamion(); // Eliminar Camionero
  ProveedorUsuario? _proveedorUsuario;

  List<LatLng> _coordenadasKml = []; // Nueva variable
  bool _mostrarRutaKml = false; // Nueva variable
  bool mostrarBotonIzquierdo = false; // Nueva variable
  bool _mostrarTrafico = false; // Nueva variable

  List<Polyline> _polylines = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _contexto = context;
    _proveedorUsuario = Provider.of<ProveedorUsuario>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _proveedorUsuario?.actualizarStatus(true);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _proveedorUsuario?.nombreUsuario;
    });
  }

  @override
  void dispose() {
    _proveedorUsuario?.actualizarStatus(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (_proveedorUsuario == null) return;
    switch (estado) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _proveedorUsuario?.actualizarStatus(false);
        break;
      case AppLifecycleState.resumed:
        _proveedorUsuario?.actualizarStatus(true);
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _alCrearMapa(GoogleMapController controlador) {
    controladorMapa = controlador;
    obtenerUbicacionActual(controlador);
  }

  Widget _construirHojaInferiorUsuario(BuildContext contexto) {
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
                'Bienvenido, ${Provider.of<ProveedorUsuario>(contexto).nombreUsuario}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _construirBotonIniciarRuta(contexto),
          const SizedBox(height: 16),
          _construirFilaEstado(contexto),
          const SizedBox(height: 16),
          _construirBotonRutaDeHoy(contexto),
        ],
      ),
    );
  }

  void _actualizarPosicionCamara({bool resetZoom = false}) {
    if (_coordenadasKml.isNotEmpty && controladorMapa != null) {
      // Calcular límites de las coordenadas
      double minLat = _coordenadasKml.first.latitude;
      double maxLat = _coordenadasKml.first.latitude;
      double minLng = _coordenadasKml.first.longitude;
      double maxLng = _coordenadasKml.first.longitude;

      for (LatLng coord in _coordenadasKml) {
        minLat = min(minLat, coord.latitude);
        maxLat = max(maxLat, coord.latitude);
        minLng = min(minLng, coord.longitude);
        maxLng = max(maxLng, coord.longitude);
      }

      // Crear bounds
      LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));

      // Ajustar cámara
      controladorMapa
          .animateCamera(CameraUpdate.newLatLngBounds(bounds, 50 // Padding
              ));
    }
  }

  Widget _construirBotonIniciarRuta(BuildContext contexto) {
    return SizedBox(
      width: double.infinity,
      child: _estilos.botonIniciarRuta(
        context: contexto,
        texto: 'Iniciar la ruta',
        accion: () {
          // Agregaremos la propiedad de status (booleano) y ubicacion () compartira la ubicacion cada cierto tiempo en firebase (15 segundos)

          // Mostrara la ruta del camion
          final proveedorUsuario =
              Provider.of<ProveedorUsuario>(contexto, listen: false);

          FirebaseFirestore.instance
              .collection('empleados')
              .doc(proveedorUsuario.id)
              .get()
              .then((snapshot) {
            String rutaAsignada = snapshot.data()?['rutaAsignada'] ?? '';

            if (rutaAsignada.isNotEmpty) {
              _cargarYMostrarRutaKml('lib/src/kml/${rutaAsignada}.kml');
            } else {
              ScaffoldMessenger.of(contexto).showSnackBar(
                  SnackBar(content: Text('No tiene una ruta asignada')));
            }
          });
        },
        colorFondo: Colors.green,
        colorTexto: Colors.white,
      ),
    );
  }

  Future<void> _cargarYMostrarRutaKml(String rutaKml) async {
    List<LatLng> coordenadasKml = [];
    await TrazarLinea().cargarRutaKml(coordenadasKml, rutaKml);

    if (mounted) {
      setState(() {
        _coordenadasKml = coordenadasKml;
        _mostrarRutaKml = true;
        mostrarBotonIzquierdo = true;
        _mostrarTrafico = true;

        // Crear la polilínea con las coordenadas KML y agregarla a la lista
        Polyline polilinea = Polyline(
          polylineId: PolylineId('ruta_kml'),
          points: _coordenadasKml,
          color: Colors.blue, // Puedes cambiar el color si lo deseas
          width: 5,
        );

        // Añadir la polilínea a la lista de polilíneas
        _polylines.add(polilinea);
      });

      // Actualizar la posición de la cámara
      _actualizarPosicionCamara(resetZoom: true);
    }
  }

  Widget _construirFilaEstado(BuildContext contexto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _estilos.botonSubtitulos(
            context: contexto,
            titulo: 'Estado',
            subtitulo: '-',
            colorFondo: Colors.greenAccent.shade100,
            colorBorde: Colors.green,
            colorTextoTitulo: Colors.green,
            colorTextoSubtitulo: Colors.black54,
            esClickeable: false,
            onTap: () {
              print("Botón clickeado");
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _estilos.botonCustom(
            context: contexto,
            texto: "Cerrar Sesión",
            icono: Icons.logout,
            colorFondo: Colors.red.shade50,
            colorBorde: Colors.red,
            colorTexto: Colors.red,
            esClickeable: true,
            accion: () {
              Provider.of<ProveedorUsuario>(_contexto, listen: false)
                  .cerrarSesion(contexto);
            },
          ),
        ),
      ],
    );
  }

  Widget _construirBotonRutaDeHoy(BuildContext contexto) {
    final proveedorUsuario =
        Provider.of<ProveedorUsuario>(contexto, listen: false);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('empleados')
          .doc(proveedorUsuario.id) // Ahora usará el getter para obtener el UID
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        String subtitulo = 'Cargando...';

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.exists) {
            subtitulo = snapshot.data!['rutaAsignada'] ?? 'Sin asignar';
          } else {
            subtitulo = 'Sin datos';
          }
        } else if (snapshot.hasError) {
          subtitulo = 'Error al cargar';
        }

        return SizedBox(
          width: double.infinity,
          child: _estilos.botonSubtitulos(
            context: contexto,
            titulo: 'Ruta de hoy:',
            subtitulo: subtitulo,
            colorFondo: Colors.lightBlue.shade50,
            colorBorde: Colors.blue,
            colorTextoTitulo: Colors.blue,
            colorTextoSubtitulo: Colors.black54,
            esClickeable: true,
            onTap: () {
              print("Botón clickeado");
            },
          ),
        );
      },
    );
  }

  Widget _construirHojaInferiorAdmin(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(FontAwesomeIcons.eye, color: Colors.red),
                onPressed: () {},
              ),
              Text(
                'Admin: ${Provider.of<ProveedorUsuario>(context).nombreUsuario}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _construirAccionesAdmin(context),
        ],
      ),
    );
  }

  Widget _construirAccionesAdmin(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _construirBotonAccionAdmin(
          context,
          texto: 'Asignar Ruta',
          icono: FontAwesomeIcons.route,
          colorFondo: Colors.orange.shade50,
          colorBorde: Colors.orange,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => AsignarRutaPage())),
        ),
        const SizedBox(height: 20),
        _construirBotonAccionAdmin(
          context,
          texto: 'Agregar Camionero',
          icono: FontAwesomeIcons.personCircleCheck,
          colorFondo: Colors.blue.shade50,
          colorBorde: Colors.blue,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const RegisterPage())),
        ),
        const SizedBox(height: 20),
        _construirBotonAccionAdmin(
          context,
          texto: 'Borrar Camionero',
          icono: FontAwesomeIcons.trash,
          colorFondo: Colors.red.shade50,
          colorBorde: Colors.redAccent,
          onTap: () => _delete.borrarCamionero(context),
        ),
        const SizedBox(height: 20),
        _construirBotonAccionAdmin(
          context,
          texto: 'Cerrar Sesion',
          icono: FontAwesomeIcons.rightFromBracket,
          colorFondo: Colors.red.shade50,
          colorBorde: Colors.red,
          onTap: () {
            Provider.of<ProveedorUsuario>(context, listen: false)
                .cerrarSesion(context);
          },
        ),
      ],
    );
  }

  Widget _construirBotonAccionAdmin(
    BuildContext contexto, {
    required String texto,
    required IconData icono,
    required Color colorFondo,
    required Color colorBorde,
    required Function onTap,
  }) {
    return _estilos.botonCustom(
      context: contexto,
      texto: texto,
      icono: icono,
      colorFondo: colorFondo,
      colorBorde: colorBorde,
      colorTexto: colorBorde, // Usamos el color del borde para el texto
      esClickeable: true,
      accion: () => onTap(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProveedorUsuario>(
      builder: (context, proveedorUsuario, child) {
        return Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: GoogleMap(
                onMapCreated: _alCrearMapa,
                initialCameraPosition: CameraPosition(
                  target: _centro,
                  zoom: 15.0,
                ),
                zoomControlsEnabled: false,
                myLocationEnabled: true,
                polylines: Set<Polyline>.of(_polylines),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
                child: FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: false,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext context) {
                        return proveedorUsuario.esAdmin
                            ? _construirHojaInferiorAdmin(context)
                            : _construirHojaInferiorUsuario(context);
                      },
                    );
                  },
                  backgroundColor:
                      proveedorUsuario.esAdmin ? Colors.red : colorPrincipal,
                  heroTag: proveedorUsuario.esAdmin ? "admin" : "config",
                  child: Icon(
                    proveedorUsuario.esAdmin
                        ? FontAwesomeIcons.key
                        : FontAwesomeIcons.bus,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
