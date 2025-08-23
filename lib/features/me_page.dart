import 'package:flutter/material.dart';
import 'profile_photo_widget.dart';
import '../core/features/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'custom_hexagon_radar_chart.dart';

class MePage extends StatefulWidget {
  const MePage({Key? key}) : super(key: key);

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  int _selectedIndex = 0;
  final List<String> _segments = ['Info', 'Skills', 'Photos'];

  User? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userId = auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        userData = null;
        isLoading = false;
      });
      return;
    }
    final userService = UserService();
    final user = await userService.getUser(userId);
    setState(() {
      userData = user;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: SegmentedButton<int>(
            segments: List.generate(
              _segments.length,
              (i) => ButtonSegment(
                value: i,
                label: Text(_segments[i]),
              ),
            ),
            selected: {_selectedIndex},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedIndex = newSelection.first;
              });
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.selected)) {
                  return Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
                }
                return null;
              }),
            ),
          ),
        ),
        Expanded(child: _buildSegmentContent()),
      ],
    );
  }

  Widget _buildSegmentContent() {
    print('MePage: _selectedIndex=$_selectedIndex, userData=${userData != null ? 'loaded' : 'null'}');
    if (isLoading) {
      print('MePage: Loading user data...');
      return const Center(child: CircularProgressIndicator());
    }
    if (userData == null) {
      print('MePage: No user data found!');
      return const Center(child: Text('No user data found.'));
    }
    switch (_selectedIndex) {
      case 0:
        print('MePage: Rendering Info segment (Spider chart should be visible)');
        double overall = ((userData!.passing + userData!.dribbling + userData!.shooting + userData!.defending + userData!.stamina + userData!.physical) / 6.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            ProfilePhotoWidget(photoUrl: userData!.photoUrl),
            const SizedBox(height: 12),
            Text(
              userData!.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              userData!.phone,
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Clickable Spider chart card
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Attributes', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            _buildSkillBar('Passing', userData!.passing),
                            _buildSkillBar('Dribbling', userData!.dribbling),
                            _buildSkillBar('Shooting', userData!.shooting),
                            _buildSkillBar('Defending', userData!.defending),
                            _buildSkillBar('Stamina', userData!.stamina),
                            _buildSkillBar('Physical', userData!.physical),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.black,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: CustomHexagonRadarChart(
                      features: const ['Passing', 'Dribbling', 'Shooting', 'Defending', 'Stamina', 'Physical'],
                      data: [userData!.passing.toDouble(), userData!.dribbling.toDouble(), userData!.shooting.toDouble(), userData!.defending.toDouble(), userData!.stamina.toDouble(), userData!.physical.toDouble()],
                      accentColor: Theme.of(context).colorScheme.primary,
                      gridColor: Colors.white,
                      textColor: Colors.white,
                      maxValue: 100.0,
                      ticks: const [20, 40, 60, 80, 100],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      case 1:
        print('MePage: Rendering Skills segment (Sliders should be visible)');
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              _buildSkillSlider('Passing', userData!.passing, (value) async {
                setState(() {
                  userData = User(
                    id: userData!.id,
                    name: userData!.name,
                    phone: userData!.phone,
                    photoUrl: userData!.photoUrl,
                    passing: value,
                    dribbling: userData!.dribbling,
                    shooting: userData!.shooting,
                    defending: userData!.defending,
                    stamina: userData!.stamina,
                    physical: userData!.physical,
                    skillLevel: userData!.skillLevel,
                    gallery: userData!.gallery,
                  );
                });
                await UserService().setUser(userData!);
              }),
              _buildSkillSlider('Dribbling', userData!.dribbling, (value) async {
                setState(() {
                  userData = User(
                    id: userData!.id,
                    name: userData!.name,
                    phone: userData!.phone,
                    photoUrl: userData!.photoUrl,
                    passing: userData!.passing,
                    dribbling: value,
                    shooting: userData!.shooting,
                    defending: userData!.defending,
                    stamina: userData!.stamina,
                    physical: userData!.physical,
                    skillLevel: userData!.skillLevel,
                    gallery: userData!.gallery,
                  );
                });
                await UserService().setUser(userData!);
              }),
              _buildSkillSlider('Shooting', userData!.shooting, (value) async {
                setState(() {
                  userData = User(
                    id: userData!.id,
                    name: userData!.name,
                    phone: userData!.phone,
                    photoUrl: userData!.photoUrl,
                    passing: userData!.passing,
                    dribbling: userData!.dribbling,
                    shooting: value,
                    defending: userData!.defending,
                    stamina: userData!.stamina,
                    physical: userData!.physical,
                    skillLevel: userData!.skillLevel,
                    gallery: userData!.gallery,
                  );
                });
                await UserService().setUser(userData!);
              }),
              _buildSkillSlider('Defending', userData!.defending, (value) async {
                setState(() {
                  userData = User(
                    id: userData!.id,
                    name: userData!.name,
                    phone: userData!.phone,
                    photoUrl: userData!.photoUrl,
                    passing: userData!.passing,
                    dribbling: userData!.dribbling,
                    shooting: userData!.shooting,
                    defending: value,
                    stamina: userData!.stamina,
                    physical: userData!.physical,
                    skillLevel: userData!.skillLevel,
                    gallery: userData!.gallery,
                  );
                });
                await UserService().setUser(userData!);
              }),
              _buildSkillSlider('Stamina', userData!.stamina, (value) async {
                setState(() {
                  userData = User(
                    id: userData!.id,
                    name: userData!.name,
                    phone: userData!.phone,
                    photoUrl: userData!.photoUrl,
                    passing: userData!.passing,
                    dribbling: userData!.dribbling,
                    shooting: userData!.shooting,
                    defending: userData!.defending,
                    stamina: value,
                    physical: userData!.physical,
                    skillLevel: userData!.skillLevel,
                    gallery: userData!.gallery,
                  );
                });
                await UserService().setUser(userData!);
              }),
              _buildSkillSlider('Physical', userData!.physical, (value) async {
                setState(() {
                  userData = User(
                    id: userData!.id,
                    name: userData!.name,
                    phone: userData!.phone,
                    photoUrl: userData!.photoUrl,
                    passing: userData!.passing,
                    dribbling: userData!.dribbling,
                    shooting: userData!.shooting,
                    defending: userData!.defending,
                    stamina: userData!.stamina,
                    physical: value,
                    skillLevel: userData!.skillLevel,
                    gallery: userData!.gallery,
                  );
                });
                await UserService().setUser(userData!);
              }),
            ],
          ),
        );
      case 2:
        print('MePage: Rendering Photos segment');
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Text('Profile Photo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ProfilePhotoWidget(photoUrl: userData!.photoUrl),
              const SizedBox(height: 24),
              Text('Gallery', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              userData!.gallery.isEmpty
                  ? const Text('No gallery photos yet.', style: TextStyle(color: Colors.grey))
                  : SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: userData!.gallery.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final url = userData!.gallery[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(url, width: 120, height: 120, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 120, height: 120, color: Colors.grey[300], child: const Icon(Icons.broken_image)),),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 24),
            ],
          ),
        );
      default:
        print('MePage: Unknown segment');
        return const SizedBox.shrink();
    }
  }

  Widget _buildSkillBar(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value / 100.0,
              minHeight: 7,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
          ),
          Text('$value/100', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildSkillSlider(String label, int value, Function(int) onChanged) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 18)),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 100,
          divisions: 100,
          label: value.toString(),
          onChanged: (double newValue) {
            onChanged(newValue.round());
          },
        ),
        Text('Current $label: $value'),
        const SizedBox(height: 16),
      ],
    );
  }
}
