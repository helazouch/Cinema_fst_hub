import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Configuration pour le web - nécessite un Client ID valide
    clientId: const String.fromEnvironment(
      'GOOGLE_CLIENT_ID',
      defaultValue: '',
    ),
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream pour écouter les changements d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Inscription avec email et mot de passe
  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Créer un document utilisateur dans Firestore
      await _createUserDocument(result.user);

      return result;
    } catch (e) {
      print('Erreur d\'inscription: $e');
      rethrow;
    }
  }

  // Connexion avec email et mot de passe
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Erreur de connexion: $e');
      rethrow;
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      print('Erreur de déconnexion: $e');
      rethrow;
    }
  }

  // Vérifier si Google Sign-In est disponible
  bool get isGoogleSignInAvailable {
    const clientId = String.fromEnvironment(
      'GOOGLE_CLIENT_ID',
      defaultValue: '',
    );
    return clientId.isNotEmpty;
  }

  // Connexion avec Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (!isGoogleSignInAvailable) {
        throw Exception(
          'Google Sign-In n\'est pas configuré. Veuillez configurer GOOGLE_CLIENT_ID.',
        );
      }

      // Déclencher le processus d'authentification
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // L'utilisateur a annulé la connexion
        return null;
      }

      // Obtenir les détails d'authentification de la demande
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Créer un nouvel identifiant
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Se connecter avec l'identifiant
      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      // Créer ou mettre à jour le document utilisateur
      await _createUserDocument(result.user);

      return result;
    } catch (e) {
      print('Erreur de connexion Google: $e');
      rethrow;
    }
  }

  // Inscription avec Google (même processus que la connexion)
  Future<UserCredential?> signUpWithGoogle() async {
    try {
      if (!isGoogleSignInAvailable) {
        throw Exception(
          'Google Sign-In n\'est pas configuré. Veuillez configurer GOOGLE_CLIENT_ID.',
        );
      }

      // Le processus d'inscription avec Google est identique à la connexion
      return await signInWithGoogle();
    } catch (e) {
      print('Erreur d\'inscription Google: $e');
      rethrow;
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Erreur de réinitialisation: $e');
      rethrow;
    }
  }

  // Créer un document utilisateur dans Firestore
  Future<void> _createUserDocument(User? user) async {
    if (user != null) {
      DocumentReference userDoc = _firestore.collection('users').doc(user.uid);

      // Vérifier si le document existe déjà
      DocumentSnapshot docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName ?? 'Utilisateur',
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastSignIn': FieldValue.serverTimestamp(),
          'authProvider': _getAuthProvider(user),
        });
      } else {
        // Mettre à jour la dernière connexion
        await userDoc.update({
          'lastSignIn': FieldValue.serverTimestamp(),
          'displayName':
              user.displayName ??
              docSnapshot.get('displayName') ??
              'Utilisateur',
          'photoURL': user.photoURL ?? docSnapshot.get('photoURL'),
        });
      }
    }
  }

  // Déterminer le fournisseur d'authentification
  String _getAuthProvider(User user) {
    for (UserInfo info in user.providerData) {
      if (info.providerId == 'google.com') {
        return 'Google';
      } else if (info.providerId == 'password') {
        return 'Email/Password';
      }
    }
    return 'Inconnu';
  }

  // Obtenir les données utilisateur depuis Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Erreur de récupération des données utilisateur: $e');
      return null;
    }
  }

  // Mettre à jour les données utilisateur
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Erreur de mise à jour des données utilisateur: $e');
      rethrow;
    }
  }

  // Vérifier si l'email existe déjà
  Future<bool> isEmailAlreadyInUse(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Gestion des erreurs Firebase
  String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'weak-password':
          return 'Le mot de passe est trop faible.';
        case 'email-already-in-use':
          return 'Un compte existe déjà avec cette adresse email.';
        case 'invalid-email':
          return 'L\'adresse email n\'est pas valide.';
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cette adresse email.';
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        case 'user-disabled':
          return 'Ce compte a été désactivé.';
        case 'too-many-requests':
          return 'Trop de tentatives. Veuillez réessayer plus tard.';
        case 'network-request-failed':
          return 'Erreur de connexion. Vérifiez votre connexion internet.';
        default:
          return 'Une erreur s\'est produite: ${error.message}';
      }
    }
    return 'Une erreur inattendue s\'est produite.';
  }
}
