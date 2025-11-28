import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../screens/splash_screen.dart';
import '../screens/sign_in_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Affichage pendant le chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // Si l'utilisateur est connecté
        if (snapshot.hasData && snapshot.data != null) {
          // TODO: Remplacer par votre page d'accueil principale
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 80),
                  SizedBox(height: 20),
                  Text(
                    'Vous êtes connecté!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Page principale à venir...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        // Si l'utilisateur n'est pas connecté
        return const SignInScreen();
      },
    );
  }
}
