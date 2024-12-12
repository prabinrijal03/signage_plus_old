class Version {
  final String id;
  final String versionName;
  final String versionUrl;
  const Version({
    required this.id,
    required this.versionName,
    required this.versionUrl,
  });

  factory Version.fromJson(Map<String, dynamic> json) => Version(
        id: json['id'] as String,
        versionName: json['versionName'] as String,
        versionUrl: json['versionUrl'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'versionName': versionName,
        'versionUrl': versionUrl,
      };

  Version copyWith({
    String? id,
    String? versionName,
    String? versionUrl,
  }) {
    return Version(
      id: id ?? this.id,
      versionName: versionName ?? this.versionName,
      versionUrl: versionUrl ?? this.versionUrl,
    );
  }
}

class UpdateInfo {
  final String? id;
  final String? versionName;
  final bool? updated;
  final String? remark;
  const UpdateInfo({
    this.id,
    this.versionName,
    required this.updated,
    this.remark,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
        id: json['id'] as String?,
        versionName: json['versionName'] as String?,
        updated: json['updated'] as bool?,
        remark: json['remark'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'versionName': versionName,
        'updated': updated,
        'remark': remark,
      };

  UpdateInfo copyWith({
    String? id,
    String? versionName,
    bool? updated,
    String? remark,
  }) {
    return UpdateInfo(
      id: id ?? this.id,
      versionName: versionName ?? this.versionName,
      updated: updated ?? this.updated,
      remark: remark ?? this.remark,
    );
  }
}
