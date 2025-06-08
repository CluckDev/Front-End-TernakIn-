import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  String nama = 'Rakarey';
  String email = 'rakarey120@email.com';
  XFile? _imageFile;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
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
            // Avatar dengan efek shadow dan tombol edit
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                   boxShadow: [
  BoxShadow(
    color: Colors.green.withValues(alpha: 0.2 * 255),
    blurRadius: 16,
    offset: const Offset(0, 8),
  ),
],
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.green[100],
                    backgroundImage: _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
                    child: _imageFile == null
                        ? Icon(Icons.person, color: Colors.green[700], size: 54)
                        : null,
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

            // Card untuk form
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
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
                        initialValue: nama,
                        decoration: InputDecoration(
                          labelText: 'Nama',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: theme.brightness == Brightness.dark
                          ? Colors.green[900]?.withValues(alpha: 0.08 * 255)
                          : Colors.green[50],
                        ),
                        style: GoogleFonts.poppins(),
                        onChanged: (val) => nama = val,
                        validator: (val) => val == null || val.isEmpty ? 'Nama tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: email,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: theme.brightness == Brightness.dark
                        ? Colors.green[900]?.withValues(alpha: 0.08 * 255)
                        : Colors.green[50],
                        ),
                        style: GoogleFonts.poppins(),
                        onChanged: (val) => email = val,
                        validator: (val) => val == null || val.isEmpty ? 'Email tidak boleh kosong' : null,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: Text('Simpan Perubahan', style: GoogleFonts.poppins(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Simpan perubahan profil di sini
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Profil berhasil diperbarui!')),
                              );
                              Navigator.pop(context);
                            }
                          },
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