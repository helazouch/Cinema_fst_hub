import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'sign_in_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Méthode pour obtenir le fournisseur d'authentification
  String _getAuthProvider(User user) {
    for (UserInfo info in user.providerData) {
      if (info.providerId == 'google.com') {
        return 'Google';
      } else if (info.providerId == 'password') {
        return 'Email/Mot de passe';
      } else if (info.providerId == 'apple.com') {
        return 'Apple';
      } else if (info.providerId == 'facebook.com') {
        return 'Facebook';
      }
    }
    return 'Inconnu';
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinema FST Hub'),
        backgroundColor: const Color(0xFF6B46C1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, size: 100, color: Color(0xFF6B46C1)),
            const SizedBox(height: 20),
            Text(
              'Bienvenue dans Cinema FST Hub!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF6B46C1),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Vous êtes connecté avec succès.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            if (authService.currentUser != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Photo de profil si disponible (Google)
                    if (authService.currentUser!.photoURL != null) ...[
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          authService.currentUser!.photoURL!,
                        ),
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(height: 15),
                    ],

                    // Nom d'affichage (surtout pour Google)
                    if (authService.currentUser!.displayName != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, color: Colors.grey[600], size: 16),
                          const SizedBox(width: 8),
                          Text(
                            authService.currentUser!.displayName!,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Email
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            authService.currentUser!.email ?? 'Non disponible',
                            style: TextStyle(color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Fournisseur d'authentification
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.security, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Via ${_getAuthProvider(authService.currentUser!)}',
                          style: TextStyle(
                            color: const Color(0xFF6B46C1),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ID utilisateur (affiché plus petit)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ID: ${authService.currentUser!.uid}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
