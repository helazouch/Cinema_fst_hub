import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'movies';

  // Récupérer tous les films
  Stream<List<Movie>> getAllMovies() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList(),
        );
  }

  // Récupérer un film par ID
  Future<Movie?> getMovieById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Movie.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du film: $e');
      return null;
    }
  }

  // Récupérer les films par genre
  Stream<List<Movie>> getMoviesByGenre(String genre) {
    return _firestore
        .collection(_collection)
        .where('genre', isEqualTo: genre)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList(),
        );
  }

  // Rechercher des films
  Stream<List<Movie>> searchMovies(String query) {
    return _firestore
        .collection(_collection)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: query + 'z')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList(),
        );
  }

  // Ajouter un film
  Future<String?> addMovie(Movie movie) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(movie.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Erreur lors de l\'ajout du film: $e');
      return null;
    }
  }

  // Mettre à jour un film
  Future<bool> updateMovie(String id, Movie movie) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(movie.toFirestore());
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du film: $e');
      return false;
    }
  }

  // Supprimer un film
  Future<bool> deleteMovie(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du film: $e');
      return false;
    }
  }

  // Incrémenter le nombre de vues
  Future<void> incrementViewCount(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Erreur lors de l\'incrémentation des vues: $e');
    }
  }

  // Mettre à jour la note moyenne
  Future<void> updateRating(String id, double newRating) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'rating': newRating,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour de la note: $e');
    }
  }

  // Récupérer les films les plus populaires
  Stream<List<Movie>> getPopularMovies({int limit = 10}) {
    return _firestore
        .collection(_collection)
        .orderBy('viewCount', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList(),
        );
  }

  // Récupérer les films les mieux notés
  Stream<List<Movie>> getTopRatedMovies({int limit = 10}) {
    return _firestore
        .collection(_collection)
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList(),
        );
  }

  // Récupérer les nouveaux films
  Stream<List<Movie>> getNewReleases({int limit = 10}) {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList(),
        );
  }

  // Compter le nombre total de films
  Future<int> getTotalMoviesCount() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs.length;
    } catch (e) {
      print('Erreur lors du comptage des films: $e');
      return 0;
    }
  }
}
