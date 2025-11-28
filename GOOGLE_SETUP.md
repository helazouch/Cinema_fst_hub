# Configuration Google Sign-In pour Cinema FST Hub

## 🎯 État actuel

✅ **Code implémenté** : Les méthodes Google Sign-In sont intégrées dans l'application  
⚠️ **Configuration nécessaire** : Vous devez configurer le Client ID Google pour activer l'authentification

Pour activer l'authentification Google dans votre application Flutter, suivez ces étapes :

### 1. Configuration Firebase Console

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet `cinema_fst_hub`
3. Allez dans **Authentication** > **Sign-in method**
4. Cliquez sur **Google** et activez-le
5. Ajoutez votre email de support

### 2. Configuration Web (Chrome)

Pour la plateforme web, vous devez :

1. Dans Firebase Console, allez dans **Project Settings**
2. Dans l'onglet **General**, trouvez la section **Your apps**
3. Cliquez sur l'icône Web et ajoutez votre domaine autorisé :
   - Pour le développement : `http://localhost`, `http://127.0.0.1`
   - Pour la production : votre domaine réel

### 3. Configuration Android (si nécessaire)

1. Téléchargez le fichier `google-services.json` depuis Firebase Console
2. Placez-le dans `android/app/`
3. Assurez-vous que le SHA-1 de votre certificat de débogage est ajouté dans Firebase Console

### 4. Configuration iOS (si nécessaire)

1. Téléchargez le fichier `GoogleService-Info.plist` depuis Firebase Console
2. Placez-le dans `ios/Runner/`
3. Ajoutez l'URL scheme dans `ios/Runner/Info.plist`

### 5. Variables d'environnement importantes

Dans le fichier `lib/firebase_options.dart`, assurez-vous que les valeurs suivantes sont correctes :

- `apiKey` : Votre clé API Firebase
- `appId` : L'ID de votre application
- `messagingSenderId` : L'ID de votre expéditeur de messages
- `projectId` : L'ID de votre projet Firebase

### 6. Test de l'authentification

Une fois configuré :

1. **Sign In avec Google** : Cliquez sur le bouton Google dans l'écran de connexion
2. **Sign Up avec Google** : Cliquez sur le bouton Google dans l'écran d'inscription
3. **Déconnexion** : Utilisez le bouton de déconnexion dans l'écran d'accueil

### Méthodes disponibles dans AuthService

```dart
// Connexion avec Google
await authService.signInWithGoogle();

// Inscription avec Google (même processus)
await authService.signUpWithGoogle();

// Déconnexion (supprime aussi la session Google)
await authService.signOut();
```

### Gestion des erreurs

L'application gère automatiquement :

- Annulation de l'utilisateur
- Erreurs réseau
- Erreurs d'authentification
- Comptes déjà existants

### Notes importantes

- L'authentification Google web nécessite une connexion internet
- Les utilisateurs peuvent annuler le processus d'authentification
- Les données utilisateur sont automatiquement sauvegardées dans Firestore
- La déconnexion supprime à la fois la session Firebase et Google

## Fichiers modifiés

- `lib/services/auth_service.dart` : Ajout des méthodes Google
- `lib/screens/sign_in_screen.dart` : Intégration Google Sign-In
- `lib/screens/sign_up_screen.dart` : Intégration Google Sign-Up
- `pubspec.yaml` : Ajout de la dépendance `google_sign_in`
