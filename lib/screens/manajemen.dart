import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manajemen_ayam.dart';
import 'manajemen_telur.dart';
import 'manajemen_pakan.dart';
import 'manajemen_kesehatan.dart';

class ManajemenScreen extends StatefulWidget {
  const ManajemenScreen({super.key});

  @override
  State<ManajemenScreen> createState() => _ManajemenScreenState();
}

class _ManajemenScreenState extends State<ManajemenScreen> {
  String activePeriod = 'Harian';

  @override
  Widget build(BuildContext context) {
    // Ambil data ringkasan dari masing-masing manajemen
    final ayam = getRingkasanAyam(activePeriod);
    final telur = getRingkasanTelur(activePeriod);
    final pakan = getRingkasanPakan(activePeriod);
    final kesehatan = getRingkasanKesehatan(activePeriod);

    final ringkasanList = [
      _RingkasanData(
        'Ayam',
        Icons.pets,
        ayam.jumlah,
        ayam.waktu,
        ayam.ringkasan,
      ),
      _RingkasanData(
        'Telur',
        Icons.egg,
        telur.jumlah,
        telur.waktu,
        telur.ringkasan,
      ),
      _RingkasanData(
        'Pakan',
        Icons.rice_bowl,
        pakan.jumlah,
        pakan.waktu,
        pakan.ringkasan,
      ),
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
          // Bagian atas tombol kategori
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

          // Tab filter Harian, Mingguan, Bulanan
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

          // List ringkasan sesuai tab aktif
          Expanded(
            child: Container(
              color: Colors.green[50],
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            // ...existing code...
            boxShadow: [
              BoxShadow(
                color: Colors.green.withAlpha(20), // 0.08 * 255 ≈ 20
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            // ...existing code...
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              // Ikon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.green[700], size: 28),
              ),
              const SizedBox(width: 8),

              // Label + waktu
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

              // Garis vertikal
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[400],
                margin: const EdgeInsets.symmetric(horizontal: 6),
              ),

              // Ringkasan
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

              // Garis vertikal
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[400],
                margin: const EdgeInsets.symmetric(horizontal: 6),
              ),

              // Jumlah
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
      ),
    );
  }
}
