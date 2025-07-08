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
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final String _profilePicturesBucket =
      'profile-pictures'; 

  Future<String> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final String fixedFileName =
          'avatar';
      final String pathInBucket =
          '$userId/$fixedFileName'; 
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
    await Supabase.instance.client.from('chickens').delete().eq('id', id as int); // Perbaikan di sini
  }

  // Eggs
  Future<List<Egg>> getEggs(String userId) async {
    final response = await Supabase.instance.client
        .from('eggs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map((json) => Egg.fromJson(json)).toList();
  }

  Future<Egg> addEgg(Egg egg) async {
    final response = await Supabase.instance.client
        .from('eggs')
        .insert(egg.toJson())
        .select()
        .single();
    return Egg.fromJson(response);
  }

  Future<Egg> updateEgg(Egg egg) async {
    final response = await Supabase.instance.client
        .from('eggs')
        .update(egg.toJson())
        .eq('id', egg.id as int) // Pastikan id adalah int
        .select()
        .single();
    return Egg.fromJson(response);
  }

  Future<void> deleteEgg(int id) async {
    await Supabase.instance.client.from('eggs').delete().eq('id', id as int); // Perbaikan di sini
  }

  // Feeds
  Future<List<Feed>> getFeeds(String userId) async {
    final response = await Supabase.instance.client
        .from('feeds')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map((json) => Feed.fromJson(json)).toList();
  }

  Future<Feed> addFeed(Feed feed) async {
    final response = await Supabase.instance.client
        .from('feeds')
        .insert(feed.toJson())
        .select()
        .single();
    return Feed.fromJson(response);
  }

  Future<Feed> updateFeed(Feed feed) async {
    final response = await Supabase.instance.client
        .from('feeds')
        .update(feed.toJson())
        .eq('id', feed.id as int) // Pastikan id adalah int
        .select()
        .single();
    return Feed.fromJson(response);
  }

  Future<void> deleteFeed(int id) async {
    await Supabase.instance.client.from('feeds').delete().eq('id', id as int); // Perbaikan di sini
  }

  // Schedules
  Future<List<Schedule>> getSchedules(String userId) async {
    final response = await Supabase.instance.client
        .from('schedule') // Nama tabel di database adalah 'schedule'
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map((json) => Schedule.fromJson(json)).toList();
  }

  Future<Schedule> addSchedule(Schedule schedule) async {
    final response = await Supabase.instance.client
        .from('schedule')
        .insert(schedule.toJson())
        .select()
        .single();
    return Schedule.fromJson(response);
  }

  Future<Schedule> updateSchedule(Schedule schedule) async {
    final response = await Supabase.instance.client
        .from('schedule')
        .update(schedule.toJson())
        .eq('id', schedule.id as int) // Pastikan id adalah int
        .select()
        .single();
    return Schedule.fromJson(response);
  }

  Future<void> deleteSchedule(int id) async {
    await Supabase.instance.client.from('schedule').delete().eq('id', id as int); // Perbaikan di sini
  }

  // Sick
  Future<List<Sick>> getSickRecords(String userId) async {
    final response = await Supabase.instance.client
        .from('sick') // Nama tabel di database adalah 'sick'
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map((json) => Sick.fromJson(json)).toList();
  }

  Future<Sick> addSick(Sick sick) async {
    final response = await Supabase.instance.client
        .from('sick')
        .insert(sick.toJson())
        .select()
        .single();
    return Sick.fromJson(response);
  }

  Future<Sick> updateSick(Sick sick) async {
    final response = await Supabase.instance.client
        .from('sick')
        .update(sick.toJson())
        .eq('id', sick.id as int) // Pastikan id adalah int
        .select()
        .single();
    return Sick.fromJson(response);
  }

  Future<void> deleteSick(int id) async {
    await Supabase.instance.client.from('sick').delete().eq('id', id as int); // Perbaikan di sini
  }
}
