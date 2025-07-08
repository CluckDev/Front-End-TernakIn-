import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifikasiList = [
      {
        'judul': 'Ayam sakit terdeteksi',
        'waktu': 'Hari ini, 08:00',
        'isi': 'Ada 2 ayam yang terdeteksi sakit di kandang A.',
        'tipe': 'bahaya'
      },
      {
        'judul': 'Stok pakan menipis',
        'waktu': 'Kemarin, 17:30',
        'isi': 'Stok pakan tinggal 5kg. Segera lakukan pengisian ulang.',
        'tipe': 'peringatan'
      },
      {
        'judul': 'Produksi telur meningkat',
        'waktu': '2 hari lalu',
        'isi': 'Produksi telur harian naik 10% dibanding kemarin.',
        'tipe': 'info'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Notifikasi',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: notifikasiList.isEmpty
          ? Center(
              child: Text('Belum ada notifikasi.', style: GoogleFonts.poppins()),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifikasiList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifikasiList[index];
                final tipe = notif['tipe'] ?? 'info';

                // Warna & ikon berdasarkan tipe
                final warna = {
                  'bahaya': Colors.red.shade50,
                  'peringatan': Colors.yellow.shade50,
                  'info': Colors.green.shade50,
                }[tipe];

                final ikon = {
                  'bahaya': Icons.warning,
                  'peringatan': Icons.notifications_active,
                  'info': Icons.info_outline,
                }[tipe];

                return Container(
                  decoration: BoxDecoration(
                    color: warna,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(ikon, color: Colors.green[800], size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notif['judul'] ?? '',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif['isi'] ?? '',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notif['waktu'] ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
