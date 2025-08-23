import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class UpdateInfo {
  final String latestVersion;
  final String apkUrl;
  final String changelog;

  UpdateInfo({
    required this.latestVersion,
    required this.apkUrl,
    required this.changelog,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersion: json['latestVersion'] as String,
      apkUrl: json['apkUrl'] as String,
      changelog: json['changelog'] ?? '',
    );
  }
}

/// Result of attempting to fetch update info.
/// info will be non-null on success. On failure, check errorMessage and optionally statusCode.
class UpdateFetchResult {
  final UpdateInfo? info;
  final String? errorMessage;
  final int? statusCode;
  final String? responseBodySnippet;

  UpdateFetchResult({
    this.info,
    this.errorMessage,
    this.statusCode,
    this.responseBodySnippet,
  });

  bool get success => info != null;
}

/// Fetches update.json and returns a detailed result.
/// On success: return UpdateFetchResult(info: UpdateInfo).
/// On failure: return UpdateFetchResult(errorMessage: <short msg>, statusCode: ..., responseBodySnippet: ...).
Future<UpdateFetchResult> fetchUpdateInfo() async {
  // Add cache-buster to avoid stale cached responses.
  final base = Uri.parse('https://raw.githubusercontent.com/swar-101/turfr/main/update.json');
  final uri = base.replace(queryParameters: {
    'ts': DateTime.now().millisecondsSinceEpoch.toString(),
  });
  const timeoutDur = Duration(seconds: 12);

  try {
    final response = await http
        .get(
          uri,
          headers: const {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
        )
        .timeout(timeoutDur);

    if (response.statusCode == 200) {
      try {
        final payload = json.decode(response.body);
        if (payload is Map<String, dynamic>) {
          final info = UpdateInfo.fromJson(payload);
          return UpdateFetchResult(info: info);
        } else {
          final snippet = _truncate(response.body);
          final msg = 'Unexpected JSON structure';
          if (kDebugMode) {
            debugPrint('Update check: expected JSON object but got ${payload.runtimeType}. Body (truncated): $snippet');
          }
          return UpdateFetchResult(
            errorMessage: msg,
            statusCode: response.statusCode,
            responseBodySnippet: snippet,
          );
        }
      } on FormatException catch (e, st) {
        final snippet = _truncate(response.body);
        final msg = 'Failed to parse update.json';
        if (kDebugMode) {
          debugPrint('JSON parse error while decoding update.json: $e\nResponse body (truncated): $snippet\nStack: $st');
        }
        return UpdateFetchResult(
          errorMessage: msg,
          statusCode: response.statusCode,
          responseBodySnippet: snippet,
        );
      } catch (e, st) {
        final snippet = _truncate(response.body);
        final msg = 'Unknown error parsing update.json';
        if (kDebugMode) {
          debugPrint('Unexpected error while parsing update.json: $e\nResponse body (truncated): $snippet\nStack: $st');
        }
        return UpdateFetchResult(
          errorMessage: msg,
          statusCode: response.statusCode,
          responseBodySnippet: snippet,
        );
      }
    } else {
      final snippet = _truncate(response.body);
      final msg = 'HTTP ${response.statusCode}';
      if (kDebugMode) {
        debugPrint('Update check failed: HTTP ${response.statusCode}\nBody (truncated): $snippet');
      }
      return UpdateFetchResult(
        errorMessage: msg,
        statusCode: response.statusCode,
        responseBodySnippet: snippet,
      );
    }
  } on TimeoutException catch (e, st) {
    final msg = 'Timeout while checking for updates';
    if (kDebugMode) debugPrint('TimeoutException fetching update.json: $e\nStack: $st');
    return UpdateFetchResult(errorMessage: msg);
  } on SocketException catch (e, st) {
    final msg = 'Network error while checking for updates';
    if (kDebugMode) debugPrint('SocketException fetching update.json: $e\nStack: $st');
    return UpdateFetchResult(errorMessage: msg);
  } on http.ClientException catch (e, st) {
    final msg = 'HTTP client error';
    if (kDebugMode) debugPrint('ClientException fetching update.json: $e\nStack: $st');
    return UpdateFetchResult(errorMessage: msg);
  } catch (e, st) {
    final msg = 'Unexpected error while checking updates';
    if (kDebugMode) debugPrint('Unknown exception fetching update.json: $e\nStack: $st');
    return UpdateFetchResult(errorMessage: msg);
  }
}

/// Backwards-compatible helper that returns `UpdateInfo?` the old way.
/// Use this if other code expects the original signature. Prefer using fetchUpdateInfo() to get richer errors.
Future<UpdateInfo?> fetchUpdateInfoOrNull() async {
  final result = await fetchUpdateInfo();
  return result.info;
}

String _truncate(String? s, [int max = 800]) {
  if (s == null) return '';
  if (s.length <= max) return s;
  return s.substring(0, max) + '...';
}

Future<void> showUpdateDialog(BuildContext context, UpdateInfo update) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      bool isLaunching = false;
      return StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Update Available'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version ${update.latestVersion} is available.'),
              const SizedBox(height: 12),
              Text(update.changelog),
              if (isLaunching) ...[
                const SizedBox(height: 16),
                const Row(
                  children: [
                    SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text('Opening download link...'),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLaunching ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Later'),
            ),
            FilledButton(
              onPressed: isLaunching
                  ? null
                  : () async {
                      setState(() => isLaunching = true);
                      final uri = Uri.parse(update.apkUrl);
                      bool launched = false;
                      String errorMsg = '';
                      try {
                        // Basic URL validity check
                        if (uri.scheme.isEmpty || uri.host.isEmpty) {
                          errorMsg = 'Invalid update URL.';
                        } else {
                          launched = await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      } catch (e) {
                        errorMsg = 'Failed to launch update URL: '
                            '${e.toString()}';
                        if (kDebugMode) debugPrint(errorMsg);
                      }
                      // Close the dialog regardless; user can return to the app after download.
                      if (Navigator.of(ctx).canPop()) {
                        Navigator.of(ctx).pop();
                      }
                      if (!launched) {
                        // Fallback: copy link and inform user.
                        try {
                          await Clipboard.setData(ClipboardData(text: update.apkUrl));
                        } catch (_) {}
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMsg.isNotEmpty
                                  ? errorMsg + ' URL copied to clipboard.'
                                  : 'Could not open the download link. URL copied to clipboard.'),
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Update'),
            ),
          ],
        ),
      );
    },
  );
}
