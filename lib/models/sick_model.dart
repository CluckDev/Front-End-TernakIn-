import 'package:flutter/foundation.dart';

class Sick {
  final int? id; // ID sekarang adalah int? (nullable)
  final String userId;
  final int? amount;
  final String? description;
  final int? total;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Sick({
    this.id, // Tidak lagi required di konstruktor
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
      id: json['id'] as int?, // Parse sebagai int?
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
    final Map<String, dynamic> data = {
      'user_id': userId,
      'amount': amount,
      'description': description,
      'total': total,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
    // Hanya sertakan 'id' jika tidak null (untuk operasi update)
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  Sick copyWith({
    int? id,
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
