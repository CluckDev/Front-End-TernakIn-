import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// LIST DATA GLOBAL
// Ini adalah daftar global untuk menyimpan data yang ditambahkan.
List<Map<String, dynamic>> ayamList = [];
List<Map<String, dynamic>> kesehatanList = [];
List<Map<String, dynamic>> pakanList = [];
List<Map<String, dynamic>> telurList = [];

class FormKesehatan extends StatefulWidget {
  final String jenisData; // Properti untuk menentukan jenis data (Ayam, Telur, Pakan, Kesehatan)
  final Map<String, dynamic>? initialData; // Data awal jika dalam mode update
  final int? itemIndex; // Indeks item yang akan diupdate dalam list global

  const FormKesehatan({
    super.key,
    required this.jenisData,
    this.initialData, // Opsional, untuk mode update
    this.itemIndex,   // Opsional, untuk mode update
  });

  @override
  State<FormKesehatan> createState() => _FormKesehatanState();
}

class _FormKesehatanState extends State<FormKesehatan> {
  // Controller untuk input jumlah
  final _jumlahController = TextEditingController();
  // Controller untuk input keterangan/ringkasan/jenis penyakit
  final _keteranganController = TextEditingController();
  // Variabel untuk menyimpan pilihan 'Masuk' atau 'Keluar'
  String? _masukKeluar;

  @override
  void initState() {
    super.initState();
    // Inisialisasi nilai default untuk dropdown 'Masuk/Keluar'
    _masukKeluar = 'Masuk';

    // Jika initialData disediakan, isi controller dan dropdown dengan data tersebut (mode update)
    if (widget.initialData != null) {
      _jumlahController.text = widget.initialData!['jumlah']?.toString() ?? '';

      // Logika pengisian berdasarkan jenis data
      if (widget.jenisData == 'Kesehatan') {
        _keteranganController.text = widget.initialData!['kasus'] ?? '';
      } else if (widget.jenisData == 'Pakan') {
        _keteranganController.text = widget.initialData!['ringkasan'] ?? '';
      } else { // Ayam atau Telur
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

  // Fungsi untuk menyimpan atau memperbarui data
  void _simpanData() {
    // Mengambil nilai jumlah dari input, jika tidak valid akan menjadi 0
    final jumlah = int.tryParse(_jumlahController.text.trim()) ?? 0;
    // Mengambil nilai keterangan dari input
    final keterangan = _keteranganController.text.trim();
    // Mendapatkan waktu saat ini
    final now = DateTime.now();
    // Memformat waktu menjadi string yang mudah dibaca
    final waktu = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - ${now.day} ${_namaBulan(now.month)}';

    final jenis = widget.jenisData; // Mengambil jenis data dari widget

    // Objek data baru atau yang diperbarui
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
    } else { // Ayam atau Telur
      dataToSave = {
        'jumlah': jumlah,
        'status': _masukKeluar,
        'waktu': waktu,
      };
    }

    // Logika penyimpanan atau pembaruan data berdasarkan apakah itemIndex ada
    if (widget.itemIndex != null) {
      // Mode update: Perbarui data yang ada di list global
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
      // Mode tambah: Tambahkan data baru ke list global
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

    // Kembali ke layar sebelumnya setelah data disimpan/diperbarui
    Navigator.pop(context);
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
    final jenis = widget.jenisData; // Mengambil jenis data
    // Menentukan judul AppBar secara dinamis berdasarkan jenis data dan mode (tambah/update)
    final title = widget.initialData != null ? 'Edit Data $jenis' : 'Tambah Data $jenis';

    // Menentukan label untuk input jumlah secara dinamis
    final labelJumlah = jenis == 'Kesehatan'
        ? 'Jumlah Ayam Sakit'
        : jenis == 'Pakan'
            ? 'Jumlah Pakan (kg)'
            : jenis == 'Telur'
                ? 'Jumlah Telur'
                : 'Jumlah Ayam'; // Default untuk Ayam

    // Menentukan label untuk input keterangan secara dinamis
    final labelKeterangan = jenis == 'Kesehatan'
        ? 'Jenis Penyakit / Keterangan'
        : jenis == 'Pakan'
            ? 'Keterangan / Ringkasan'
            : ''; // Kosong jika tidak diperlukan (Ayam/Telur)

    return Scaffold(
      appBar: AppBar(
        title: Text(title), // Judul AppBar yang dinamis
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
            // Icon yang berubah berdasarkan jenis data
            Icon(
              jenis == 'Ayam'
                  ? Icons.add // Icon untuk Ayam
                  : jenis == 'Telur'
                      ? Icons.egg // Icon untuk Telur
                      : jenis == 'Pakan'
                          ? Icons.rice_bowl // Icon untuk Pakan
                          : Icons.health_and_safety, // Icon untuk Kesehatan
              color: Colors.green[700],
              size: 64,
            ),
            const SizedBox(height: 20),
            // Input field untuk jumlah
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number, // Hanya mengizinkan input angka
              decoration: InputDecoration(
                labelText: labelJumlah, // Label dinamis
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Dropdown 'Masuk / Keluar' hanya untuk 'Ayam' dan 'Telur'
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
                    _masukKeluar = value; // Memperbarui nilai saat pilihan berubah
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Masuk / Keluar',
                  border: OutlineInputBorder(),
                ),
              ),
            // Input field 'Keterangan' hanya untuk 'Kesehatan' dan 'Pakan'
            if (jenis == 'Kesehatan' || jenis == 'Pakan')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: TextField(
                  controller: _keteranganController,
                  maxLines: 3, // Mengizinkan input multi-baris
                  decoration: InputDecoration(
                    labelText: labelKeterangan, // Label dinamis
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Input field untuk waktu otomatis (tidak bisa diedit)
            TextField(
              enabled: false, // Tidak bisa diedit
              controller: TextEditingController(
                text: // Menampilkan waktu saat ini secara otomatis
                    '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} - ${DateTime.now().day} ${_namaBulan(DateTime.now().month)}',
              ),
              decoration: InputDecoration(
                labelText: 'Waktu Otomatis',
                filled: true,
                fillColor: Colors.grey[100], // Warna latar belakang abu-abu muda
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            // Tombol 'Simpan Data'
            ElevatedButton.icon(
              onPressed: _simpanData, // Memanggil fungsi _simpanData saat ditekan
              icon: const Icon(Icons.save, color: Colors.white),
              label: Text(
                widget.initialData != null ? 'Update Data' : 'Simpan Data', // Label tombol dinamis
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