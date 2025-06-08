class DataService {
  // Singleton pattern
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Contoh data, ganti sesuai kebutuhan
  List<Map<String, dynamic>> dataTelur = [];
  List<Map<String, dynamic>> dataAyam = [];
  List<Map<String, dynamic>> dataPakan = [];
  List<Map<String, dynamic>> dataKesehatan = [];

  // Tambah data dari manajemen
  void tambahTelur(Map<String, dynamic> data) => dataTelur.add(data);
  void tambahAyam(Map<String, dynamic> data) => dataAyam.add(data);
  void tambahPakan(Map<String, dynamic> data) => dataPakan.add(data);
  void tambahKesehatan(Map<String, dynamic> data) => dataKesehatan.add(data);

  // Ambil data untuk dashboard (bisa filter by tanggal/periode)
  List<Map<String, dynamic>> getTelur() => dataTelur;
  List<Map<String, dynamic>> getAyam() => dataAyam;
  List<Map<String, dynamic>> getPakan() => dataPakan;
  List<Map<String, dynamic>> getKesehatan() => dataKesehatan;
}