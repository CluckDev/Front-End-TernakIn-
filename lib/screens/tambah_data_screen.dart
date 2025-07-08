import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manajemen_ayam.dart'; // import model Ayam supaya bisa dipakai

class TambahDataScreen extends StatefulWidget {
  final String jenisData;
  final Ayam? initialAyam; // data awal jika edit

  const TambahDataScreen({
    super.key,
    required this.jenisData,
    this.initialAyam,
  });

  @override
  State<TambahDataScreen> createState() => _TambahDataScreenState();
}

class _TambahDataScreenState extends State<TambahDataScreen> {
  late TextEditingController _jumlahController;
  late String _status; // Masuk / Keluar

  @override
  void initState() {
    super.initState();

    _jumlahController = TextEditingController(
      text: widget.initialAyam?.jumlah.toString() ?? '',
    );
    _status = widget.initialAyam?.status ?? 'Masuk';
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }

  void _simpanData() {
    final jumlah = int.tryParse(_jumlahController.text.trim()) ?? 0;
    final now = DateTime.now();
    final waktu = '${now.day} ${_namaBulan(now.month)} ${now.year}';

    final newAyam = Ayam(
      jumlah: jumlah,
      status: _status,
      waktu: waktu,
    );

    Navigator.pop(context, newAyam);
  }

  String _namaBulan(int bulan) {
    const namaBulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return namaBulan[bulan];
  }

  @override
  Widget build(BuildContext context) {
    final jenis = widget.jenisData;
    final title =
        widget.initialAyam != null ? 'Edit Data $jenis' : 'Tambah Data $jenis';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green[700],
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: Colors.green[700],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Ayam',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              items: ['Masuk', 'Keluar']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _simpanData,
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(
                widget.initialAyam != null ? 'Update Data' : 'Simpan Data',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
