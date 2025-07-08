import 'package:flutter/foundation.dart'; // Untuk @required

class Schedule {
  final int? id; // ID sekarang adalah int
  final String userId;
  final String? type; // Menggunakan String untuk type
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Schedule({
    this.id,
    required this.userId,
    this.type,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor untuk membuat objek Schedule dari JSON (Map)
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] as int, // Parse sebagai int
      userId: json['user_id'] as String,
      type: json['type'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : null,
    );
  }

  // Metode untuk mengubah objek Schedule menjadi JSON (Map)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      'user_id': userId,
      'type': type,
      'description': description,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
    // Hanya sertakan 'id' jika tidak null (untuk operasi update)
    if (id != null) {
      jsonMap['id'] = id;
    }
    return jsonMap;
  }

  Schedule copyWith({
    int? id, // ID di copyWith juga int
    String? userId,
    String? type,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
