import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'manajemen_ayam.dart';
import 'manajemen_telur.dart';

// LIST DATA GLOBAL
List<Map<String, dynamic>> ayamList = [];
List<Map<String, dynamic>> kesehatanList = [];
List<Map<String, dynamic>> pakanList = [];
List<Map<String, dynamic>> telurList = [];

class TambahDataScreen extends StatefulWidget {
  final String jenisData;
  final Map<String, dynamic>? initialData;
  final int? itemIndex;

  const TambahDataScreen({
    super.key,
    required this.jenisData,
    this.initialData,
    this.itemIndex,
  });

  @override
  State<TambahDataScreen> createState() => _TambahDataScreenState();
}

class _TambahDataScreenState extends State<TambahDataScreen> {
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();
  String? _masukKeluar;

  @override
  void initState() {
    super.initState();
    _masukKeluar = 'Masuk';

    if (widget.initialData != null) {
      _jumlahController.text = widget.initialData!['jumlah']?.toString() ?? '';

      if (widget.jenisData == 'Kesehatan') {
        _keteranganController.text = widget.initialData!['kasus'] ?? '';
      } else if (widget.jenisData == 'Pakan') {
        _keteranganController.text = widget.initialData!['ringkasan'] ?? '';
      } else {
        _masukKeluar = widget.initialData!['status'] ?? 'Masuk';
      }
    }
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  void _simpanData() {
    final jumlah = int.tryParse(_jumlahController.text.trim()) ?? 0;
    final keterangan = _keteranganController.text.trim();
    final now = DateTime.now();
    final waktu =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - ${now.day} ${_namaBulan(now.month)}';

    final jenis = widget.jenisData;
    Map<String, dynamic> dataToSave;

    if (jenis == 'Kesehatan') {
      dataToSave = {
        'jumlah': jumlah,
        'kasus': keterangan,
        'tanggal': waktu,
      };
    } else if (jenis == 'Pakan') {
      dataToSave = {
        'jumlah': jumlah,
        'ringkasan': keterangan,
        'waktu': waktu,
      };
    } else {
      dataToSave = {
        'jumlah': jumlah,
        'status': _masukKeluar,
        'waktu': waktu,
      };
    }

    if (widget.itemIndex != null) {
      if (jenis == 'Kesehatan') {
        kesehatanList[widget.itemIndex!] = dataToSave;
      } else if (jenis == 'Pakan') {
        pakanList[widget.itemIndex!] = dataToSave;
      } else if (jenis == 'Ayam') {
        ayamList[widget.itemIndex!] = dataToSave;
      } else if (jenis == 'Telur') {
        telurList[widget.itemIndex!] = dataToSave;
      }
    } else {
      if (jenis == 'Kesehatan') {
        kesehatanList.add(dataToSave);
      } else if (jenis == 'Pakan') {
        pakanList.add(dataToSave);
      } else if (jenis == 'Ayam') {
        ayamList.add(dataToSave);
      } else if (jenis == 'Telur') {
        telurList.add(dataToSave);
      }
    }

    Navigator.pop(context);
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
    final title = widget.initialData != null
        ? 'Edit Data $jenis'
        : 'Tambah Data $jenis';

    final labelJumlah = jenis == 'Kesehatan'
        ? 'Jumlah Ayam Sakit'
        : jenis == 'Pakan'
            ? 'Jumlah Pakan (kg)'
            : jenis == 'Telur'
                ? 'Jumlah Telur'
                : 'Jumlah Ayam';

    final labelKeterangan = jenis == 'Kesehatan'
        ? 'Jenis Penyakit / Keterangan'
        : jenis == 'Pakan'
            ? 'Keterangan / Ringkasan'
            : '';

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              jenis == 'Ayam'
                  ? Icons.add
                  : jenis == 'Telur'
                      ? Icons.egg
                      : jenis == 'Pakan'
                          ? Icons.rice_bowl
                          : Icons.health_and_safety,
              color: Colors.green[700],
              size: 64,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: labelJumlah,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (jenis == 'Ayam' || jenis == 'Telur')
              DropdownButtonFormField<String>(
                value: _masukKeluar,
                items: ['Masuk', 'Keluar']
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _masukKeluar = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Masuk / Keluar',
                  border: OutlineInputBorder(),
                ),
              ),
            if (jenis == 'Kesehatan' || jenis == 'Pakan')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextField(
                  controller: _keteranganController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: labelKeterangan,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              enabled: false,
              controller: TextEditingController(
                text:
                    '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} - ${DateTime.now().day} ${_namaBulan(DateTime.now().month)}',
              ),
              decoration: InputDecoration(
                labelText: 'Waktu Otomatis',
                filled: true,
                fillColor: Colors.grey[100],
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _simpanData,
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(
                widget.initialData != null ? 'Update Data' : 'Simpan Data',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}
