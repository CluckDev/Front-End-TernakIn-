import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_data_screen.dart';

// List data pakan global (bisa diakses dari file lain)
List<RingkasanPakan> pakanList = [
  RingkasanPakan(
    jumlah: 100,
    waktu: '08:00 - 20 April',
    ringkasan: 'Keluar 50 kg',
  ),
  RingkasanPakan(
    jumlah: 40,
    waktu: '08:00 - 20 April',
    ringkasan: 'Masuk: 10 kg',
  ),
];

class ManajemenPakanScreen extends StatefulWidget {
  const ManajemenPakanScreen({super.key});

  @override
  State<ManajemenPakanScreen> createState() => _ManajemenPakanScreenState();
}

class _ManajemenPakanScreenState extends State<ManajemenPakanScreen> {
  String activePeriod = 'Harian';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pakan'),
        backgroundColor: Colors.green[700],
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
// ...existing code...
      body: Column(
        children: [
          // Tampilkan total data pakan di sini
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
            child: Row(
              children: [
                Icon(Icons.rice_bowl, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Total Data Pakan: ${pakanList.length}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          // Chart dummy/grafik
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Grafik Produksi Pakan - $activePeriod',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
          ),
          // Tab filter
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
          // List ringkasan dari getRingkasanPakan sesuai tab aktif
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _RingkasanItem(
                  label: 'Pakan',
                  icon: Icons.rice_bowl,
                  jumlah: getRingkasanPakan(activePeriod).jumlah,
                  satuan: 'kg',
                  waktu: getRingkasanPakan(activePeriod).waktu,
                  ringkasan: getRingkasanPakan(activePeriod).ringkasan,
                ),
              ],
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
        builder: (context) => const TambahDataScreen(jenisData: 'Pakan'),
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

class _RingkasanItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final int jumlah;
  final String satuan;
  final String waktu;
  final String ringkasan;

  const _RingkasanItem({
    required this.label,
    required this.icon,
    required this.jumlah,
    required this.satuan,
    required this.waktu,
    required this.ringkasan,
  });

  @override
  Widget build(BuildContext context) {
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
                        Text(waktu, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700])),
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
                    Text('$jumlah $satuan', style: GoogleFonts.poppins(fontSize: 14)),
                  ],
                ),
              ],
            );
          }
          return Row(
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
                    Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(waktu, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // Garis vertikal
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
              // Garis vertikal
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[400],
                margin: const EdgeInsets.symmetric(horizontal: 6),
              ),
              // Kanan (jumlah + satuan)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Jumlah', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('$jumlah $satuan', style: GoogleFonts.poppins(fontSize: 14)),
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

// Model ringkasan pakan
class RingkasanPakan {
  final int jumlah;
  final String waktu;
  final String ringkasan;
  RingkasanPakan({
    required this.jumlah,
    required this.waktu,
    required this.ringkasan,
  });
}

// Fungsi untuk mengambil ringkasan pakan sesuai periode (opsional)
RingkasanPakan getRingkasanPakan(String periode) {
  // Contoh data dummy, nanti bisa diganti ambil dari database atau API
  if (periode == 'Harian') {
    return RingkasanPakan(
      jumlah: 20,
      waktu: '08:00 - 20 April',
      ringkasan: 'Masuk: Jagung 20 kg',
    );
  } else if (periode == 'Mingguan') {
    return RingkasanPakan(
      jumlah: 140,
      waktu: 'Minggu ini',
      ringkasan: 'Masuk: Jagung 140 kg',
    );
  } else {
    return RingkasanPakan(
      jumlah: 600,
      waktu: 'Bulan ini',
      ringkasan: 'Masuk: Jagung 600 kg',
    );
  }
}