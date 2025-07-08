import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ternakin/services/auth_services.dart'; // Untuk mendapatkan userId
import 'package:ternakin/services/supabase_services.dart'; // Untuk berinteraksi dengan Supabase
import '../components/schedule_form.dart'; // Import ScheduleForm yang baru
import '../models/schedule_model.dart'; // Import model Schedule

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  List<Schedule> _schedules =
      []; // List untuk menyimpan data jadwal dari Supabase
  bool _isLoading = true; // State untuk indikator loading
  String? _errorMessage; // State untuk pesan error
  DateTime? _selectedFilterDate; // Filter tanggal

  // Deklarasikan GlobalKey untuk Scaffold
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchSchedules(); // Muat data jadwal saat inisialisasi
  }

  // Fungsi pembantu untuk mendapatkan nama bulan dalam Bahasa Indonesia
  String _namaBulan(int bulan) {
    const namaBulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return namaBulan[bulan];
  }

  Future<void> _fetchSchedules() async {
    debugPrint('DEBUG: _fetchSchedules() called. Setting _isLoading = true.');
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final userId = authService.currentUser?.uid;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Pengguna tidak login.';
        _isLoading = false;
      });
      debugPrint(
          'DEBUG: _fetchSchedules() - User not logged in. Setting _isLoading = false.');
      return;
    }
    try {
      final fetchedSchedules = await supabaseService.getSchedules(userId);
      if (!mounted) return;
      setState(() {
        _schedules = fetchedSchedules;
      });
      debugPrint('DEBUG: _fetchSchedules() - Data fetched successfully.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat data jadwal: $e';
      });
      debugPrint('ERROR: _fetchSchedules() - Gagal memuat data jadwal: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint(
            'DEBUG: _fetchSchedules() - Finally block executed. Setting _isLoading = false.');
      }
    }
  }

  Future<void> _handleDeleteSchedule(int id) async {
    debugPrint('DEBUG: _handleDeleteSchedule() called for ID: $id');
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await supabaseService.deleteSchedule(id);
      await _fetchSchedules(); // Muat ulang data
      if (_scaffoldKey.currentContext != null && mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil dihapus!')),
        );
      }
    } catch (e) {
      debugPrint('ERROR: Gagal menghapus jadwal di _handleDeleteSchedule: $e');
      if (_scaffoldKey.currentContext != null && mounted) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Gagal menghapus jadwal: $e')),
        );
      }
    } finally {
      // _fetchSchedules() sudah memiliki finally block yang mengatur _isLoading = false
    }
  }

  Future<void> _selectFilterDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFilterDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedFilterDate) {
      setState(() {
        _selectedFilterDate = picked;
      });
    }
  }

  void _clearFilterDate() {
    setState(() {
      _selectedFilterDate = null;
    });
  }

  IconData _getAktivitasIcon(String? aktivitasType) {
    switch (aktivitasType) {
      case 'Panen':
        return Icons.agriculture;
      case 'Vaksin':
        return Icons.healing;
      case 'Pemberian Pakan':
        return Icons.restaurant;
      case 'Lainnya': // Tambahkan case untuk 'Lainnya'
        return Icons.event_note;
      default:
        return Icons.event_note;
    }
  }

  Color _getAktivitasColor(String? aktivitasType) {
    switch (aktivitasType) {
      case 'Panen':
        return Colors.green.shade700;
      case 'Vaksin':
        return Colors.blue.shade700;
      case 'Pemberian Pakan':
        return Colors.orange.shade700;
      case 'Lainnya': // Tambahkan case untuk 'Lainnya'
        return Colors.grey.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSchedules = _selectedFilterDate == null
        ? _schedules
        : _schedules.where((schedule) {
            if (schedule.createdAt == null) return false;
            final scheduleDate = schedule.createdAt!.toLocal();
            return scheduleDate.year == _selectedFilterDate!.year &&
                scheduleDate.month == _selectedFilterDate!.month &&
                scheduleDate.day == _selectedFilterDate!.day;
          }).toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Manajemen Jadwal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _selectFilterDate(context),
            tooltip: 'Filter Tanggal',
          ),
          if (_selectedFilterDate != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: _clearFilterDate,
              tooltip: 'Hapus Filter',
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tampilkan tanggal filter yang dipilih
          if (_selectedFilterDate != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Jadwal untuk tanggal: ${_selectedFilterDate!.day} ${_namaBulan(_selectedFilterDate!.month)} ${_selectedFilterDate!.year}',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : filteredSchedules.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_note,
                                    color: Colors.green[200], size: 80),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada jadwal ditambahkan.',
                                  style: GoogleFonts.poppins(
                                      fontSize: 18, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            itemCount: filteredSchedules.length,
                            itemBuilder: (context, index) {
                              final schedule = filteredSchedules[index];
                              return _ScheduleListItem(
                                schedule: schedule,
                                getAktivitasIcon: _getAktivitasIcon,
                                getAktivitasColor: _getAktivitasColor,
                                namaBulanHelper: _namaBulan,
                                onEdit: () async {
                                  final editedSchedule =
                                      await showDialog<Schedule>(
                                    context: _scaffoldKey.currentContext!,
                                    builder: (context) => AlertDialog(
                                      title: Text('Edit Jadwal',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold)),
                                      content: SingleChildScrollView(
                                        child: ScheduleForm(
                                          // Menggunakan ScheduleForm
                                          initialData:
                                              schedule, // Meneruskan schedule sebagai initialData
                                          onSave: (savedData) {
                                            Navigator.pop(context, savedData);
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                  if (editedSchedule != null) {
                                    await supabaseService
                                        .updateSchedule(editedSchedule.copyWith(
                                      userId: authService.currentUser!.uid,
                                    ));
                                    _fetchSchedules();
                                  }
                                },
                                onDeleteConfirmed: (id) async {
                                  await _handleDeleteSchedule(id);
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newSchedule = await showDialog<Schedule>(
            context: _scaffoldKey.currentContext!,
            builder: (context) => AlertDialog(
              title: Text('Tambah Jadwal Baru',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: ScheduleForm(
                  // Menggunakan ScheduleForm
                  onSave: (savedData) {
                    Navigator.pop(context, savedData);
                  },
                ),
              ),
            ),
          );

          if (newSchedule != null) {
            await supabaseService.addSchedule(newSchedule.copyWith(
              userId: authService.currentUser!.uid,
            ));
            _fetchSchedules();
          }
        },
        backgroundColor: Colors.green[700],
        tooltip: 'Tambah Jadwal',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Widget item list jadwal
class _ScheduleListItem extends StatelessWidget {
  final Schedule schedule;
  final Function(String?) getAktivitasIcon;
  final Function(String?) getAktivitasColor;
  final Function(int) namaBulanHelper;
  final VoidCallback? onEdit;
  final Future<void> Function(int id) onDeleteConfirmed;

  const _ScheduleListItem({
    super.key,
    required this.schedule,
    required this.getAktivitasIcon,
    required this.getAktivitasColor,
    required this.namaBulanHelper,
    this.onEdit,
    required this.onDeleteConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    // Menggunakan createdAt untuk tanggal dan waktu
    final String waktuFormatted = schedule.createdAt != null
        ? '${schedule.createdAt!.toLocal().hour.toString().padLeft(2, '0')}:${schedule.createdAt!.toLocal().minute.toString().padLeft(2, '0')} - ${schedule.createdAt!.toLocal().day} ${namaBulanHelper(schedule.createdAt!.toLocal().month)}'
        : 'N/A';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: getAktivitasColor(schedule.type).withOpacity(0.15),
          child: Icon(
            getAktivitasIcon(schedule.type),
            color: getAktivitasColor(schedule.type),
            size: 28,
          ),
        ),
        title: Text(
          schedule.type ?? 'Tidak Diketahui',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7)),
                const SizedBox(width: 4),
                Text(
                  waktuFormatted,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7)),
                ),
              ],
            ),
            if (schedule.description != null &&
                schedule.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                schedule.description!,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7)),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.orange[700]),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red[700]),
              tooltip: 'Hapus',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Konfirmasi Hapus'),
                    content: const Text('Yakin ingin menghapus jadwal ini?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          if (schedule.id != null) {
                            await onDeleteConfirmed(schedule.id!);
                          } else {
                            debugPrint(
                                'ERROR: Cannot delete schedule with null ID.');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Gagal menghapus jadwal: ID jadwal kosong.')),
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
            ),
          ],
        ),
      ),
    );
  }
}
