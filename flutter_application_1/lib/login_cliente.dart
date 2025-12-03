import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class LoginClientePage extends StatefulWidget {
  const LoginClientePage({super.key});

  @override
  _LoginClientePageState createState() => _LoginClientePageState();
}

class _LoginClientePageState extends State<LoginClientePage> {
  double _topContainerHeight = 400;
  double _logoOpacity = 1.0;
  double _logoContainer = 300;

  Offset _columnOffset = Offset.zero; // Animación de desplazamiento

  void _navigateToLoading() {
    Navigator.pushReplacementNamed(context, '/loading');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          // Fondo animado superior
          SlideInDown(
            duration: const Duration(seconds: 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              height: _topContainerHeight,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/img/dinnerfond.webp'),
                  fit: BoxFit.cover,
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                  bottomRight: Radius.circular(100),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.redAccent.withOpacity(0.7),
                        Colors.redAccent.withOpacity(0.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _logoOpacity,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/img/logodin.png',
                            height: _logoContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Contenido principal con Slide
          AnimatedSlide(
            offset: _columnOffset,
            duration: const Duration(milliseconds: 800),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 50.0),

                  // Contenedor negro de bienvenida
                  SlideInUp(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 450.0, left: 30.0, right: 30.0),
                      child: SlideInUp(
                        duration: const Duration(seconds: 1),
                        child: Container(
                          padding: const EdgeInsets.all(25.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(235, 49, 47, 47),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                const Text(
                                  'Bienvenido, ¿Listo para ordenar?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20.0),

                                // BOTÓN INGRESAR
                                ElevatedButton(
                                  onPressed: () {
                                    Future.delayed(const Duration(seconds: 1),
                                        () {
                                      Navigator.pushReplacementNamed(
                                          context, '/loading');
                                    });

                                    setState(() {
                                      _topContainerHeight = 0;
                                      _logoOpacity = 0.0;
                                      _logoContainer = 0;
                                      _columnOffset = const Offset(0, 2);
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 100, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  child: const Text(
                                    'Ingresar',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
