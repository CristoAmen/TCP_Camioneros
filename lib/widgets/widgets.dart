import 'package:flutter/material.dart';
import 'package:tcp/pages/validator/validator.dart';

const Color colorPrincipal = Color.fromARGB(255, 1, 31, 10);

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
        'lib/src/img/autenticacion.png',
        height: 300, // ajusta la altura según sea necesario
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
        'lib/src/img/email.png',
        height: 200, // Altura máxima de la imagen
        width: 100, // Ancho máximo de la imagen
      ),
    ),
  );
}

Widget RegistroIMG() {
  return Column(
    children: [
      Image.asset(
        'lib/src/img/registro.png',
        height: 200, // ajusta la altura según sea necesario
        width: 250, // ajusta el ancho según sea necesario
      ),
    ],
  );
}

class Login {
  // Función para crear el campo de correo electrónico
  Widget txtCorreoElectronico({required TextEditingController controller}) {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email, color: Colors.white),
        labelText: 'Correo electrónico',
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white24,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) => validaciones.validarCorreo(value),
    );
  }

// Función para crear el campo de contraseña
  Widget txtContra(bool isPasswordObscure, Function(bool) onVisibilityChanged,
      {required TextEditingController controller}) {
    return StatefulBuilder(
      builder: (context, setState) => TextFormField(
        obscureText: isPasswordObscure,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock, color: Colors.white),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordObscure ? Icons.visibility : Icons.visibility_off,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isPasswordObscure = !isPasswordObscure;
                onVisibilityChanged(isPasswordObscure);
              });
            },
          ),
          labelText: 'Contraseña',
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.white24,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
        validator: (value) => validaciones.validarContra(value),
      ),
    );
  }

// Función para crear el botón de inicio de sesión
  Widget btnInicioSesion(bool isConnected, bool showProgress) {
    return ElevatedButton(
      onPressed: (isConnected && !showProgress)
          ? () {
              // Acción de inicio de sesión simulada
            }
          : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: colorPrincipal,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
      child: const Text(
        'Iniciar Sesión',
        style: TextStyle(
          color: colorPrincipal,
        ),
      ),
    );
  }
}

class Register {
  // Método para crear la página de nombre
  Widget buildNamePage(
      TextEditingController nombreController,
      TextEditingController maternoController,
      TextEditingController paternoController) {
    return Column(
      children: [
        RegistroIMG(),
        const SizedBox(height: 20.0),
        _buildTextField(
          controller: nombreController,
          icon: Icons.supervised_user_circle_outlined,
          label: 'Nombre(s)',
          validator: (value) => validaciones.validarNombre(value),
        ),
        const SizedBox(height: 20.0),
        _buildTextField(
          controller: maternoController,
          icon: Icons.person_outline,
          label: 'Apellido Paterno',
          validator: (value) => validaciones.validarApellido(value),
        ),
        const SizedBox(height: 20.0),
        _buildTextField(
          controller: paternoController,
          icon: Icons.person_outline,
          label: 'Apellido Materno',
          validator: (value) => validaciones.validarApellido(value),
        ),
      ],
    );
  }

  // Método para crear la página de correo electrónico
  Widget buildEmailPage(TextEditingController emailController,
      TextEditingController repeatEmailController) {
    return Column(
      children: [
        PerfilIMG(),
        const SizedBox(height: 20.0),
        _buildTextField(
          controller: emailController,
          icon: Icons.email_outlined,
          label: 'Correo Electrónico',
          validator: (value) => validaciones.validarCorreo(value),
        ),
        const SizedBox(height: 20.0),
        _buildTextField(
          controller: repeatEmailController,
          icon: Icons.email_outlined,
          label: 'Repetir Correo Electrónico',
          validator: (value) => validaciones.validarCorreo(value),
        ),
      ],
    );
  }

  // Método para crear la página de contraseña
  Widget buildPasswordPage(
      TextEditingController passwordController,
      TextEditingController repeatPasswordController,
      bool isPasswordObscure,
      bool isPasswordObscureRepeat,
      Function() togglePasswordVisibility,
      Function() togglePasswordVisibilityRepeat) {
    return Column(
      children: [
        AutenticacionIMG(),
        const SizedBox(height: 20.0),
        _buildPasswordField(
          controller: passwordController,
          label: 'Contraseña',
          isPasswordObscure: isPasswordObscure,
          togglePasswordVisibility: togglePasswordVisibility,
          validator: (value) => validaciones.validarContra(value),
        ),
        const SizedBox(height: 20.0),
        _buildPasswordField(
          controller: repeatPasswordController,
          label: 'Repetir Contraseña',
          isPasswordObscure: isPasswordObscureRepeat,
          togglePasswordVisibility: togglePasswordVisibilityRepeat,
          validator: (value) => validaciones.validarContra(value),
        ),
      ],
    );
  }

  // Campo de texto con validación
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  // Campo de contraseña con validación
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isPasswordObscure,
    required VoidCallback togglePasswordVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPasswordObscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordObscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: togglePasswordVisibility,
        ),
      ),
      validator: validator,
    );
  }
}
