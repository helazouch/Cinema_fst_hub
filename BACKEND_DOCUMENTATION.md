# Backend Architecture - Cinema FST Hub

## 📁 Structure Backend

```
lib/
├── models/              # Modèles de données
│   ├── movie_model.dart
│   ├── user_model.dart
│   ├── review_model.dart
│   └── models.dart      # Barrel file
│
├── services/            # Services backend
│   ├── auth_service.dart
│   ├── movie_service.dart
│   ├── review_service.dart
│   ├── user_service.dart
│   ├── storage_service.dart
│   ├── firebase_constants.dart
│   └── services.dart    # Barrel file
```

## 🗂️ Modèles de Données

### 1. **Movie Model**

```dart
Movie(
  id: String,
  title: String,
  genre: String,
  description: String,
  duration: int,           // en secondes
  language: String,
  imageUrl: String,
  rating: double,          // 0.0 à 5.0
  viewCount: int,
  createdAt: DateTime,
  cast: List<String>,
  director: String,
  releaseYear: int,
  availableLanguages: List<String>
)
```

### 2. **User Model**

```dart
UserModel(
  uid: String,
  email: String,
  firstName: String,
  lastName: String,
  displayName: String,
  dateOfBirth: String,
  photoURL: String,
  role: String,            // 'user' ou 'admin'
  isActive: bool,
  authProvider: String,    // 'email', 'google'
  createdAt: DateTime,
  lastSignIn: DateTime,
  favoriteMovies: List<String>
)
```

### 3. **Review Model**

```dart
Review(
  id: String,
  userId: String,
  userName: String,
  movieId: String,
  rating: double,          // 0.0 à 5.0
  comment: String,
  createdAt: DateTime
)
```

## 🔧 Services Backend

### 1. **MovieService**

Gestion complète des films :

- `getAllMovies()` - Stream de tous les films
- `getMovieById(id)` - Récupérer un film
- `getMoviesByGenre(genre)` - Filtrer par genre
- `searchMovies(query)` - Recherche
- `addMovie(movie)` - Ajouter un film
- `updateMovie(id, movie)` - Modifier un film
- `deleteMovie(id)` - Supprimer un film
- `incrementViewCount(id)` - Incrémenter les vues
- `updateRating(id, rating)` - Mettre à jour la note
- `getPopularMovies()` - Films populaires
- `getTopRatedMovies()` - Films mieux notés
- `getNewReleases()` - Nouveautés
- `getTotalMoviesCount()` - Nombre total

### 2. **ReviewService**

Gestion des critiques :

- `addReview(review)` - Ajouter une critique
- `getMovieReviews(movieId)` - Critiques d'un film
- `getUserReviews(userId)` - Critiques d'un utilisateur
- `updateReview(id, review)` - Modifier une critique
- `deleteReview(id)` - Supprimer une critique
- `calculateAverageRating(movieId)` - Calculer la moyenne
- `hasUserReviewed(userId, movieId)` - Vérifier si déjà noté
- `getUserReviewForMovie(userId, movieId)` - Récupérer la critique

### 3. **UserService**

Gestion des utilisateurs :

- `getUserById(uid)` - Récupérer un utilisateur
- `getUserStream(uid)` - Stream d'un utilisateur
- `updateUser(uid, data)` - Mettre à jour
- `addToFavorites(uid, movieId)` - Ajouter aux favoris
- `removeFromFavorites(uid, movieId)` - Retirer des favoris
- `isFavorite(uid, movieId)` - Vérifier favori
- `getAllUsers()` - Tous les utilisateurs (admin)
- `getRegularUsers()` - Utilisateurs non-admin
- `toggleUserStatus(uid, isActive)` - Activer/Désactiver
- `changeUserRole(uid, role)` - Changer le rôle
- `getTotalUsersCount()` - Nombre total
- `getActiveUsersCount()` - Utilisateurs actifs

### 5. **StorageService**

Gestion du stockage Firebase :

- `uploadImage(...)` - Upload image générique
- `uploadMovieImage(...)` - Upload affiche film
- `uploadProfileImage(...)` - Upload photo profil
- `deleteImage(url)` - Supprimer une image
- `getImageMetadata(url)` - Métadonnées
- `listImagesInFolder(folder)` - Lister images

### 6. **AuthService**

Authentification (existant) :

- `registerWithEmailAndPassword(...)`
- `signInWithEmailAndPassword(...)`
- `signInWithGoogle()`
- `signOut()`
- `getUserRole()`
- `resetPassword(email)`

## 📊 Collections Firestore

### **users**

```json
{
  "uid": "string",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "displayName": "string",
  "dateOfBirth": "string",
  "photoURL": "string",
  "role": "user|admin",
  "isActive": true,
  "authProvider": "email|google",
  "createdAt": timestamp,
  "lastSignIn": timestamp,
  "favoriteMovies": ["movieId1", "movieId2"]
}
```

### **movies**

```json
{
  "title": "string",
  "genre": "string",
  "description": "string",
  "duration": 7200,
  "language": "string",
  "imageUrl": "string",
  "rating": 4.5,
  "viewCount": 150,
  "createdAt": timestamp,
  "cast": ["actor1", "actor2"],
  "director": "string",
  "releaseYear": 2024,
  "availableLanguages": ["en", "fr"]
}
```

### **reviews**

```json
{
  "userId": "string",
  "userName": "string",
  "movieId": "string",
  "rating": 4.5,
  "comment": "string",
  "createdAt": timestamp
}
```

## 🔐 Règles de Sécurité Firestore (Recommandées)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || isAdmin();
    }

    // Movies collection
    match /movies/{movieId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // Bookings collection
    match /bookings/{bookingId} {
      allow read: if request.auth.uid == resource.data.userId || isAdmin();
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId || isAdmin();
    }

    // Reviews collection
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId || isAdmin();
    }

    // Helper function
    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 📦 Utilisation

### Import des services

```dart
import 'package:cinema_fst_hub/services/services.dart';
import 'package:cinema_fst_hub/models/models.dart';
```

### Exemple d'utilisation

```dart
// Initialiser les services
final movieService = MovieService();
final reviewService = ReviewService();
final userService = UserService();
final storageService = StorageService();

// Récupérer tous les films
Stream<List<Movie>> movies = movieService.getAllMovies();

// Ajouter une critique
final review = Review(
  id: '',
  userId: 'user123',
  userName: 'John Doe',
  movieId: 'movie456',
  rating: 4.5,
  comment: 'Excellent film!',
);
await reviewService.addReview(review);
```

## ✅ Backend Complet

Le backend est maintenant prêt avec :

- ✅ 3 modèles de données complets (Movie, User, Review)
- ✅ 5 services backend fonctionnels
- ✅ Gestion Firebase Storage
- ✅ Constantes centralisées
- ✅ Architecture scalable
- ✅ Type-safe avec modèles
- ✅ Streams en temps réel
- ✅ Gestion d'erreurs

Vous pouvez maintenant utiliser ces services dans vos écrans et widgets !
