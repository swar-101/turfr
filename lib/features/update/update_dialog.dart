import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UpdateInfo {
  final String latestVersion;
  final String apkUrl;
  final String changelog;

  UpdateInfo({required this.latestVersion, required this.apkUrl, required this.changelog});

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersion: json['latestVersion'],
      apkUrl: json['apkUrl'],
      changelog: json['changelog'] ?? '',
    );
  }
}

Future<UpdateInfo?> fetchUpdateInfo() async {
  try {
    final url = Uri.parse('https://raw.githubusercontent.com/swar-101/turfr/main/update.json');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return UpdateInfo.fromJson(json.decode(response.body));
    }
  } catch (e) {
    debugPrint('Error fetching update info: $e');
  }
  return null;
}

Future<void> showUpdateDialog(BuildContext context, UpdateInfo update) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Update Available'),
      content: Text('Version ${update.latestVersion} is available.\n\n${update.changelog}'),
      actions: [
        TextButton(
          onPressed: () async {
            final uri = Uri.parse(update.apkUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
          child: const Text('Update Now'),
        ),
      ],
    ),
  );
}

