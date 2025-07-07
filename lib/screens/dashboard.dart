import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ternakin/services/auth_services.dart';
import '../widgets/bottom_navbar.dart';
import 'dashboard_chart.dart';
import 'jadwal.dart';
import 'manajemen.dart';
import 'manajemen_ayam.dart';
import 'manajemen_kesehatan.dart';
import 'manajemen_pakan.dart';
import 'manajemen_telur.dart';
import 'profile.dart';
import 'statistik_screen.dart';
import 'data_summary_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _userName = 'Pengguna'; // Default value
  String? _photoUrl; // Default to null

  // Langganan untuk mendengarkan perubahan status otentikasi
  late final Stream<fb_auth.User?> _authStateChangesSubscription;

  @override
  void initState() {
    super.initState();
    // Inisialisasi langganan di initState
    _authStateChangesSubscription = authService.authStateChanges;
    _authStateChangesSubscription.listen((fb_auth.User? user) {
      if (mounted) {
        // Pastikan widget masih ada di tree
        _loadUserProfile(user);
      }
    });

    // Muat profil awal saat widget pertama kali dibuat
    _loadUserProfile(authService.currentUser);
  }

  void _loadUserProfile(fb_auth.User? user) {
    setState(() {
      if (user != null) {
        _userName = user.displayName ?? 'Pengguna';
        _photoUrl = user.photoURL;
      } else {
        _userName = 'Pengguna';
        _photoUrl = null;
      }
    });
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Bangun DashboardContent di sini agar selalu menggunakan _userName dan _photoUrl terbaru
    final List<Widget> currentPage = [
      DashboardContent(userName: _userName, photoUrl: _photoUrl),
      JadwalScreen(),
      ManajemenScreen(),
      ProfilScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: currentPage[_selectedIndex]), // Gunakan currentPage
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  final String userName;
  final String? photoUrl; // Tambahkan properti photoUrl
  const DashboardContent({super.key, required this.userName, this.photoUrl});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  String selectedChart = 'telur';

  final Map<String, String> chartLabels = {
    'telur': 'Grafik Produksi Telur',
    'ayam': 'Grafik Populasi Ayam',
    'pakan': 'Grafik Penggunaan Pakan',
    'kesehatan': 'Grafik Kesehatan Ayam',
  };

  final Map<String, IconData> chartIcons = {
    'telur': Icons.egg,
    'ayam': Icons.pets,
    'pakan': Icons.rice_bowl,
    'kesehatan': Icons.health_and_safety,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header lebih menarik
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700, Colors.green.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withAlpha((0.2 * 255).toInt()),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Logo aplikasi
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/images/logo.png'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat datang di aplikasi kami',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Ternakin',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Manajemen Peternakan',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Profil user (bisa diklik ke halaman profil)
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ProfilScreen()));
                  },
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        backgroundImage: widget.photoUrl != null &&
                                widget.photoUrl!.isNotEmpty
                            ? NetworkImage(widget.photoUrl!)
                                as ImageProvider<Object>?
                            : const AssetImage('assets/images/logo.png'),
                        // Jika tidak ada gambar, tampilkan ikon default
                        child:
                            widget.photoUrl == null || widget.photoUrl!.isEmpty
                                ? Icon(Icons.person, color: Colors.green[700])
                                : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.userName,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Summary cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SummaryCard(
                  label: 'Telur',
                  value: DataSummaryService.getTotalTelur().toString(),
                  icon: Icons.egg,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ManajemenTelurScreen()));
                  },
                ),
                SummaryCard(
                  label: 'Ayam',
                  value: DataSummaryService.getTotalAyam().toString(),
                  icon: Icons.pets,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ManajemenAyamScreen()));
                  },
                ),
                SummaryCard(
                  label: 'Pakan',
                  value: DataSummaryService.getTotalPakan().toString(),
                  icon: Icons.rice_bowl,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ManajemenPakanScreen()));
                  },
                ),
                SummaryCard(
                  label: 'Sakit',
                  value: DataSummaryService.getTotalSakit().toString(),
                  icon: Icons.warning,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ManajemenKesehatanScreen()));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Grafik utama dengan dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.brown[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(chartIcons[selectedChart],
                              color: Colors.green[700], size: 22),
                        ),
                        const SizedBox(width: 10),
                        // Ganti Expanded dengan Flexible agar lebih adaptif
                        Flexible(
                          child: Text(
                            chartLabels[selectedChart]!,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow:
                                TextOverflow.ellipsis, // Supaya tidak menumpuk
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: selectedChart,
                          isDense: true,
                          underline: const SizedBox(),
                          borderRadius: BorderRadius.circular(12),
                          items: chartLabels.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value,
                                  style: GoogleFonts.poppins(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedChart = val);
                              }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child:
                          DashboardChart(period: 'daily', type: selectedChart),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Aktivitas terakhir (dummy)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Aktivitas Terakhir',
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.add, color: Colors.green[700]),
                title: Text('Tambah data ayam',
                    style: GoogleFonts.poppins(fontSize: 14)),
                subtitle: Text('Hari ini, 08:00',
                    style: GoogleFonts.poppins(fontSize: 12)),
              ),
            ),
          ),
          // Tombol ke statistik detail
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatistikScreen()),
                );
              },
              icon: const Icon(Icons.bar_chart, color: Colors.white),
              label: Text(
                'Lihat Statistik Lengkap',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      child: Column(
        children: [
          Icon(icon, color: Colors.green[700], size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
          ),
        ],
      ),
    );

    return Card(
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: onTap == null
          ? cardContent
          : InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: cardContent,
            ),
    );
  }
}
