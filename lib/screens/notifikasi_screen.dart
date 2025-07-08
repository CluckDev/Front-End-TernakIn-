import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Contoh data notifikasi dummy
    final List<Map<String, String>> notifikasiList = [
      {
        'judul': 'Ayam sakit terdeteksi',
        'waktu': 'Hari ini, 08:00',
        'isi': 'Ada 2 ayam yang terdeteksi sakit di kandang A.'
      },
      {
        'judul': 'Stok pakan menipis',
        'waktu': 'Kemarin, 17:30',
        'isi': 'Stok pakan tinggal 5kg. Segera lakukan pengisian ulang.'
      },
      {
        'judul': 'Produksi telur meningkat',
        'waktu': '2 hari lalu',
        'isi': 'Produksi telur harian naik 10% dibanding kemarin.'
      },
    ];

    return Scaffold(
            appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Notifikasi',
          style: GoogleFonts.poppins(
            color: Colors.white, // ⬅️ Warna teks putih
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: notifikasiList.isEmpty
          ? const Center(child: Text('Belum ada notifikasi.'))
          : ListView.separated(
              itemCount: notifikasiList.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (context, index) {
                final notif = notifikasiList[index];
                return ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.brown),
                  title: Text(
                    notif['judul'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notif['isi'] ?? ''),
                      const SizedBox(height: 4),
                      Text(
                        notif['waktu'] ?? '',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}