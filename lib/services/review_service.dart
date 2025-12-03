import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reviews';

  // Ajouter une critique
  Future<String?> addReview(Review review) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(review.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Erreur lors de l\'ajout de la critique: $e');
      return null;
    }
  }

  // Récupérer les critiques d'un film
  Stream<List<Review>> getMovieReviews(String movieId) {
    return _firestore
        .collection(_collection)
        .where('movieId', isEqualTo: movieId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList(),
        );
  }

  // Récupérer les critiques d'un utilisateur
  Stream<List<Review>> getUserReviews(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList(),
        );
  }

  // Mettre à jour une critique
  Future<bool> updateReview(String id, Review review) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(review.toFirestore());
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de la critique: $e');
      return false;
    }
  }

  // Supprimer une critique
  Future<bool> deleteReview(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de la critique: $e');
      return false;
    }
  }

  // Calculer la note moyenne d'un film
  Future<double> calculateAverageRating(String movieId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('movieId', isEqualTo: movieId)
          .get();

      if (snapshot.docs.isEmpty) {
        return 0.0;
      }

      double total = 0;
      for (var doc in snapshot.docs) {
        final review = Review.fromFirestore(doc);
        total += review.rating;
      }

      return total / snapshot.docs.length;
    } catch (e) {
      print('Erreur lors du calcul de la moyenne: $e');
      return 0.0;
    }
  }

  // Vérifier si l'utilisateur a déjà laissé une critique pour ce film
  Future<bool> hasUserReviewed(String userId, String movieId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification de la critique: $e');
      return false;
    }
  }

  // Récupérer la critique d'un utilisateur pour un film
  Future<Review?> getUserReviewForMovie(String userId, String movieId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('movieId', isEqualTo: movieId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Review.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de la critique: $e');
      return null;
    }
  }
}
