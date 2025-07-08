import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_data_screen.dart';

// Dummy Data Telur
List<RingkasanTelur> telurList = [
  RingkasanTelur(jumlah: 2000, waktu: '08:00 - 20 April', ringkasan: 'Telur masuk 2000'),
  RingkasanTelur(jumlah: 1500, waktu: '08:00 - 20 April', ringkasan: 'Telur keluar 1500'),
];

class RingkasanTelur {
  final int jumlah;
  final String waktu;
  final String ringkasan;
  RingkasanTelur({required this.jumlah, required this.waktu, required this.ringkasan});
}

RingkasanTelur getRingkasanTelur(String periode) {
  if (periode == 'Harian') {
    return RingkasanTelur(jumlah: 1500, waktu: '08:00 - 20 April', ringkasan: 'Telur masuk 2000');
  } else if (periode == 'Mingguan') {
    return RingkasanTelur(jumlah: 10500, waktu: 'Minggu ini', ringkasan: 'Telur masuk 14000');
  } else {
    return RingkasanTelur(jumlah: 45000, waktu: 'Bulan ini', ringkasan: 'Telur masuk 60000');
  }
}

class ManajemenTelurScreen extends StatefulWidget {
  const ManajemenTelurScreen({super.key});

  @override
  State<ManajemenTelurScreen> createState() => _ManajemenTelurScreenState();
}

class _ManajemenTelurScreenState extends State<ManajemenTelurScreen> {
  String activePeriod = 'Harian';

  @override
  Widget build(BuildContext context) {
    final telur = getRingkasanTelur(activePeriod);
    final ringkasanList = [
      _RingkasanData('Telur', Icons.egg, telur.jumlah, telur.waktu, telur.ringkasan),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Telur'),
        backgroundColor: Colors.green,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Total Data Telur
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
                  child: const Icon(Icons.egg, size: 28, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Telur',
                        style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
                    Text('${telurList.length}',
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

          // Tab Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Harian', 'Mingguan', 'Bulanan'].map((label) => _tabFilter(label)).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Ringkasan
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ringkasanList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
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
              builder: (context) => const TambahDataScreen(jenisData: 'Telur'),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _tabFilter(String label) {
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

// Model Ringkasan Internal
class _RingkasanData {
  final String label;
  final IconData icon;
  final int jumlah;
  final String waktu;
  final String ringkasan;
  _RingkasanData(this.label, this.icon, this.jumlah, this.waktu, this.ringkasan);
}

// Komponen Ringkasan Telur
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha(30),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Kolom 1: Label dan Waktu
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

            // Kolom 2: Masuk
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Text('Masuk', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    '${ringkasan.replaceAll(RegExp(r'Telur (masuk|keluar)', caseSensitive: false), '').trim()} butir',
                    style: GoogleFonts.poppins(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Garis Vertikal
            Container(width: 1, color: Colors.grey[300], margin: const EdgeInsets.symmetric(horizontal: 8)),

            // Kolom 3: Jumlah
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Jumlah', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('$jumlah butir', style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
