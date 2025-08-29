import 'dart:math';
import 'package:flutter/foundation.dart';
import '../domain/turf_model.dart';
import '../data/turf_repository.dart';

class TurfProvider extends ChangeNotifier {
  final TurfRepository _turfRepository = TurfRepository();

  List<Turf> _recommendedTurfs = [];
  List<Turf> _allTurfs = [];
  List<Turf> _searchResults = [];
  Turf? _selectedTurf;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedLocation = 'Ulwe'; // Default to Ulwe instead of 'All'
  List<String> _availableLocations = []; // Available cities

  // Getters
  List<Turf> get recommendedTurfs => _recommendedTurfs;
  List<Turf> get allTurfs => _allTurfs;
  List<Turf> get searchResults => _searchResults;
  Turf? get selectedTurf => _selectedTurf;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedLocation => _selectedLocation;
  List<String> get availableLocations => _availableLocations;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Load recommended turfs
  void loadRecommendedTurfs() {
    print('TurfProvider: Starting to load recommended turfs'); // Debug log
    _turfRepository.getRecommendedTurfs().listen(
      (turfs) {
        print('TurfProvider: Received ${turfs.length} turfs from repository'); // Debug log
        _allTurfs = turfs; // Store all turfs
        _updateAvailableLocations(turfs); // Update available cities
        _applyLocationFilter(); // Apply current location filter
        _setError(null);
        notifyListeners();
      },
      onError: (error) {
        print('TurfProvider: Error loading turfs: $error'); // Debug log
        _setError('Failed to load recommended turfs: $error');
      },
    );
  }

  // Update available locations based on loaded turfs
  void _updateAvailableLocations(List<Turf> turfs) {
    final cities = turfs.map((turf) => turf.city).toSet().toList();
    cities.sort();
    _availableLocations = cities;
  }

  // Apply location filter to turfs
  void _applyLocationFilter() {
    if (_selectedLocation == 'All') {
      _recommendedTurfs = List.from(_allTurfs);
    } else {
      _recommendedTurfs = _allTurfs.where((turf) => turf.city == _selectedLocation).toList();
    }

    // Sort by rating within the filtered results
    _recommendedTurfs.sort((a, b) => b.rating.compareTo(a.rating));
  }

  // Set selected location and filter turfs
  void setSelectedLocation(String location) {
    _selectedLocation = location;
    _applyLocationFilter();
    notifyListeners();
  }

  // Get display title for current location
  String get locationDisplayTitle {
    if (_selectedLocation == 'All') {
      return 'All Locations';
    } else {
      return _selectedLocation;
    }
  }

  // Load all turfs
  void loadAllTurfs() {
    _turfRepository.getTurfs().listen(
      (turfs) {
        _allTurfs = turfs;
        _setError(null);
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to load turfs: $error');
      },
    );
  }

  // Search turfs
  void searchTurfs(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _turfRepository.searchTurfs(query).listen(
      (turfs) {
        _searchResults = turfs;
        _setError(null);
        notifyListeners();
      },
      onError: (error) {
        _setError('Failed to search turfs: $error');
      },
    );
  }

  // Get turfs by city
  void getTurfsByCity(String city) {
    _setLoading(true);
    _turfRepository.getTurfsByCity(city).listen(
      (turfs) {
        _allTurfs = turfs;
        _setLoading(false);
        _setError(null);
        notifyListeners();
      },
      onError: (error) {
        _setLoading(false);
        _setError('Failed to load turfs for $city: $error');
      },
    );
  }

  // Get turfs by type
  void getTurfsByType(TurfType type) {
    _setLoading(true);
    _turfRepository.getTurfsByType(type).listen(
      (turfs) {
        _allTurfs = turfs;
        _setLoading(false);
        _setError(null);
        notifyListeners();
      },
      onError: (error) {
        _setLoading(false);
        _setError('Failed to load ${type.displayName} turfs: $error');
      },
    );
  }

  // Select a turf
  Future<void> selectTurf(String turfId) async {
    _setLoading(true);
    try {
      final turf = await _turfRepository.getTurfById(turfId);
      _selectedTurf = turf;
      _setLoading(false);
      _setError(null);
      notifyListeners();
    } catch (error) {
      _setLoading(false);
      _setError('Failed to load turf details: $error');
    }
  }

  // Clear selected turf
  void clearSelectedTurf() {
    _selectedTurf = null;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  // Add sample turfs (for development/testing)
  Future<void> addSampleTurfs() async {
    _setLoading(true);
    try {
      await _turfRepository.addSampleTurfs();
      _setLoading(false);
      _setError(null);
      // Reload data after adding sample turfs
      loadRecommendedTurfs();
      loadAllTurfs();
    } catch (error) {
      _setLoading(false);
      _setError('Failed to add sample turfs: $error');
    }
  }

  // Add a new turf
  Future<void> addNewTurf(Turf turf) async {
    _setLoading(true);
    try {
      await _turfRepository.addNewTurf(turf);
      _setLoading(false);
      _setError(null);
      // Reload data after adding new turf
      loadRecommendedTurfs();
      loadAllTurfs();
    } catch (error) {
      _setLoading(false);
      _setError('Failed to add new turf: $error');
    }
  }

  // Get turf types for filtering
  List<TurfType> get availableTurfTypes => TurfType.values;

  // Filter turfs by rating
  List<Turf> getTurfsByMinRating(double minRating) {
    return _allTurfs.where((turf) => turf.rating >= minRating).toList();
  }

  // Filter turfs by price range
  List<Turf> getTurfsByPriceRange(double minPrice, double maxPrice) {
    return _allTurfs
        .where((turf) => turf.pricePerHour >= minPrice && turf.pricePerHour <= maxPrice)
        .toList();
  }

  // Get nearby turfs (requires user location)
  List<Turf> getNearbyTurfs(double userLat, double userLon, double radiusKm) {
    return _allTurfs.where((turf) {
      final distance = _calculateDistance(userLat, userLon, turf.latitude, turf.longitude);
      return distance <= radiusKm;
    }).toList();
  }

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double lat1Rad = _degreesToRadians(lat1);
    final double lat2Rad = _degreesToRadians(lat2);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
