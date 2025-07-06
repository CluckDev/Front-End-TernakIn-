import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
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
}
