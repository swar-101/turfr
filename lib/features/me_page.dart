import 'package:flutter/material.dart';
import 'profile_photo_widget.dart';
import '../core/features/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

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
              backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.selected)) {
                  return Theme.of(context).colorScheme.primary.withOpacity(0.1);
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (userData == null) {
      return const Center(child: Text('No user data found.'));
    }
    switch (_selectedIndex) {
      case 0:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const ProfilePhotoWidget(),
              const SizedBox(height: 16),
              Text(
                userData!.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                userData!.phone,
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text('Skills', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _buildSkillBar('Passing', userData!.passing),
              _buildSkillBar('Dribbling', userData!.dribbling),
              _buildSkillBar('Shooting', userData!.shooting),
              _buildSkillBar('Defending', userData!.defending),
            ],
          ),
        );
      case 1:
        return const Center(child: Text('Skills', style: TextStyle(fontSize: 20)));
      case 2:
        return const Center(child: Text('Photos', style: TextStyle(fontSize: 20)));
      default:
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
}
