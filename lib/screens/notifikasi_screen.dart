import 'package:flutter/material.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  IconData _getIcon(String? judul) {
    if (judul == null) return Icons.notifications;
    if (judul.toLowerCase().contains('pakan')) return Icons.rice_bowl;
    if (judul.toLowerCase().contains('sakit')) return Icons.warning_amber_rounded;
    if (judul.toLowerCase().contains('telur')) return Icons.egg;
    return Icons.notifications;
  }

  Color _getIconColor(String? judul) {
    if (judul == null) return Colors.green;
    if (judul.toLowerCase().contains('pakan')) return Colors.orange;
    if (judul.toLowerCase().contains('sakit')) return Colors.red;
    if (judul.toLowerCase().contains('telur')) return Colors.blue;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifikasiList = [
      {
        'judul': 'Stok pakan menipis',
        'isi': 'Segera tambahkan pakan, stok tersisa 5 kg.',
        'waktu': 'Hari ini, 08:00'
      },
      {
        'judul': 'Ayam sakit terdeteksi',
        'isi': '2 ayam terdeteksi sakit pada kandang A.',
        'waktu': 'Kemarin, 17:30'
      },
      {
        'judul': 'Data telur berhasil ditambahkan',
        'isi': 'Data produksi telur hari ini sudah masuk.',
        'waktu': 'Kemarin, 09:15'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Colors.green[700],
      ),
      body: notifikasiList.isEmpty
          ? const Center(
              child: Text(
                'Belum ada notifikasi.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifikasiList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notif = notifikasiList[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                   leading: CircleAvatar(
                      backgroundColor: _getIconColor(notif['judul']).withValues(alpha: 0.15 * 255),
                      child: Icon(
                        _getIcon(notif['judul']),
                        color: _getIconColor(notif['judul']),
                      ),
                    ),
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
                  ),
                );
              },
            ),
    );
  }
}