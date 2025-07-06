import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ternakin/main.dart';

import 'package:ternakin/services/auth_services.dart'; // Pastikan path ini benar

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _nama;
  late String _email;
  XFile? _imageFile;
  String? _photoUrl; // Untuk URL foto profil yang sedang ditampilkan

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Panggil fungsi untuk memuat profil
  }

  // Fungsi terpisah untuk memuat profil pengguna
  void _loadUserProfile() {
    final user = authService.currentUser;
    if (user != null) {
      _nama = user.displayName ?? 'Pengguna';
      _email = user.email ?? 'email@example.com';
      _photoUrl =
          user.photoURL; // Ambil URL foto profil yang sudah ada dari Firebase
    } else {
      _nama = 'Pengguna';
      _email = 'email@example.com';
      _photoUrl = null;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile =
            pickedFile; // Tampilkan gambar yang baru dipilih segera di UI
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mengunggah gambar profil...')),
      );

      try {
        final fb_auth.User? firebaseUser = authService.currentUser;
        if (firebaseUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Anda harus login untuk mengunggah gambar.')),
          );
          return;
        }

        final File fileToUpload = File(pickedFile.path);

        // Gunakan SupabaseService untuk mengunggah gambar
        final String newPhotoUrl = await supabaseService.uploadProfileImage(
          imageFile: fileToUpload,
          userId: firebaseUser.uid, // Gunakan UID pengguna untuk nama file unik
        );


        // Perbarui URL foto pengguna di Firebase Auth
        await authService.updatePhotoUrl(photoUrl: newPhotoUrl);
        // Setelah memperbarui Firebase, muat ulang profil untuk mendapatkan URL terbaru
        // Ini memastikan _photoUrl di state widget ini sinkron dengan Firebase
        _loadUserProfile(); // Memuat ulang profil setelah update Firebase

        if (!mounted) return;
        setState(() {
          // _photoUrl sudah diperbarui oleh _loadUserProfile(), jadi mungkin tidak perlu di sini
          // Namun, untuk memastikan, kita bisa set ulang _imageFile ke null
          _imageFile = null; // Hapus file sementara setelah berhasil diunggah
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar profil berhasil diperbarui!')),
        );
      } on StorageException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Gagal mengunggah gambar ke Supabase: ${e.message}')),
        );
        setState(() {
          _imageFile = null;
        });
      } on fb_auth.FirebaseAuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Gagal memperbarui profil Firebase: ${e.message}')),
        );
        setState(() {
          _imageFile = null;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
        setState(() {
          _imageFile = null;
        });
      }
    }
  }

  void _saveProfileChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menyimpan perubahan profil...')),
      );

      try {
        await authService.updateProfile(name: _nama);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        if (!mounted) return;
        Navigator.pop(context);
      } on fb_auth.FirebaseAuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profil: ${e.message}')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.green[100],
                    child: _photoUrl != null && _photoUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              _photoUrl!,
                              width: 108,
                              height: 108,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Jika gambar network gagal dimuat, tampilkan ikon default
                                return Icon(Icons.person,
                                    color: Colors.green[700], size: 54);
                              },
                            ),
                          )
                        : (_imageFile != null
                            ? ClipOval(
                                child: Image.file(
                                  File(_imageFile!.path),
                                  width: 108,
                                  height: 108,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.person,
                                color: Colors.green[700], size: 54)),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Material(
                    color: Colors.green[700],
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _pickImage,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Informasi Profil',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        initialValue: _nama,
                        decoration: InputDecoration(
                          labelText: 'Nama',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: theme.brightness == Brightness.dark
                              ? Colors.green[900]?.withOpacity(0.08)
                              : Colors.green[50],
                        ),
                        style: GoogleFonts.poppins(),
                        onChanged: (val) => _nama = val,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Nama tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: _email,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: theme.brightness == Brightness.dark
                              ? Colors.green[900]?.withOpacity(0.08)
                              : Colors.green[50],
                        ),
                        style: GoogleFonts.poppins(),
                        readOnly: true,
                        validator: (val) => val == null || val.isEmpty
                            ? 'Email tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: Text('Simpan Perubahan',
                              style: GoogleFonts.poppins(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          onPressed: _saveProfileChanges,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
