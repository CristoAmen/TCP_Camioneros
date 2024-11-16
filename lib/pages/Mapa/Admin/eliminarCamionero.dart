import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Gestión de Camioneros')),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          deleteCamion().borrarCamionero(context);
        },
        child: const Text("Eliminar Camionero"),
      ),
    );
  }
}

class Camionero {
  String id;
  String nombre;

  Camionero({required this.id, required this.nombre});
}

class deleteCamion {
  // No borra el camionero correctamente
  void borrarCamionero(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Selecciona el/los camionero(s) a eliminar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('empleados')
                        .where('rol', isEqualTo: 'choffer')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text("No hay camioneros disponibles."));
                      }

                      List<Camionero> listaCamioneros =
                          snapshot.data!.docs.map((doc) {
                        return Camionero(
                          id: doc.id,
                          nombre: doc['nombres'],
                        );
                      }).toList();

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: listaCamioneros.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(listaCamioneros[index].nombre[0]),
                            ),
                            title: Text(listaCamioneros[index].nombre),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title:
                                          const Text("Confirmar Eliminación"),
                                      content: Text(
                                          "¿Estás seguro de que deseas eliminar a ${listaCamioneros[index].nombre}?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Cerrar diálogo
                                          },
                                          child: const Text("Cancelar"),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            // Aquí llamamos a la función de eliminación
                                            await eliminarCamionero(
                                                context, listaCamioneros[index],
                                                scaffoldContext: context);
                                            Navigator.of(context)
                                                .pop(); // Cerrar el diálogo
                                          },
                                          child: const Text("Eliminar"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cerrar el modal sin eliminar
                    },
                    child: const Text("Cancelar"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> eliminarCamionero(BuildContext context, Camionero camionero,
      {required BuildContext scaffoldContext}) async {
    try {
      // Eliminar camionero de Firestore
      await FirebaseFirestore.instance
          .collection('empleados')
          .doc(camionero.id)
          .delete();

      // Mostrar mensaje de éxito utilizando el ScaffoldMessenger correcto
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(
          content: Text("Camionero eliminado con éxito."),
        ),
      );
    } catch (e) {
      print(e);
      // Mostrar mensaje de error
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(
          content: Text("Error al eliminar el camionero."),
        ),
      );
    }
  }
}
