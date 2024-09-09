import 'package:flutter/material.dart';

// MI BOTON
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onTap,
    required this.text,
  });
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 40),
      ),
      onPressed: onTap,
      child: Text(text),
    );
  }
}

// BOTON BASADO EN MI SQUEMA
class AppButtonStyle {
  AppButtonStyle(BuildContext context);

  static ButtonStyle elevatedButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    );
  }
}

// IMAGENES
Widget logotipo() {
  return Column(
    children: [
      Image.asset(
        'lib/src/img/imfine.png',
        height: 100, // ajusta la altura según sea necesario
        width: 100, // ajusta el ancho según sea necesario
      ),
    ],
  );
}

Widget AutenticacionIMG() {
  return Column(
    children: [
      Image.asset(
        'lib/src/img/authentication.png',
        height: 200, // ajusta la altura según sea necesario
        width: 200, // ajusta el ancho según sea necesario
      ),
    ],
  );
}

Widget PerfilIMG() {
  return AspectRatio(
    aspectRatio: 1, // Relación de aspecto 1:1 (cuadrada)
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        'lib/src/img/Perfil.png',
        fit: BoxFit
            .contain, // Ajusta la imagen para que se ajuste dentro del espacio disponible
        height: 100, // Altura máxima de la imagen
        width: 100, // Ancho máximo de la imagen
      ),
    ),
  );
}

Widget RegistroIMG() {
  return Column(
    children: [
      Image.asset(
        'lib/src/img/REGISTRATION.png',
        height: 100, // ajusta la altura según sea necesario
        width: 100, // ajusta el ancho según sea necesario
      ),
    ],
  );
}

Widget TextFieldContra({
  required TextEditingController controller,
  required String labelText,
  required IconData prefixIcon,
  required bool obscureText,
  required Function()? onPressedSuffixIcon,
  required String? Function(String?)? validator,
  void Function(String)? onChanged, // Make onChanged optional by adding '?'
}) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.text,
    obscureText: obscureText,
    decoration: InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: IconButton(
        icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: onPressedSuffixIcon,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
    ),
    validator: validator,
    onChanged: onChanged, // Pass the onChanged function to the TextFormField
  );
}

Widget TextFieldMod({
  required TextEditingController controller,
  required String labelText,
  required IconData prefixIcon,
  required bool obscureText,
  required String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.text,
    obscureText: obscureText,
    decoration: InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(prefixIcon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
    ),
    validator: validator,
  );
}
