import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ternakin/services/auth_services.dart'; // Untuk mendapatkan userId
import 'package:ternakin/services/supabase_services.dart'; // Untuk berinteraksi dengan Supabase
import '../components/health_form.dart'; // Import HealthForm
import '../models/sick_model.dart'; // Import model Sick

class ManajemenKesehatanScreen extends StatefulWidget {
  const ManajemenKesehatanScreen({super.key});

  @override
  State<ManajemenKesehatanScreen> createState() => _ManajemenKesehatanScreenState();
}

class _ManajemenKesehatanScreenState extends State<ManajemenKesehatanScreen> {
  String activePeriod = 'Harian';
  List<Sick> _sicks = []; // List untuk menyimpan data sakit dari Supabase
  bool _isLoading = true; // State untuk indikator loading
  String? _errorMessage; // State untuk pesan error

  // Deklarasikan GlobalKey untuk Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchSicks(); // Muat data sakit saat inisialisasi
  }

  // Fungsi pembantu untuk mendapatkan nama bulan dalam Bahasa Indonesia
  String _namaBulan(int bulan) {
    const namaBulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return namaBulan[bulan];
  }

  Future<void> _fetchSicks() async {
    debugPrint('DEBUG: _fetchSicks() called. Setting _isLoading = true.');
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
      debugPrint('DEBUG: _fetchSicks() - User not logged in. Setting _isLoading = false.');
      return;
    }
    try {
      final fetchedSicks = await supabaseService.getSicks(userId);
      if (!mounted) return; // Pastikan mounted sebelum setState
      setState(() {
        _sicks = fetchedSicks;
      });
      debugPrint('DEBUG: _fetchSicks() - Data fetched successfully.');
    } catch (e) {
      if (!mounted) return; // Pastikan mounted sebelum setState
      setState(() {
        _errorMessage = 'Gagal memuat data kesehatan: $e';
      });
      debugPrint('ERROR: _fetchSicks() - Gagal memuat data kesehatan: $e');
    } finally {
      if (mounted) { // Pastikan widget masih mounted sebelum memanggil setState
        setState(() {
          _isLoading = false; // Ini akan selalu mematikan loading
        });
        debugPrint('DEBUG: _fetchSicks() - Finally block executed. Setting _isLoading = false.');
      }
    }
  }

  // Fungsi untuk menghitung total ayam sakit berdasarkan filter
  int _hitungTotalSakit() {
    int totalAmount = 0;
    DateTime now = DateTime.now();

    final filteredSicks = _sicks.where((sick) {
      if (sick.createdAt == null) return false; // Abaikan jika createdAt null

      DateTime waktuSick = sick.createdAt!.toLocal(); // Pastikan waktu lokal

      if (activePeriod == 'Harian') {
        return waktuSick.year == now.year &&
            waktuSick.month == now.month &&
            waktuSick.day == now.day;
      } else if (activePeriod == 'Mingguan') {
        DateTime awalMinggu = now.subtract(Duration(days: now.weekday - 1));
        DateTime akhirMinggu = awalMinggu.add(const Duration(days: 6));
        return waktuSick.isAfter(awalMinggu.subtract(const Duration(seconds: 1))) &&
            waktuSick.isBefore(akhirMinggu.add(const Duration(days: 1)));
      } else if (activePeriod == 'Bulanan') {
        return waktuSick.year == now.year && waktuSick.month == now.month;
      }
      return true; // Tampilkan semua jika tidak ada filter periode yang cocok
    }).toList();

    for (var sick in filteredSicks) {
      totalAmount += sick.amount ?? 0;
    }
    return totalAmount;
  }

  // Metode untuk menangani logika penghapusan dari parent
  Future<void> _handleDeleteSick(int id) async {
    debugPrint('DEBUG: _handleDeleteSick() called for ID: $id');
    if (!mounted) return; // Pastikan mounted sebelum setState
    setState(() {
      _isLoading = true; // Tampilkan loading untuk seluruh layar
      _errorMessage = null; // Reset error message
    });
    try {
      await supabaseService.deleteSick(id);
      await _fetchSicks(); // Muat ulang data, ini akan mengatur _isLoading=false
      // Gunakan _scaffoldKey.currentContext untuk menampilkan SnackBar
      if (_scaffoldKey.currentContext != null && mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('Data kesehatan berhasil dihapus!')),
        );
      }
    } catch (e) {
      debugPrint('ERROR: Gagal menghapus data di _handleDeleteSick: $e');
      // Gunakan _scaffoldKey.currentContext untuk menampilkan SnackBar
      if (_scaffoldKey.currentContext != null && mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data: $e')),
        );
      }
    } finally {
      // _fetchSicks() sudah memiliki finally block yang mengatur _isLoading = false
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan activePeriod
    final filteredList = _sicks.where((sick) {
      if (sick.createdAt == null) return false; // Abaikan jika createdAt null

      DateTime now = DateTime.now();
      DateTime waktuSick = sick.createdAt!.toLocal(); // Pastikan waktu lokal

      if (activePeriod == 'Harian') {
        return waktuSick.year == now.year &&
            waktuSick.month == now.month &&
            waktuSick.day == now.day;
      } else if (activePeriod == 'Mingguan') {
        DateTime awalMinggu = now.subtract(Duration(days: now.weekday - 1));
        DateTime akhirMinggu = awalMinggu.add(const Duration(days: 6));
        return waktuSick.isAfter(awalMinggu.subtract(const Duration(seconds: 1))) &&
            waktuSick.isBefore(akhirMinggu.add(const Duration(days: 1)));
      } else if (activePeriod == 'Bulanan') {
        return waktuSick.year == now.year && waktuSick.month == now.month;
      }
      return true; // Tampilkan semua jika tidak ada filter periode yang cocok
    }).toList();

    return Scaffold(
      key: _scaffoldKey, // Pasang GlobalKey ke Scaffold
      appBar: AppBar(
        title: const Text('Manajemen Kesehatan'),
        backgroundColor: Colors.green,
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Kesehatan (card mini)
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
                  child: const Icon(Icons.health_and_safety, size: 28, color: Colors.green), // Icon kesehatan
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Ayam Sakit',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey[700])),
                    Text('${_hitungTotalSakit()} ekor',
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

          // List data kesehatan dengan tombol edit & hapus
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : filteredList.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada data kesehatan untuk periode ini.',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final sick = filteredList[index];
                              return _SickListItem( // Menggunakan _SickListItem
                                sick: sick,
                                namaBulanHelper: _namaBulan, // Teruskan namaBulanHelper
                                onEdit: () async {
                                  final editedSick = await showDialog<Sick>(
                                    context: _scaffoldKey.currentContext!, // Gunakan context dari GlobalKey
                                    builder: (context) => AlertDialog(
                                      title: Text('Edit Data Kesehatan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                      content: SingleChildScrollView(
                                        child: HealthForm(
                                          initialData: sick,
                                          onSave: (savedData) {
                                            Navigator.pop(context, savedData);
                                          },
                                          namaBulanHelper: _namaBulan, // Teruskan namaBulanHelper
                                        ),
                                      ),
                                    ),
                                  );
                                  if (editedSick != null) {
                                    // SupabaseService.updateSick akan dipanggil di parent
                                    await supabaseService.updateSick(editedSick.copyWith(
                                      userId: authService.currentUser!.uid,
                                    ));
                                    _fetchSicks(); // Muat ulang data setelah edit
                                  }
                                },
                                onDeleteConfirmed: (id) async {
                                  await _handleDeleteSick(id); // Panggil metode penanganan hapus di parent
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
          // Tampilkan HealthForm dalam dialog untuk tambah data
          final newSick = await showDialog<Sick>(
            context: _scaffoldKey.currentContext!, // Gunakan context dari GlobalKey
            builder: (context) => AlertDialog(
              title: Text('Tambah Data Kesehatan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: HealthForm(
                  onSave: (savedData) {
                    Navigator.pop(context, savedData);
                  },
                  namaBulanHelper: _namaBulan, // Teruskan namaBulanHelper
                ),
              ),
            ),
          );

          if (newSick != null) {
            // SupabaseService.addSick akan dipanggil di parent
            await supabaseService.addSick(newSick.copyWith(
              userId: authService.currentUser!.uid,
            ));
            _fetchSicks(); // Muat ulang data setelah tambah
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

// Widget Item Kesehatan (meniru _EggListItem)
class _SickListItem extends StatelessWidget {
  final Sick sick; // Menerima objek Sick
  final String Function(int month) namaBulanHelper;
  final VoidCallback? onEdit;
  final Future<void> Function(int id) onDeleteConfirmed; // Callback untuk konfirmasi hapus

  const _SickListItem({
    super.key,
    required this.sick,
    required this.namaBulanHelper,
    this.onEdit,
    required this.onDeleteConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final String waktuFormatted = sick.createdAt != null
        ? '${sick.createdAt!.toLocal().hour.toString().padLeft(2, '0')}:${sick.createdAt!.toLocal().minute.toString().padLeft(2, '0')} - ${sick.createdAt!.toLocal().day} ${namaBulanHelper(sick.createdAt!.toLocal().month)}'
        : 'N/A';

    final String ringkasan = '${sick.amount ?? 0} ekor (${sick.description ?? 'Tidak ada keterangan'})';

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
                    'Kesehatan', // Label 'Kesehatan'
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

            // Jumlah + Keterangan (ringkasan)
            Expanded(
              flex: 4, // Beri lebih banyak ruang untuk ringkasan
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  ringkasan,
                  style: GoogleFonts.poppins(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
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
                showDialog(
                  context: context, // Context dari _SickListItem, OK untuk dialog
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
                          // Panggil callback hapus dengan ID sakit
                          // Pastikan sick.id tidak null sebelum memanggil onDeleteConfirmed
                          if (sick.id != null) {
                            await onDeleteConfirmed(sick.id!);
                          } else {
                            debugPrint('ERROR: Cannot delete sick with null ID.');
                            // Opsional: Tampilkan SnackBar error di sini jika ID null
                            if (context.mounted) { // Gunakan context dari _SickListItem
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Gagal menghapus data: ID kesehatan kosong.')),
                              );
                            }
                          }
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
