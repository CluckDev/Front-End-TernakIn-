import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_data_screen.dart';

// List data telur global (bisa diakses dari file lain)
List<RingkasanTelur> telurList = [
  RingkasanTelur(
    jumlah: 2000,
    waktu: '08:00 - 20 April',
    ringkasan: 'Telur masuk: 2000 butir',
  ),
  RingkasanTelur(
    jumlah: 1500,
    waktu: '08:00 - 20 April',
    ringkasan: 'Telur keluar: 1500 butir',
  ),
  // Tambahkan data asli kamu di sini
];

class ManajemenTelurScreen extends StatefulWidget {
  const ManajemenTelurScreen({super.key});

  @override
  State<ManajemenTelurScreen> createState() => _ManajemenTelurScreenState();
}

class _ManajemenTelurScreenState extends State<ManajemenTelurScreen> {
  String activePeriod = 'Harian';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Telur'),
        backgroundColor: Colors.green[700],
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          // Tampilkan total telur di sini
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
            child: Row(
              children: [
                Icon(Icons.egg, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Total Data Telur: ${telurList.length}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          // Chart dummy yang berubah sesuai tab aktif
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Grafik Produksi Telur - $activePeriod',
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

          // List ringkasan dari data telurList
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: telurList.length,
              itemBuilder: (context, index) {
                final data = telurList[index];
                return _RingkasanItem(
                  label: data.jumlah >= 0 ? 'Masuk' : 'Keluar',
                  icon: Icons.egg,
                  jumlah: data.jumlah.abs(),
                  satuan: 'butir',
                  waktu: data.waktu,
                  ringkasan: data.ringkasan,
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
            MaterialPageRoute(builder: (context) => const TambahDataScreen()),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          // Default: tampilan baris (row) responsif
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
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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

// Model ringkasan telur
class RingkasanTelur {
  final int jumlah;
  final String waktu;
  final String ringkasan;
  RingkasanTelur({
    required this.jumlah,
    required this.waktu,
    required this.ringkasan,
  });
}

// Fungsi untuk mengambil ringkasan telur sesuai periode (opsional, jika ingin filter)
RingkasanTelur getRingkasanTelur(String periode) {
  // Contoh data dummy, nanti bisa diganti ambil dari database atau API
  if (periode == 'Harian') {
    return RingkasanTelur(
      jumlah: 1500,
      waktu: '08:00 - 20 April',
      ringkasan: 'Masuk: 2000',
    );
  } else if (periode == 'Mingguan') {
    return RingkasanTelur(
      jumlah: 10500,
      waktu: 'Minggu ini',
      ringkasan: 'Masuk: 14000',
    );
  } else {
    return RingkasanTelur(
      jumlah: 45000,
      waktu: 'Bulan ini',
      ringkasan: 'Masuk: 60000',
    );
  }
}