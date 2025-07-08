import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_data_screen.dart';

// Data Ayam
List<Ayam> ayamList = [
  Ayam(jumlah: 1200, waktu: '20 April 2025', ringkasan: 'Masuk 1000, Keluar 200'),
  Ayam(jumlah: 1500, waktu: '21 April 2025', ringkasan: 'Masuk 1500, Keluar 0'),
];

// Model Ayam
class Ayam {
  final int jumlah;
  final String waktu;
  final String ringkasan;
  Ayam({required this.jumlah, required this.waktu, required this.ringkasan});
}

// Ringkasan
class RingkasanAyam {
  final int jumlah;
  final String waktu;
  final String ringkasan;
  RingkasanAyam({required this.jumlah, required this.waktu, required this.ringkasan});
}

RingkasanAyam getRingkasanAyam(String periode) {
  switch (periode) {
    case 'Mingguan':
      return RingkasanAyam(jumlah: 12000, waktu: 'Minggu ke-3 April', ringkasan: 'Masuk 8000');
    case 'Bulanan':
      return RingkasanAyam(jumlah: 48000, waktu: 'April 2025', ringkasan: 'Masuk 32000');
    default:
      return RingkasanAyam(jumlah: 2000, waktu: '08:00 - 20 April', ringkasan: 'Masuk 1500');
  }
}

class ManajemenAyamScreen extends StatefulWidget {
  const ManajemenAyamScreen({super.key});

  @override
  State<ManajemenAyamScreen> createState() => _ManajemenAyamScreenState();
}

class _ManajemenAyamScreenState extends State<ManajemenAyamScreen> {
  String activePeriod = 'Harian';

  @override
  Widget build(BuildContext context) {
    final ayam = getRingkasanAyam(activePeriod);
    final ringkasanList = [
      _RingkasanData('Ayam', Icons.pets, ayam.jumlah, ayam.waktu, ayam.ringkasan),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Ayam'),
        backgroundColor: Colors.green,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Ayam (card mini)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFd0f0c0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pets, size: 28, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Ayam',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
                    Text('${ayamList.length}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.green[800],
                        )),
                  ],
                ),
              ],
            ),
          ),

          // Filter Harian/Mingguan/Bulanan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Harian', 'Mingguan', 'Bulanan'].map((label) => _buildTab(label)).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Ringkasan Ayam
          Expanded(
            child: ListView.builder(
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahDataScreen(jenisData: 'Ayam'),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTab(String label) {
    final bool isActive = activePeriod == label;
    return ElevatedButton(
      onPressed: () => setState(() => activePeriod = label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.green[700] : Colors.green[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label, style: GoogleFonts.poppins(color: Colors.white)),
    );
  }
}

// Data Ringkasan
class _RingkasanData {
  final String label;
  final IconData icon;
  final int jumlah;
  final String waktu;
  final String ringkasan;

  _RingkasanData(this.label, this.icon, this.jumlah, this.waktu, this.ringkasan);
}

// Komponen Ringkasan
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
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
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Kolom 1
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(waktu, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
                ],
              ),
            ),

            // Garis Vertikal
            Container(width: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),

            // Kolom 2
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text('Masuk', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    '${ringkasan.replaceAll(RegExp(r'Masuk|Keluar', caseSensitive: false), '').split(',')[0].trim()} ekor',
                    style: GoogleFonts.poppins(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Garis Vertikal
            Container(width: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),

            // Kolom 3
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Jumlah', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('$jumlah ekor', style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
