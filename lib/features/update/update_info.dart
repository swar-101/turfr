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
