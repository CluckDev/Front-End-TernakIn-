
class Chicken {
  final int? id; // ID sekarang adalah int? (nullable)
  final String userId;
  final int? amount;
  final int? total;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Chicken({
    this.id, // Tidak lagi required
    required this.userId,
    this.amount,
    this.total,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Chicken.fromJson(Map<String, dynamic> json) {
    return Chicken(
      id: json['id'] as int?, // Tetap parse sebagai int?
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'amount': amount,
      'total': total,
      'status': status,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
    if (id != null) { // Hanya sertakan ID jika tidak null (untuk update)
      data['id'] = id;
    }
    return data;
  }

  Chicken copyWith({
    int? id,
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
