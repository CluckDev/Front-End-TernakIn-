import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ternakin/widgets/auth_guard.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/dashboard.dart';
import 'screens/forgot_password.dart';
import 'screens/manajemen.dart';
import 'screens/manajemen_ayam.dart';
import 'screens/manajemen_telur.dart';
import 'screens/manajemen_pakan.dart';
import 'screens/manajemen_kesehatan.dart';
import 'screens/profile.dart';
import 'screens/pengaturan_screen.dart';
import 'screens/notifikasi_screen.dart';
import 'services/supabase_services.dart'; // Pastikan path ini benar
import 'services/data_summary_service.dart'; // Import DataSummaryService
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase Flutter
import 'package:intl/date_symbol_data_local.dart';

// Deklarasikan supabaseService dan dataSummaryService sebagai late final
late final SupabaseService supabaseService;
late final DataSummaryService
    dataSummaryService; // Pastikan ini ada dan diinisialisasi!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initializeDateFormatting('id_ID', null);

  // PENTING: Muat file .env di sini SEBELUM mencoba mengakses variabelnya
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi Supabase secara global di sini, hanya sekali
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!, // Ambil dari .env
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!, // Ambil dari .env
  );

  // Inisialisasi instance service SETELAH Supabase.initialize selesai
  supabaseService = SupabaseService();
  dataSummaryService =
      DataSummaryService(); // Inisialisasi dataSummaryService di sini
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarIconBrightness: Brightness.dark, // Untuk Android (ikon terang)
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TernakIn',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color.fromARGB(255, 245, 246, 247),
        brightness: Brightness.light,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const AuthGuard(child: DashboardScreen()),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/manajemen': (context) => const ManajemenScreen(),
        '/manajemen-ayam': (context) => const ManajemenAyamScreen(),
        '/manajemen-telur': (context) => const ManajemenTelurScreen(),
        '/manajemen-pakan': (context) => const ManajemenPakanScreen(),
        '/manajemen-kesehatan': (context) => const ManajemenKesehatanScreen(),
        '/profile': (context) => const ProfilScreen(),
        '/pengaturan': (context) => const PengaturanScreen(),
        '/notifikasi': (context) => const NotifikasiScreen(),
      },
    );
  }
}
