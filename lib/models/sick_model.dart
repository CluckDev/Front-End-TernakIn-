import 'package:flutter/foundation.dart'; // Untuk @required

class Sick {
  final int id; // ID sekarang adalah int
  final String userId;
  final int? amount;
  final String? description;
  final int? total;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Sick({
    required this.id,
    required this.userId,
    this.amount,
    this.description,
    this.total,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor untuk membuat objek Sick dari JSON (Map)
  factory Sick.fromJson(Map<String, dynamic> json) {
    return Sick(
      id: json['id'] as int, // Parse sebagai int
      userId: json['user_id'] as String,
      amount: json['amount'] as int?,
      description: json['description'] as String?,
      total: json['total'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : null,
    );
  }

  // Metode untuk mengubah objek Sick menjadi JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'description': description,
      'total': total,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
  }

  Sick copyWith({
    int? id, // ID di copyWith juga int
    String? userId,
    int? amount,
    String? description,
    int? total,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Sick(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
