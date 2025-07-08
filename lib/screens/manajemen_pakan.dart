import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ternakin/services/auth_services.dart'; // Untuk mendapatkan userId
import 'package:ternakin/services/supabase_services.dart'; // Untuk berinteraksi dengan Supabase
import '../components/feed_form.dart'; // Import FeedForm
import '../models/feed_model.dart'; // Import model Feed

class ManajemenPakanScreen extends StatefulWidget {
  const ManajemenPakanScreen({super.key});

  @override
  State<ManajemenPakanScreen> createState() => _ManajemenPakanScreenState();
}

class _ManajemenPakanScreenState extends State<ManajemenPakanScreen> {
  String activePeriod = 'Harian';
  List<Feed> _feeds = []; // List untuk menyimpan data pakan dari Supabase
  bool _isLoading = true; // State untuk indikator loading
  String? _errorMessage; // State untuk pesan error

  // Deklarasikan GlobalKey untuk Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchFeeds(); // Muat data pakan saat inisialisasi
  }

  // Fungsi pembantu untuk mendapatkan nama bulan dalam Bahasa Indonesia
  String _namaBulan(int bulan) {
    const namaBulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return namaBulan[bulan];
  }

  Future<void> _fetchFeeds() async {
    debugPrint('DEBUG: _fetchFeeds() called. Setting _isLoading = true.');
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
      debugPrint('DEBUG: _fetchFeeds() - User not logged in. Setting _isLoading = false.');
      return;
    }
    try {
      final fetchedFeeds = await supabaseService.getFeeds(userId);
      if (!mounted) return; // Pastikan mounted sebelum setState
      setState(() {
        _feeds = fetchedFeeds;
      });
      debugPrint('DEBUG: _fetchFeeds() - Data fetched successfully.');
    } catch (e) {
      if (!mounted) return; // Pastikan mounted sebelum setState
      setState(() {
        _errorMessage = 'Gagal memuat data pakan: $e';
      });
      debugPrint('ERROR: _fetchFeeds() - Gagal memuat data pakan: $e');
    } finally {
      if (mounted) { // Pastikan widget masih mounted sebelum memanggil setState
        setState(() {
          _isLoading = false; // Ini akan selalu mematikan loading
        });
        debugPrint('DEBUG: _fetchFeeds() - Finally block executed. Setting _isLoading = false.');
      }
    }
  }

  // Fungsi untuk menghitung total pakan berdasarkan filter
  int _hitungTotalPakan() {
    int masuk = 0;
    int keluar = 0;
    DateTime now = DateTime.now();

    final filteredFeeds = _feeds.where((feed) {
      if (feed.createdAt == null) return false; // Abaikan jika createdAt null

      DateTime waktuFeed = feed.createdAt!.toLocal(); // Pastikan waktu lokal

      if (activePeriod == 'Harian') {
        return waktuFeed.year == now.year &&
            waktuFeed.month == now.month &&
            waktuFeed.day == now.day;
      } else if (activePeriod == 'Mingguan') {
        DateTime awalMinggu = now.subtract(Duration(days: now.weekday - 1));
        DateTime akhirMinggu = awalMinggu.add(const Duration(days: 6));
        return waktuFeed.isAfter(awalMinggu.subtract(const Duration(seconds: 1))) &&
            waktuFeed.isBefore(akhirMinggu.add(const Duration(days: 1)));
      } else if (activePeriod == 'Bulanan') {
        return waktuFeed.year == now.year && waktuFeed.month == now.month;
      }
      return true; // Tampilkan semua jika tidak ada filter periode yang cocok
    }).toList();

    for (var feed in filteredFeeds) {
      if (feed.status == 'in') { // Sesuaikan dengan nilai 'in'/'out' di database
        masuk += feed.amount ?? 0;
      } else if (feed.status == 'out') {
        keluar += feed.amount ?? 0;
      }
    }
    return masuk - keluar;
  }

  // Metode untuk menangani logika penghapusan dari parent
  Future<void> _handleDeleteFeed(int id) async {
    debugPrint('DEBUG: _handleDeleteFeed() called for ID: $id');
    if (!mounted) return; // Pastikan mounted sebelum setState
    setState(() {
      _isLoading = true; // Tampilkan loading untuk seluruh layar
      _errorMessage = null; // Reset error message
    });
    try {
      await supabaseService.deleteFeed(id);
      await _fetchFeeds(); // Muat ulang data, ini akan mengatur _isLoading=false
      // Gunakan _scaffoldKey.currentContext untuk menampilkan SnackBar
      if (_scaffoldKey.currentContext != null && mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('Data pakan berhasil dihapus!')),
        );
      }
    } catch (e) {
      debugPrint('ERROR: Gagal menghapus data di _handleDeleteFeed: $e');
      // Gunakan _scaffoldKey.currentContext untuk menampilkan SnackBar
      if (_scaffoldKey.currentContext != null && mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data: $e')),
        );
      }
    } finally {
      // _fetchFeeds() sudah memiliki finally block yang mengatur _isLoading = false
      // Jadi, tidak perlu lagi mengatur _isLoading = false di sini secara eksplisit
      // jika _fetchFeeds() selalu dipanggil.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan activePeriod
    final filteredList = _feeds.where((feed) {
      if (feed.createdAt == null) return false; // Abaikan jika createdAt null

      DateTime now = DateTime.now();
      DateTime waktuFeed = feed.createdAt!.toLocal(); // Pastikan waktu lokal

      if (activePeriod == 'Harian') {
        return waktuFeed.year == now.year &&
            waktuFeed.month == now.month &&
            waktuFeed.day == now.day;
      } else if (activePeriod == 'Mingguan') {
        DateTime awalMinggu = now.subtract(Duration(days: now.weekday - 1));
        DateTime akhirMinggu = awalMinggu.add(const Duration(days: 6));
        return waktuFeed.isAfter(awalMinggu.subtract(const Duration(seconds: 1))) &&
            waktuFeed.isBefore(akhirMinggu.add(const Duration(days: 1)));
      } else if (activePeriod == 'Bulanan') {
        return waktuFeed.year == now.year && waktuFeed.month == now.month;
      }
      return true; // Tampilkan semua jika tidak ada filter periode yang cocok
    }).toList();

    return Scaffold(
      key: _scaffoldKey, // Pasang GlobalKey ke Scaffold
      appBar: AppBar(
        title: const Text('Manajemen Pakan'),
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
          // Total Pakan (card mini)
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
                  child: const Icon(Icons.grass, size: 28, color: Colors.green), // Icon pakan
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Pakan (kg)',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey[700])),
                    Text('${_hitungTotalPakan()}',
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

          // List data pakan dengan tombol edit & hapus
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : filteredList.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada data pakan untuk periode ini.',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final feed = filteredList[index];
                              return _FeedListItem( // Menggunakan _FeedListItem
                                feed: feed,
                                namaBulanHelper: _namaBulan, // Teruskan namaBulanHelper
                                onEdit: () async {
                                  final editedFeed = await showDialog<Feed>(
                                    context: _scaffoldKey.currentContext!, // Gunakan context dari GlobalKey
                                    builder: (context) => AlertDialog(
                                      title: Text('Edit Data Pakan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                      content: SingleChildScrollView(
                                        child: FeedForm(
                                          initialData: feed,
                                          onSave: (savedData) {
                                            Navigator.pop(context, savedData);
                                          },
                                          namaBulanHelper: _namaBulan, // Teruskan namaBulanHelper
                                        ),
                                      ),
                                    ),
                                  );
                                  if (editedFeed != null) {
                                    // SupabaseService.updateFeed sudah mengembalikan Feed yang diperbarui
                                    // Jadi cukup panggil _fetchFeeds() untuk refresh
                                    _fetchFeeds();
                                  }
                                },
                                onDeleteConfirmed: (id) async {
                                  await _handleDeleteFeed(id); // Panggil metode penanganan hapus di parent
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
          // Tampilkan FeedForm dalam dialog untuk tambah data
          final newFeed = await showDialog<Feed>(
            context: _scaffoldKey.currentContext!, // Gunakan context dari GlobalKey
            builder: (context) => AlertDialog(
              title: Text('Tambah Data Pakan', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: FeedForm(
                  onSave: (savedData) {
                    Navigator.pop(context, savedData);
                  },
                  namaBulanHelper: _namaBulan, // Teruskan namaBulanHelper
                ),
              ),
            ),
          );

          if (newFeed != null) {
            // SupabaseService.addFeed sudah mengembalikan Feed yang baru ditambahkan
            // Jadi cukup panggil _fetchFeeds() untuk refresh
            _fetchFeeds(); // Muat ulang data setelah tambah
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

// Widget Item Pakan (meniru _EggListItem)
class _FeedListItem extends StatelessWidget {
  final Feed feed; // Menerima objek Feed
  final String Function(int month) namaBulanHelper;
  final VoidCallback? onEdit;
  final Future<void> Function(int id) onDeleteConfirmed; // Callback untuk konfirmasi hapus

  const _FeedListItem({
    super.key,
    required this.feed,
    required this.namaBulanHelper,
    this.onEdit,
    required this.onDeleteConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final String waktuFormatted = feed.createdAt != null
        ? '${feed.createdAt!.toLocal().hour.toString().padLeft(2, '0')}:${feed.createdAt!.toLocal().minute.toString().padLeft(2, '0')} - ${feed.createdAt!.toLocal().day} ${namaBulanHelper(feed.createdAt!.toLocal().month)}'
        : 'N/A';

    final String statusText = feed.status == 'in' ? 'Masuk' : 'Keluar';
    final String ringkasan = '$statusText ${feed.amount ?? 0} kg'; // Menampilkan status dan jumlah pakan

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
                    'Pakan', // Label tetap 'Pakan'
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
                  context: context, // Context dari _FeedListItem, OK untuk dialog
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
                          // Panggil callback hapus dengan ID pakan
                          // Pastikan feed.id tidak null sebelum memanggil onDeleteConfirmed
                          if (feed.id != null) {
                            await onDeleteConfirmed(feed.id!);
                          } else {
                            debugPrint('ERROR: Cannot delete feed with null ID.');
                            // Opsional: Tampilkan SnackBar error di sini jika ID null
                            if (context.mounted) { // Gunakan context dari _FeedListItem
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Gagal menghapus data: ID pakan kosong.')),
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
