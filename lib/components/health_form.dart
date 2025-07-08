import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sick_model.dart'; // Import model Sick

class HealthForm extends StatefulWidget {
  final Sick? initialData; // Data awal untuk mode edit
  final Function(Sick savedData) onSave; // Callback saat data disimpan
  final String Function(int month) namaBulanHelper; // Helper untuk nama bulan

  const HealthForm({
    super.key,
    this.initialData,
    required this.onSave,
    required this.namaBulanHelper,
  });

  @override
  State<HealthForm> createState() => _HealthFormState();
}

class _HealthFormState extends State<HealthForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController(); // Untuk jenis penyakit / keterangan

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _amountController.text = widget.initialData!.amount?.toString() ?? '';
      _descriptionController.text = widget.initialData!.description ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _simpanData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final amount = int.tryParse(_amountController.text.trim()) ?? 0;
      final description = _descriptionController.text.trim();
      Sick sick;

      if (widget.initialData != null) {
        // Mode edit
        sick = widget.initialData!.copyWith(
          amount: amount,
          description: description,
          updatedAt: DateTime.now().toUtc(),
        );
        // SupabaseService.updateSick akan dipanggil di parent
      } else {
        // Mode tambah
        sick = Sick(
          userId: '', // userId akan diisi di ManajemenKesehatanScreen
          amount: amount,
          description: description,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
          total: null, // Total mungkin dihitung di backend atau di layar utama
        );
        // SupabaseService.addSick akan dipanggil di parent
      }
      widget.onSave(sick); // Kirim data kembali ke parent
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
      debugPrint('ERROR: Gagal menyimpan data kesehatan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah Ayam Sakit',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.numbers),
            ),
            style: GoogleFonts.poppins(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jumlah tidak boleh kosong';
              }
              if (int.tryParse(value) == null) {
                return 'Masukkan angka yang valid';
              }
              if (int.parse(value) <= 0) {
                return 'Jumlah harus lebih dari 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Jenis Penyakit / Keterangan',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.description),
            ),
            style: GoogleFonts.poppins(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Keterangan tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            enabled: false,
            controller: TextEditingController(
              text:
                  '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} - ${DateTime.now().day} ${widget.namaBulanHelper(DateTime.now().month)}',
            ),
            decoration: InputDecoration(
              labelText: 'Waktu Otomatis',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            style: GoogleFonts.poppins(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _simpanData,
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(
                widget.initialData != null ? 'Simpan Perubahan' : 'Tambah Data',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          )
        ],
      ),
    );
  }
}
