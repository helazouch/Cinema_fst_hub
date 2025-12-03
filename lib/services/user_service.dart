import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Récupérer un utilisateur par ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  // Stream d'un utilisateur
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Mettre à jour un utilisateur
  Future<bool> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(uid).update(data);
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'utilisateur: $e');
      return false;
    }
  }

  // Ajouter un film aux favoris
  Future<bool> addToFavorites(String uid, String movieId) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'favoriteMovies': FieldValue.arrayUnion([movieId]),
      });
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout aux favoris: $e');
      return false;
    }
  }

  // Retirer un film des favoris
  Future<bool> removeFromFavorites(String uid, String movieId) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'favoriteMovies': FieldValue.arrayRemove([movieId]),
      });
      return true;
    } catch (e) {
      print('Erreur lors du retrait des favoris: $e');
      return false;
    }
  }

  // Vérifier si un film est dans les favoris
  Future<bool> isFavorite(String uid, String movieId) async {
    try {
      final user = await getUserById(uid);
      if (user != null) {
        return user.favoriteMovies.contains(movieId);
      }
      return false;
    } catch (e) {
      print('Erreur lors de la vérification des favoris: $e');
      return false;
    }
  }

  // Récupérer tous les utilisateurs (admin)
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  // Récupérer les utilisateurs non-admin
  Stream<List<UserModel>> getRegularUsers() {
    return _firestore
        .collection(_collection)
        .where('role', isEqualTo: 'user')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
        );
  }

  // Activer/Désactiver un utilisateur (admin)
  Future<bool> toggleUserStatus(String uid, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({
        'isActive': isActive,
      });
      return true;
    } catch (e) {
      print('Erreur lors du changement de statut: $e');
      return false;
    }
  }

  // Changer le rôle d'un utilisateur (admin)
  Future<bool> changeUserRole(String uid, String role) async {
    try {
      await _firestore.collection(_collection).doc(uid).update({'role': role});
      return true;
    } catch (e) {
      print('Erreur lors du changement de rôle: $e');
      return false;
    }
  }

  // Compter le nombre total d'utilisateurs
  Future<int> getTotalUsersCount() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.length;
    } catch (e) {
      print('Erreur lors du comptage des utilisateurs: $e');
      return 0;
    }
  }

  // Compter les utilisateurs actifs (connectés dans les 30 derniers jours)
  Future<int> getActiveUsersCount() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final snapshot = await _firestore
          .collection(_collection)
          .where('lastSignIn', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Erreur lors du comptage des utilisateurs actifs: $e');
      return 0;
    }
  }
}
