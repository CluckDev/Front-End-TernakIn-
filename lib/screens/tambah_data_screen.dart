import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TambahDataScreen extends StatelessWidget {
  const TambahDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Data'),
        backgroundColor: Colors.green[700],
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form Data Baru',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Tanggal',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? Colors.green[900]?.withValues(alpha: 0.08 * 255)
                        : Colors.green[50],
                  ),
                  readOnly: true,
                  onTap: () {
                    // TODO: Tampilkan date picker
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? Colors.green[900]?.withValues(alpha: 0.08 * 255)
                        : Colors.green[50],
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Keterangan',
                    prefixIcon: const Icon(Icons.notes),
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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text('Simpan', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: GoogleFonts.poppins(fontSize: 16),
                      elevation: 2,
                    ),
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