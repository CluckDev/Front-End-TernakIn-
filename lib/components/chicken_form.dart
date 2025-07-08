import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ternakin/services/auth_services.dart';
import 'package:ternakin/services/supabase_services.dart';
import '../models/chicken_model.dart';

class ChickenForm extends StatefulWidget {
  final Chicken? initialData;
  final Function(Chicken savedData) onSave;
  final String Function(int month) namaBulanHelper;

  const ChickenForm({
    super.key,
    this.initialData,
    required this.onSave,
    required this.namaBulanHelper,
  });

  @override
  State<ChickenForm> createState() => _ChickenFormState();
}

class _ChickenFormState extends State<ChickenForm> {
  final _jumlahController = TextEditingController();
  String? _masukKeluar;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _masukKeluar = 'in'; // Default
    if (widget.initialData != null) {
      _jumlahController.text = widget.initialData!.amount?.toString() ?? '';
      _masukKeluar = widget.initialData!.status;
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
      Chicken chicken;

      if (widget.initialData != null) {
        // Mode update: ID sudah ada di initialData
        chicken = widget.initialData!.copyWith(
          amount: amount,
          status: _masukKeluar,
          updatedAt: DateTime.now().toUtc(),
        );
        chicken = await supabaseService.updateChicken(chicken);
      } else {
        // Mode tambah: Jangan sertakan ID, biarkan Supabase mengisinya
        chicken = Chicken(
          userId: userId,
          amount: amount,
          status: _masukKeluar,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        );
        chicken = await supabaseService.addChicken(chicken);
      }
      widget.onSave(chicken);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
      debugPrint('ERROR: Gagal menyimpan data ayam: $e');
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
            decoration: const InputDecoration(
              labelText: 'Jumlah Ayam',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Jumlah tidak boleh kosong';
              }
              if (int.tryParse(value) == null) {
                return 'Masukkan angka yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _masukKeluar,
            items: ['in', 'out']
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value == 'in' ? 'Masuk' : 'Keluar'),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _masukKeluar = value;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
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
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          )
        ],
      ),
    );
  }
}
