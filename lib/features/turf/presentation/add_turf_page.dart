import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/turf_model.dart';
import '../providers/turf_provider.dart';

class AddTurfPage extends StatefulWidget {
  const AddTurfPage({super.key});

  @override
  State<AddTurfPage> createState() => _AddTurfPageState();
}

class _AddTurfPageState extends State<AddTurfPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _priceController = TextEditingController();
  final _contactController = TextEditingController();

  TurfType _selectedType = TurfType.football;
  SurfaceType _selectedSurfaceType = SurfaceType.artificial;
  bool _isFree = false;
  List<String> _amenities = [];
  List<String> _timeSlots = [];
  List<String> _imageUrls = [];
  double _rating = 4.0;

  final List<String> _availableAmenities = [
    'Floodlights',
    'Parking',
    'Changing Rooms',
    'Refreshments',
    'First Aid',
    'Air Conditioning',
    'Wi-Fi',
    'Equipment Rental',
    'Coaching',
    'Professional Pitch',
    'Scoreboard',
    'Sound System',
    'Seating',
    'Locker Rooms',
  ];

  final List<String> _defaultTimeSlots = [
    '06:00-08:00',
    '08:00-10:00',
    '10:00-12:00',
    '12:00-14:00',
    '14:00-16:00',
    '16:00-18:00',
    '18:00-20:00',
    '20:00-22:00',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _priceController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Turf'),
        actions: [
          IconButton(
            onPressed: _saveTurf,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildBasicInfo(),
              const SizedBox(height: 8),
              _buildLocationInfo(),
              const SizedBox(height: 8),
              _buildPricingAndContact(),
              const SizedBox(height: 8),
              _buildTurfType(),
              const SizedBox(height: 8),
              _buildAmenities(),
              const SizedBox(height: 8),
              _buildTimeSlots(),
              const SizedBox(height: 8),
              _buildImages(),
              const SizedBox(height: 8),
              _buildRating(),
              const SizedBox(height: 12),
              _buildSaveButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Turf Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Green Valley Football Arena',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter turf name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                hintText: 'Describe the turf facilities and features',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _showLocationHelp,
                  icon: const Icon(Icons.help_outline, size: 16),
                  label: const Text('Help', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Lat',
                      border: OutlineInputBorder(),
                      hintText: '19.07',
                      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Lng',
                      border: OutlineInputBorder(),
                      hintText: '72.87',
                      contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingAndContact() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price & Contact',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                Row(
                  children: [
                    const Text('Is the venue free?'),
                    const Spacer(),
                    Switch(
                      value: _isFree,
                      onChanged: (value) {
                        setState(() {
                          _isFree = value;
                          if (value) {
                            _priceController.text = '0';
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  enabled: !_isFree,
                  decoration: InputDecoration(
                    labelText: 'Price per hour (₹)',
                    border: const OutlineInputBorder(),
                    hintText: _isFree ? 'Free venue' : '2500',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_isFree) return null;
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Invalid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact number',
                    border: OutlineInputBorder(),
                    hintText: '9876543210',
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurfType() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Turf Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TurfType>(
              value: _selectedType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Sport Type',
              ),
              items: TurfType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SurfaceType>(
              value: _selectedSurfaceType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Surface Type',
              ),
              items: SurfaceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSurfaceType = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenities() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amenities',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableAmenities.map((amenity) {
                final isSelected = _amenities.contains(amenity);
                return FilterChip(
                  label: Text(amenity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _amenities.add(amenity);
                      } else {
                        _amenities.remove(amenity);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Time Slots',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _defaultTimeSlots.map((slot) {
                final isSelected = _timeSlots.contains(slot);
                return FilterChip(
                  label: Text(slot),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _timeSlots.add(slot);
                      } else {
                        _timeSlots.remove(slot);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImages() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Images (Optional)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'For now, we\'ll use default images. Image upload will be added later.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRating() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Initial Rating',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Rating: ${_rating.toStringAsFixed(1)}'),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 1.0,
                    max: 5.0,
                    divisions: 40,
                    onChanged: (value) {
                      setState(() {
                        _rating = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Consumer<TurfProvider>(
      builder: (context, turfProvider, child) {
        return ElevatedButton(
          onPressed: turfProvider.isLoading ? null : _saveTurf,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
          child: turfProvider.isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Saving...'),
                  ],
                )
              : const Text('Save Turf'),
        );
      },
    );
  }

  void _showLocationHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Get Coordinates'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To get latitude and longitude:'),
            SizedBox(height: 8),
            Text('1. Open Google Maps'),
            Text('2. Search for the turf location'),
            Text('3. Right-click on the exact location'),
            Text('4. Click on the coordinates that appear'),
            Text('5. Copy and paste them here'),
            SizedBox(height: 12),
            Text(
              'Example: 19.0760, 72.8777',
              style: TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _saveTurf() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_amenities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one amenity')),
      );
      return;
    }

    if (_timeSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one time slot')),
      );
      return;
    }

    final turf = Turf(
      id: '', // Will be generated by Firebase
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      latitude: double.parse(_latitudeController.text.trim()),
      longitude: double.parse(_longitudeController.text.trim()),
      imageUrls: _imageUrls.isNotEmpty ? _imageUrls : ['assets/images/home.png'],
      pricePerHour: _isFree ? 0.0 : double.parse(_priceController.text.trim()),
      isFree: _isFree,
      contact: _contactController.text.trim(),
      type: _selectedType,
      surfaceType: _selectedSurfaceType,
      amenities: _amenities,
      rating: _rating,
      totalBookings: 0, // New turf starts with 0 bookings
      availableTimeSlots: _timeSlots,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final turfProvider = Provider.of<TurfProvider>(context, listen: false);
    turfProvider.addNewTurf(turf).then((_) {
      if (turfProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turf added successfully!')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${turfProvider.error}')),
        );
      }
    });
  }
}
