import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String genre;
  final String description;
  final int duration; // en secondes
  final String language;
  final String imageUrl;
  final double rating;
  final int viewCount;
  final DateTime? createdAt;
  final List<String> cast;
  final String director;
  final int releaseYear;
  final List<String> availableLanguages;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.description,
    required this.duration,
    required this.language,
    required this.imageUrl,
    this.rating = 0.0,
    this.viewCount = 0,
    this.createdAt,
    this.cast = const [],
    this.director = '',
    this.releaseYear = 0,
    this.availableLanguages = const [],
  });

  // Convertir depuis Firestore
  factory Movie.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Movie(
      id: doc.id,
      title: data['title'] ?? '',
      genre: data['genre'] ?? '',
      description: data['description'] ?? '',
      duration: data['duration'] ?? 0,
      language: data['language'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      viewCount: data['viewCount'] ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      cast: data['cast'] != null ? List<String>.from(data['cast']) : [],
      director: data['director'] ?? '',
      releaseYear: data['releaseYear'] ?? 0,
      availableLanguages: data['availableLanguages'] != null
          ? List<String>.from(data['availableLanguages'])
          : [],
    );
  }

  // Convertir vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'genre': genre,
      'description': description,
      'duration': duration,
      'language': language,
      'imageUrl': imageUrl,
      'rating': rating,
      'viewCount': viewCount,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'cast': cast,
      'director': director,
      'releaseYear': releaseYear,
      'availableLanguages': availableLanguages,
    };
  }

  // Copier avec modifications
  Movie copyWith({
    String? id,
    String? title,
    String? genre,
    String? description,
    int? duration,
    String? language,
    String? imageUrl,
    double? rating,
    int? viewCount,
    DateTime? createdAt,
    List<String>? cast,
    String? director,
    int? releaseYear,
    List<String>? availableLanguages,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      language: language ?? this.language,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      cast: cast ?? this.cast,
      director: director ?? this.director,
      releaseYear: releaseYear ?? this.releaseYear,
      availableLanguages: availableLanguages ?? this.availableLanguages,
    );
  }

  // Formater la durée en heures et minutes
  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}
