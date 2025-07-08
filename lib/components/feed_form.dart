import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ternakin/services/auth_services.dart';
import 'package:ternakin/services/supabase_services.dart';
import '../models/feed_model.dart'; // Pastikan ini mengarah ke models/feed.dart

class FeedForm extends StatefulWidget {
  final Feed? initialData;
  final Function(Feed savedData) onSave;
  final String Function(int month) namaBulanHelper;

  const FeedForm({
    super.key,
    this.initialData,
    required this.onSave,
    required this.namaBulanHelper,
  });

  @override
  State<FeedForm> createState() => _FeedFormState();
}

class _FeedFormState extends State<FeedForm> {
  final _jumlahController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _status; // Menggunakan _status untuk dropdown

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _jumlahController.text = widget.initialData!.amount?.toString() ?? '';
      _status = widget.initialData!.status ?? 'in'; // Inisialisasi status dari data awal
    } else {
      _status = 'in'; // Default status 'in' untuk data baru
    }
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }

  void _simpanData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = authService.currentUser?.uid;
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk menyimpan data.')),
      );
      return;
    }

    try {
      final amount = int.tryParse(_jumlahController.text.trim()) ?? 0;
      Feed feed;

      if (widget.initialData != null) {
        feed = widget.initialData!.copyWith(
          amount: amount,
          status: _status, // Menggunakan _status dari dropdown
          updatedAt: DateTime.now().toUtc(),
        );
        feed = await supabaseService.updateFeed(feed);
      } else {
        feed = Feed(
          userId: userId,
          amount: amount,
          status: _status, // Menggunakan _status dari dropdown
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
          total: null, // Total mungkin dihitung di backend saat insert
        );
        feed = await supabaseService.addFeed(feed);
      }
      widget.onSave(feed);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
      debugPrint('ERROR: Gagal menyimpan data pakan: $e');
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
            controller: _jumlahController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration( // Menggunakan InputDecoration untuk styling
              labelText: 'Jumlah Pakan (kg)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
              prefixIcon: const Icon(Icons.numbers), // Icon
            ),
            style: GoogleFonts.poppins(), // Menggunakan GoogleFonts
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jumlah tidak boleh kosong';
              }
              if (int.tryParse(value) == null) {
                return 'Masukkan angka yang valid';
              }
              if (int.parse(value) <= 0) { // Tambahkan validasi jumlah > 0
                return 'Jumlah harus lebih dari 0';
              }
              return null;
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
            style: GoogleFonts.poppins(color: Colors.black), // Teks hitam untuk kontras
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
            ),
            style: GoogleFonts.poppins(), // Menggunakan GoogleFonts
          ),
          const SizedBox(height: 24),
          SizedBox( // Bungkus ElevatedButton dengan SizedBox untuk lebar penuh
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _simpanData,
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(
                widget.initialData != null ? 'Simpan Perubahan' : 'Tambah Data', // Ubah label
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: const EdgeInsets.symmetric(vertical: 16), // Padding vertikal lebih besar
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
                elevation: 2, // Tambahkan sedikit elevasi
              ),
            ),
          )
        ],
      ),
    );
  }
}
