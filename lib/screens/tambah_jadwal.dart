import 'package:flutter/material.dart';
import '../models/jadwal.dart';

class TambahJadwalScreen extends StatefulWidget {
  final Jadwal? editJadwal;

  const TambahJadwalScreen({super.key, this.editJadwal});

  @override
  State<TambahJadwalScreen> createState() => _TambahJadwalScreenState();
}

class _TambahJadwalScreenState extends State<TambahJadwalScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String selectedAktivitas = 'Panen';
  final TextEditingController catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.editJadwal != null) {
      final jadwal = widget.editJadwal!;
      selectedDate = jadwal.tanggal;

      final waktuParts = jadwal.waktu.split(':');
      selectedTime = TimeOfDay(
        hour: int.tryParse(waktuParts[0]) ?? 0,
        minute: int.tryParse(waktuParts[1]) ?? 0,
      );

      selectedAktivitas = jadwal.aktivitas;
      catatanController.text = jadwal.catatan;
    }
  }

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (!mounted) return;

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.now(),
      );

      if (!mounted) return;

      if (time != null) {
        setState(() {
          selectedDate = date;
          selectedTime = time;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
       appBar: AppBar(
        title: const Text(
          'Jadwal Kegiatan',
          style: TextStyle(
            color: Colors.white, // Ubah warna teks jadi putih
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 2,
        actions: [ // ...
          ],
                  leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      selectedDate != null && selectedTime != null
                          ? '${selectedDate!.toLocal().toString().split(" ")[0]} - ${selectedTime!.format(context)}'
                          : 'Pilih Tanggal & Waktu',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  value: selectedAktivitas,
                  decoration: InputDecoration(
                    labelText: 'Aktivitas',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? Colors.green[900]?.withValues(alpha: 0.08 * 255)
                        : Colors.green[50],
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Panen',
                      child: Row(
                        children: [
                          Icon(Icons.agriculture, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Panen'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Vaksin',
                      child: Row(
                        children: [
                          Icon(Icons.healing, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Vaksin'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Pemberian Pakan',
                      child: Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Pemberian Pakan'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedAktivitas = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: catatanController,
                  decoration: InputDecoration(
                    labelText: 'Catatan Tambahan',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? Colors.green[900]?.withValues(alpha: 0.08 * 255)
                        : Colors.green[50],
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(widget.editJadwal != null ? Icons.save : Icons.add, color: Colors.white),
                    label: Text(
                      widget.editJadwal != null ? 'Simpan Perubahan' : 'Tambah Jadwal',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (selectedDate == null || selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Harap pilih tanggal dan waktu terlebih dahulu')),
                        );
                        return;
                      }

                      final newJadwal = Jadwal(
                        tanggal: selectedDate!,
                        waktu: selectedTime!.format(context),
                        aktivitas: selectedAktivitas,
                        catatan: catatanController.text,
                      );

                      Navigator.pop(context, newJadwal);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}