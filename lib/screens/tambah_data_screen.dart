import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'manajemen_ayam.dart';
import 'manajemen_kesehatan.dart';
import 'manajemen_pakan.dart';
import 'manajemen_telur.dart';

class TambahDataScreen extends StatefulWidget {
  final String jenisData;

  const TambahDataScreen({super.key, required this.jenisData});

  @override
  State<TambahDataScreen> createState() => _TambahDataScreenState();
}

class _TambahDataScreenState extends State<TambahDataScreen> {
  final TextEditingController jumlahController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text('Tambah Data ${widget.jenisData}'),
        backgroundColor: Colors.green[700],
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.add_circle, size: 80, color: Colors.green[300]),
            Text(
              'Input Data ${widget.jenisData}',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Silakan masukkan jumlah dan ringkasan yang sesuai',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),

            // Input Jumlah
            _buildInputField(
              label: 'Jumlah',
              controller: jumlahController,
              keyboardType: TextInputType.number,
              icon: Icons.numbers,
            ),

            const SizedBox(height: 16),

            // Input Keterangan
            _buildInputField(
              label: 'Keterangan / Ringkasan',
              controller: keteranganController,
              icon: Icons.description,
            ),

            const SizedBox(height: 28),

            Center(
              child: ElevatedButton.icon(
                onPressed: _simpanData,
                icon: const Icon(Icons.save),
                label: Text('Simpan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  shadowColor: Colors.black45,
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: Colors.green[700]) : null,
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.green.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.green.shade700, width: 2),
          ),
        ),
      ),
    );
  }

  void _simpanData() {
    final int jumlah = int.tryParse(jumlahController.text) ?? 0;
    final String ringkasan = keteranganController.text;
    final String waktu =
        '${TimeOfDay.now().format(context)} - ${DateTime.now().day} ${_getMonthName(DateTime.now().month)}';

    if (jumlah <= 0 || ringkasan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      switch (widget.jenisData) {
        case 'Ayam':
          ayamList.add(Ayam(jumlah: jumlah, waktu: waktu, ringkasan: ringkasan));
          break;
        case 'Telur':
          telurList.add(RingkasanTelur(jumlah: jumlah, waktu: waktu, ringkasan: ringkasan));
          break;
        case 'Pakan':
          pakanList.add(RingkasanPakan(jumlah: jumlah, waktu: waktu, ringkasan: ringkasan));
          break;
        case 'Kesehatan':
          kesehatanList.add(KesehatanAyam(tanggal: waktu, kasus: ringkasan, jumlah: jumlah));
          break;
      }
    });

    Navigator.pop(context);
  }

  String _getMonthName(int month) {
    const List<String> months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month];
  }

  @override
  void dispose() {
    jumlahController.dispose();
    keteranganController.dispose();
    super.dispose();
  }
}
