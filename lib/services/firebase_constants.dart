class FirebaseConstants {
  // Collections Firestore
  static const String usersCollection = 'users';
  static const String moviesCollection = 'movies';
  static const String reviewsCollection = 'reviews';
  static const String favoritesCollection = 'favorites';

  // Champs utilisateur
  static const String userUid = 'uid';
  static const String userEmail = 'email';
  static const String userDisplayName = 'displayName';
  static const String userPhotoUrl = 'photoUrl';
  static const String userCreatedAt = 'createdAt';
  static const String userLastSignIn = 'lastSignIn';

  // Messages d'erreur
  static const String networkError = 'Erreur de connexion internet';
  static const String unknownError = 'Une erreur inattendue s\'est produite';
  static const String signInSuccess = 'Connexion réussie!';
  static const String signUpSuccess = 'Compte créé avec succès!';
  static const String signOutSuccess = 'Déconnexion réussie!';
}
