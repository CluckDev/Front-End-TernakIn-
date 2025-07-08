import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/schedule_model.dart'; // Import model Schedule

class ScheduleForm extends StatefulWidget {
  final Schedule? initialData; // Data awal untuk mode edit
  final Function(Schedule) onSave; // Callback saat data disimpan

  const ScheduleForm({
    super.key,
    this.initialData,
    required this.onSave,
  });

  @override
  State<ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late String _description;
  late DateTime _selectedDateTime; // Menyimpan tanggal dan waktu yang dipilih

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      // Mode edit
      _type = widget.initialData!.type ?? 'Panen';
      _description = widget.initialData!.description ?? '';
      _selectedDateTime = widget.initialData!.createdAt?.toLocal() ?? DateTime.now();
    } else {
      // Mode tambah
      _type = 'Panen'; // Default type
      _description = '';
      _selectedDateTime = DateTime.now(); // Default waktu sekarang
    }
  }

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (!mounted) return;

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime), // Gunakan waktu yang sudah ada
      );

      if (!mounted) return;

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  // Fungsi pembantu untuk mendapatkan nama bulan dalam Bahasa Indonesia
  String _namaBulan(int bulan) {
    const namaBulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return namaBulan[bulan];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              onPressed: _pickDateTime,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                '${_selectedDateTime.toLocal().day} ${_namaBulan(_selectedDateTime.toLocal().month)} ${_selectedDateTime.toLocal().year} - ${_selectedDateTime.toLocal().hour.toString().padLeft(2, '0')}:${_selectedDateTime.toLocal().minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: InputDecoration(
              labelText: 'Tipe Aktivitas',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? Colors.green[900]?.withOpacity(0.08)
                  : Colors.green[50],
            ),
            style: GoogleFonts.poppins(color: Colors.black), // Teks hitam untuk kontras
            items: const [
              DropdownMenuItem(value: 'Panen', child: Row(children: [Icon(Icons.agriculture, color: Colors.green), SizedBox(width: 8), Text('Panen')])),
              DropdownMenuItem(value: 'Vaksin', child: Row(children: [Icon(Icons.healing, color: Colors.blue), SizedBox(width: 8), Text('Vaksin')])),
              DropdownMenuItem(value: 'Pemberian Pakan', child: Row(children: [Icon(Icons.restaurant, color: Colors.orange), SizedBox(width: 8), Text('Pemberian Pakan')])),
              DropdownMenuItem(value: 'Lainnya', child: Row(children: [Icon(Icons.event_note, color: Colors.grey), SizedBox(width: 8), Text('Lainnya')])),
            ],
            onChanged: (value) {
              setState(() {
                _type = value!;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pilih tipe aktivitas';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: _description,
            decoration: InputDecoration(
              labelText: 'Deskripsi',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.description),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? Colors.green[900]?.withOpacity(0.08)
                  : Colors.green[50],
            ),
            style: GoogleFonts.poppins(),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Deskripsi tidak boleh kosong';
              }
              return null;
            },
            onSaved: (value) {
              _description = value!;
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final now = DateTime.now().toUtc(); // Waktu saat ini dalam UTC

                  final newSchedule = Schedule(
                    id: widget.initialData?.id, // ID akan null untuk insert baru
                    userId: widget.initialData?.userId ?? '', // Akan diisi di ManajemenJadwalScreen
                    type: _type,
                    description: _description,
                    createdAt: _selectedDateTime.toUtc(), // Gunakan waktu terpilih sebagai createdAt
                    updatedAt: now, // Selalu perbarui updatedAt ke waktu sekarang
                  );
                  widget.onSave(newSchedule);
                }
              },
              icon: Icon(widget.initialData != null ? Icons.save : Icons.add, color: Colors.white),
              label: Text(
                widget.initialData != null ? 'Simpan Perubahan' : 'Tambah Jadwal',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
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
