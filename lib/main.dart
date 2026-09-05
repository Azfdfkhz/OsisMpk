import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Format tanggal Bahasa Indonesia (dipakai di core/utils/date_formatter.dart)
  await initializeDateFormatting('id_ID', null);

  // README bagian 2 & 4: Supabase sebagai backend utama + Auth.
  // Isi AppConstants.supabaseUrl & supabaseAnonKey sebelum menjalankan
  // aplikasi terhubung ke project Supabase asli. Selama masih memakai
  // MockData (lib/data/services/mock_data.dart), inisialisasi Supabase
  // dilewati sepenuhnya agar tidak mencoba konek ke host placeholder
  // (menghindari delay/hang saat testing tanpa koneksi Supabase asli).
  if (AppConstants.hasSupabaseCredentials) {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (_) {
      // Diabaikan saat kredensial belum valid / tidak ada koneksi.
    }
  }

  runApp(const ProviderScope(child: OsisFinanceApp()));
}

class OsisFinanceApp extends StatelessWidget {
  const OsisFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}
