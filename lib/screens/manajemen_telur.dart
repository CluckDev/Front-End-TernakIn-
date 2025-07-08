import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ternakin/services/auth_services.dart'; // Untuk mendapatkan userId
import 'package:ternakin/services/supabase_services.dart'; // Untuk berinteraksi dengan Supabase
import '../components/egg_form.dart'; // Import EggForm yang baru
import '../models/egg_model.dart'; // Import model Egg

class ManajemenTelurScreen extends StatefulWidget {
  const ManajemenTelurScreen({super.key});

  @override
  State<ManajemenTelurScreen> createState() => _ManajemenTelurScreenState();
}

class _ManajemenTelurScreenState extends State<ManajemenTelurScreen> {
  String activePeriod = 'Harian';
  List<Egg> _eggs = []; // List untuk menyimpan data telur dari Supabase
  bool _isLoading = true; // State untuk indikator loading
  String? _errorMessage; // State untuk pesan error

  // Deklarasikan GlobalKey untuk Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchEggs(); // Muat data telur saat inisialisasi
  }

  // Fungsi pembantu untuk mendapatkan nama bulan dalam Bahasa Indonesia
  String _namaBulan(int bulan) {
    const namaBulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return namaBulan[bulan];
  }

  Future<void> _fetchEggs() async {
    debugPrint('DEBUG: _fetchEggs() called. Setting _isLoading = true.');
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
      debugPrint('DEBUG: _fetchEggs() - User not logged in. Setting _isLoading = false.');
      return;
    }
    try {
      final fetchedEggs = await supabaseService.getEggs(userId);
      if (!mounted) return; // Pastikan mounted sebelum setState
      setState(() {
        _eggs = fetchedEggs;
      });
      debugPrint('DEBUG: _fetchEggs() - Data fetched successfully.');
    } catch (e) {
      if (!mounted) return; // Pastikan mounted sebelum setState
      setState(() {
        _errorMessage = 'Gagal memuat data telur: $e';
      });
      debugPrint('ERROR: _fetchEggs() - Gagal memuat data telur: $e');
    } finally {
      if (mounted) { // Pastikan widget masih mounted sebelum memanggil setState
        setState(() {
          _isLoading = false; // Ini akan selalu mematikan loading
        });
        debugPrint('DEBUG: _fetchEggs() - Finally block executed. Setting _isLoading = false.');
      }
    }
  }

  // Fungsi untuk menghitung total telur berdasarkan filter
  int _hitungTotalTelur() {
    int masuk = 0;
    int keluar = 0;
    DateTime now = DateTime.now();

    final filteredEggs = _eggs.where((egg) {
      if (egg.createdAt == null) return false; // Abaikan jika createdAt null

      DateTime waktuEgg = egg.createdAt!.toLocal(); // Pastikan waktu lokal

      if (activePeriod == 'Harian') {
        return waktuEgg.year == now.year &&
            waktuEgg.month == now.month &&
            waktuEgg.day == now.day;
      } else if (activePeriod == 'Mingguan') {
        DateTime awalMinggu = now.subtract(Duration(days: now.weekday - 1));
        DateTime akhirMinggu = awalMinggu.add(const Duration(days: 6));
        return waktuEgg.isAfter(awalMinggu.subtract(const Duration(seconds: 1))) &&
            waktuEgg.isBefore(akhirMinggu.add(const Duration(days: 1)));
      } else if (activePeriod == 'Bulanan') {
        return waktuEgg.year == now.year && waktuEgg.month == now.month;
      }
      return true; // Tampilkan semua jika tidak ada filter periode yang cocok
    }).toList();

    for (var egg in filteredEggs) {
      if (egg.status == 'in') { // Sesuaikan dengan nilai 'in'/'out' di database
        masuk += egg.amount ?? 0;
      } else if (egg.status == 'out') {
        keluar += egg.amount ?? 0;
      }
    }
    return masuk - keluar;
  }

  // Metode untuk menangani logika penghapusan dari parent
  Future<void> _handleDeleteEgg(int id) async {
    debugPrint('DEBUG: _handleDeleteEgg() called for ID: $id');
    if (!mounted) return; // Pastikan mounted sebelum setState
    setState(() {
      _isLoading = true; // Tampilkan loading untuk seluruh layar
      _errorMessage = null; // Reset error message
    });
    try {
      await supabaseService.deleteEgg(id);
      await _fetchEggs(); // Muat ulang data, ini akan mengatur _isLoading=false
      // Gunakan _scaffoldKey.currentContext untuk menampilkan SnackBar
      if (_scaffoldKey.currentContext != null && mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('Data berhasil dihapus!')),
        );
      }
    } catch (e) {
      debugPrint('ERROR: Gagal menghapus data di _handleDeleteEgg: $e');
      // Gunakan _scaffoldKey.currentContext untuk menampilkan SnackBar
      if (_scaffoldKey.currentContext != null && mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data: $e')),
        );
      }
    } finally {
      // _fetchEggs() sudah memiliki finally block yang mengatur _isLoading = false
      // Jadi, tidak perlu lagi mengatur _isLoading = false di sini secara eksplisit
      // jika _fetchEggs() selalu dipanggil.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan activePeriod
    final filteredList = _eggs.where((egg) {
      if (egg.createdAt == null) return false; // Abaikan jika createdAt null

      DateTime now = DateTime.now();
      DateTime waktuEgg = egg.createdAt!.toLocal(); // Pastikan waktu lokal

      if (activePeriod == 'Harian') {
        return waktuEgg.year == now.year &&
            waktuEgg.month == now.month &&
            waktuEgg.day == now.day;
      } else if (activePeriod == 'Mingguan') {
        DateTime awalMinggu = now.subtract(Duration(days: now.weekday - 1));
        DateTime akhirMinggu = awalMinggu.add(const Duration(days: 6));
        return waktuEgg.isAfter(awalMinggu.subtract(const Duration(seconds: 1))) &&
            waktuEgg.isBefore(akhirMinggu.add(const Duration(days: 1)));
      } else if (activePeriod == 'Bulanan') {
        return waktuEgg.year == now.year && waktuEgg.month == now.month;
      }
      return true; // Tampilkan semua jika tidak ada filter periode yang cocok
    }).toList();

    return Scaffold(
      key: _scaffoldKey, // Pasang GlobalKey ke Scaffold
      appBar: AppBar(
        title: const Text('Manajemen Telur'),
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
          // Total Telur (card mini)
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
                  child: const Icon(Icons.egg, size: 28, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Telur',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey[700])),
                    Text('${_hitungTotalTelur()}',
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

          // List data telur dengan tombol edit & hapus
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : filteredList.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada data telur untuk periode ini.',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final egg = filteredList[index];
                              return _EggListItem( // Menggunakan _EggListItem
                                egg: egg,
                                onEdit: () async {
                                  final editedEgg = await showDialog<Egg>(
                                    context: _scaffoldKey.currentContext!, // Gunakan context dari GlobalKey
                                    builder: (context) => AlertDialog(
                                      title: Text('Edit Data Telur', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                      content: SingleChildScrollView(
                                        child: EggForm(
                                          initialData: egg,
                                          onSave: (savedData) {
                                            Navigator.pop(context, savedData);
                                          },
                                          // namaBulanHelper tidak lagi diteruskan
                                        ),
                                      ),
                                    ),
                                  );
                                  if (editedEgg != null) {
                                    // Perbarui data di Supabase
                                    await supabaseService.updateEgg(editedEgg.copyWith(
                                      userId: authService.currentUser!.uid, // Pastikan userId terisi
                                    ));
                                    _fetchEggs(); // Muat ulang data setelah edit
                                  }
                                },
                                onDeleteConfirmed: (id) async {
                                  await _handleDeleteEgg(id); // Panggil metode penanganan hapus di parent
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
          // Tampilkan EggForm dalam dialog untuk tambah data
          final newEgg = await showDialog<Egg>(
            context: _scaffoldKey.currentContext!, // Gunakan context dari GlobalKey
            builder: (context) => AlertDialog(
              title: Text('Tambah Data Telur', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: EggForm(
                  onSave: (savedData) {
                    Navigator.pop(context, savedData);
                  },
                  // namaBulanHelper tidak lagi diteruskan
                ),
              ),
            ),
          );

          if (newEgg != null) {
            // Tambahkan data ke Supabase
            await supabaseService.addEgg(newEgg.copyWith(
              userId: authService.currentUser!.uid, // Pastikan userId terisi
              // ID tidak perlu diisi untuk insert baru, Supabase akan mengaturnya
            ));
            _fetchEggs(); // Muat ulang data setelah tambah
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

// Widget Item Telur (seperti _ChickenListItem)
class _EggListItem extends StatelessWidget {
  final Egg egg; // Menerima objek Egg
  final VoidCallback? onEdit;
  final Future<void> Function(int id) onDeleteConfirmed; // Callback untuk konfirmasi hapus

  const _EggListItem({
    super.key,
    required this.egg,
    this.onEdit,
    required this.onDeleteConfirmed,
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
    final String waktuFormatted = egg.createdAt != null
        ? '${egg.createdAt!.toLocal().hour.toString().padLeft(2, '0')}:${egg.createdAt!.toLocal().minute.toString().padLeft(2, '0')} - ${egg.createdAt!.toLocal().day} ${_namaBulan(egg.createdAt!.toLocal().month)}'
        : 'N/A';

    final String statusText = egg.status == 'in' ? 'Masuk' : 'Keluar';
    final String ringkasan = '$statusText ${egg.amount ?? 0}'; // Menggunakan null-aware operator

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
                    'Telur', // Label tetap 'Telur'
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
                showDialog(
                  context: context, // Context dari _EggListItem, OK untuk dialog
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
                          // Panggil callback hapus dengan ID telur
                          // Pastikan egg.id tidak null sebelum memanggil onDeleteConfirmed
                          if (egg.id != null) {
                            await onDeleteConfirmed(egg.id!);
                          } else {
                            debugPrint('ERROR: Cannot delete egg with null ID.');
                            // Opsional: Tampilkan SnackBar error di sini jika ID null
                            if (context.mounted) { // Gunakan context dari _EggListItem
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Gagal menghapus data: ID telur kosong.')),
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
