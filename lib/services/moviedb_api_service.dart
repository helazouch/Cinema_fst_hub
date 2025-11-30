import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieDbApiService {
  // Configuration RapidAPI
  static const String _baseUrl = 'https://moviesdatabase.p.rapidapi.com';
  static const String _rapidApiKey =
      'a14a7e4944mshe05bffb60029eacp1e00fcjsnf37cd198ea8d';
  static const String _rapidApiHost = 'moviesdatabase.p.rapidapi.com';

  // Headers pour RapidAPI
  Map<String, String> get _headers => {
    'X-RapidAPI-Key': _rapidApiKey,
    'X-RapidAPI-Host': _rapidApiHost,
  };

  // Récupérer les films populaires
  Future<List<Map<String, dynamic>>> getPopularMovies({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/titles?page=$page&limit=20'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des films populaires: $e');
      return [];
    }
  }

  // Récupérer les détails d'un film par ID
  Future<Map<String, dynamic>?> getMovieDetails(String movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/titles/$movieId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] as Map<String, dynamic>?;
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des détails du film: $e');
      return null;
    }
  }

  // Rechercher des films
  Future<List<Map<String, dynamic>>> searchMovies(
    String query, {
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/titles/search/title/$query?page=$page&limit=20'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la recherche de films: $e');
      return [];
    }
  }

  // Récupérer les films par genre
  Future<List<Map<String, dynamic>>> getMoviesByGenre(
    String genre, {
    int page = 1,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/titles?genre=$genre&page=$page&limit=20'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des films par genre: $e');
      return [];
    }
  }

  // Récupérer les genres disponibles
  Future<List<String>> getGenres() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/titles/utils/genres'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['results'] ?? []);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des genres: $e');
      return [];
    }
  }

  // Récupérer les images d'un film
  Future<Map<String, dynamic>?> getMovieImages(String movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/titles/$movieId/images'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] as Map<String, dynamic>?;
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des images: $e');
      return null;
    }
  }

  // Récupérer les films récents/nouveautés
  Future<List<Map<String, dynamic>>> getNewReleases({int page = 1}) async {
    try {
      final currentYear = DateTime.now().year;
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/titles?year=$currentYear&page=$page&limit=20&sort=year.decr',
        ),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results'] ?? []);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des nouveautés: $e');
      return [];
    }
  }

  // Convertir un film de l'API en format compatible avec notre modèle
  Map<String, dynamic> convertToMovieModel(Map<String, dynamic> apiMovie) {
    return {
      'id': apiMovie['id'] ?? '',
      'title': apiMovie['titleText']?['text'] ?? 'Sans titre',
      'genre': _extractGenres(apiMovie['genres']),
      'description': apiMovie['plot']?['plotText']?['plainText'] ?? '',
      'duration': _extractDuration(apiMovie['runtime']),
      'language':
          apiMovie['originalTitleText']?['language']?['name'] ?? 'English',
      'imageUrl': _extractImageUrl(apiMovie['primaryImage']),
      'rating': _extractRating(apiMovie['ratingsSummary']),
      'viewCount': 0,
      'cast': _extractCast(apiMovie['cast']),
      'director': _extractDirector(apiMovie['directors']),
      'releaseYear': apiMovie['releaseYear']?['year'] ?? 0,
      'availableLanguages': _extractLanguages(apiMovie['spokenLanguages']),
    };
  }

  // Helper: Extraire les genres
  String _extractGenres(dynamic genres) {
    if (genres == null) return 'Unknown';
    if (genres is List && genres.isNotEmpty) {
      final genreList = genres.map((g) => g['text'] ?? g['id'] ?? '').toList();
      return genreList.first;
    }
    return 'Unknown';
  }

  // Helper: Extraire la durée
  int _extractDuration(dynamic runtime) {
    if (runtime == null) return 0;
    if (runtime is Map && runtime['seconds'] != null) {
      return runtime['seconds'] as int;
    }
    return 0;
  }

  // Helper: Extraire l'URL de l'image
  String _extractImageUrl(dynamic primaryImage) {
    if (primaryImage == null) return '';
    if (primaryImage is Map && primaryImage['url'] != null) {
      return primaryImage['url'] as String;
    }
    return '';
  }

  // Helper: Extraire la note
  double _extractRating(dynamic ratingsSummary) {
    if (ratingsSummary == null) return 0.0;
    if (ratingsSummary is Map && ratingsSummary['aggregateRating'] != null) {
      final rating = ratingsSummary['aggregateRating'];
      return (rating is num) ? rating.toDouble() : 0.0;
    }
    return 0.0;
  }

  // Helper: Extraire le casting
  List<String> _extractCast(dynamic cast) {
    if (cast == null) return [];
    if (cast is List) {
      return cast
          .take(5)
          .map((c) => c['actor']?['name'] ?? '')
          .where((name) => name.isNotEmpty)
          .toList()
          .cast<String>();
    }
    return [];
  }

  // Helper: Extraire le réalisateur
  String _extractDirector(dynamic directors) {
    if (directors == null) return '';
    if (directors is List && directors.isNotEmpty) {
      return directors.first['name'] ?? '';
    }
    return '';
  }

  // Helper: Extraire les langues disponibles
  List<String> _extractLanguages(dynamic spokenLanguages) {
    if (spokenLanguages == null) return ['English'];
    if (spokenLanguages is List) {
      return spokenLanguages
          .map((lang) => lang['name'] ?? '')
          .where((name) => name.isNotEmpty)
          .toList()
          .cast<String>();
    }
    return ['English'];
  }
}
