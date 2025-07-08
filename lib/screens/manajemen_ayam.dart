import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_data_screen.dart';

// Model Ayam
class Ayam {
  int jumlah;
  String waktu;
  String status; // Masuk / Keluar

  Ayam({required this.jumlah, required this.waktu, required this.status});
}
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

RingkasanAyam getRingkasanAyam(String periode) {
  int totalMasuk = 0;
  int totalKeluar = 0;

  for (var ayam in ayamList) {
    if (ayam.status == 'Masuk') {
      totalMasuk += ayam.jumlah;
    } else if (ayam.status == 'Keluar') {
      totalKeluar += ayam.jumlah;
    }
  }

  int jumlahSekarang = totalMasuk - totalKeluar;

  String waktuText;
  String ringkasanText;

  switch (periode) {
    case 'Harian':
      waktuText = 'Hari ini';
      ringkasanText = 'Jumlah ayam saat ini $jumlahSekarang';
      break;
    case 'Mingguan':
      waktuText = 'Minggu ini';
      ringkasanText = 'Estimasi ayam mingguan';
      break;
    case 'Bulanan':
      waktuText = 'Bulan ini';
      ringkasanText = 'Estimasi ayam bulanan';
      break;
    default:
      waktuText = 'Hari ini';
      ringkasanText = 'Jumlah ayam saat ini $jumlahSekarang';
      break;
  }

  return RingkasanAyam(
    jumlah: jumlahSekarang,
    waktu: waktuText,
    ringkasan: ringkasanText,
  );
}

// Data global ayamList sebagai sumber data
List<Ayam> ayamList = [
  Ayam(jumlah: 1200, waktu: '2025-04-20', status: 'Masuk'),
  Ayam(jumlah: 1500, waktu: '2025-04-21', status: 'Masuk'),
];

class ManajemenAyamScreen extends StatefulWidget {
  const ManajemenAyamScreen({super.key});

  @override
  State<ManajemenAyamScreen> createState() => _ManajemenAyamScreenState();
}

class _ManajemenAyamScreenState extends State<ManajemenAyamScreen> {
  String activePeriod = 'Harian';

  @override
  Widget build(BuildContext context) {
final ringkasanList = ayamList.asMap().entries.where((entry) {
  final item = entry.value;
  DateTime now = DateTime.now();
  DateTime waktuItem = DateTime.tryParse(item.waktu) ?? now;

  if (activePeriod == 'Harian') {
    return waktuItem.year == now.year &&
           waktuItem.month == now.month &&
           waktuItem.day == now.day;
  } else if (activePeriod == 'Mingguan') {
    DateTime awalMinggu = now.subtract(Duration(days: now.weekday - 1));
    DateTime akhirMinggu = awalMinggu.add(const Duration(days: 6));
    return waktuItem.isAfter(awalMinggu.subtract(const Duration(seconds: 1))) &&
           waktuItem.isBefore(akhirMinggu.add(const Duration(days: 1)));
  } else if (activePeriod == 'Bulanan') {
    return waktuItem.year == now.year && waktuItem.month == now.month;
  }
  return true;
}).map((entry) {
  final index = entry.key;
  final item = entry.value;

  return _RingkasanData(
    'Ayam',
    Icons.pets,
    item.jumlah,
    item.waktu,
    '${item.status} ${item.jumlah}',
    index,
  );
}).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Ayam'),
        backgroundColor: Colors.green,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey[700])),
                    Text('${_hitungTotalAyam()}',
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

          // Filter Harian/Mingguan/Bulanan (belum pakai fungsi, hanya UI)
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

          // List data ayam dengan tombol edit & hapus
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
                  onEdit: () async {
                    // Buka TambahDataScreen dengan data awal untuk edit
                    final edited = await Navigator.push<Ayam>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TambahDataScreen(
                          jenisData: 'Ayam',
                          initialAyam: ayamList[item.index],
                        ),
                      ),
                    );

                    if (edited != null) {
                      setState(() {
                        ayamList[item.index] = edited;
                      });
                    }
                  },
                  onDelete: () {
                    // Konfirmasi hapus
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi Hapus'),
                        content: const Text('Yakin ingin menghapus data ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                ayamList.removeAt(item.index);
                              });
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Hapus',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () async {
          // Tambah data baru
          final newAyam = await Navigator.push<Ayam>(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahDataScreen(jenisData: 'Ayam'),
            ),
          );

          if (newAyam != null) {
            setState(() {
              ayamList.add(newAyam);
            });
          }
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
int _hitungTotalAyam() {
  int masuk = 0;
  int keluar = 0;
  DateTime now = DateTime.now();

  for (var ayam in ayamList) {
    DateTime waktuAyam = DateTime.tryParse(ayam.waktu) ?? now;

    // Cek apakah data sesuai filter
    bool cocok = false;
    if (activePeriod == 'Harian') {
      cocok = waktuAyam.year == now.year &&
              waktuAyam.month == now.month &&
              waktuAyam.day == now.day;
    } else if (activePeriod == 'Mingguan') {
      DateTime awalMinggu = now.subtract(Duration(days: now.weekday - 1));
      DateTime akhirMinggu = awalMinggu.add(const Duration(days: 6));
      cocok = waktuAyam.isAfter(awalMinggu.subtract(const Duration(seconds: 1))) &&
              waktuAyam.isBefore(akhirMinggu.add(const Duration(days: 1)));
    } else if (activePeriod == 'Bulanan') {
      cocok = waktuAyam.year == now.year && waktuAyam.month == now.month;
    }

    if (cocok) {
      if (ayam.status == 'Masuk') {
        masuk += ayam.jumlah;
      } else if (ayam.status == 'Keluar') {
        keluar += ayam.jumlah;
      }
    }
  }

  return masuk - keluar;
}
}
// Data ringkasan dengan index agar bisa edit/hapus
class _RingkasanData {
  final String label;
  final IconData icon;
  final int jumlah;
  final String waktu;
  final String ringkasan;
  final int index;

  _RingkasanData(this.label, this.icon, this.jumlah, this.waktu, this.ringkasan,
      this.index);
}

// Widget item list ayam dengan tombol edit dan hapus
class _RingkasanItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final int jumlah;
  final String waktu;
  final String ringkasan;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _RingkasanItem({
    required this.label,
    required this.icon,
    required this.jumlah,
    required this.waktu,
    required this.ringkasan,
    this.onEdit,
    this.onDelete,
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
            // Icon + Label + Waktu
            Expanded(
              flex: 3,
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

            // Jumlah + Status (ringkasan)
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  ringkasan,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ),

            // Tombol edit
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Edit Data',
            ),

            // Tombol hapus
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Hapus Data',
            ),
          ],
        ),
      ),
    );
  }
}
