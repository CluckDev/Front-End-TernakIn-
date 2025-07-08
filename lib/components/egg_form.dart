import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart'; // Tidak lagi dibutuhkan karena tanggal dihapus
import '../models/egg_model.dart'; // Import model Egg

class EggForm extends StatefulWidget {
  final Egg? initialData; // Data awal untuk mode edit
  final Function(Egg) onSave; // Callback saat data disimpan
  // final String Function(int) namaBulanHelper; // Tidak lagi dibutuhkan karena tanggal dihapus

  const EggForm({
    super.key,
    this.initialData,
    required this.onSave,
    // required this.namaBulanHelper, // Hapus dari konstruktor
  });

  @override
  State<EggForm> createState() => _EggFormState();
}

class _EggFormState extends State<EggForm> {
  final _formKey = GlobalKey<FormState>();
  late int _amount;
  late String _status;
  // late DateTime _selectedDate; // Hapus state ini

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      // Mode edit
      _amount = widget.initialData!.amount ?? 0;
      _status = widget.initialData!.status ?? 'in'; // Default 'in' jika null
      // _selectedDate = widget.initialData!.createdAt?.toLocal() ?? DateTime.now(); // Hapus inisialisasi ini
    } else {
      // Mode tambah
      _amount = 0;
      _status = 'in'; // Default status masuk
      // _selectedDate = DateTime.now(); // Hapus inisialisasi ini
    }
  }

  // Hapus metode _selectDate
  // Future<void> _selectDate(BuildContext context) async { ... }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            initialValue: _amount.toString(),
            decoration: InputDecoration(
              labelText: 'Jumlah Telur',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.numbers),
            ),
            keyboardType: TextInputType.number,
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
            onSaved: (value) {
              _amount = int.parse(value!);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.swap_horiz),
            ),
            style: GoogleFonts.poppins(color: Colors.black),
            items: const [
              DropdownMenuItem(value: 'in', child: Text('Masuk')),
              DropdownMenuItem(value: 'out', child: Text('Keluar')),
            ],
            onChanged: (value) {
              setState(() {
                _status = value!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pilih status';
              }
              return null;
            },
          ),
          // Hapus SizedBox(height: 16) dan GestureDetector/TextFormField untuk tanggal
          // const SizedBox(height: 16),
          // GestureDetector( ... ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final now = DateTime.now().toUtc(); // Ambil waktu saat ini dalam UTC
                  final newEgg = Egg(
                    id: widget.initialData?.id, // ID akan null untuk insert baru
                    userId: widget.initialData?.userId ?? '', // Akan diisi di ManajemenTelurScreen
                    amount: _amount,
                    status: _status,
                    createdAt: widget.initialData?.createdAt ?? now, // Gunakan createdAt yang sudah ada atau waktu sekarang
                    updatedAt: now, // Selalu perbarui updatedAt ke waktu sekarang
                  );
                  widget.onSave(newEgg);
                }
              },
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(
                widget.initialData != null ? 'Simpan Perubahan' : 'Tambah Data',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
