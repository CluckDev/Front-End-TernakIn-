import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ternakin/main.dart';
import 'package:ternakin/services/auth_services.dart'; // Untuk mendapatkan userId
import '../services/data_summary_service.dart'; // Import DataSummaryService
import 'manajemen_ayam.dart';
import 'manajemen_telur.dart';
import 'manajemen_pakan.dart';
import 'manajemen_kesehatan.dart';

// Hapus model dan fungsi RingkasanKesehatan yang lama
// class RingkasanKesehatan {
//   final int jumlah;
//   final String waktu;
//   final String ringkasan;
//
//   RingkasanKesehatan({
//     required this.jumlah,
//     required this.waktu,
//     required this.ringkasan,
//   });
// }
//
// RingkasanKesehatan getRingkasanKesehatan(String periode) {
//   if (periode == 'Harian') {
//     return RingkasanKesehatan(jumlah: 2, waktu: 'Hari ini', ringkasan: 'Ayam sakit: 2');
//   } else if (periode == 'Mingguan') {
//     return RingkasanKesehatan(jumlah: 8, waktu: 'Minggu ini', ringkasan: 'Ayam sakit: 8');
//   } else {
//     return RingkasanKesehatan(jumlah: 20, waktu: 'Bulan ini', ringkasan: 'Ayam sakit: 20');
//   }
// }

class ManajemenScreen extends StatefulWidget {
  const ManajemenScreen({super.key});

  @override
  State<ManajemenScreen> createState() => _ManajemenScreenState();
}

class _ManajemenScreenState extends State<ManajemenScreen> {
  String activePeriod = 'Harian';
  Map<String, int> _summaryTotals = {
    'Ayam': 0,
    'Telur': 0,
    'Pakan': 0,
    'Kesehatan': 0,
  };
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSummaryData(); // Muat data ringkasan saat inisialisasi
  }

  Future<void> _fetchSummaryData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userId = authService.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _errorMessage = 'Pengguna tidak login.';
        _isLoading = false;
      });
      return;
    }

    try {
      final totalAyam = await dataSummaryService.getTotalChickens(userId, activePeriod);
      final totalTelur = await dataSummaryService.getTotalEggs(userId, activePeriod);
      final totalPakan = await dataSummaryService.getTotalFeeds(userId, activePeriod);
      final totalSakit = await dataSummaryService.getTotalSick(userId, activePeriod);

      setState(() {
        _summaryTotals = {
          'Ayam': totalAyam,
          'Telur': totalTelur,
          'Pakan': totalPakan,
          'Kesehatan': totalSakit,
        };
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data ringkasan: $e';
        debugPrint('Error fetching summary data: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi pembantu untuk mendapatkan nama bulan dalam Bahasa Indonesia
  String _namaBulan(int bulan) {
    const namaBulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return namaBulan[bulan];
  }

  @override
  Widget build(BuildContext context) {
    final ringkasanList = [
      _RingkasanData(
        'Ayam',
        Icons.pets,
        _summaryTotals['Ayam']!,
        activePeriod == 'Harian' ? 'Hari ini' : activePeriod == 'Mingguan' ? 'Minggu ini' : 'Bulan ini',
        'Jumlah ayam saat ini ${_summaryTotals['Ayam']}',
      ),
      _RingkasanData(
        'Telur',
        Icons.egg,
        _summaryTotals['Telur']!,
        activePeriod == 'Harian' ? 'Hari ini' : activePeriod == 'Mingguan' ? 'Minggu ini' : 'Bulan ini',
        'Jumlah telur saat ini ${_summaryTotals['Telur']}',
      ),
      _RingkasanData(
        'Pakan',
        Icons.rice_bowl,
        _summaryTotals['Pakan']!,
        activePeriod == 'Harian' ? 'Hari ini' : activePeriod == 'Mingguan' ? 'Minggu ini' : 'Bulan ini',
        'Total pakan ${_summaryTotals['Pakan']} kg',
      ),
      _RingkasanData(
        'Kesehatan',
        Icons.health_and_safety,
        _summaryTotals['Kesehatan']!,
        activePeriod == 'Harian' ? 'Hari ini' : activePeriod == 'Mingguan' ? 'Minggu ini' : 'Bulan ini',
        'Ayam sakit: ${_summaryTotals['Kesehatan']}',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen'),
        backgroundColor: Colors.green[700],
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.green[100],
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _iconButton(
                  context,
                  Icons.pets,
                  'Ayam',
                  const ManajemenAyamScreen(),
                ),
                _iconButton(
                  context,
                  Icons.egg,
                  'Telur',
                  const ManajemenTelurScreen(),
                ),
                _iconButton(
                  context,
                  Icons.rice_bowl,
                  'Pakan',
                  const ManajemenPakanScreen(),
                ),
                _iconButton(
                  context,
                  Icons.health_and_safety,
                  'Kesehatan',
                  const ManajemenKesehatanScreen(),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.green[50],
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _tabFilterButton('Harian'),
                const SizedBox(width: 8),
                _tabFilterButton('Mingguan'),
                const SizedBox(width: 8),
                _tabFilterButton('Bulanan'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: ringkasanList.length,
                        itemBuilder: (context, index) {
                          final item = ringkasanList[index];
                          return _RingkasanItem(
                            label: item.label,
                            icon: item.icon,
                            jumlah: item.jumlah,
                            waktu: item.waktu,
                            ringkasan: item.ringkasan,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _tabFilterButton(String label) {
    final bool isActive = activePeriod == label;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          activePeriod = label;
        });
        _fetchSummaryData(); // Panggil ulang untuk memuat data berdasarkan periode baru
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.green[700] : Colors.green[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      child: Text(label, style: GoogleFonts.poppins(color: Colors.white)),
    );
  }

  Widget _iconButton(
    BuildContext context,
    IconData icon,
    String label,
    Widget page,
  ) {
    Color bgColor;
    switch (label) {
      case 'Ayam':
        bgColor = Colors.green[700]!;
        break;
      case 'Telur':
        bgColor = Colors.orange[400]!;
        break;
      case 'Pakan':
        bgColor = Colors.blue[400]!;
        break;
      case 'Kesehatan':
        bgColor = Colors.red[400]!;
        break;
      default:
        bgColor = Colors.green[700]!;
    }
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }
}

// Data ringkasan (tanpa index karena tidak ada edit/hapus di sini)
class _RingkasanData {
  final String label;
  final IconData icon;
  final int jumlah;
  final String waktu;
  final String ringkasan;

  _RingkasanData(
    this.label,
    this.icon,
    this.jumlah,
    this.waktu,
    this.ringkasan,
  );
}

class _RingkasanItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final int jumlah;
  final String waktu;
  final String ringkasan;

  const _RingkasanItem({
    required this.label,
    required this.icon,
    required this.jumlah,
    required this.waktu,
    required this.ringkasan,
  });

  @override
  Widget build(BuildContext context) {
    String jumlahText = label == 'Pakan' ? '$jumlah kg' : '$jumlah';

    return MouseRegion(
      cursor: SystemMouseCursors.basic, // 🔧 agar kursor tidak berubah
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.green[700], size: 28),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    waktu,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey[400],
              margin: const EdgeInsets.symmetric(horizontal: 6),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  ringkasan,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey[400],
              margin: const EdgeInsets.symmetric(horizontal: 6),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Jumlah',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    jumlahText,
                    style: GoogleFonts.poppins(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
