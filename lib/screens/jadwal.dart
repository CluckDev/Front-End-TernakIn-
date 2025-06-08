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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kegiatan'),
        backgroundColor: Colors.green[700],
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2023),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                setState(() {
                  selectedFilterDate = date;
                });
              }
            },
          ),
          if (selectedFilterDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  selectedFilterDate = null;
                });
              },
            ),
        ],
      ),
      body: filteredJadwal.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, color: Colors.green[200], size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada jadwal ditambahkan.',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
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
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: _getAktivitasColor(jadwal.aktivitas).withValues(alpha: 0.15 * 255),
                      child: Icon(
                        _getAktivitasIcon(jadwal.aktivitas),
                        color: _getAktivitasColor(jadwal.aktivitas),
                        size: 28,
                      ),
                    ),
                    title: Text(
                      jadwal.aktivitas,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              jadwal.tanggal.toLocal().toString().split(" ")[0],
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              jadwal.waktu,
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                        if (jadwal.catatan.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            jadwal.catatan,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          tooltip: 'Edit',
                          onPressed: () => _editJadwal(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
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