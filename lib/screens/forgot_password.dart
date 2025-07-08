import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ternakin/services/auth_services.dart'; // Pastikan import ini ada

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // GlobalKey untuk validasi form
  final _formKey = GlobalKey<FormState>();
  // Controller untuk mendapatkan teks dari TextField
  final _emailController = TextEditingController();
  // State untuk menandai proses loading
  bool _isLoading = false;

  // Fungsi untuk menangani proses reset password
  Future<void> _handleResetPassword() async {
    // Validasi form terlebih dahulu
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Ubah state menjadi loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil service untuk mengirim email reset password
      await authService.resetPassword(email: _emailController.text.trim());

      // Tampilkan notifikasi sukses jika berhasil
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Link reset password telah dikirim ke email Anda!'),
          ),
        );
        // Kembali ke halaman sebelumnya setelah berhasil
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      // Tangani error dari Firebase (misal: email tidak terdaftar)
      String errorMessage = 'Terjadi kesalahan. Coba lagi nanti.';
      if (e.code == 'user-not-found') {
        errorMessage = 'Email tidak terdaftar.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Format email tidak valid.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(errorMessage),
          ),
        );
      }
    } finally {
      // Kembalikan state loading menjadi false setelah selesai
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Hapus controller saat widget tidak lagi digunakan untuk mencegah memory leak
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Lupa Password'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          // Gunakan Form untuk validasi
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png', // Pastikan path asset ini benar
                  height: 150,
                  // Tambahkan error builder untuk menangani jika gambar tidak ditemukan
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.lock_reset,
                        size: 150, color: Colors.green[700]);
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Reset Password',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text('Masukkan email kamu untuk menerima link reset password.',
                    style:
                        GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                // Gunakan TextFormField untuk validasi
                TextFormField(
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  // Tambahkan validator
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Masukkan format email yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Nonaktifkan tombol saat loading, dan panggil fungsi saat ditekan
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: GoogleFonts.poppins(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    // Tampilkan loading indicator atau teks sesuai state
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text('Kirim Link Reset'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
