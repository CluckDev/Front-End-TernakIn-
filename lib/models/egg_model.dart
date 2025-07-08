import 'package:flutter/foundation.dart'; // Untuk @required

class Egg {
  final int? id; // ID bisa null untuk data baru, akan diisi oleh DB saat insert
  final String userId;
  final int? amount;
  final int? total; // Kolom 'total' dari skema database
  final String? status; // Menggunakan String untuk status 'in'/'out'
  final DateTime? createdAt; // Waktu pembuatan/pencatatan data
  final DateTime? updatedAt; // Waktu pembaruan data

  Egg({
    this.id,
    required this.userId,
    this.amount,
    this.total, // Tambahkan ke konstruktor
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor untuk membuat objek Egg dari JSON (Map)
  factory Egg.fromJson(Map<String, dynamic> json) {
    return Egg(
      id: json['id'] as int, // Parse sebagai int
      userId: json['user_id'] as String,
      amount: json['amount'] as int?,
      total: json['total'] as int?, // Parse total
      status: json['status'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal() // Konversi ke waktu lokal untuk display
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal() // Konversi ke waktu lokal untuk display
          : null,
    );
  }

  // Metode untuk mengubah objek Egg menjadi JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      // 'id' tidak disertakan di sini untuk operasi insert baru (Supabase akan auto-increment)
      // Namun, jika ini untuk update, pastikan ID disertakan di query .eq('id', egg.id)
      'user_id': userId,
      'amount': amount,
      'total': total, // Sertakan total
      'status': status,
      'created_at': createdAt?.toUtc().toIso8601String(), // Simpan sebagai ISO 8601 string UTC
      'updated_at': updatedAt?.toUtc().toIso8601String(), // Simpan sebagai ISO 8601 string UTC
    };
  }

  // Metode copyWith untuk membuat salinan objek dengan beberapa properti yang diubah
  Egg copyWith({
    int? id, // ID di copyWith juga int
    String? userId,
    int? amount,
    int? total,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Egg(
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
