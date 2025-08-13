import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BackgroundPreviewPage extends StatefulWidget {
  const BackgroundPreviewPage({Key? key}) : super(key: key);

  @override
  State<BackgroundPreviewPage> createState() => _BackgroundPreviewPageState();
}

class _BackgroundPreviewPageState extends State<BackgroundPreviewPage> {
  final List<String> _images = [
    'assets/images/home.png',
    'assets/images/kick-mates.png',
    'assets/images/kick-off.png',
    'assets/images/me.png',
    'assets/images/noise-texture.png',
    'assets/images/noise_texture.png',
    'assets/images/noise_texture_1.png',
    'assets/images/Rectangle 1.png',
    'assets/images/turfr_icon.png',
    'assets/images/google_logo.svg',
    'assets/images/home.svg',
    'assets/images/kick-mates.svg',
    'assets/images/kick-off.svg',
    'assets/images/kickbit.svg',
    'assets/images/me.svg',
    'assets/images/Rectangle 1.svg',
    'assets/images/turfr_logo.svg',
  ];
  int _currentIndex = 0;

  void _nextImage() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _images.length;
    });
  }

  void _prevImage() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _images.length) % _images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final image = _images[_currentIndex];
    final isSvg = image.endsWith('.svg');
    return Scaffold(
      appBar: AppBar(title: const Text('Background Preview')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          isSvg
              ? SvgPicture.asset(image, fit: BoxFit.cover)
              : Image.asset(image, fit: BoxFit.cover),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _prevImage,
                ),
                Text(
                  image.split('/').last,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    backgroundColor: Colors.black54,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _nextImage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
