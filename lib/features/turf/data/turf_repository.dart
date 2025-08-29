import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/turf_model.dart';

class TurfRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'turfs';

  // Get all turfs
  Stream<List<Turf>> getTurfs() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Turf.fromJson({...doc.data(), 'id': doc.id}))
            .toList()
            ..sort((a, b) => b.rating.compareTo(a.rating))); // Sort in code instead of query
  }

  // Get recommended turfs (prioritize local turfs from Ulwe)
  Stream<List<Turf>> getRecommendedTurfs({int limit = 6}) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          print('Firestore returned ${snapshot.docs.length} documents'); // Debug log
          final allTurfs = snapshot.docs
              .map((doc) {
                final data = doc.data();
                print('Processing turf: ${data['name']} in ${data['city']}'); // Debug log
                return Turf.fromJson({...data, 'id': doc.id});
              })
              .toList();

          // Prioritize Ulwe turfs first, then others
          final ulweTurfs = allTurfs.where((turf) =>
            turf.city.toLowerCase().contains('ulwe')).toList();
          final otherTurfs = allTurfs.where((turf) =>
            !turf.city.toLowerCase().contains('ulwe')).toList();

          // Sort each group by rating
          ulweTurfs.sort((a, b) => b.rating.compareTo(a.rating));
          otherTurfs.sort((a, b) => b.rating.compareTo(a.rating));

          // Combine: Ulwe turfs first, then others
          final finalTurfs = [...ulweTurfs, ...otherTurfs];

          print('Found ${ulweTurfs.length} Ulwe turfs and ${otherTurfs.length} other turfs'); // Debug log
          print('Final turfs list has ${finalTurfs.length} items'); // Debug log

          return finalTurfs.take(limit).toList();
        });
  }

  // Get turfs by city
  Stream<List<Turf>> getTurfsByCity(String city, {int limit = 10}) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .where('city', isEqualTo: city)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Turf.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get turfs by type
  Stream<List<Turf>> getTurfsByType(TurfType type, {int limit = 10}) {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .where('type', isEqualTo: type.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Turf.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Get single turf by ID
  Future<Turf?> getTurfById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Turf.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      print('Error getting turf by ID: $e');
      return null;
    }
  }

  // Search turfs by name or city
  Stream<List<Turf>> searchTurfs(String searchQuery, {int limit = 20}) {
    final query = searchQuery.toLowerCase();
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Turf.fromJson({...doc.data(), 'id': doc.id}))
            .where((turf) =>
                turf.name.toLowerCase().contains(query) ||
                turf.city.toLowerCase().contains(query) ||
                turf.description.toLowerCase().contains(query))
            .take(limit)
            .toList());
  }

  // Add sample turfs (for initial setup)
  Future<void> addSampleTurfs() async {
    final sampleTurfs = _getSampleTurfs();

    for (final turf in sampleTurfs) {
      try {
        await _firestore.collection(_collection).add(turf.toJson());
      } catch (e) {
        print('Error adding sample turf: $e');
      }
    }
  }

  // Add a single new turf
  Future<void> addNewTurf(Turf turf) async {
    try {
      await _firestore.collection(_collection).add(turf.toJson());
    } catch (e) {
      print('Error adding new turf: $e');
      rethrow;
    }
  }

  // Get sample turf data for initial setup
  List<Turf> _getSampleTurfs() {
    final now = DateTime.now();
    return [
      Turf(
        id: '',
        name: 'Green Valley Football Arena',
        description: 'Premium football turf with FIFA standard grass and floodlights. Perfect for professional matches and training sessions.',
        address: '123 Sports Complex, Green Valley',
        city: 'Mumbai',
        latitude: 19.0760,
        longitude: 72.8777,
        imageUrls: ['assets/images/recommended_turf0.png'],
        pricePerHour: 2500.0,
        contact: '+91 9876543210',
        type: TurfType.football,
        amenities: ['Floodlights', 'Parking', 'Changing Rooms', 'Refreshments', 'First Aid'],
        rating: 4.8,
        totalBookings: 156,
        availableTimeSlots: ['06:00-08:00', '08:00-10:00', '10:00-12:00', '14:00-16:00', '16:00-18:00', '18:00-20:00', '20:00-22:00'],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      Turf(
        id: '',
        name: 'Champions Football Ground',
        description: 'Professional football ground with natural turf and excellent drainage system. Ideal for tournaments and practice.',
        address: '456 Football Lane, Sports City',
        city: 'Delhi',
        latitude: 28.7041,
        longitude: 77.1025,
        imageUrls: ['assets/images/recommended_turf1.png'],
        pricePerHour: 3000.0,
        contact: '+91 9876543211',
        type: TurfType.football,
        amenities: ['Professional Pitch', 'Pavilion', 'Scoreboard', 'Practice Area', 'Equipment Storage'],
        rating: 4.9,
        totalBookings: 89,
        availableTimeSlots: ['06:00-09:00', '09:00-12:00', '14:00-17:00', '17:00-20:00'],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now,
      ),
      Turf(
        id: '',
        name: 'Urban Football Complex',
        description: 'Modern football turf with artificial grass and excellent lighting. Perfect for evening matches and training.',
        address: '789 Urban Center, Tech Park',
        city: 'Bangalore',
        latitude: 12.9716,
        longitude: 77.5946,
        imageUrls: ['assets/images/recommended_turf2.png'],
        pricePerHour: 1800.0,
        contact: '+91 9876543212',
        type: TurfType.football,
        amenities: ['Artificial Turf', 'Air Conditioning', 'Cafe', 'Wi-Fi', 'Sound System'],
        rating: 4.6,
        totalBookings: 234,
        availableTimeSlots: ['05:00-07:00', '07:00-09:00', '09:00-11:00', '17:00-19:00', '19:00-21:00', '21:00-23:00'],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
      ),
      Turf(
        id: '',
        name: 'Elite Football Arena',
        description: 'Premium football facility with both natural and artificial surfaces. Perfect for professional training.',
        address: '321 Football Avenue, Elite Sports',
        city: 'Chennai',
        latitude: 13.0827,
        longitude: 80.2707,
        imageUrls: ['assets/images/home.png'],
        pricePerHour: 1200.0,
        contact: '+91 9876543213',
        type: TurfType.football,
        amenities: ['Natural Grass', 'Artificial Turf', 'Pro Shop', 'Coaching', 'Equipment Rental'],
        rating: 4.7,
        totalBookings: 178,
        availableTimeSlots: ['06:00-08:00', '08:00-10:00', '16:00-18:00', '18:00-20:00', '20:00-22:00'],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
      ),
      Turf(
        id: '',
        name: 'Skyline Football Ground',
        description: 'Modern football ground with professional grass and excellent drainage system.',
        address: '654 Skyline Mall, Sports Wing',
        city: 'Pune',
        latitude: 18.5204,
        longitude: 73.8567,
        imageUrls: ['assets/images/home.png'],
        pricePerHour: 1500.0,
        contact: '+91 9876543214',
        type: TurfType.football,
        amenities: ['Professional Grass', 'Drainage System', 'Scoreboard', 'Seating', 'Locker Rooms'],
        rating: 4.5,
        totalBookings: 145,
        availableTimeSlots: ['08:00-10:00', '10:00-12:00', '14:00-16:00', '18:00-20:00', '20:00-22:00'],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
      ),
      Turf(
        id: '',
        name: 'Royal Football Club',
        description: 'Premium football facility with international standards and excellent maintenance.',
        address: '987 Royal Complex, Football Wing',
        city: 'Hyderabad',
        latitude: 17.3850,
        longitude: 78.4867,
        imageUrls: ['assets/images/home.png'],
        pricePerHour: 800.0,
        contact: '+91 9876543215',
        type: TurfType.football,
        amenities: ['Multiple Pitches', 'International Standards', 'Equipment Rental', 'Coaching', 'Tournament Hosting'],
        rating: 4.4,
        totalBookings: 267,
        availableTimeSlots: ['05:00-07:00', '07:00-09:00', '17:00-19:00', '19:00-21:00', '21:00-23:00'],
        isActive: true,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
    ];
  }
}
