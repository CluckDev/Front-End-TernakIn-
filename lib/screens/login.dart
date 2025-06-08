import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.jpg',
                height: 250,
              ),
              const SizedBox(height: 40),
              // Judul
              Text(
                'TernakIn',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
              const SizedBox(height: 40),
              // Email
              TextField(
                decoration: InputDecoration(
                  labelText: 'Masukan Username atau Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Password
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Tombol Masuk
          // Tombol Masuk (ubah teks jadi putih)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.white), // pastikan teks putih
                elevation: 4,
              ),
              child: const Text('Masuk', style: TextStyle(color: Colors.white)),
            ),
          ),

          const SizedBox(height: 16),

        // Tombol Login dengan Google
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Logika login dengan Google nanti di sini
            },
            icon: Image.asset(
              'assets/images/google.jpg', // Pastikan kamu punya gambar logo Google ini di folder assets/images/
              height: 20,
              width: 20,
            ),
            label: Text(
              'Masuk dengan Google',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.grey), // border abu-abu
              backgroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ),

              // Link daftar
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  'Belum punya akun? Daftar',
                  style: GoogleFonts.poppins(color: Colors.green[700]),
                ),
              ),
              // Link lupa password
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgot-password');
                },
                child: Text(
                  'Lupa Password?',
                  style: GoogleFonts.poppins(color: Colors.green[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
