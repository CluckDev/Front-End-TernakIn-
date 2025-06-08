// lib/models/jadwal.dart
class Jadwal {
  DateTime tanggal;
  String waktu;
  String aktivitas;
  String catatan;

  Jadwal({
    required this.tanggal,
    required this.waktu,
    required this.aktivitas,
    required this.catatan,
  });
}
