class Feed {
  final int? id; // ID sekarang adalah int? (nullable)
  final String userId;
  final String? status;
  final int? amount;
  final int? total;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Feed({
    this.id, // Tidak lagi required
    required this.userId,
    this.status,
    this.amount,
    this.total,
    this.createdAt,
    this.updatedAt,
  });

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
      id: json['id'] as int?,
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'status': status,
      'amount': amount,
      'total': total,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'updated_at': updatedAt?.toUtc().toIso8601String(),
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }

  Feed copyWith({
    int? id,
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
