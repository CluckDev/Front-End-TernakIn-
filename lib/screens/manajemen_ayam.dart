import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ternakin/services/auth_services.dart'; // Untuk mendapatkan userId
import 'package:ternakin/services/supabase_services.dart'; // Untuk berinteraksi dengan Supabase
import '../components/chicken_form.dart'; // Import ChickenForm yang sudah terpisah
import '../models/chicken_model.dart'; // Import model Chicken

class ManajemenAyamScreen extends StatefulWidget {
  const ManajemenAyamScreen({super.key});

  @override
  State<ManajemenAyamScreen> createState() => _ManajemenAyamScreenState();
}

class _ManajemenAyamScreenState extends State<ManajemenAyamScreen> {
  String activePeriod = 'Harian';
  List<Chicken> _chickens = []; // List untuk menyimpan data ayam dari Supabase
  bool _isLoading = true; // State untuk indikator loading
  String? _errorMessage; // State untuk pesan error

  // Deklarasikan GlobalKey untuk Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchChickens(); // Muat data ayam saat inisialisasi
  }

  // Fungsi pembantu untuk mendapatkan nama bulan dalam Bahasa Indonesia
  String _namaBulan(int bulan) {
    const namaBulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return namaBulan[bulan];
  }

  Future<void> _fetchChickens() async {
    debugPrint('DEBUG: _fetchChickens() called. Setting _isLoading = true.');
    if (!mounted) return; // Pastikan mounted sebelum setState
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      if (!mounted) return; // Pastikan mounted sebelum setState
      setState(() {
        _errorMessage = 'Pengguna tidak login.';
        _isLoading = false; // Ini akan mematikan loading jika tidak ada user
      });
      debugPrint('DEBUG: _fetchChickens() - User not logged in. Setting _isLoading = false.');
      return;
    }
    try {
      final fetchedChickens = await supabaseService.getChickens(userId);
      if (!mounted) return; // Pastikan mounted sebelum setState
      setState(() {
        _chickens = fetchedChickens;
      });
      debugPrint('DEBUG: _fetchChickens() - Data fetched successfully.');
    } catch (e) {
      if (!mounted) return; // Pastikan mounted sebelum setState
      setState(() {
        _errorMessage = 'Gagal memuat data ayam: $e';
      });
      debugPrint('ERROR: _fetchChickens() - Gagal memuat data ayam: $e');
    } finally {
      if (mounted) { // Pastikan widget masih mounted sebelum memanggil setState
        setState(() {
          _isLoading = false; // Ini akan selalu mematikan loading
        });
        debugPrint('DEBUG: _fetchChickens() - Finally block executed. Setting _isLoading = false.');
      }
    }
  }

  // Fungsi untuk menghitung total ayam berdasarkan filter
  int _hitungTotalAyam() {
    int masuk = 0;
    int keluar = 0;
    DateTime now = DateTime.now();

    final filteredChickens = _chickens.where((chicken) {
      if (chicken.createdAt == null) return false; // Abaikan jika createdAt null

      DateTime waktuChicken = chicken.createdAt!.toLocal(); // Pastikan waktu lokal

      if (activePeriod == 'Harian') {
        return waktuChicken.year == now.year &&
            waktuChicken.month == now.month &&
            waktuChicken.day == now.day;
      } else if (activePeriod == 'Mingguan') {
        DateTime awalMinggu = now.subtract(Duration(days: now.weekday - 1));
        DateTime akhirMinggu = awalMinggu.add(const Duration(days: 6));
        return waktuChicken.isAfter(awalMinggu.subtract(const Duration(seconds: 1))) &&
            waktuChicken.isBefore(akhirMinggu.add(const Duration(days: 1)));
      } else if (activePeriod == 'Bulanan') {
        return waktuChicken.year == now.year && waktuChicken.month == now.month;
      }
      return true; // Tampilkan semua jika tidak ada filter periode yang cocok
    }).toList();

    for (var chicken in filteredChickens) {
      if (chicken.status == 'in') { // Sesuaikan dengan nilai 'in'/'out' di database
        masuk += chicken.amount ?? 0;
      } else if (chicken.status == 'out') {
        keluar += chicken.amount ?? 0;
      }
    }
    return masuk - keluar;
  }

  // Metode baru untuk menangani logika penghapusan dari parent
  Future<void> _handleDeleteChicken(int id) async {
    debugPrint('DEBUG: _handleDeleteChicken() called for ID: $id');
    if (!mounted) return; // Pastikan mounted sebelum setState
    setState(() {
      _isLoading = true; // Tampilkan loading untuk seluruh layar
      _errorMessage = null; // Reset error message
    });
    try {
      await supabaseService.deleteChicken(id);
      await _fetchChickens(); // Muat ulang data, ini akan mengatur _isLoading=false
      // Gunakan _scaffoldKey.currentContext untuk menampilkan SnackBar
      if (_scaffoldKey.currentContext != null && mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('Data berhasil dihapus!')),
        );
      }
    } catch (e) {
      debugPrint('ERROR: Gagal menghapus data di _handleDeleteChicken: $e');
      // Gunakan _scaffoldKey.currentContext untuk menampilkan SnackBar
      if (_scaffoldKey.currentContext != null && mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data: $e')),
        );
      }
    } finally {
      // _fetchChickens() sudah memiliki finally block yang mengatur _isLoading = false
      // Jadi, tidak perlu lagi mengatur _isLoading = false di sini secara eksplisit
      // jika _fetchChickens() selalu dipanggil.
    }
  }


  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan activePeriod
    final filteredList = _chickens.where((chicken) {
      if (chicken.createdAt == null) return false; // Abaikan jika createdAt null

      DateTime now = DateTime.now();
      DateTime waktuChicken = chicken.createdAt!.toLocal(); // Pastikan waktu lokal

      if (activePeriod == 'Harian') {
        return waktuChicken.year == now.year &&
            waktuChicken.month == now.month &&
            waktuChicken.day == now.day;
      } else if (activePeriod == 'Mingguan') {
        DateTime awalMinggu = now.subtract(Duration(days: now.weekday - 1));
        DateTime akhirMinggu = awalMinggu.add(const Duration(days: 6));
        return waktuChicken.isAfter(awalMinggu.subtract(const Duration(seconds: 1))) &&
            waktuChicken.isBefore(akhirMinggu.add(const Duration(days: 1)));
      } else if (activePeriod == 'Bulanan') {
        return waktuChicken.year == now.year && waktuChicken.month == now.month;
      }
      return true; // Tampilkan semua jika tidak ada filter periode yang cocok
    }).toList();

    return Scaffold(
      key: _scaffoldKey, // Pasang GlobalKey ke Scaffold
      appBar: AppBar(
        title: const Text('Manajemen Ayam'),
        backgroundColor: Colors.green,
        titleTextStyle: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Ayam (card mini)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFd0f0c0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pets, size: 28, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Ayam',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey[700])),
                    Text('${_hitungTotalAyam()}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.green[800],
                        )),
                  ],
                ),
              ],
            ),
          ),

          // Filter Harian/Mingguan/Bulanan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTab('Harian'),
                _buildTab('Mingguan'),
                _buildTab('Bulanan'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // List data ayam dengan tombol edit & hapus
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : filteredList.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada data ayam untuk periode ini.',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final chicken = filteredList[index];
                              return _ChickenListItem(
                                chicken: chicken,
                                onEdit: () async {
                                  // Tampilkan ChickenForm dalam dialog untuk edit
                                  final editedChicken = await showDialog<Chicken>(
                                    context: _scaffoldKey.currentContext!, // Gunakan context dari GlobalKey
                                    builder: (context) => AlertDialog(
                                      title: Text('Edit Data Ayam', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                      content: SingleChildScrollView( // Tambahkan SingleChildScrollView
                                        child: ChickenForm(
                                          initialData: chicken, // Teruskan data ayam yang akan diedit
                                          onSave: (savedData) {
                                            Navigator.pop(context, savedData); // Tutup dialog dan kirim data kembali
                                          },
                                          namaBulanHelper: _namaBulan, // Teruskan helper function
                                        ),
                                      ),
                                    ),
                                  );
                                  if (editedChicken != null) {
                                    _fetchChickens(); // Muat ulang data setelah edit
                                  }
                                },
                                // Meneruskan callback untuk penghapusan
                                onDeleteConfirmed: (id) async {
                                  await _handleDeleteChicken(id); // Panggil metode penanganan hapus di parent
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () async {
          // Tampilkan ChickenForm dalam dialog untuk tambah data
          final newChicken = await showDialog<Chicken>(
            context: _scaffoldKey.currentContext!, // Gunakan context dari GlobalKey
            builder: (context) => AlertDialog(
              title: Text('Tambah Data Ayam', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView( // Tambahkan SingleChildScrollView
                child: ChickenForm(
                  onSave: (savedData) {
                    Navigator.pop(context, savedData); // Tutup dialog dan kirim data kembali
                  },
                  namaBulanHelper: _namaBulan, // Teruskan helper function
                ),
              ),
            ),
          );

          if (newChicken != null) {
            _fetchChickens(); // Muat ulang data setelah tambah
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTab(String label) {
    final bool isActive = activePeriod == label;
    return ElevatedButton(
      onPressed: () => setState(() => activePeriod = label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.green[700] : Colors.green[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label, style: GoogleFonts.poppins(color: Colors.white)),
    );
  }
}

// Widget item list ayam dengan tombol edit dan hapus
class _ChickenListItem extends StatelessWidget {
  final Chicken chicken; // Menerima objek Chicken
  final VoidCallback? onEdit;
  // Mengubah callback hapus menjadi satu fungsi yang menerima ID
  final Future<void> Function(int id) onDeleteConfirmed;

  const _ChickenListItem({
    super.key,
    required this.chicken,
    this.onEdit,
    required this.onDeleteConfirmed, // Jadikan required
  });

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
    final String waktuFormatted = chicken.createdAt != null
        ? '${chicken.createdAt!.toLocal().hour.toString().padLeft(2, '0')}:${chicken.createdAt!.toLocal().minute.toString().padLeft(2, '0')} - ${chicken.createdAt!.toLocal().day} ${_namaBulan(chicken.createdAt!.toLocal().month)}'
        : 'N/A';

    final String statusText = chicken.status == 'in' ? 'Masuk' : 'Keluar';
    final String ringkasan = '$statusText ${chicken.amount ?? 0}'; // Menggunakan null-aware operator

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Icon + Label + Waktu
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ayam', // Label tetap 'Ayam'
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    waktuFormatted,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            // Jumlah + Status (ringkasan)
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  ringkasan,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
            ),

            // Tombol edit
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Edit Data',
            ),

            // Tombol hapus
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Menggunakan context dari _ChickenListItem untuk showDialog
                // Ini aman karena dialog akan menutup sebelum _ChickenListItem mungkin di-dispose
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Konfirmasi Hapus'),
                    content: const Text('Yakin ingin menghapus data ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext); // Tutup dialog
                          // Panggil callback yang disediakan oleh parent
                          // Parent akan menangani loading, delete, fetch, dan SnackBar
                          await onDeleteConfirmed(chicken.id!);
                        },
                        child: const Text(
                          'Hapus',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Hapus Data',
            ),
          ],
        ),
      ),
    );
  }
}
