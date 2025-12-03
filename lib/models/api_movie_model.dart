class ApiMovie {
  final String id;
  final String title;
  final String genre;
  final String description;
  final int duration;
  final String language;
  final String imageUrl;
  final double rating;
  final List<String> cast;
  final String director;
  final int releaseYear;
  final List<String> availableLanguages;

  ApiMovie({
    required this.id,
    required this.title,
    this.genre = 'Unknown',
    this.description = '',
    this.duration = 0,
    this.language = 'English',
    this.imageUrl = '',
    this.rating = 0.0,
    this.cast = const [],
    this.director = '',
    this.releaseYear = 0,
    this.availableLanguages = const [],
  });

  // Créer depuis JSON de l'API
  factory ApiMovie.fromJson(Map<String, dynamic> json) {
    return ApiMovie(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Sans titre',
      genre: json['genre'] ?? 'Unknown',
      description: json['description'] ?? '',
      duration: json['duration'] ?? 0,
      language: json['language'] ?? 'English',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      cast: json['cast'] != null ? List<String>.from(json['cast']) : [],
      director: json['director'] ?? '',
      releaseYear: json['releaseYear'] ?? 0,
      availableLanguages: json['availableLanguages'] != null
          ? List<String>.from(json['availableLanguages'])
          : [],
    );
  }

  // Convertir vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'description': description,
      'duration': duration,
      'language': language,
      'imageUrl': imageUrl,
      'rating': rating,
      'cast': cast,
      'director': director,
      'releaseYear': releaseYear,
      'availableLanguages': availableLanguages,
    };
  }

  // Convertir vers le format Firestore (pour l'ajout manuel par l'admin)
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'genre': genre,
      'description': description,
      'duration': duration,
      'language': language,
      'imageUrl': imageUrl,
      'rating': rating,
      'viewCount': 0,
      'cast': cast,
      'director': director,
      'releaseYear': releaseYear,
      'availableLanguages': availableLanguages,
    };
  }

  // Formater la durée
  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  // Obtenir le premier genre
  String get primaryGenre => genre.split(',').first.trim();
}
