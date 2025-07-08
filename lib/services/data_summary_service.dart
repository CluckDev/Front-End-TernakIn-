import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ternakin/services/auth_services.dart'; // Untuk mendapatkan userId
import 'package:flutter/foundation.dart'; // Untuk debugPrint

class DataSummaryService {
  // Konstruktor kosong karena Supabase.instance.client sudah diinisialisasi di main.dart
  DataSummaryService();

  // Helper untuk memformat DateTime ke awal periode (hari/minggu/bulan)
  DateTime _getPeriodStart(String period, DateTime now) {
    switch (period) {
      case 'Harian':
        return DateTime(now.year, now.month, now.day);
      case 'Mingguan':
        // Dapatkan awal minggu saat ini (Senin)
        // DateTime.now().weekday mengembalikan 1 untuk Senin, 7 untuk Minggu
        return DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
      case 'Bulanan':
        return DateTime(now.year, now.month, 1);
      default:
        return DateTime(now.year, now.month, now.day); // Default ke harian
    }
  }

  // Helper untuk memformat DateTime ke akhir periode (hari/minggu/bulan)
  DateTime _getPeriodEnd(String period, DateTime now) {
    switch (period) {
      case 'Harian':
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
      case 'Mingguan':
        // Dapatkan akhir minggu saat ini (Minggu)
        DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
        return startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      case 'Bulanan':
        // Hari terakhir bulan ini
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      default:
        return DateTime(now.year, now.month, now.day, 23, 59, 59); // Default ke harian
    }
  }

  /// Mengambil total jumlah ayam (masuk - keluar) untuk periode tertentu.
  Future<int> getTotalChickens(String userId, String period) async {
    final now = DateTime.now();
    final start = _getPeriodStart(period, now).toUtc();
    final end = _getPeriodEnd(period, now).toUtc();

    try {
      final response = await Supabase.instance.client
          .from('chickens')
          .select('amount, status')
          .eq('user_id', userId)
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      int totalMasuk = 0;
      int totalKeluar = 0;

      for (var item in response) {
        if (item['status'] == 'in') {
          totalMasuk += (item['amount'] as int?) ?? 0;
        } else if (item['status'] == 'out') {
          totalKeluar += (item['amount'] as int?) ?? 0;
        }
      }
      return totalMasuk - totalKeluar;
    } catch (e) {
      debugPrint('Error fetching total chickens: $e');
      return 0; // Kembalikan 0 jika ada error
    }
  }

  /// Mengambil total jumlah telur (masuk - keluar) untuk periode tertentu.
  Future<int> getTotalEggs(String userId, String period) async {
    final now = DateTime.now();
    final start = _getPeriodStart(period, now).toUtc();
    final end = _getPeriodEnd(period, now).toUtc();

    try {
      final response = await Supabase.instance.client
          .from('eggs')
          .select('amount, status')
          .eq('user_id', userId)
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      int totalMasuk = 0;
      int totalKeluar = 0;

      for (var item in response) {
        if (item['status'] == 'in') {
          totalMasuk += (item['amount'] as int?) ?? 0;
        } else if (item['status'] == 'out') {
          totalKeluar += (item['amount'] as int?) ?? 0;
        }
      }
      return totalMasuk - totalKeluar;
    } catch (e) {
      debugPrint('Error fetching total eggs: $e');
      return 0;
    }
  }

  /// Mengambil total jumlah pakan yang digunakan untuk periode tertentu.
  Future<int> getTotalFeeds(String userId, String period) async {
    final now = DateTime.now();
    final start = _getPeriodStart(period, now).toUtc();
    final end = _getPeriodEnd(period, now).toUtc();

    try {
      final response = await Supabase.instance.client
          .from('feeds')
          .select('amount')
          .eq('user_id', userId)
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      int total = 0;
      for (var item in response) {
        total += (item['amount'] as int?) ?? 0;
      }
      return total;
    } catch (e) {
      debugPrint('Error fetching total feeds: $e');
      return 0;
    }
  }

  /// Mengambil total jumlah ayam sakit untuk periode tertentu.
  Future<int> getTotalSick(String userId, String period) async {
    final now = DateTime.now();
    final start = _getPeriodStart(period, now).toUtc();
    final end = _getPeriodEnd(period, now).toUtc();

    try {
      final response = await Supabase.instance.client
          .from('sick')
          .select('amount')
          .eq('user_id', userId)
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      int total = 0;
      for (var item in response) {
        total += (item['amount'] as int?) ?? 0;
      }
      return total;
    } catch (e) {
      debugPrint('Error fetching total sick chickens: $e');
      return 0;
    }
  }
}
