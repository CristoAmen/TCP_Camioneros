import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:tcp/pages/Login_Page.dart';
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

class SinConexion {
  static void mostrarDialogo(BuildContext context, VoidCallback onRetry) {
    PanaraInfoDialog.show(
      context,
      title: "Sin conexión a Internet",
      message: "No tienes conexión a Internet. ¿Quieres reintentar?",
      buttonText: "Reintentar",
      onTapDismiss: () {
        Navigator.of(context).pop();
        onRetry(); // Llamada a la función para reintentar la conexión
      },
      panaraDialogType: PanaraDialogType.error,
      barrierDismissible: false,
    );
  }
}

class interacciones {
  static void errorCuenta(BuildContext context, VoidCallback onRetry) {
    PanaraInfoDialog.show(
      context,
      title: "Hemos tuvido un problema",
      message: "Posiblemente se elimino tu cuento o haya sido desabilitado",
      buttonText: "Ir a Login",
      onTapDismiss: () {
        Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
      },
      panaraDialogType: PanaraDialogType.error,
      barrierDismissible: false,
    );
  }
}

class Estilos {
  Widget botonCustom({
    required BuildContext context,
    required String texto,
    String? subtitulo,
    IconData? icono,
    Color colorFondo = const Color(0xFFF3E5F5),
    Color colorBorde = Colors.purple,
    Color colorTexto = Colors.purple,
    Color colorSubtitulo = Colors.black54,
    bool esClickeable = true,
    VoidCallback? accion,
  }) {
    final size = MediaQuery.of(context).size;
    final hasSubtitulo = subtitulo != null && subtitulo.isNotEmpty;

    Widget textoWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          texto,
          style: TextStyle(
            fontSize: size.width * (hasSubtitulo ? 0.035 : 0.045),
            fontWeight: FontWeight.bold,
            color: colorTexto,
          ),
        ),
        if (hasSubtitulo)
          Text(
            subtitulo,
            style: TextStyle(
              fontSize: size.width * 0.03,
              color: colorSubtitulo,
            ),
          ),
      ],
    );

    final contenido = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icono != null) ...[
          Icon(icono, color: colorTexto, size: size.width * 0.06),
          SizedBox(width: size.width * 0.02),
        ],
        Flexible(child: textoWidget),
      ],
    );

    final widgetBase = Container(
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
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.02,
        horizontal: size.width * 0.04,
      ),
      child: Center(child: contenido),
    );

    return esClickeable
        ? InkWell(
            onTap: accion,
            borderRadius: BorderRadius.circular(12),
            child: widgetBase,
          )
        : widgetBase;
  }

  // Método para obtener un tamaño de letra responsivo
  double obtenerTamanioLetra(BuildContext context, double porcentaje) {
    final size = MediaQuery.of(context).size;
    // Limitar el tamaño mínimo y máximo
    return (size.width * porcentaje)
        .clamp(12.0, 24.0); // Ajusta según necesites
  }

  // Método para crear un botón de iniciar ruta
  Widget botonIniciarRuta({
    required BuildContext context,
    required String texto,
    required VoidCallback accion,
    required Color colorFondo,
    required Color colorTexto,
    double bordeCircular = 30.0,
    double elevacion = 5.0,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 15),
  }) {
    return ElevatedButton(
      onPressed: accion,
      style: ElevatedButton.styleFrom(
        foregroundColor: colorTexto,
        backgroundColor: colorFondo,
        elevation: elevacion,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(bordeCircular),
        ),
        padding: padding,
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize:
              obtenerTamanioLetra(context, 0.045), // Tamaño de letra responsivo
        ),
      ),
    );
  }

  // Método general para crear un contenedor con opción de ser clickeable
  Widget contenedorBoton({
    required BuildContext context,
    required Color colorFondo,
    required Color colorBorde,
    required String titulo,
    required String subtitulo,
    required Color colorTexto,
    bool esClickeable = false,
    VoidCallback? onTap,
  }) {
    final contenedor = Container(
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
              fontSize: obtenerTamanioLetra(
                  context, 0.04), // Tamaño de letra responsivo
              fontWeight: FontWeight.bold,
              color: colorTexto,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitulo,
            style: TextStyle(
              fontSize: obtenerTamanioLetra(
                  context, 0.035), // Tamaño de letra responsivo
            ),
          ),
        ],
      ),
    );

    return esClickeable
        ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: contenedor,
          )
        : contenedor;
  }

  // Botón personalizado
  Widget botonPersonalizado({
    required BuildContext context,
    required String texto,
    required Color colorPrincipal,
    double borderRadius = 30,
    double paddingVertical = 15,
    bool esClickeable = true,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: esClickeable ? onPressed : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: colorPrincipal,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: EdgeInsets.symmetric(vertical: paddingVertical),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize:
              obtenerTamanioLetra(context, 0.045), // Tamaño de letra responsivo
        ),
      ),
    );
  }

  // Módulo para mostrar la ruta seleccionada
  Widget botonSubtitulos({
    required BuildContext context,
    required String titulo,
    required String subtitulo,
    Color colorFondo = colorPrincipal,
    Color colorBorde = Colors.green,
    Color colorTextoTitulo = Colors.green,
    Color colorTextoSubtitulo = Colors.black,
    bool esClickeable = false,
    VoidCallback? onTap,
  }) {
    final contenedor = Container(
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
              fontSize: obtenerTamanioLetra(
                  context, 0.04), // Tamaño de letra responsivo
              fontWeight: FontWeight.bold,
              color: colorTextoTitulo,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitulo,
            style: TextStyle(
              fontSize: obtenerTamanioLetra(
                  context, 0.035), // Tamaño de letra responsivo
              color: colorTextoSubtitulo,
            ),
          ),
        ],
      ),
    );

    // Si es clickeable, envolvemos en InkWell
    return esClickeable
        ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: contenedor,
          )
        : contenedor; // Si no es clickeable, devolvemos solo el contenedor
  }
}

class Estilos2 {
  Widget botonIniciarRuta({
    required BuildContext context,
    required String texto,
    required VoidCallback accion,
    Color colorFondo = Colors.green,
    Color colorTexto = Colors.white,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorFondo,
        foregroundColor: colorTexto,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: accion,
      child: Text(
        texto,
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget botonSubtitulos({
    required BuildContext context,
    required String titulo,
    required String subtitulo,
    Color colorFondo = Colors.white,
    Color colorBorde = Colors.grey,
    Color colorTextoTitulo = Colors.black,
    Color colorTextoSubtitulo = Colors.grey,
    bool esClickeable = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: esClickeable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorFondo,
          border: Border.all(color: colorBorde),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorTextoTitulo,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitulo,
              style: TextStyle(
                fontSize: 14,
                color: colorTextoSubtitulo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget botonCustom({
    required BuildContext context,
    required String texto,
    required IconData icono,
    Color colorFondo = Colors.white,
    Color colorBorde = Colors.grey,
    Color colorTexto = Colors.black,
    bool esClickeable = true,
    VoidCallback? accion,
  }) {
    return InkWell(
      onTap: esClickeable ? accion : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: colorFondo,
          border: Border.all(color: colorBorde),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: colorTexto),
            const SizedBox(width: 8),
            Text(
              texto,
              style: TextStyle(
                color: colorTexto,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Sesion Login

// Clase de errores para centralizar los mensajes de error
class ErrorMessages {
  static const String invalidEmail =
      'El formato del correo electrónico no es válido.';
  static const String userDisabled =
      'Esta cuenta de usuario ha sido deshabilitada.';
  static const String userNotFound =
      'No se encontró ningún usuario con este correo electrónico.';
  static const String wrongPassword = 'La contraseña es incorrecta.';
  static const String tooManyRequests =
      'Demasiados intentos fallidos. Intente más tarde.';
  static const String networkRequestFailed =
      'Error de red. Verifique su conexión.';
  static const String unknownError = 'Ocurrió un error inesperado.';
}

class Login {
  // Función para crear el campo de correo electrónico
  Widget txtCorreoElectronico({required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
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

  // Función para crear el botón de inicio de sesión
  Widget btnInicioSesion(
    bool isConnected,
    bool showProgress,
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    TextEditingController passwordController,
    FirebaseAuth auth,
    BuildContext context,
    VoidCallback setProgressTrue,
    VoidCallback setProgressFalse,
    Function(String) showSnackBar,
  ) {
    return ElevatedButton(
      onPressed: (isConnected && !showProgress)
          ? () async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              setProgressTrue();

              final email = emailController.text.trim();
              final password = passwordController.text.trim();

              try {
                final UserCredential userCredential =
                    await auth.signInWithEmailAndPassword(
                  email: email,
                  password: password,
                );

                if (userCredential.user != null) {
                  Navigator.of(context).pushReplacementNamed('/mapa');
                }
              } on FirebaseAuthException catch (e) {
                String errorMessage;
                switch (e.code) {
                  case 'invalid-email':
                    errorMessage = ErrorMessages.invalidEmail;
                    break;
                  case 'user-disabled':
                    errorMessage = ErrorMessages.userDisabled;
                    break;
                  case 'user-not-found':
                    errorMessage = ErrorMessages.userNotFound;
                    break;
                  case 'wrong-password':
                    errorMessage = ErrorMessages.wrongPassword;
                    break;
                  case 'too-many-requests':
                    errorMessage = ErrorMessages.tooManyRequests;
                    break;
                  case 'network-request-failed':
                    errorMessage = ErrorMessages.networkRequestFailed;
                    break;
                  default:
                    errorMessage = ErrorMessages.unknownError;
                }
                showSnackBar(errorMessage);
              } catch (e) {
                showSnackBar(ErrorMessages.unknownError);
              } finally {
                setProgressFalse();
              }
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
      child: Text(
        showProgress ? 'Iniciando sesión...' : 'Iniciar Sesión',
        style: const TextStyle(
          color: colorPrincipal,
        ),
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  final bool isPasswordObscure;
  final Function(bool) onVisibilityChanged;
  final TextEditingController controller;

  const PasswordField({
    required this.isPasswordObscure,
    required this.onVisibilityChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPasswordObscure,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: Colors.white),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordObscure ? Icons.visibility : Icons.visibility_off,
            color: Colors.white,
          ),
          onPressed: () {
            onVisibilityChanged(!isPasswordObscure);
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
    );
  }
}
