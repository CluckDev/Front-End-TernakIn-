import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_data_screen.dart';

// List data kesehatan global (bisa diakses dari file lain)
List<KesehatanAyam> kesehatanList = [
  KesehatanAyam(
    tanggal: '20 April',
    kasus: 'Flu',
    jumlah: 2,
  ),
  KesehatanAyam(
    tanggal: '21 April',
    kasus: 'Cacingan',
    jumlah: 1,
  ),
  // Tambahkan data asli kamu di sini
];

// Model KesehatanAyam
class KesehatanAyam {
  final String tanggal;
  final String kasus;
  final int jumlah;
  KesehatanAyam({required this.tanggal, required this.kasus, required this.jumlah});
}

// Model ringkasan kesehatan
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

// Fungsi untuk ambil ringkasan
RingkasanKesehatan getRingkasanKesehatan(String periode) {
  if (periode == 'Harian') {
    return RingkasanKesehatan(
      jumlah: 5,
      waktu: '08:00 - 20 April',
      ringkasan: 'Ayam sakit: 5 ekor',
    );
  } else if (periode == 'Mingguan') {
    return RingkasanKesehatan(
      jumlah: 35,
      waktu: 'Minggu ini',
      ringkasan: 'Ayam sakit: 35 ekor',
    );
  } else {
    return RingkasanKesehatan(
      jumlah: 150,
      waktu: 'Bulan ini',
      ringkasan: 'Ayam sakit: 150 ekor',
    );
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
    final kesehatan = getRingkasanKesehatan(activePeriod);
    final ringkasanList = [
      _RingkasanData(
        'Kesehatan',
        Icons.health_and_safety,
        kesehatan.jumlah,
        kesehatan.waktu,
        kesehatan.ringkasan,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Kesehatan'),
        backgroundColor: Colors.green[700],
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
            child: Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Total Data Kesehatan: ${kesehatanList.length}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Grafik Produksi Kesehatan - $activePeriod',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _tabFilter('Harian'),
                _tabFilter('Mingguan'),
                _tabFilter('Bulanan'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Ringkasan
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
        builder: (context) => const TambahDataScreen(jenisData: 'Kesehatan'),
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
      onPressed: () {
        setState(() {
          activePeriod = label;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.green[700] : Colors.green[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: GoogleFonts.poppins(color: Colors.white)),
    );
  }
}

// Model ringkasan item
class _RingkasanData {
  final String label;
  final IconData icon;
  final int jumlah;
  final String waktu;
  final String ringkasan;

  _RingkasanData(this.label, this.icon, this.jumlah, this.waktu, this.ringkasan);
}

// Komponen ringkasan
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
    String jumlahText = '$jumlah ekor';
    return Container(
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 350) {
            // Responsive kolom
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(waktu, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 18, thickness: 1),
               Center(
                child: Text(
                  ringkasan,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                  textAlign: TextAlign.center,
                  // Tambahkan ini:
                  softWrap: true,
                  maxLines: 3, // atau boleh lebih besar sesuai kebutuhan
                  overflow: TextOverflow.visible, // agar tidak dipotong
                ),
              ),
                const Divider(height: 18, thickness: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Jumlah', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(jumlahText, style: GoogleFonts.poppins(fontSize: 14)),
                  ],
                ),
              ],
            );
          }
          return Row(
            children: [
              // Kiri (ikon + label + waktu)
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
                    Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(waktu, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[400],
                margin: const EdgeInsets.symmetric(horizontal: 6),
              ),
              // Tengah (ringkasan)
              Expanded(
                flex: 3,
                child: Center(
                  child: Text(
                    ringkasan,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    textAlign: TextAlign.center,
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[400],
                margin: const EdgeInsets.symmetric(horizontal: 6),
              ),
              // Kanan (jumlah)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Jumlah', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(jumlahText, style: GoogleFonts.poppins(fontSize: 14)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}