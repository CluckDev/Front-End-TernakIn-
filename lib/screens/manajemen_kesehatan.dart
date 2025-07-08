import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_data_screen.dart';

List<KesehatanAyam> kesehatanList = [
  KesehatanAyam(tanggal: '20 April', kasus: 'Flu', jumlah: 2),
  KesehatanAyam(tanggal: '21 April', kasus: 'Cacingan', jumlah: 1),
];

class KesehatanAyam {
  final String tanggal;
  final String kasus;
  final int jumlah;
  KesehatanAyam({required this.tanggal, required this.kasus, required this.jumlah});
}

class RingkasanKesehatan {
  final int jumlah;
  final String waktu;
  final String ringkasan;
  RingkasanKesehatan({
    required this.jumlah,
    required this.waktu,
    required this.ringkasan,
  });
}

RingkasanKesehatan getRingkasanKesehatan(String periode) {
  if (periode == 'Harian') {
    return RingkasanKesehatan(jumlah: 5, waktu: '08:00 - 20 April', ringkasan: 'Ayam sakit: 5');
  } else if (periode == 'Mingguan') {
    return RingkasanKesehatan(jumlah: 35, waktu: 'Minggu ini', ringkasan: 'Ayam sakit: 35');
  } else {
    return RingkasanKesehatan(jumlah: 150, waktu: 'Bulan ini', ringkasan: 'Ayam sakit: 150');
  }
}

class ManajemenKesehatanScreen extends StatefulWidget {
  const ManajemenKesehatanScreen({super.key});

  @override
  State<ManajemenKesehatanScreen> createState() => _ManajemenKesehatanScreenState();
}

class _ManajemenKesehatanScreenState extends State<ManajemenKesehatanScreen> {
  String activePeriod = 'Harian';

  @override
  Widget build(BuildContext context) {
    final RingkasanKesehatan data = getRingkasanKesehatan(activePeriod);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kesehatan'),
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
        children: [
          // Total Data Kesehatan
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
                  child: const Icon(Icons.health_and_safety, size: 28, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Kasus',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
                    Text('${kesehatanList.length}',
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

          // Filter Tab
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTab('Harian'),
                _buildTab('Mingguan'),
                _buildTab('Bulanan'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Ringkasan Item
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _RingkasanItem(
                  label: 'Kesehatan',
                  icon: Icons.health_and_safety,
                  jumlah: data.jumlah,
                  waktu: data.waktu,
                  ringkasan: data.ringkasan,
                ),
              ],
            ),
          ),
        ],
      ),

      // FAB Tambah
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahDataScreen(jenisData: 'Kesehatan'),
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
            // Kolom 1 - Label dan Waktu
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    waktu,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // Garis Vertikal
            Container(width: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),

            // Kolom 2 - Jumlah sakit
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Sakit',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ringkasan.replaceAll('Ayam sakit:', '').trim()} ekor',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ],
              ),
            ),

            // Garis Vertikal
            Container(width: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),

            // Kolom 3 - Jumlah Total
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Jumlah',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$jumlah',
                    style: GoogleFonts.poppins(fontSize: 14),
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
