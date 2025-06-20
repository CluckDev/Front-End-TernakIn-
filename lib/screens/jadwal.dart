import 'package:flutter/material.dart';
import 'tambah_jadwal.dart';
import '../models/jadwal.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  List<Jadwal> daftarJadwal = [];
  DateTime? selectedFilterDate;

  void _navigateToTambahJadwal() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TambahJadwalScreen()),
    );

    if (hasil != null && hasil is Jadwal) {
      setState(() {
        daftarJadwal.add(hasil);
      });
    }
  }

  void _editJadwal(int index) async {
    final jadwalLama = daftarJadwal[index];
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TambahJadwalScreen(editJadwal: jadwalLama),
      ),
    );

    if (hasil != null && hasil is Jadwal) {
      setState(() {
        daftarJadwal[index] = hasil;
      });
    }
  }

  void _hapusJadwal(int index) {
    setState(() {
      daftarJadwal.removeAt(index);
    });
  }

  IconData _getAktivitasIcon(String aktivitas) {
    switch (aktivitas) {
      case 'Panen':
        return Icons.agriculture;
      case 'Vaksin':
        return Icons.healing;
      case 'Pemberian Pakan':
        return Icons.restaurant;
      default:
        return Icons.event_note;
    }
  }

  Color _getAktivitasColor(String aktivitas) {
    switch (aktivitas) {
      case 'Panen':
        return Colors.green.shade700;
      case 'Vaksin':
        return Colors.blue.shade700;
      case 'Pemberian Pakan':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

@override
  Widget build(BuildContext context) {
    final filteredJadwal = selectedFilterDate == null
        ? daftarJadwal
        : daftarJadwal
            .where((jadwal) => jadwal.tanggal.toLocal().toString().split(" ")[0] == selectedFilterDate!.toString().split(" ")[0])
            .toList();

    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceSecondary = onSurface.withValues(alpha: 0.7 * 255);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kegiatan'),
        backgroundColor: Colors.green[700],
        elevation: 2,
        actions: [
          // ...existing code...
        ],
      ),
      body: filteredJadwal.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, color: Colors.green[200], size: 80),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada jadwal ditambahkan.',
                    style: TextStyle(fontSize: 18, color: onSurfaceSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              itemCount: filteredJadwal.length,
              itemBuilder: (context, index) {
                final jadwal = filteredJadwal[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: Theme.of(context).colorScheme.surface,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: _getAktivitasColor(jadwal.aktivitas).withValues(alpha: (0.15 * 255)),
                      child: Icon(
                        _getAktivitasIcon(jadwal.aktivitas),
                        color: _getAktivitasColor(jadwal.aktivitas),
                        size: 28,
                      ),
                    ),
                    title: Text(
                      jadwal.aktivitas,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: onSurface,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: onSurfaceSecondary),
                            const SizedBox(width: 4),
                            Text(
                              jadwal.tanggal.toLocal().toString().split(" ")[0],
                              style: TextStyle(fontSize: 13, color: onSurfaceSecondary),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.access_time, size: 14, color: onSurfaceSecondary),
                            const SizedBox(width: 4),
                            Text(
                              jadwal.waktu,
                              style: TextStyle(fontSize: 13, color: onSurfaceSecondary),
                            ),
                          ],
                        ),
                        if (jadwal.catatan.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            jadwal.catatan,
                            style: TextStyle(fontSize: 13, color: onSurfaceSecondary),
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange[700]),
                          tooltip: 'Edit',
                          onPressed: () => _editJadwal(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[700]),
                          tooltip: 'Hapus',
                          onPressed: () => _hapusJadwal(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToTambahJadwal,
        backgroundColor: Colors.green,
        tooltip: 'Tambah Jadwal',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}