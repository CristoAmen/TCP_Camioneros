import 'package:flutter/material.dart';
import 'package:tcp/provider/asignarRutaProvider.dart';
import 'package:tcp/widgets/widgets.dart';

class AsignarRutaPage extends StatefulWidget {
  @override
  _AsignarRutaPageState createState() => _AsignarRutaPageState();
  static const String routeName = '/asignarRuta';
}

class _AsignarRutaPageState extends State<AsignarRutaPage> {
  String? empleadoSeleccionado;
  String? rutaSeleccionada;
  String? turnoSeleccionado;
  List<String> horariosDelTurno = [];
  List<Map<String, dynamic>> empleados = [];
  bool isLoading = false;

  final Map<String, List<String>> horariosTurnos = {
    'Turno Matutino': ['5:00 a.m. - 9:00 a.m.', '9:30 a.m. - 1:00 p.m.'],
    'Turno Vespertino': ['1:00 p.m. - 5:00 p.m.', '5:30 p.m. - 9:00 p.m.'],
    'Turno Nocturno': ['9:00 p.m. - 11:00 p.m.'],
  };

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    setState(() => isLoading = true);
    try {
      empleados = await AsignarRutaProvider.cargarEmpleados();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _guardarCambios() async {
    if (empleadoSeleccionado == null ||
        rutaSeleccionada == null ||
        turnoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await AsignarRutaProvider.guardarAsignacion(
        empleadoId: empleadoSeleccionado!,
        ruta: rutaSeleccionada!,
        turno: turnoSeleccionado!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Asignación guardada exitosamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asignar Ruta'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCard(
                      titulo: 'Empleado',
                      contenido: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Seleccionar Empleado',
                          border: OutlineInputBorder(),
                        ),
                        items: empleados.map((empleado) {
                          String nombreCompleto =
                              '${empleado['nombre']} ${empleado['paterno']} ${empleado['materno']}';
                          return DropdownMenuItem<String>(
                            value: empleado['id'],
                            child: Text(nombreCompleto),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => empleadoSeleccionado = value),
                        value: empleadoSeleccionado,
                      ),
                    ),
                    _buildCard(
                      titulo: 'Ruta',
                      contenido: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Seleccionar Ruta',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          {'id': 'Rut_PradosSol', 'nombre': 'Prados del Sol'},
                          {
                            'id': 'Rut_Hogar del pescador',
                            'nombre': 'Hogar del Pescador'
                          },
                          {
                            'id': 'Rut_AlarconSabalo',
                            'nombre': 'Alarcón Sábalo'
                          },
                        ].map((ruta) {
                          return DropdownMenuItem<String>(
                            value: ruta['id'],
                            child: Text(ruta['nombre']!),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => rutaSeleccionada = value),
                        value: rutaSeleccionada,
                      ),
                    ),
                    _buildCard(
                      titulo: 'Turno',
                      contenido: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Seleccionar Turno',
                          border: OutlineInputBorder(),
                        ),
                        items: horariosTurnos.keys.map((turno) {
                          return DropdownMenuItem<String>(
                            value: turno,
                            child: Text(turno),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            turnoSeleccionado = value;
                            horariosDelTurno =
                                horariosTurnos[turnoSeleccionado] ?? [];
                          });
                        },
                        value: turnoSeleccionado,
                      ),
                    ),
                    if (horariosDelTurno.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Horarios del $turnoSeleccionado:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            ...horariosDelTurno.map((horario) => Text(horario)),
                          ],
                        ),
                      ),
                    SizedBox(height: 20),
                    Center(
                      child: Estilos().botonIniciarRuta(
                        context: context,
                        texto: 'Guardar Cambios',
                        accion: _guardarCambios,
                        colorFondo: Theme.of(context).primaryColor,
                        colorTexto: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCard({required String titulo, required Widget contenido}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            contenido,
          ],
        ),
      ),
    );
  }
}
