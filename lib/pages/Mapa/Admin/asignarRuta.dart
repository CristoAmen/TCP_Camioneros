import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcp/widgets/widgets.dart';

class asignarRuta {
  void irAsignarRuta(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AsignarRutaPage()),
    );
  }
}

class AsignarRutaPage extends StatefulWidget {
  @override
  _AsignarRutaPageState createState() => _AsignarRutaPageState();
}

class _AsignarRutaPageState extends State<AsignarRutaPage> {
  String? empleadoSeleccionado;
  String? rutaSeleccionada;
  bool isLoading = false;

  final Map<String, List<String>> horariosTurnos = {
    'Turno Matutino': [
      '5:00 a.m. - 9:00 a.m.: Conducción',
      '9:30 a.m. - 1:00 p.m.: Conducción',
    ],
    'Turno Vespertino': [
      '1:00 p.m. - 5:00 p.m.: Conducción',
      '5:30 p.m. - 9:00 p.m.: Conducción',
    ],
    'Turno Nocturno': [
      '9:00 p.m. - 11:00 p.m.: Conducción',
    ],
  };

  String? turnoSeleccionado;
  List<String> horariosDelTurno = [];

  List<Map<String, dynamic>> empleados = [];

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('empleados')
          .where('rol', isEqualTo: 'choffer')
          .get();

      empleados = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nombre': doc['nombres'],
          'paterno': doc['paterno'],
          'materno': doc['materno'],
        };
      }).toList();
    } catch (e) {
      print('Error al cargar empleados: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar empleados')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (empleadoSeleccionado == null ||
        rutaSeleccionada == null ||
        turnoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Actualizar el documento del empleado en Firestore
      await FirebaseFirestore.instance
          .collection('empleados')
          .doc(empleadoSeleccionado)
          .update({
        'rutaAsignada': rutaSeleccionada,
        'turnoAsignado': turnoSeleccionado,
        'fechaAsignacion': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Asignación guardada exitosamente')),
      );

      // Opcional: regresar a la pantalla anterior
      Navigator.pop(context);
    } catch (e) {
      print('Error al guardar cambios: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar los cambios')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asignar Ruta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading) LinearProgressIndicator(),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
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
              onChanged: (newValue) {
                setState(() {
                  empleadoSeleccionado = newValue;
                });
              },
              value: empleadoSeleccionado,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Seleccionar Ruta',
                border: OutlineInputBorder(),
              ),
              items: <Map<String, String>>[
                {'id': 'Rut_PradosSol.kml', 'nombre': 'Prados del Sol'},
                {
                  'id': 'Rut_HogarDelPescador.kml',
                  'nombre': 'Hogar del Pescador'
                },
                {'id': 'Rut_AlarconSabalo.kml', 'nombre': 'Alarcón Sábalo'},
              ].map((ruta) {
                return DropdownMenuItem<String>(
                  value: ruta['id'],
                  child: Text(ruta['nombre']!),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  rutaSeleccionada = newValue;
                });
              },
              value: rutaSeleccionada,
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Seleccionar Turno',
                border: OutlineInputBorder(),
              ),
              items: [
                'Turno Matutino',
                'Turno Vespertino',
                'Turno Nocturno',
              ].map((String turno) {
                return DropdownMenuItem<String>(
                  value: turno,
                  child: Text(turno),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  turnoSeleccionado = newValue;
                  horariosDelTurno = horariosTurnos[turnoSeleccionado] ?? [];
                });
              },
              value: turnoSeleccionado,
            ),
            SizedBox(height: 20),
            if (turnoSeleccionado != null) ...[
              Text(
                'Horarios del $turnoSeleccionado:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...horariosDelTurno.map((horario) => Text(horario)).toList(),
            ],
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Estilos().botonIniciarRuta(
                  context: context,
                  texto: "Guardar Cambios",
                  accion: _guardarCambios,
                  colorFondo: const Color.fromARGB(255, 24, 95, 45),
                  colorTexto: Color.fromRGBO(255, 255, 255, 1.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
