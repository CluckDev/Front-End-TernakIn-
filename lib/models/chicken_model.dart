import 'package:flutter/foundation.dart'; // Untuk @required

class Chicken {
  final int id; // ID sekarang adalah int
  final String userId;
  final int? amount;
  final int? total;
  final String? status; // Menggunakan String untuk status 'in'/'out'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Chicken({
    required this.id,
    required this.userId,
    this.amount,
    this.total,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor untuk membuat objek Chicken dari JSON (Map)
  factory Chicken.fromJson(Map<String, dynamic> json) {
    return Chicken(
      id: json['id'] as int, // Parse sebagai int
      userId: json['user_id'] as String,
      amount: json['amount'] as int?,
      total: json['total'] as int?,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : null,
    );
  }

  // Metode untuk mengubah objek Chicken menjadi JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'total': total,
      'status': status,
      'created_at': createdAt?.toUtc().toIso8601String(), // Simpan sebagai UTC ISO 8601 string
      'updated_at': updatedAt?.toUtc().toIso8601String(), // Simpan sebagai UTC ISO 8601 string
    };
  }

  // Metode copyWith untuk mempermudah pembuatan objek baru dengan perubahan tertentu
  Chicken copyWith({
    int? id, // ID di copyWith juga int
    String? userId,
    int? amount,
    int? total,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chicken(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
