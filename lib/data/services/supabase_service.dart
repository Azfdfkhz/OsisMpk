import 'package:supabase_flutter/supabase_flutter.dart';

/// Stub integrasi Supabase (Phase 1 — README bagian 4 & 10).
///
/// Database PostgreSQL adalah source of truth. Permission di Flutter
/// HANYA mengontrol UI; keamanan ditegakkan via RLS di server.
///
/// Setup:
/// 1. Buat project di https://supabase.com, jalankan schema_osis_finance.sql
/// 2. Aktifkan Google provider di Authentication > Providers
/// 3. Isi url & anonKey dari Settings > API
class SupabaseService {
  SupabaseService._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    if (url.isEmpty || anonKey.isEmpty) return; // mode mock/demo
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  /// Google OAuth login (README bagian 4).
  static Future<bool> signInWithGoogle() async {
    return client.auth.signInWithOAuth(OAuthProvider.google);
  }

  static Future<void> signOut() => client.auth.signOut();
}
