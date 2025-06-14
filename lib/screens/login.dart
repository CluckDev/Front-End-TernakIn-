import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard.dart'; // 

enum AuthFormType { login, register, forgot }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthFormType currentForm = AuthFormType.login;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isObscure = true;

  void _login() {
    // TODO: Ganti dengan validasi login asli
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email dan password harus diisi')),
      );
    }
  }

  void _register() {
    // TODO: Ganti dengan validasi register asli
    if (nameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty) {
      setState(() {
        currentForm = AuthFormType.login;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi berhasil, silakan login!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field harus diisi')),
      );
    }
  }

  void _forgotPassword() {
    // TODO: Ganti dengan proses reset password asli
    if (emailController.text.isNotEmpty) {
      setState(() {
        currentForm = AuthFormType.login;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Link reset password telah dikirim ke email')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email harus diisi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:   Colors.green[700],
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            color: const Color.fromARGB(255, 255, 255, 255),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 8,
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/images/logo.png'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentForm == AuthFormType.login
                        ? 'Selamat Datang'
                        : currentForm == AuthFormType.register
                            ? 'Daftar Akun'
                            : 'Lupa Password',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (currentForm == AuthFormType.login)
                    Text(
                      'Silakan login untuk melanjutkan',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                    ),
                  if (currentForm == AuthFormType.register)
                    Text(
                      'Isi data untuk membuat akun baru',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                    ),
                  if (currentForm == AuthFormType.forgot)
                    Text(
                      'Masukkan email untuk reset password',
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                    ),
                  const SizedBox(height: 24),

                  // Form sesuai currentForm
                  if (currentForm == AuthFormType.register)
                    Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Nama',
                            prefixIcon: Icon(Icons.person, color: Colors.green[700]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.green[700]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (currentForm != AuthFormType.forgot)
                    TextField(
                      controller: passwordController,
                      obscureText: isObscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: Colors.green[700]),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.green[400],
                          ),
                          onPressed: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                        ),
                      ),
                    ),
                  if (currentForm != AuthFormType.forgot) const SizedBox(height: 12),

                  // Lupa password
                  if (currentForm == AuthFormType.login)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentForm = AuthFormType.forgot;
                            });
                          },
                          child: Text(
                            'Lupa password?',
                            style: GoogleFonts.poppins(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (currentForm == AuthFormType.login) {
                          _login();
                        } else if (currentForm == AuthFormType.register) {
                          _register();
                        } else {
                          _forgotPassword();
                        }
                      },
                      child: Text(
                        currentForm == AuthFormType.login
                            ? 'Login'
                            : currentForm == AuthFormType.register
                                ? 'Daftar'
                                : 'Kirim Email',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Navigasi antar form
                  if (currentForm == AuthFormType.login)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Belum punya akun?",
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.brown[700]),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentForm = AuthFormType.register;
                            });
                          },
                          child: Text(
                            'Daftar',
                            style: GoogleFonts.poppins(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (currentForm == AuthFormType.register)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun?",
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.green[700]),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentForm = AuthFormType.login;
                            });
                          },
                          child: Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (currentForm == AuthFormType.forgot)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentForm = AuthFormType.login;
                            });
                          },
                          child: Text(
                            'Kembali ke Login',
                            style: GoogleFonts.poppins(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Google login hanya di form login
                  if (currentForm == AuthFormType.login) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.green[300])),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'atau',
                            style: GoogleFonts.poppins(color: Colors.green[400]),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.green[300])),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.green[400]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white,
                        ),
                        icon: Image.asset(
                          'assets/images/google.png',
                          height: 24,
                          width: 24,
                        ),
                        label: Text(
                          'Masuk dengan Google',
                          style: GoogleFonts.poppins(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        onPressed: () {
                          // TODO: Implementasi login Google
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}