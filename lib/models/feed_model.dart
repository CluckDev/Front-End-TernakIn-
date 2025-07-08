import 'package:flutter/foundation.dart'; // Untuk @required

class Feed {
  final int id; // ID sekarang adalah int
  final String userId;
  final String? status; // Menggunakan String untuk status 'in'/'out'
  final int? amount;
  final int? total;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Feed({
    required this.id,
    required this.userId,
    this.status,
    this.amount,
    this.total,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor untuk membuat objek Feed dari JSON (Map)
  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'] as int, // Parse sebagai int
      userId: json['user_id'] as String,
      status: json['status'] as String?,
      amount: json['amount'] as int?,
      total: json['total'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : null,
    );
  }

  // Metode untuk mengubah objek Feed menjadi JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'amount': amount,
      'total': total,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
  }

  Feed copyWith({
    int? id, // ID di copyWith juga int
    String? userId,
    String? status,
    int? amount,
    int? total,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Feed(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
