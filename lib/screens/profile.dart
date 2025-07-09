import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ternakin/screens/dashboard.dart';
import 'package:ternakin/services/auth_services.dart';
import 'edit_profile_screen.dart';
import 'pengaturan_screen.dart';
import 'notifikasi_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Alias untuk User Firebase

class ProfilScreen extends StatefulWidget {
  // Hapus properti ini karena data akan dimuat di dalam state
  // final String email;
  // final String photoUrl;
  // final String username;
  const ProfilScreen({super.key}); // Ubah konstruktor

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String? errorMessage;
  String _nama = 'Pengguna'; // State untuk nama pengguna
  String _email = 'email@example.com'; // State untuk email pengguna
  String? _photoUrl; // State untuk URL foto profil

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Muat data profil saat initState
  }

  // Metode untuk memuat data profil dari Firebase Auth
  void _loadUserProfile() {
    final user = authService.currentUser;
    setState(() {
      if (user != null) {
        _nama = user.displayName ?? 'Pengguna';
        _email = user.email ?? 'email@example.com';
        _photoUrl = user.photoURL;
      } else {
        _nama = 'Pengguna';
        _email = 'email@example.com';
        _photoUrl = null;
      }
    });
  }

  void logout() async {
    try {
      await authService.signOut();
      // Setelah logout, navigasi ke layar login atau splash
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
        });
        // Tampilkan SnackBar atau AlertDialog untuk error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Profil',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        children: [
          // Header dengan gradient
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  // Tampilkan gambar profil dinamis
                  backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty
                      ? NetworkImage(_photoUrl!) as ImageProvider<Object>?
                      : const AssetImage('assets/images/cipaaa.png'), // Default image
                  // Jika tidak ada gambar, tampilkan ikon default
                  child: _photoUrl == null || _photoUrl!.isEmpty
                      ? const Icon(Icons.person, color: Colors.green, size: 40)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  _nama, // Gunakan nama dari state
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _email, // Gunakan email dari state
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu List
          _profileMenu(
            context,
            icon: Icons.edit,
            label: 'Edit Profil',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilScreen(),
                ),
              ).then((_) {
                // Setelah kembali dari EditProfilScreen, muat ulang data profil
                _loadUserProfile();
              });
            },
          ),
          _profileMenu(
            context,
            icon: Icons.settings,
            label: 'Pengaturan',
            color: Colors.green[400]!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PengaturanScreen(),
                ),
              );
            },
          ),
          _profileMenu(
            context,
            icon: Icons.notifications,
            label: 'Notifikasi',
            color: Colors.green[400]!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotifikasiScreen(),
                ),
              );
            },
          ),
          _profileMenu(
            context,
            icon: Icons.logout,
            label: 'Logout',
            color: Colors.red,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Apakah Anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Ya'),
                    ),
                  ],
                ),
              );
              if (!context.mounted) return;
              if (confirm == true) {
                logout();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _profileMenu(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(
            label,
            style:
                GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
          onTap: onTap,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        ),
        const Divider(height: 0, thickness: 1, indent: 24, endIndent: 24),
      ],
    );
  }
}
