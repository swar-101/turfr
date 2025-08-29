import 'package:flutter/material.dart';

class LocationSelectorDialog extends StatefulWidget {
  final String currentLocation;
  final List<String> availableLocations;
  final Function(String) onLocationSelected;

  const LocationSelectorDialog({
    super.key,
    required this.currentLocation,
    required this.availableLocations,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelectorDialog> createState() => _LocationSelectorDialogState();
}

class _LocationSelectorDialogState extends State<LocationSelectorDialog> {
  String? selectedLocation;

  @override
  void initState() {
    super.initState();
    // Default to Ulwe if it's available, otherwise use the current location
    if (widget.availableLocations.contains('Ulwe')) {
      selectedLocation = 'Ulwe';
    } else {
      selectedLocation = widget.currentLocation;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: colors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Select Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show "All Locations" option
                    RadioListTile<String>(
                      title: Row(
                        children: [
                          Icon(Icons.public, size: 20, color: colors.onSurface),
                          const SizedBox(width: 8),
                          const Text(
                            'All Locations',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      value: 'All',
                      groupValue: selectedLocation,
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value;
                        });
                      },
                      dense: true,
                    ),
                    const Divider(height: 1),
                    // Individual locations
                    ...widget.availableLocations.map((location) {
                      return RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(
                              location.toLowerCase().contains('ulwe')
                                  ? Icons.home
                                  : Icons.location_city,
                              size: 20,
                              color: colors.onSurface,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                location,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        value: location,
                        groupValue: selectedLocation,
                        onChanged: (value) {
                          setState(() {
                            selectedLocation = value;
                          });
                        },
                        dense: true,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            // Actions
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedLocation != null) {
                        widget.onLocationSelected(selectedLocation!);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
