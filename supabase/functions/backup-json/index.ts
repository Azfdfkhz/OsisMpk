// Supabase Edge Function: backup-json (README bagian 19)
//
// Alur: Supabase Database → Generate JSON → Google Drive.
// JALANKAN DI SERVER (Edge Function terjadwal / cron), BUKAN dari Flutter.
//
// Deploy:  supabase functions deploy backup-json
// Jadwal:  supabase functions schedule backup-json --cron "0 2 * * *"  (harian 02:00)
//          atau gunakan Supabase Dashboard > Database > Cron (pg_cron) untuk
//          memanggil fungsi ini.
//
// Struktur folder Drive (README bagian 18):
//   OSIS-FINANCE/BACKUP/daily/2026-09-05.json

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const TABLES = [
  "cash_accounts",
  "categories",
  "events",
  "budgets",
  "budget_items",
  "transactions",
  "logistics_items",
  "documents",
] as const;

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, // service role: bypass RLS (aman untuk backup server-side)
  );

  const data: Record<string, unknown[]> = {};
  for (const table of TABLES) {
    const { data: rows, error } = await supabase.from(table).select("*");
    if (error) {
      return new Response(JSON.stringify({ error: `${table}: ${error.message}` }), {
        status: 500,
      });
    }
    data[table] = rows ?? [];
  }

  const backup = {
    backup_version: 1,
    created_at: new Date().toISOString(),
    organization: "OSIS",
    data,
  };

  const json = JSON.stringify(backup, null, 2);

  // TODO: upload ke Google Drive menggunakan akun Google organisasi
  // (service account + Drive API, README bagian 4 & 18). Simpan ke:
  //   OSIS-FINANCE/BACKUP/daily/<YYYY-MM-DD>.json
  // Jangan simpan credential Google API di dalam aplikasi Flutter
  // (README prinsip keamanan #4).

  return new Response(json, {
    headers: { "Content-Type": "application/json; charset=utf-8" },
  });
});
