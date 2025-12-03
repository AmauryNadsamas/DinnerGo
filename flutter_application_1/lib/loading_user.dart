import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class LoadingPageUser extends StatelessWidget {
  const LoadingPageUser({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login_cliente');
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ZoomIn(
          duration: const Duration(seconds: 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/img/Serve-unscreen.gif'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
