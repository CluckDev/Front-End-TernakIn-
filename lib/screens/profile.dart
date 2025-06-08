import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'edit_profile_screen.dart';
import 'statistik_screen.dart';
import 'pengaturan_screen.dart';
import 'notifikasi_screen.dart';


class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.green, size: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  'Rakarey',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'rakarey120@email.com',
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
          // ...existing code...
          _profileMenu(
            context,
            icon: Icons.edit,
            label: 'Edit Profil',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilScreen()),
              );
            },
          ),
          // ...existing code...
          _profileMenu(
            context,
            icon: Icons.bar_chart,
            label: 'Statistik',
            color: Colors.green[400]!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatistikScreen()),
              );
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
                MaterialPageRoute(builder: (context) => const PengaturanScreen()),
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
              MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
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
          if (!context.mounted) return; // <-- Tambahkan ini
          if (confirm == true) {
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        ),
        const Divider(height: 0, thickness: 1, indent: 24, endIndent: 24),
      ],
    );
  }
}