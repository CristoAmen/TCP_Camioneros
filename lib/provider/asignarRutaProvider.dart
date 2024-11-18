import 'package:cloud_firestore/cloud_firestore.dart';

class AsignarRutaProvider {
  /// Carga los empleados con el rol de "chofer" desde Firebase
  static Future<List<Map<String, dynamic>>> cargarEmpleados() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('empleados')
          .where('rol', isEqualTo: 'choffer')
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'nombre': doc['nombres'],
          'paterno': doc['paterno'],
          'materno': doc['materno'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Error al cargar empleados: $e');
    }
  }

  /// Actualiza la información del empleado con la ruta y el turno asignados
  static Future<void> guardarAsignacion({
    required String empleadoId,
    required String ruta,
    required String turno,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('empleados')
          .doc(empleadoId)
          .update({
        'rutaAsignada': ruta,
        'turnoAsignado': turno,
        'fechaAsignacion': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al guardar los cambios: $e');
    }
  }
}
