import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_data_screen.dart';
import 'package:intl/intl.dart';
String formattedWaktu = DateFormat('d MMMM yyyy', 'id_ID')
    .format(DateTime.tryParse(item.waktu) ?? now);

// Model Telur
class Telur {
  int jumlah;
  String waktu; // Format 'yyyy-MM-dd'
  String status; // Masuk / Keluar

  Telur({required this.jumlah, required this.waktu, required this.status});
}

List<Telur> telurList = [
  Telur(jumlah: 2000, waktu: '2025-07-08', status: 'Masuk'),
  Telur(jumlah: 1500, waktu: '2025-07-08', status: 'Keluar'),
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
    DateTime now = DateTime.now();

    final ringkasanList = telurList.asMap().entries.where((entry) {
      final item = entry.value;
      DateTime waktuItem = DateTime.tryParse(item.waktu) ?? now;

      if (activePeriod == 'Harian') {
        return waktuItem.year == now.year &&
            waktuItem.month == now.month &&
            waktuItem.day == now.day;
      } else if (activePeriod == 'Mingguan') {
        DateTime awal = now.subtract(Duration(days: now.weekday - 1));
        DateTime akhir = awal.add(const Duration(days: 6));
        return waktuItem.isAfter(awal.subtract(const Duration(seconds: 1))) &&
            waktuItem.isBefore(akhir.add(const Duration(days: 1)));
      } else if (activePeriod == 'Bulanan') {
        return waktuItem.year == now.year && waktuItem.month == now.month;
      }
      return true;
    }).map((entry) {
      final index = entry.key;
      final item = entry.value;

      return _RingkasanData(
        'Telur',
        Icons.egg,
        item.jumlah,
        item.waktu,
        '${item.status} ${item.jumlah}',
        index,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Telur'),
        backgroundColor: Colors.green,
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Telur
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
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey[700])),
                    Text('${_hitungTotalTelur()}',
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
              children: ['Harian', 'Mingguan', 'Bulanan']
                  .map((label) => _buildTab(label))
                  .toList(),
            ),
          ),

          const SizedBox(height: 12),

          // List Telur
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
                    final edited = await Navigator.push<Telur>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TambahDataScreen(
                          jenisData: 'Telur',
                          initialTelur: telurList[item.index],
                        ),
                      ),
                    );

                    if (edited != null) {
                      setState(() {
                        telurList[item.index] = edited;
                      });
                    }
                  },
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi Hapus'),
                        content: const Text('Yakin ingin menghapus data ini?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Batal')),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  telurList.removeAt(item.index);
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Hapus',
                                  style: TextStyle(color: Colors.red))),
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

      // FAB tambah telur
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () async {
          final newTelur = await Navigator.push<Telur>(
            context,
            MaterialPageRoute(
              builder: (context) => const TambahDataScreen(jenisData: 'Telur'),
            ),
          );

          if (newTelur != null) {
            setState(() {
              telurList.add(newTelur);
            });
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTab(String label) {
    final isActive = activePeriod == label;
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

  int _hitungTotalTelur() {
    int masuk = 0;
    int keluar = 0;
    DateTime now = DateTime.now();

    for (var telur in telurList) {
      DateTime waktu = DateTime.tryParse(telur.waktu) ?? now;

      bool cocok = false;
      if (activePeriod == 'Harian') {
        cocok = waktu.year == now.year &&
            waktu.month == now.month &&
            waktu.day == now.day;
      } else if (activePeriod == 'Mingguan') {
        DateTime awal = now.subtract(Duration(days: now.weekday - 1));
        DateTime akhir = awal.add(const Duration(days: 6));
        cocok = waktu.isAfter(awal.subtract(const Duration(seconds: 1))) &&
            waktu.isBefore(akhir.add(const Duration(days: 1)));
      } else if (activePeriod == 'Bulanan') {
        cocok = waktu.year == now.year && waktu.month == now.month;
      }

      if (cocok) {
        if (telur.status == 'Masuk') {
          masuk += telur.jumlah;
        } else if (telur.status == 'Keluar') {
          keluar += telur.jumlah;
        }
      }
    }

    return masuk - keluar;
  }
}

// Model Ringkasan dengan Index
class _RingkasanData {
  final String label;
  final IconData icon;
  final int jumlah;
  final String waktu;
  final String ringkasan;
  final int index;

  _RingkasanData(
      this.label, this.icon, this.jumlah, this.waktu, this.ringkasan, this.index);
}

// Widget Item Telur
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
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(waktu,
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.grey[700])),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: Text(ringkasan,
                    style: GoogleFonts.poppins(fontSize: 13)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Edit Data',
            ),
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
