import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/turf_model.dart';
import '../providers/turf_provider.dart';

class TurfDetailsPage extends StatelessWidget {
  final String turfId;

  const TurfDetailsPage({
    super.key,
    required this.turfId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TurfProvider>(
        builder: (context, turfProvider, child) {
          if (turfProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (turfProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${turfProvider.error}'),
                  ElevatedButton(
                    onPressed: () => turfProvider.selectTurf(turfId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final turf = turfProvider.selectedTurf;
          if (turf == null) {
            // Load turf if not already loaded
            WidgetsBinding.instance.addPostFrameCallback((_) {
              turfProvider.selectTurf(turfId);
            });
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, turf),
              SliverToBoxAdapter(
                child: _buildContent(context, turf),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<TurfProvider>(
        builder: (context, turfProvider, child) {
          final turf = turfProvider.selectedTurf;
          if (turf == null) return const SizedBox.shrink();

          return _buildBottomBar(context, turf);
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Turf turf) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          turf.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            turf.imageUrls.isNotEmpty
                ? Image.asset(
                    turf.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Icon(
                          Icons.sports_soccer,
                          size: 80,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  )
                : Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.sports_soccer,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Turf turf) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating and type row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      turf.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTurfTypeColor(turf.type),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  turf.type.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price and bookings
          Row(
            children: [
              Text(
                '₹${turf.pricePerHour.toInt()}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' per hour',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                '${turf.totalBookings} bookings',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location
          Row(
            children: [
              Icon(Icons.location_on, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turf.address,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      turf.city,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            turf.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Amenities
          if (turf.amenities.isNotEmpty) ...[
            Text(
              'Amenities',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: turf.amenities.map((amenity) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getAmenityIcon(amenity),
                        size: 16,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        amenity,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Available time slots
          if (turf.availableTimeSlots.isNotEmpty) ...[
            Text(
              'Available Time Slots',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: turf.availableTimeSlots.map((slot) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    slot,
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Contact
          Row(
            children: [
              Icon(Icons.phone, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                turf.contact,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Turf turf) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement call functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Calling ${turf.contact}')),
                );
              },
              icon: const Icon(Icons.phone),
              label: const Text('Call'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement booking functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking feature coming soon!')),
                );
              },
              icon: const Icon(Icons.book_online),
              label: const Text('Book Now'),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTurfTypeColor(TurfType type) {
    switch (type) {
      case TurfType.football:
        return Colors.green;
    }
  }

  IconData _getAmenityIcon(String amenity) {
    final lowerAmenity = amenity.toLowerCase();
    if (lowerAmenity.contains('parking')) return Icons.local_parking;
    if (lowerAmenity.contains('wifi')) return Icons.wifi;
    if (lowerAmenity.contains('changing') || lowerAmenity.contains('locker')) {
      return Icons.meeting_room;
    }
    if (lowerAmenity.contains('refreshment') || lowerAmenity.contains('cafe')) {
      return Icons.restaurant;
    }
    if (lowerAmenity.contains('first aid')) return Icons.medical_services;
    if (lowerAmenity.contains('floodlight')) return Icons.lightbulb;
    if (lowerAmenity.contains('air')) return Icons.ac_unit;
    if (lowerAmenity.contains('sound')) return Icons.volume_up;
    return Icons.check_circle;
  }
}
