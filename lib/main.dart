import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tcp/config/Metodos_Firebase.dart';
import 'package:tcp/config/firebase_options.dart';
import 'package:tcp/pages/Home_Page.dart';
import 'package:tcp/pages/Login_Page.dart';
import 'package:tcp/pages/Perfil_Page.dart';
import 'package:tcp/pages/Register_Page.dart';
import 'package:tcp/pages/splash_screen.dart';

// Instancias de mis archivos
void main() async {
  const Color colorPrincipal = Color.fromARGB(255, 1, 31, 10);

  // Asegúrate de que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquear orientación solo en vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    // Inicializa Firebase con las opciones predeterminadas de la plataforma
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Ejecuta la aplicación
    runApp(const MyApp(colorPrincipal: colorPrincipal));
  } catch (e) {
    // Maneja cualquier error al inicializar Firebase
    print('Error al inicializar Firebase: $e');
    // Podrías mostrar un Snackbar o un AlertDialog aquí para informar al usuario sobre el error.
  }
}

class MyApp extends StatelessWidget {
  final Color colorPrincipal;

  const MyApp({super.key, required this.colorPrincipal});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Proveedores para la autenticación y el estado de la autenticación
      providers: [
        // Proveedor para la clase de métodos de autenticación de Firebase
        Provider<AuthenticationMethods>(
          create: (_) => AuthenticationMethods(
            FirebaseAuth.instance,
            FirebaseFirestore.instance, // Pasar instancia de FirebaseFirestore
          ),
        ),
        // Proveedor de Stream para escuchar cambios en el estado de la autenticación
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationMethods>().authStateChanges,
          initialData: null,
        ),
      ],
      // MaterialApp que representa la aplicación
      child: MaterialApp(
        title: 'TCP', // Título de la aplicación
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child!,
              );
            },
          );
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: colorPrincipal,
          ),
        ),
        home: const AuthWrapper(), // Página inicial de la aplicación
        // Definición de rutas para la navegación
        routes: {
          LoginPage.routeName: (context) => const LoginPage(),
          RegisterPage.routeName: (context) => const RegisterPage(),
          SplashPage.routeName: (context) => const SplashPage(),
          HomePage.routeName: (context) => const HomePage(),
          PerfilPage.routeName: (context) => const PerfilPage()
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      // Si el usuario no está autenticado, mostrar la página de splash/login
      return const SplashPage();
    } else {
      // Si el usuario está autenticado, verificamos si existe en Firestore
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('empleados')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Mostrar un indicador de carga
          }

          if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Ocurrió un error: ${snapshot.error}')); // Mostrar un error si ocurre
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Si el documento no existe, redirigir a la página de inicio de sesión
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
            });
            return const SizedBox
                .shrink(); // No mostrar nada mientras se redirige
          }

          // Si el documento existe, redirigir a la página de inicio
          return const HomePage(); // Puedes cambiar a la página deseada
        },
      );
    }
  }
}
