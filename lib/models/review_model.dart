import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String userName;
  final String movieId;
  final double rating; // 0.0 à 5.0
  final String comment;
  final DateTime? createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.movieId,
    required this.rating,
    required this.comment,
    this.createdAt,
  });

  // Convertir depuis Firestore
  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      movieId: data['movieId'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convertir vers Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'movieId': movieId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  // Copier avec modifications
  Review copyWith({
    String? id,
    String? userId,
    String? userName,
    String? movieId,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      movieId: movieId ?? this.movieId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
