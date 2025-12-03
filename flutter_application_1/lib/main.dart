import 'package:flutter/material.dart';
import 'package:flutter_application_1/cart.dart';
import 'loading_user.dart';
import 'login.dart';
import 'mesas.dart';
import 'mensaje.dart';
import 'login_cliente.dart';
import 'home.dart';
import 'loading.dart'; // Importa la página de carga

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Oculta la marca de depuración
      initialRoute: '/', // Ruta inicial de la aplicación
      routes: {
        // Ruta principal: Login
        '/': (context) => const LoginPage(),

        // Ruta de selección de mesas
        '/tables': (context) => const TableSelectionPage(),

        // Ruta de mensajes al cliente
        '/mensaje': (context) => const MensajePage(),

        // Login de cliente
        '/login_cliente': (context) => const LoginClientePage(),

        // Pantalla de carga general
        '/loading': (context) => const LoadingPage(),

        // Pantalla de inicio principal
        '/home': (context) => const HomePage(),

        // Pantalla de carga específica para usuario
        '/loading_user': (context) => const LoadingPageUser(),

        // Ruta redundante del login (puedes eliminarla si no es necesaria)
        '/loginpage': (context) => const LoginPage(),

        '/cart': (context) => const Cart(),
      },
      // Agregar un tema básico para personalizar la aplicación
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
