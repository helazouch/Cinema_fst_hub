import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/moviedb_api_service.dart';
import '../models/movie_model.dart';
import 'admin_users_screen.dart';
import 'admin_films_screen.dart';
import 'sign_in_screen.dart';
import 'dart:math' as math;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MovieDbApiService _apiService = MovieDbApiService();

  int _totalFilms = 0;
  int _totalUsers = 0;
  int _activeUsers = 0;
  String _mostFavoriteFilm = 'Chargement...';
  int _mostFavoriteCount = 0;
  int _totalViews = 0;
  int _totalReviews = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Compter les utilisateurs
      final usersSnapshot = await _firestore.collection('users').get();
      _totalUsers = usersSnapshot.docs.length;

      // Compter les utilisateurs actifs (connectés dans les 30 derniers jours)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      _activeUsers = usersSnapshot.docs.where((doc) {
        final data = doc.data();
        if (data.containsKey('lastSignIn')) {
          final lastSignIn = (data['lastSignIn'] as Timestamp).toDate();
          return lastSignIn.isAfter(thirtyDaysAgo);
        }
        return false;
      }).length;

      // Compter les films Firestore + API
      final firestoreMoviesSnapshot = await _firestore
          .collection('movies')
          .get();
      final apiMovies = await _apiService.getPopularMovies();
      _totalFilms = firestoreMoviesSnapshot.docs.length + apiMovies.length;

      // Calculer le total des vues (films Firestore uniquement)
      _totalViews = 0;
      for (var doc in firestoreMoviesSnapshot.docs) {
        final movie = Movie.fromFirestore(doc);
        _totalViews += movie.viewCount;
      }

      // Calculer le nombre total de reviews
      final reviewsSnapshot = await _firestore.collection('reviews').get();
      _totalReviews = reviewsSnapshot.docs.length;

      // Trouver le film le plus favori
      final favoritesSnapshot = await _firestore.collection('favorites').get();
      final Map<String, int> favoriteCounts = {};
      final Map<String, String> movieTitles = {};

      // Compter les favoris par film
      for (var doc in favoritesSnapshot.docs) {
        final data = doc.data();
        final movieId = data['movieId'] as String?;
        final movieTitle = data['movieTitle'] as String?;

        if (movieId != null && movieTitle != null) {
          favoriteCounts[movieId] = (favoriteCounts[movieId] ?? 0) + 1;
          movieTitles[movieId] = movieTitle;
        }
      }

      // Trouver le film avec le plus de favoris
      String? mostFavoriteId;
      int maxFavorites = 0;
      favoriteCounts.forEach((movieId, count) {
        if (count > maxFavorites) {
          maxFavorites = count;
          mostFavoriteId = movieId;
        }
      });

      _mostFavoriteFilm = mostFavoriteId != null
          ? movieTitles[mostFavoriteId] ?? 'Aucun film'
          : 'Aucun film';
      _mostFavoriteCount = maxFavorites;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur chargement dashboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onNavItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminFilmsScreen()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminUsersScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePercentage = _totalUsers > 0
        ? ((_activeUsers / _totalUsers) * 100).toInt()
        : 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6B46C1)),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'HEY, LINDA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              onPressed: _loadDashboardData,
                              tooltip: 'Actualiser',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              onPressed: _handleLogout,
                              tooltip: 'Déconnexion',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Stats Grid
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          // Row 1
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'NUMBER OF FILMS',
                                  _totalFilms.toString(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'NUMBER OF ACTIVE USERS',
                                  _activeUsers.toString(),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Row 2
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'NUMBER OF USERS',
                                  _totalUsers.toString(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildPercentageCard(
                                  'PERCENTAGE OF\nACTIVE USERS',
                                  activePercentage,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Row 3
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'TOTAL VIEWS',
                                  _totalViews.toString(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'TOTAL REVIEWS',
                                  _totalReviews.toString(),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Most Favorite Film Card
                          _buildFavoriteFilmCard(
                            'MOST FAVORITE FILM',
                            _mostFavoriteFilm,
                            _mostFavoriteCount,
                          ),

                          const SizedBox(height: 16),

                          // Statistics Chart
                          _buildStatisticsChart(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Navigation
                  _buildBottomNav(),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageCard(String title, int percentage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF6B46C1),
                      ),
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteFilmCard(String title, String filmName, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            filmName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            '$count favoris',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsChart() {
    final stats = [
      {
        'label': 'Films',
        'value': _totalFilms,
        'color': const Color(0xFF6B46C1),
      },
      {
        'label': 'Users',
        'value': _totalUsers,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'label': 'Active',
        'value': _activeUsers,
        'color': const Color(0xFFEC4899),
      },
      {
        'label': 'Views',
        'value': _totalViews,
        'color': const Color(0xFF10B981),
      },
      {
        'label': 'Reviews',
        'value': _totalReviews,
        'color': const Color(0xFFF59E0B),
      },
    ];

    final maxValue = stats.map((s) => s['value'] as int).reduce(math.max);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STATISTICS OVERVIEW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          ...stats.map(
            (stat) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildChartBar(
                stat['label'] as String,
                stat['value'] as int,
                maxValue > 0 ? (stat['value'] as int) / maxValue : 0,
                stat['color'] as Color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(
    String label,
    int value,
    double percentage,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem('Dashboard', 0),
              _buildNavItem('Films', 1),
              _buildNavItem('Users', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onNavItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B46C1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
