class validaciones {
  // Valida un correo electrónico
  static String? validarCorreo(String? email) {
    if (email == null || email.isEmpty) {
      return 'Por favor, ingresa un correo electrónico';
    }

    // Expresión regular mejorada para validar el formato del correo electrónico
    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailRegex).hasMatch(email)) {
      return 'Por favor, ingresa un correo válido';
    }

    return null; // Si el correo es válido
  }

  // Valida una contraseña
  static String? validarContra(String? password) {
    if (password == null || password.isEmpty) {
      return 'Por favor, ingresa una contraseña';
    }

    // Condición mínima para una contraseña segura (longitud >= 8 caracteres)
    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    // Condiciones adicionales (opcional): al menos un número, una letra mayúscula, una minúscula y un carácter especial
    const passwordRegex =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    if (!RegExp(passwordRegex).hasMatch(password)) {
      return 'La contraseña debe contener al menos una mayúscula, una minúscula, un número y un carácter especial';
    }

    return null; // Si la contraseña es válida
  }

  // Valida un nombre
  static String? validarNombre(String? nombre) {
    if (nombre == null || nombre.isEmpty) {
      return 'Por favor, ingresa un nombre';
    }

    // Verificar que el nombre solo contenga letras y espacios, incluyendo caracteres acentuados
    const nombreRegex = r'^[a-zA-ZÀ-ÿ\s]+$';
    if (!RegExp(nombreRegex).hasMatch(nombre)) {
      return 'El nombre solo puede contener letras y espacios';
    }

    return null; // Si el nombre es válido
  }

  // Valida un apellido
  static String? validarApellido(String? apellido) {
    if (apellido == null || apellido.isEmpty) {
      return 'Por favor, ingresa un apellido';
    }

    // Verificar que el apellido solo contenga letras y espacios, incluyendo caracteres acentuados
    const apellidoRegex = r'^[a-zA-ZÀ-ÿ\s]+$';
    if (!RegExp(apellidoRegex).hasMatch(apellido)) {
      return 'El apellido solo puede contener letras y espacios';
    }

    return null; // Si el apellido es válido
  }
}
