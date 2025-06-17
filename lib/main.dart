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

// Notifier untuk ThemeMode
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MyApp(themeMode: mode);
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;
  const MyApp({super.key, required this.themeMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TernakIn',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF222222),
      ),
      themeMode: themeMode,
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
