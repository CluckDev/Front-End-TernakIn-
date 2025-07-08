import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chicken_model.dart'; // Import models Anda
import '../models/egg_model.dart';
import '../models/feed_model.dart';
import '../models/schedule_model.dart';
import '../models/sick_model.dart';

final SupabaseService supabaseService = SupabaseService();

class SupabaseService {
  final String _profilePicturesBucket = 'profile-pictures';

  Future<String> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final String fixedFileName = 'avatar';
      final String pathInBucket = '$userId/$fixedFileName';
      // Gunakan metode 'upload' dengan 'upsert: true' untuk menimpa file jika sudah ada.
      // Ini akan secara otomatis mengganti gambar lama dengan nama file yang sama.
      final String uploadedPath = await Supabase.instance.client.storage
          .from(_profilePicturesBucket)
          .upload(
            pathInBucket, // Menggunakan path lengkap di dalam bucket dengan nama file tetap
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600', // Cache selama 1 jam
              upsert:
                  true, // PENTING: Timpa jika file dengan nama yang sama sudah ada
            ),
          );

      final String publicUrl =
          '${Supabase.instance.client.storage.url}/object/public/$uploadedPath';
      debugPrint('DEBUG: URL Supabase yang didapat setelah upload: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      throw Exception(
          'Gagal mengunggah/memperbarui gambar ke Supabase Storage: ${e.message}');
    } catch (e) {
      throw Exception(
          'Terjadi kesalahan tidak terduga saat mengunggah/memperbarui gambar: $e');
    }
  }

  // --- Metode CRUD untuk Model Data ---

  // Chickens
  Future<List<Chicken>> getChickens(String userId) async {
    final response = await Supabase.instance.client
        .from('chickens')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map((json) => Chicken.fromJson(json)).toList();
  }

  Future<Chicken> addChicken(Chicken chicken) async {
    final response = await Supabase.instance.client
        .from('chickens')
        .insert(chicken.toJson())
        .select()
        .single(); // Mengembalikan satu objek yang baru dibuat
    return Chicken.fromJson(response);
  }

  Future<Chicken> updateChicken(Chicken chicken) async {
    final response = await Supabase.instance.client
        .from('chickens')
        .update(chicken.toJson())
        .eq('id', chicken.id as int) // Pastikan id adalah int
        .select()
        .single();
    return Chicken.fromJson(response);
  }

  Future<void> deleteChicken(int id) async {
    await Supabase.instance.client
        .from('chickens')
        .delete()
        .eq('id', id as int); // Perbaikan di sini
  }

  // Eggs
  Future<List<Egg>> getEggs(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('eggs') // Nama tabel di Supabase
          .select()
          .eq('user_id', userId)
          .order('created_at',
              ascending: false); // Urutkan berdasarkan waktu terbaru

      return response.map((json) => Egg.fromJson(json)).toList();
    } catch (e) {
      print('Error getting eggs: $e');
      throw Exception('Gagal mendapatkan data telur: $e');
    }
  }

  Future<void> addEgg(Egg egg) async {
    try {
      // Supabase akan secara otomatis menetapkan ID jika tidak disertakan
      // Pastikan toJson() tidak mengirim 'id' jika itu adalah kolom auto-increment
      // atau biarkan model Egg.toJson() menangani itu.
      await Supabase.instance.client.from('eggs').insert(egg.toJson());
    } catch (e) {
      print('Error adding egg: $e');
      throw Exception('Gagal menambahkan data telur: $e');
    }
  }

  Future<void> updateEgg(Egg egg) async {
    try {
      // Memastikan egg.id tidak null sebelum digunakan dalam query .eq
      if (egg.id == null) {
        throw Exception('Tidak dapat memperbarui telur tanpa ID.');
      }
      await Supabase.instance.client.from('eggs').update(egg.toJson()).eq(
          'id', egg.id!); // Menggunakan operator ! untuk memastikan non-null
    } catch (e) {
      print('Error updating egg: $e');
      throw Exception('Gagal memperbarui data telur: $e');
    }
  }

  Future<void> deleteEgg(int id) async {
    try {
      await Supabase.instance.client
          .from('eggs')
          .delete()
          .eq('id', id); // ID sudah int (non-nullable), jadi tidak perlu !
    } catch (e) {
      print('Error deleting egg: $e');
      throw Exception('Gagal menghapus data telur: $e');
    }
  }

// Feeds
   Future<List<Feed>> getFeeds(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('feeds') // Nama tabel di Supabase
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false); // Urutkan berdasarkan waktu terbaru

      return response.map((json) => Feed.fromJson(json)).toList();
    } catch (e) {
      print('Error getting feeds: $e');
      throw Exception('Gagal mendapatkan data pakan: $e');
    }
  }

  Future<Feed> addFeed(Feed feed) async {
    try {
      final response = await Supabase.instance.client.from('feeds').insert(feed.toJson()).select().single();
      return Feed.fromJson(response);
    } catch (e) {
      print('Error adding feed: $e');
      throw Exception('Gagal menambahkan data pakan: $e');
    }
  }

  Future<Feed> updateFeed(Feed feed) async {
    try {
      if (feed.id == null) {
        throw Exception('Tidak dapat memperbarui pakan tanpa ID.');
      }
      final response = await Supabase.instance.client
          .from('feeds')
          .update(feed.toJson())
          .eq('id', feed.id!)
          .select()
          .single();
      return Feed.fromJson(response);
    } catch (e) {
      print('Error updating feed: $e');
      throw Exception('Gagal memperbarui data pakan: $e');
    }
  }

  Future<void> deleteFeed(int id) async {
    try {
      await Supabase.instance.client.from('feeds').delete().eq('id', id);
    } catch (e) {
      print('Error deleting feed: $e');
      throw Exception('Gagal menghapus data pakan: $e');
    }
  }

// Schedules
   Future<List<Schedule>> getSchedules(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('schedule') // Nama tabel di Supabase
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false); // Urutkan berdasarkan waktu terbaru

      return response.map((json) => Schedule.fromJson(json)).toList();
    } catch (e) {
      print('Error getting schedules: $e');
      throw Exception('Gagal mendapatkan data jadwal: $e');
    }
  }

  Future<void> addSchedule(Schedule schedule) async {
    try {
      // Supabase akan secara otomatis menetapkan ID jika tidak disertakan
      await Supabase.instance.client.from('schedule').insert(schedule.toJson());
    } catch (e) {
      print('Error adding schedule: $e');
      throw Exception('Gagal menambahkan data jadwal: $e');
    }
  }

  Future<void> updateSchedule(Schedule schedule) async {
    try {
      if (schedule.id == null) {
        throw Exception('Tidak dapat memperbarui jadwal tanpa ID.');
      }
      await Supabase.instance.client
          .from('schedule')
          .update(schedule.toJson())
          .eq('id', schedule.id!); // Perbarui berdasarkan ID jadwal
    } catch (e) {
      print('Error updating schedule: $e');
      throw Exception('Gagal memperbarui data jadwal: $e');
    }
  }

  Future<void> deleteSchedule(int id) async {
    try {
      await Supabase.instance.client.from('schedule').delete().eq('id', id); // Hapus berdasarkan ID jadwal
    } catch (e) {
      print('Error deleting schedule: $e');
      throw Exception('Gagal menghapus data jadwal: $e');
    }
  }

// Sick
   Future<List<Sick>> getSicks(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('sick') // Nama tabel di Supabase
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false); // Urutkan berdasarkan waktu terbaru

      return response.map((json) => Sick.fromJson(json)).toList();
    } catch (e) {
      print('Error getting sicks: $e');
      throw Exception('Gagal mendapatkan data kesehatan: $e');
    }
  }

  Future<Sick> addSick(Sick sick) async {
    try {
      final response = await Supabase.instance.client.from('sick').insert(sick.toJson()).select().single();
      return Sick.fromJson(response);
    } catch (e) {
      print('Error adding sick: $e');
      throw Exception('Gagal menambahkan data kesehatan: $e');
    }
  }

  Future<Sick> updateSick(Sick sick) async {
    try {
      if (sick.id == null) {
        throw Exception('Tidak dapat memperbarui data kesehatan tanpa ID.');
      }
      final response = await Supabase.instance.client
          .from('sick')
          .update(sick.toJson())
          .eq('id', sick.id!)
          .select()
          .single();
      return Sick.fromJson(response);
    } catch (e) {
      print('Error updating sick: $e');
      throw Exception('Gagal memperbarui data kesehatan: $e');
    }
  }

  Future<void> deleteSick(int id) async {
    try {
      await Supabase.instance.client.from('sick').delete().eq('id', id);
    } catch (e) {
      print('Error deleting sick: $e');
      throw Exception('Gagal menghapus data kesehatan: $e');
    }
  }
}
