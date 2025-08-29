import 'package:flutter/material.dart';
import '../../domain/turf_model.dart';

class TurfCard extends StatelessWidget {
  final Turf turf;
  final VoidCallback? onTap;
  final bool showFullDetails;

  const TurfCard({
    super.key,
    required this.turf,
    this.onTap,
    this.showFullDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: colors.surfaceContainerHighest,
        elevation: 4,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: showFullDetails ? double.infinity : 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section with rating overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: turf.imageUrls.isNotEmpty
                        ? Image.asset(
                            turf.imageUrls.first,
                            height: showFullDetails ? 200 : 110,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: showFullDetails ? 200 : 110,
                                width: double.infinity,
                                color: colors.surfaceVariant,
                                child: Icon(
                                  Icons.sports_soccer,
                                  size: 40,
                                  color: colors.onSurfaceVariant,
                                ),
                              );
                            },
                          )
                        : Container(
                            height: showFullDetails ? 200 : 110,
                            width: double.infinity,
                            color: colors.surfaceVariant,
                            child: Icon(
                              Icons.sports_soccer,
                              size: 40,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                  ),
                  // Rating badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: colors.onPrimary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            turf.rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Content section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        turf.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: showFullDetails ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              turf.city,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (showFullDetails) ...[
                        const SizedBox(height: 8),
                        // Description
                        Text(
                          turf.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Amenities
                        if (turf.amenities.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: turf.amenities.take(3).map((amenity) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  amenity,
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                      const Spacer(),
                      // Price and bookings
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (turf.isFree)
                                Text(
                                  'FREE',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w300,
                                  ),
                                )
                              else
                                Text(
                                  '₹${turf.pricePerHour.toInt()}/hr',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: turf.surfaceType == SurfaceType.natural
                                          ? Colors.green.withOpacity(0.2)
                                          : Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      turf.surfaceType.shortName,
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: turf.surfaceType == SurfaceType.natural
                                            ? Colors.green.shade700
                                            : Colors.blue.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (showFullDetails) ...[
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        '${turf.totalBookings} bookings',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          if (!showFullDetails)
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: colors.onSurfaceVariant,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTurfTypeColor(TurfType type, ColorScheme colors) {
    switch (type) {
      case TurfType.football:
        return Colors.green;
    }
  }
}
