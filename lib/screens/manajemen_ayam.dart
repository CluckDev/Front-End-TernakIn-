import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_data_screen.dart';

// List data ayam global (bisa diakses dari file lain)
List<Ayam> ayamList = [
  Ayam(nama: 'Ayam 1', umur: 12, jenis: 'Petelur'),
  Ayam(nama: 'Ayam 2', umur: 10, jenis: 'Petelur'),
  Ayam(nama: 'Ayam 3', umur: 8, jenis: 'Pedaging'),
  Ayam(nama: 'Ayam 4', umur: 15, jenis: 'Pedaging'),
];

// Contoh model Ayam
class Ayam {
  final String nama;
  final int umur;
  final String jenis;
  Ayam({required this.nama, required this.umur, required this.jenis});
}

// Model ringkasan ayam
class RingkasanAyam {
  final int jumlah;
  final String waktu;
  final String ringkasan;
  RingkasanAyam({
    required this.jumlah,
    required this.waktu,
    required this.ringkasan,
  });
}

// Fungsi untuk ambil ringkasan
RingkasanAyam getRingkasanAyam(String periode) {
  if (periode == 'Harian') {
    return RingkasanAyam(
      jumlah: 2000,
      waktu: '08:00 - 20 April',
      ringkasan: 'Masuk: 1500',
    );
  } else if (periode == 'Mingguan') {
    return RingkasanAyam(
      jumlah: 12000,
      waktu: 'Minggu ke-3 April',
      ringkasan: 'Masuk: 8000',
    );
  } else {
    return RingkasanAyam(
      jumlah: 48000,
      waktu: 'April 2025',
      ringkasan: 'Masuk: 32000',
    );
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
      _RingkasanData(
        'Ayam',
        Icons.pets,
        ayam.jumlah,
        ayam.waktu,
        ayam.ringkasan,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Ayam'),
        backgroundColor: Colors.green[700],
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          // Tampilkan total ayam di sini
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
            child: Row(
              children: [
                Icon(Icons.pets, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Total Ayam: ${ayamList.length}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          // Grafik dummy
          Container(
            height: 200,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Grafik Produksi Ayam - $activePeriod',
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
    String jumlahText = label == 'Pakan' ? '$jumlah kg' : '$jumlah';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
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
              // Default tampilan baris
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
        ),
      ),
    );
  }
}