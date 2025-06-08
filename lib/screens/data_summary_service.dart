import 'manajemen_telur.dart';
import 'manajemen_ayam.dart';
import 'manajemen_pakan.dart';
import 'manajemen_kesehatan.dart';

class DataSummaryService {
  static int getTotalTelur()  => telurList.fold(0, (sum, item) => sum + item.jumlah);
  static int getTotalAyam() => ayamList.length;
  static int getTotalPakan() => pakanList.fold(0, (sum, item) => sum + item.jumlah);
  static int getTotalSakit() => kesehatanList.length;
}