import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class ProfilePhotoWidget extends StatefulWidget {
  const ProfilePhotoWidget({Key? key}) : super(key: key);

  @override
  State<ProfilePhotoWidget> createState() => _ProfilePhotoWidgetState();
}

class _ProfilePhotoWidgetState extends State<ProfilePhotoWidget> {
  File? _imageFile;
  String? _photoUrl;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPhotoUrl();
  }

  Future<void> _loadPhotoUrl() async {
    final userId = auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = doc.data();
    if (data != null && data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty) {
      setState(() {
        _photoUrl = data['photoUrl'];
      });
    }
  }

  Future<void> _pickImage() async {
    final userId = auth.FirebaseAuth.instance.currentUser?.uid;
    debugPrint('Firebase Auth userId: $userId');
    if (userId == null) return;
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });
      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instance.ref().child('profile_photos/$userId.jpg');
      debugPrint('Firebase Storage ref: ${ref.fullPath}');
      try {
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(userId).update({'photoUrl': url});
        setState(() {
          _imageFile = file;
          _photoUrl = url;
          _isUploading = false;
        });
      } catch (e, stack) {
        debugPrint('Photo upload failed: $e');
        debugPrint('Stack trace: $stack');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo upload failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 64,
                backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty
                    ? NetworkImage(_photoUrl!)
                    : _imageFile != null
                        ? FileImage(_imageFile!)
                        : const AssetImage('assets/images/me.png') as ImageProvider,
                child: (_photoUrl == null || _photoUrl!.isEmpty) && _imageFile == null
                    ? const Icon(Icons.person, size: 64, color: Colors.white54)
                    : null,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _isUploading ? null : _pickImage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
