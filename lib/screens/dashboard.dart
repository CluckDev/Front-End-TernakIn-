import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ternakin/services/auth_services.dart';
import 'package:ternakin/services/data_summary_service.dart'; // Import DataSummaryService
import '../widgets/bottom_navbar.dart';
import 'dashboard_chart.dart';
import 'jadwal.dart';
import 'manajemen.dart';
import 'manajemen_ayam.dart';
import 'manajemen_kesehatan.dart';
import 'manajemen_pakan.dart';
import 'manajemen_telur.dart';
import 'profile.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// Karena dataSummaryService sekarang diinisialisasi sebagai late final di main.dart,
// kita bisa mengaksesnya secara global setelah main.dart selesai inisialisasi.
// Namun, untuk robusta, kita akan meneruskannya sebagai parameter ke DashboardContent.
import '../main.dart'; // Import main.dart untuk mengakses dataSummaryService global

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
    if (!mounted) return; // Tambahkan pemeriksaan mounted di sini
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
      // Teruskan instance dataSummaryService ke DashboardContent
      DashboardContent(userName: _userName, photoUrl: _photoUrl, dataSummaryService: dataSummaryService),
      const JadwalScreen(), // Pastikan JadwalScreen juga const jika tidak ada state
      const ManajemenScreen(),
      const ProfilScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: currentPage[_selectedIndex]), // Gunakan currentPage
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          _onTap(index);
          // Jika kembali ke tab Dashboard (index 0) setelah perubahan, muat ulang profil
          if (index == 0) {
            _loadUserProfile(authService.currentUser); // Panggil dengan user saat ini
          }
        },
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  final String userName;
  final String? photoUrl; // Tambahkan properti photoUrl
  final DataSummaryService dataSummaryService; // Tambahkan parameter ini

  const DashboardContent({
    super.key,
    required this.userName,
    this.photoUrl,
    required this.dataSummaryService, // Tandai sebagai required
  });

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  String selectedChart = 'telur';
  Map<String, int> _summaryTotals = {
    'Ayam': 0,
    'Telur': 0,
    'Pakan': 0,
    'Sakit': 0, // Menggunakan 'Sakit' agar konsisten dengan label di UI
  };
  bool _isLoadingSummary = true;
  String? _summaryErrorMessage;

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
  void initState() {
    super.initState();
    _fetchSummaryData(); // Muat data ringkasan saat inisialisasi DashboardContent
  }

  Future<void> _fetchSummaryData() async {
    if (!mounted) return; // Tambahkan pemeriksaan mounted di awal fungsi
    setState(() {
      _isLoadingSummary = true;
      _summaryErrorMessage = null;
    });

    final userId = authService.currentUser?.uid;
    if (userId == null) {
      if (!mounted) return; // Pemeriksaan mounted sebelum setState
      setState(() {
        _summaryErrorMessage = 'Pengguna tidak login.';
        _isLoadingSummary = false;
      });
      return;
    }

    try {
      final totalAyam = await widget.dataSummaryService.getTotalChickens(userId, 'Bulanan');
      final totalTelur = await widget.dataSummaryService.getTotalEggs(userId, 'Bulanan');
      final totalPakan = await widget.dataSummaryService.getTotalFeeds(userId, 'Bulanan');
      final totalSakit = await widget.dataSummaryService.getTotalSick(userId, 'Bulanan');

      if (!mounted) return; // Pemeriksaan mounted sebelum setState
      setState(() {
        _summaryTotals = {
          'Ayam': totalAyam,
          'Telur': totalTelur,
          'Pakan': totalPakan,
          'Sakit': totalSakit,
        };
      });
    } catch (e) {
      if (!mounted) return; // Pemeriksaan mounted sebelum setState
      setState(() {
        _summaryErrorMessage = 'Gagal memuat data ringkasan: $e';
        debugPrint('Error fetching summary data for DashboardContent: $e');
      });
    } finally {
      if (mounted) { // Pemeriksaan mounted di blok finally
        setState(() {
          _isLoadingSummary = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double basePadding = screenWidth * 0.04; // 4% dari lebar layar sebagai padding dasar
    final double smallSpacing = screenWidth * 0.02; // 2% untuk spasi kecil
    final double mediumSpacing = screenWidth * 0.04; // 4% untuk spasi sedang

    // Radius avatar responsif
    final double logoAvatarRadius = screenWidth * 0.07; // Radius logo
    final double profileAvatarRadius = screenWidth * 0.06; // Radius profil

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header lebih menarik
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade700!, Colors.green.shade400!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            // Padding responsif untuk Container header
            padding: EdgeInsets.fromLTRB(basePadding, 48, basePadding, 32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Bagian Kiri: Logo Aplikasi dan Teks Selamat Datang
                CircleAvatar(
                  radius: logoAvatarRadius, // Radius responsif
                  backgroundColor: Colors.white,
                  backgroundImage: const AssetImage('assets/images/logo.png'),
                ),
                SizedBox(width: smallSpacing), // Spasi responsif

                Expanded( // Expanded untuk Column teks agar mengambil sisa ruang
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Selamat datang di aplikasi kami',
                        style: GoogleFonts.poppins(
                          fontSize: 14, // Ukuran font tetap
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Ternakin',
                        style: GoogleFonts.poppins(
                          fontSize: 20, // Ukuran font tetap
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Manajemen Peternakan',
                        style: GoogleFonts.poppins(
                          fontSize: 13, // Ukuran font tetap
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const Spacer(), // Mendorong elemen ke ujung kanan

                // Bagian Kanan: Profil user
                GestureDetector(
                  onTap: () {
                    // Ketika menavigasi ke ProfilScreen, kita ingin tahu kapan kembali
                    // agar bisa memuat ulang data profil jika ada perubahan.
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilScreen()))
                        .then((_) {
                      // Setelah kembali dari ProfilScreen, muat ulang data pengguna
                      // Ini akan memicu setState di DashboardScreen dan memperbarui DashboardContent
                      // ignore: use_build_context_synchronously
                      final _DashboardScreenState? dashboardState = context.findAncestorStateOfType<_DashboardScreenState>();
                      dashboardState?._loadUserProfile(authService.currentUser); // Panggil dengan user saat ini
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: profileAvatarRadius, // Radius responsif
                        backgroundColor: Colors.white,
                        // Gunakan photoUrl dari widget jika tersedia, jika tidak gunakan aset default
                        backgroundImage: widget.photoUrl != null && widget.photoUrl!.isNotEmpty
                            ? NetworkImage(widget.photoUrl!) as ImageProvider<Object>?
                            : const AssetImage('assets/images/cipaaa.png'),
                        // Jika tidak ada gambar, tampilkan ikon default
                        child: widget.photoUrl == null || widget.photoUrl!.isEmpty
                            ? Icon(Icons.person, color: Colors.green[700], size: profileAvatarRadius * 1.5)
                            : null,
                      ),
                      SizedBox(height: screenWidth * 0.01), // Spasi responsif
                      Text(
                        widget.userName,
                        style: GoogleFonts.poppins(
                          fontSize: 13, // Ukuran font tetap
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: mediumSpacing), // Spasi responsif

          // Summary cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: basePadding), // Padding responsif
            child: LayoutBuilder( // Gunakan LayoutBuilder untuk responsivitas kartu
              builder: (context, constraints) {
                // Tentukan jumlah kolom berdasarkan lebar yang tersedia
                int crossAxisCount = (constraints.maxWidth / (120 + smallSpacing * 2)).floor(); // Estimasi lebar kartu + spasi
                if (crossAxisCount < 2) crossAxisCount = 2; // Minimal 2 kolom
                if (crossAxisCount > 4) crossAxisCount = 4; // Maksimal 4 kolom

                return GridView.count(
                  shrinkWrap: true, // Penting agar GridView tidak mengambil tinggi tak terbatas
                  physics: const NeverScrollableScrollPhysics(), // Nonaktifkan scroll GridView
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: smallSpacing, // Spasi horizontal responsif
                  mainAxisSpacing: smallSpacing, // Spasi vertikal responsif
                  childAspectRatio: 0.9, // Rasio aspek kartu (width / height)
                  children: [
                    SummaryCard(
                      label: 'Telur',
                      value: _summaryTotals['Telur']!.toString(),
                      icon: Icons.egg,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ManajemenTelurScreen()));
                      },
                    ),
                    SummaryCard(
                      label: 'Ayam',
                      value: _summaryTotals['Ayam']!.toString(),
                      icon: Icons.pets,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ManajemenAyamScreen()));
                      },
                    ),
                    SummaryCard(
                      label: 'Pakan',
                      value: _summaryTotals['Pakan']!.toString(),
                      icon: Icons.rice_bowl,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ManajemenPakanScreen()));
                      },
                    ),
                    SummaryCard(
                      label: 'Sakit',
                      value: _summaryTotals['Sakit']!.toString(),
                      icon: Icons.warning,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ManajemenKesehatanScreen()));
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: mediumSpacing), // Spasi responsif

          // Grafik utama dengan dropdown
          Padding(
            padding: EdgeInsets.symmetric(horizontal: basePadding), // Padding responsif
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(basePadding), // Padding responsif
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
                          padding: EdgeInsets.all(smallSpacing), // Padding responsif
                          child: Icon(chartIcons[selectedChart],
                              color: Colors.green[700], size: screenWidth * 0.06), // Ukuran ikon responsif
                        ),
                        SizedBox(width: smallSpacing), // Spasi responsif
                        Expanded( // Gunakan Expanded untuk teks judul grafik
                          child: Text(
                            chartLabels[selectedChart]!,
                            style: GoogleFonts.poppins(
                              fontSize: 16, // Ukuran font tetap
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: smallSpacing), // Spasi responsif
                        DropdownButton<String>(
                          value: selectedChart,
                          isDense: true,
                          underline: const SizedBox(),
                          borderRadius: BorderRadius.circular(12),
                          items: chartLabels.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value,
                                  style: GoogleFonts.poppins(fontSize: 14)), // Ukuran font tetap
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedChart = val);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: mediumSpacing), // Spasi responsif
                    SizedBox(
                      height: screenWidth * 0.6, // Tinggi grafik responsif (misal 60% dari lebar layar)
                      child: DashboardChart(period: 'daily', type: selectedChart),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(height: mediumSpacing), // Spasi responsif
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
    // Ukuran ikon kartu juga bisa responsif
    final screenWidth = MediaQuery.of(context).size.width;
    final double cardIconSize = screenWidth * 0.08; // Contoh: 8% dari lebar layar

    final cardContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Penting untuk kartu
        children: [
          Icon(icon, color: Colors.green[700], size: cardIconSize), // Ukuran ikon responsif
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14, // Ukuran font tetap
              fontWeight: FontWeight.w600,
              color: Colors.green[900],
            ),
            textAlign: TextAlign.center, // Pusatkan teks
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18, // Ukuran font tetap
              fontWeight: FontWeight.bold,
              color: Colors.green[900],
            ),
            textAlign: TextAlign.center, // Pusatkan teks
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
