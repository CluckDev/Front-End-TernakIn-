import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

// Global ValueNotifier untuk melacak status pengguna yang sedang login
ValueNotifier<fb_auth.User?> currentUserNotifier = ValueNotifier(null);