# Configuration MovieDB API via RapidAPI

## 🎬 Configuration de l'API

### 1. Créer un compte RapidAPI

1. Allez sur [RapidAPI](https://rapidapi.com/)
2. Créez un compte gratuit
3. Recherchez "MovieDatabase" ou "IMDb Alternative"
4. Abonnez-vous au plan gratuit

### 2. Obtenir votre clé API

1. Une fois abonné, copiez votre **X-RapidAPI-Key**
2. Ouvrez `lib/services/moviedb_api_service.dart`
3. Remplacez `YOUR_RAPIDAPI_KEY_HERE` par votre vraie clé :

```dart
static const String _rapidApiKey = 'votre-vraie-cle-ici';
```

## 📋 Fonctionnalités Disponibles

### Pour les UTILISATEURS (lecture seule)

✅ **Afficher les films populaires**

```dart
final apiService = MovieDbApiService();
final movies = await apiService.getPopularMovies();
```

✅ **Voir les détails d'un film**

```dart
final details = await apiService.getMovieDetails('tt1234567');
```

✅ **Rechercher des films**

```dart
final results = await apiService.searchMovies('Inception');
```

✅ **Filtrer par genre**

```dart
final actionMovies = await apiService.getMoviesByGenre('Action');
```

✅ **Afficher les nouveautés**

```dart
final newMovies = await apiService.getNewReleases();
```

✅ **Récupérer les images**

```dart
final images = await apiService.getMovieImages('tt1234567');
```

### Pour les ADMINS (ajout manuel)

⚠️ **IMPORTANT** : Les films de l'API ne sont **JAMAIS** automatiquement stockés dans Firebase !

✅ **L'admin peut ajouter un film à Firebase**

```dart
// 1. Récupérer le film depuis l'API
final apiMovie = await apiService.getMovieDetails('tt1234567');

// 2. Convertir en format ApiMovie
final movie = ApiMovie.fromJson(
  apiService.convertToMovieModel(apiMovie!)
);

// 3. L'admin clique sur "Ajouter ce film dans ma base"
final movieService = MovieService();
await movieService.addMovie(Movie(
  id: '',
  title: movie.title,
  genre: movie.genre,
  description: movie.description,
  duration: movie.duration,
  language: movie.language,
  imageUrl: movie.imageUrl,
  rating: movie.rating,
  cast: movie.cast,
  director: movie.director,
  releaseYear: movie.releaseYear,
  availableLanguages: movie.availableLanguages,
));
```

## 🏗️ Architecture des Données

### Deux sources de films distinctes

```
┌─────────────────────────────────────┐
│  MovieDB API (via RapidAPI)         │
│  - Films populaires                 │
│  - Nouveautés                       │
│  - Détails complets                 │
│  - Images haute qualité             │
│  ❌ NON STOCKÉ dans Firebase        │
└─────────────────────────────────────┘
              │
              │ L'admin décide
              │ d'ajouter
              ▼
┌─────────────────────────────────────┐
│  Firebase Firestore                 │
│  Collection: movies                 │
│  - Films ajoutés par l'admin        │
│  - Personnalisables                 │
│  - Modifiables                      │
│  ✅ STOCKÉ dans Firebase            │
└─────────────────────────────────────┘
```

## 🎯 Cas d'Usage

### Utilisateur Normal

1. Ouvre l'app → Voit films populaires depuis API
2. Recherche "Avatar" → Résultats depuis API
3. Clique sur un film → Détails depuis API
4. Peut ajouter aux favoris (stocké dans Firebase)
5. Peut laisser un avis (stocké dans Firebase)

### Admin

1. Voit les mêmes films depuis API
2. **Bouton spécial** : "➕ Ajouter ce film dans ma base"
3. Le film est copié dans Firebase
4. Peut modifier les infos du film dans Firebase
5. Peut supprimer le film de Firebase

## 🔧 Modèles de Données

### ApiMovie (depuis MovieDB API)

```dart
ApiMovie {
  id: String              // ID MovieDB (ex: tt1234567)
  title: String
  genre: String
  description: String
  duration: int
  language: String
  imageUrl: String        // URL directe de l'API
  rating: double
  cast: List<String>
  director: String
  releaseYear: int
  availableLanguages: List<String>
}
```

### Movie (dans Firebase)

```dart
Movie {
  id: String              // ID Firestore généré
  title: String
  genre: String
  description: String
  duration: int
  language: String
  imageUrl: String        // Peut être URL API ou Firebase Storage
  rating: double
  viewCount: int          // Nombre de vues (local)
  cast: List<String>
  director: String
  releaseYear: int
  availableLanguages: List<String>
  createdAt: DateTime     // Date d'ajout dans Firebase
}
```

## 📱 Exemple d'Écran

### HomeScreen avec films API

```dart
class HomeScreen extends StatelessWidget {
  final MovieDbApiService _apiService = MovieDbApiService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _apiService.getPopularMovies(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final movies = snapshot.data!.map((json) {
          return ApiMovie.fromJson(
            _apiService.convertToMovieModel(json)
          );
        }).toList();

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return MovieCard(movie: movie);
          },
        );
      },
    );
  }
}
```

### Bouton Admin "Ajouter à Firebase"

```dart
if (isAdmin) {
  ElevatedButton(
    onPressed: () async {
      await _addMovieToFirebase(apiMovie);
    },
    child: Text('➕ Ajouter ce film dans ma base'),
  );
}
```

## ⚡ Performance

- **Chargement initial** : Films depuis API (rapide)
- **Favoris** : Stockés dans Firebase (persistant)
- **Avis** : Stockés dans Firebase (persistant)
- **Films admin** : Stockés dans Firebase (modifiables)

## 🔒 Sécurité

- ✅ Clé API stockée côté client (acceptable pour apps mobiles)
- ✅ Limite de requêtes : Plan gratuit RapidAPI
- ✅ Seul l'admin peut ajouter des films à Firebase
- ✅ Règles Firestore protègent la collection movies

## 🚀 Prochaines Étapes

1. ✅ Configurer la clé RapidAPI
2. ⬜ Créer un écran avec films API
3. ⬜ Ajouter bouton "Ajouter à Firebase" pour admin
4. ⬜ Gérer le cache local (optionnel)
5. ⬜ Ajouter pagination pour les listes

## 📝 Notes Importantes

- **Ne pas** stocker automatiquement tous les films de l'API
- **Toujours** demander confirmation à l'admin avant d'ajouter
- **Vérifier** si le film existe déjà dans Firebase avant d'ajouter
- **Optimiser** : Charger 20 films à la fois (pagination)
