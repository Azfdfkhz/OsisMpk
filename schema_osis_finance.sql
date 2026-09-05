-- =====================================================================
-- OSIS FINANCE - DATABASE SCHEMA (Supabase / PostgreSQL)
-- =====================================================================
-- Disusun berdasarkan:
--   - README_OSIS_MPK.md (Arsitektur, Role/Permission, Modul Keuangan,
--     RAB, Logistik, Dokumentasi, Audit Log - bagian 5 s/d 26)
--   - Desain UI "OSIS Finance" (Dashboard, Event, Transaksi, RAB,
--     Logistik, Dokumentasi, Persetujuan)
--
-- Catatan:
--   - Struktur ini adalah baseline (README bagian 26) yang sudah
--     dilengkapi kolom & tabel tambahan agar sesuai dengan yang
--     ditampilkan pada desain (progress event, badge persetujuan,
--     rincian RAB per kategori, status logistik "Diterima/Belum", dst).
--   - File fisik (foto barang, foto nota, backup JSON) TIDAK disimpan
--     di database ini. Yang disimpan hanya metadata/referensi
--     (drive_file_id) sesuai README bagian 3, 17, 19.
--   - Permission dari Flutter hanya mengatur UI. Keamanan sesungguhnya
--     ditegakkan lewat Row Level Security (RLS) di sini (README bagian 10).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. EXTENSIONS
-- ---------------------------------------------------------------------
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ---------------------------------------------------------------------
-- 1. ENUM TYPES
-- ---------------------------------------------------------------------

-- Scope permission (README bagian 9)
create type permission_scope as enum ('ALL', 'EVENT', 'OWN');

-- Status event (tab "Semua / Aktif / Selesai / Draft" pada desain)
create type event_status as enum ('DRAFT', 'ACTIVE', 'COMPLETED', 'CANCELLED');

-- Jenis transaksi (README bagian 12)
create type transaction_type as enum ('income', 'expense', 'transfer', 'adjustment');

-- Status transaksi / RAB (README bagian 13 & 15)
create type workflow_status as enum (
  'DRAFT', 'SUBMITTED', 'REVIEW', 'APPROVED', 'REJECTED', 'VOID', 'COMPLETED'
);

-- Jenis kategori (income/expense), untuk pemasukan & RAB
create type category_type as enum ('income', 'expense');

-- Status barang logistik ("Diterima" / "Belum" pada desain)
create type logistics_status as enum ('PENDING', 'RECEIVED', 'ISSUE');

-- Jenis dokumentasi logistik (README bagian 21)
create type logistics_document_type as enum (
  'item_photo', 'receipt', 'delivery', 'condition', 'other'
);

-- Status pengajuan persetujuan (menu "Persetujuan" pada desain)
create type approval_status as enum ('PENDING', 'APPROVED', 'REJECTED');

create type approval_entity as enum ('transaction', 'budget', 'logistics_item', 'event');

-- ---------------------------------------------------------------------
-- 2. ORGANIZATION & USER (README bagian 4, 5, 26)
-- ---------------------------------------------------------------------

create table organizations (
  id            uuid primary key default uuid_generate_v4(),
  name          text not null,
  school_name   text,
  logo_url      text,
  drive_root_folder_id text,      -- root folder "OSIS-FINANCE/" di Google Drive
  sheets_rab_template_id text,    -- template Google Sheets untuk RAB
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Mirror dari auth.users (Supabase Auth + Google OAuth)
create table profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  email       text,
  avatar_url  text,
  phone       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table organization_members (
  id              uuid primary key default uuid_generate_v4(),
  organization_id uuid not null references organizations(id) on delete cascade,
  user_id         uuid not null references profiles(id) on delete cascade,
  is_active       boolean not null default true,
  joined_at       timestamptz not null default now(),
  unique (organization_id, user_id)
);

-- ---------------------------------------------------------------------
-- 3. ROLE & PERMISSION (README bagian 5, 6, 7, 8, 9)
-- ---------------------------------------------------------------------

create table roles (
  id          uuid primary key default uuid_generate_v4(),
  name        text not null,          -- Superadmin, Admin, Pembina, Ketua OSIS,
                                       -- Bendahara, Logistik, Sekretaris, Anggota, Viewer
  description text,
  is_system   boolean not null default false, -- role bawaan tidak boleh dihapus
  created_at  timestamptz not null default now()
);

create table permissions (
  id          uuid primary key default uuid_generate_v4(),
  key         text not null unique,   -- e.g. transaction.approve, rab.submit
  name        text not null,
  module      text not null,          -- dashboard, user, transaction, event, rab,
                                       -- document, report, backup, logistics
  description text
);

-- Default permission per role (README bagian 8: Role Template)
create table role_permissions (
  role_id       uuid not null references roles(id) on delete cascade,
  permission_id uuid not null references permissions(id) on delete cascade,
  allowed       boolean not null default true,
  primary key (role_id, permission_id)
);

-- Role yang dimiliki tiap user (bisa lebih dari satu jika dibutuhkan)
create table user_roles (
  user_id    uuid not null references profiles(id) on delete cascade,
  role_id    uuid not null references roles(id) on delete cascade,
  organization_id uuid not null references organizations(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, role_id, organization_id)
);

-- Override permission per-user + scope (README bagian 7, 8, 9)
create table user_permissions (
  id              uuid primary key default uuid_generate_v4(),
  user_id         uuid not null references profiles(id) on delete cascade,
  organization_id uuid not null references organizations(id) on delete cascade,
  permission_id   uuid not null references permissions(id) on delete cascade,
  allowed         boolean not null default true,
  scope           permission_scope not null default 'ALL',
  event_id        uuid, -- diisi jika scope = EVENT; FK ditambahkan setelah tabel events dibuat
  created_at      timestamptz not null default now(),
  unique (user_id, permission_id, event_id)
);

-- ---------------------------------------------------------------------
-- 4. CASH ACCOUNT & CATEGORY (README bagian 12)
-- ---------------------------------------------------------------------

create table cash_accounts (
  id               uuid primary key default uuid_generate_v4(),
  organization_id  uuid not null references organizations(id) on delete cascade,
  name             text not null,          -- Kas OSIS, Kas Event, dst
  initial_balance  numeric(14,2) not null default 0,
  current_balance  numeric(14,2) not null default 0,
  is_active        boolean not null default true,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create table categories (
  id              uuid primary key default uuid_generate_v4(),
  organization_id uuid not null references organizations(id) on delete cascade,
  name            text not null,           -- Konsumsi, Perlengkapan, Dekorasi, Lain-lain, Sponsor, dst
  type            category_type not null,
  icon            text,
  color           text,
  is_active       boolean not null default true,
  created_at      timestamptz not null default now()
);

-- ---------------------------------------------------------------------
-- 5. EVENT (README bagian 14)
-- ---------------------------------------------------------------------

create table events (
  id              uuid primary key default uuid_generate_v4(),
  organization_id uuid not null references organizations(id) on delete cascade,
  name            text not null,           -- PORSENI 2026, Class Meeting, Study Tour, dst
  description     text,
  icon            text,                    -- untuk kartu event pada desain
  color           text,
  start_date      date,
  end_date        date,
  budget          numeric(14,2) default 0, -- total anggaran (denormalized, disinkron dari budgets)
  status          event_status not null default 'DRAFT',
  created_by      uuid not null references profiles(id),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index idx_events_org_status on events (organization_id, status);

-- Tambahkan FK user_permissions.event_id sekarang tabel events sudah ada
alter table user_permissions
  add constraint user_permissions_event_id_fkey
  foreign key (event_id) references events(id) on delete cascade;

-- ---------------------------------------------------------------------
-- 6. RAB / BUDGET (README bagian 15, 16)
-- ---------------------------------------------------------------------

create table budgets (
  id          uuid primary key default uuid_generate_v4(),
  event_id    uuid not null references events(id) on delete cascade,
  name        text not null,               -- "RAB PORSENI 2026"
  total       numeric(14,2) not null default 0,
  status      workflow_status not null default 'DRAFT',
  sheets_file_id text,                     -- referensi Google Sheets hasil export
  submitted_by  uuid references profiles(id),
  submitted_at  timestamptz,
  approved_by   uuid references profiles(id),
  approved_at   timestamptz,
  rejection_reason text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create table budget_items (
  id              uuid primary key default uuid_generate_v4(),
  budget_id       uuid not null references budgets(id) on delete cascade,
  category_id     uuid references categories(id),
  description     text not null,           -- Konsumsi, Dekorasi, Hadiah, ATK, dst
  quantity        numeric(10,2) not null default 1,
  unit            text,                    -- pcs, dus, paket, dst
  estimated_price numeric(14,2) not null default 0,
  total           numeric(14,2) generated always as (quantity * estimated_price) stored,
  created_at      timestamptz not null default now()
);

create index idx_budget_items_budget on budget_items (budget_id);

-- ---------------------------------------------------------------------
-- 7. TRANSACTION / LEDGER (README bagian 12, 13)
-- ---------------------------------------------------------------------

create table transactions (
  id                  uuid primary key default uuid_generate_v4(),
  organization_id     uuid not null references organizations(id) on delete cascade,
  event_id            uuid references events(id) on delete set null,
  cash_account_id     uuid not null references cash_accounts(id),
  target_cash_account_id uuid references cash_accounts(id), -- dipakai jika type = transfer
  category_id         uuid references categories(id),
  type                transaction_type not null,
  amount              numeric(14,2) not null check (amount >= 0),
  description         text,
  payment_method      text,               -- Tunai, Transfer, dst (lihat "Detail Transaksi")
  transaction_date    timestamptz not null default now(),
  status              workflow_status not null default 'DRAFT',
  void_reason         text,               -- README bagian 13: histori tetap ada saat VOID
  created_by          uuid not null references profiles(id),
  approved_by         uuid references profiles(id),
  approved_at         timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

create index idx_transactions_event on transactions (event_id, transaction_date desc);
create index idx_transactions_org_date on transactions (organization_id, transaction_date desc);
create index idx_transactions_status on transactions (status);

-- ---------------------------------------------------------------------
-- 8. DOCUMENTS - bukti transaksi (README bagian 3, 17)
-- ---------------------------------------------------------------------

create table documents (
  id             uuid primary key default uuid_generate_v4(),
  transaction_id uuid references transactions(id) on delete cascade,
  event_id       uuid references events(id) on delete cascade,
  drive_file_id  text not null,       -- referensi file di Google Drive
  file_name      text,
  mime_type      text,
  file_size      bigint,
  note           text,                -- "Catatan" pada layar Detail Transaksi
  uploaded_by    uuid not null references profiles(id),
  created_at     timestamptz not null default now()
);

create index idx_documents_transaction on documents (transaction_id);

-- ---------------------------------------------------------------------
-- 9. LOGISTICS (README bagian 20, 21)
-- ---------------------------------------------------------------------

create table logistics_items (
  id          uuid primary key default uuid_generate_v4(),
  event_id    uuid not null references events(id) on delete cascade,
  name        text not null,          -- Air Mineral, Banner, Konsumsi Panitia, dst
  description text,
  quantity    numeric(10,2) not null default 1,
  unit        text,                   -- Dus, Buah, Pack, Set, Paket
  status      logistics_status not null default 'PENDING',
  created_by  uuid not null references profiles(id),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index idx_logistics_items_event on logistics_items (event_id, status);

create table logistics_documents (
  id                 uuid primary key default uuid_generate_v4(),
  logistics_item_id  uuid not null references logistics_items(id) on delete cascade,
  document_type      logistics_document_type not null,
  drive_file_id      text not null,
  file_name          text,
  note               text,            -- "Barang diterima dalam kondisi baik."
  uploaded_by        uuid not null references profiles(id),
  created_at         timestamptz not null default now()
);

create index idx_logistics_documents_item on logistics_documents (logistics_item_id);

-- ---------------------------------------------------------------------
-- 10. APPROVAL (menu "Persetujuan" pada desain, README bagian 13 & 15)
-- ---------------------------------------------------------------------

create table approval_requests (
  id              uuid primary key default uuid_generate_v4(),
  organization_id uuid not null references organizations(id) on delete cascade,
  entity_type     approval_entity not null,   -- transaction | budget | logistics_item | event
  entity_id       uuid not null,
  event_id        uuid references events(id) on delete cascade,
  requested_by    uuid not null references profiles(id),
  approver_id     uuid references profiles(id),
  status          approval_status not null default 'PENDING',
  notes           text,
  requested_at    timestamptz not null default now(),
  decided_at      timestamptz
);

create index idx_approval_requests_pending
  on approval_requests (organization_id, status)
  where status = 'PENDING';

-- ---------------------------------------------------------------------
-- 11. NOTIFICATIONS & ACTIVITY (bell icon + "Aktivitas Terbaru" + "Pengingat")
-- ---------------------------------------------------------------------

create table notifications (
  id              uuid primary key default uuid_generate_v4(),
  organization_id uuid not null references organizations(id) on delete cascade,
  user_id         uuid references profiles(id) on delete cascade, -- null = broadcast org
  title           text not null,
  body            text,
  type            text not null default 'info', -- info | reminder | approval | activity
  related_table   text,
  related_id      uuid,
  is_read         boolean not null default false,
  created_at      timestamptz not null default now()
);

create index idx_notifications_user_unread
  on notifications (user_id, is_read, created_at desc);

-- ---------------------------------------------------------------------
-- 12. AUDIT LOG (README bagian 25)
-- ---------------------------------------------------------------------

create table audit_logs (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid references profiles(id),
  action      text not null,      -- CREATE, UPDATE, DELETE, APPROVE, REJECT, VOID, RESTORE
  table_name  text not null,
  record_id   uuid,
  old_data    jsonb,
  new_data    jsonb,
  created_at  timestamptz not null default now()
);

create index idx_audit_logs_table_record on audit_logs (table_name, record_id);
create index idx_audit_logs_user on audit_logs (user_id, created_at desc);

-- =====================================================================
-- 13. FUNCTIONS & TRIGGERS
-- =====================================================================

-- 13.1 updated_at otomatis
create or replace function fn_set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_updated_at_organizations before update on organizations
  for each row execute function fn_set_updated_at();
create trigger trg_updated_at_profiles before update on profiles
  for each row execute function fn_set_updated_at();
create trigger trg_updated_at_cash_accounts before update on cash_accounts
  for each row execute function fn_set_updated_at();
create trigger trg_updated_at_events before update on events
  for each row execute function fn_set_updated_at();
create trigger trg_updated_at_budgets before update on budgets
  for each row execute function fn_set_updated_at();
create trigger trg_updated_at_transactions before update on transactions
  for each row execute function fn_set_updated_at();
create trigger trg_updated_at_logistics_items before update on logistics_items
  for each row execute function fn_set_updated_at();

-- 13.2 Audit log generik
create or replace function fn_audit_log()
returns trigger as $$
declare
  v_user uuid := auth.uid();
begin
  if (tg_op = 'INSERT') then
    insert into audit_logs(user_id, action, table_name, record_id, new_data)
    values (v_user, 'CREATE', tg_table_name, new.id, to_jsonb(new));
    return new;
  elsif (tg_op = 'UPDATE') then
    insert into audit_logs(user_id, action, table_name, record_id, old_data, new_data)
    values (v_user, 'UPDATE', tg_table_name, new.id, to_jsonb(old), to_jsonb(new));
    return new;
  elsif (tg_op = 'DELETE') then
    insert into audit_logs(user_id, action, table_name, record_id, old_data)
    values (v_user, 'DELETE', tg_table_name, old.id, to_jsonb(old));
    return old;
  end if;
  return null;
end;
$$ language plpgsql security definer;

create trigger trg_audit_transactions
  after insert or update or delete on transactions
  for each row execute function fn_audit_log();
create trigger trg_audit_budgets
  after insert or update or delete on budgets
  for each row execute function fn_audit_log();
create trigger trg_audit_events
  after insert or update or delete on events
  for each row execute function fn_audit_log();
create trigger trg_audit_user_permissions
  after insert or update or delete on user_permissions
  for each row execute function fn_audit_log();
create trigger trg_audit_user_roles
  after insert or update or delete on user_roles
  for each row execute function fn_audit_log();

-- 13.3 Update saldo kas otomatis saat transaksi COMPLETED / dibatalkan
create or replace function fn_apply_cash_balance()
returns trigger as $$
declare
  v_delta numeric(14,2);
begin
  -- Terapkan efek saldo saat transaksi baru langsung berstatus COMPLETED,
  -- atau saat status berubah MENJADI COMPLETED.
  if (tg_op = 'INSERT' and new.status = 'COMPLETED')
     or (tg_op = 'UPDATE' and old.status <> 'COMPLETED' and new.status = 'COMPLETED') then

    if new.type = 'income' then
      update cash_accounts set current_balance = current_balance + new.amount
        where id = new.cash_account_id;
    elsif new.type = 'expense' then
      update cash_accounts set current_balance = current_balance - new.amount
        where id = new.cash_account_id;
    elsif new.type = 'transfer' then
      update cash_accounts set current_balance = current_balance - new.amount
        where id = new.cash_account_id;
      update cash_accounts set current_balance = current_balance + new.amount
        where id = new.target_cash_account_id;
    elsif new.type = 'adjustment' then
      update cash_accounts set current_balance = current_balance + new.amount
        where id = new.cash_account_id;
    end if;

  -- Balikkan efek saldo saat transaksi COMPLETED dibatalkan (VOID/REJECTED)
  elsif (tg_op = 'UPDATE' and old.status = 'COMPLETED'
         and new.status in ('VOID', 'REJECTED')) then

    if new.type = 'income' then
      update cash_accounts set current_balance = current_balance - new.amount
        where id = new.cash_account_id;
    elsif new.type = 'expense' then
      update cash_accounts set current_balance = current_balance + new.amount
        where id = new.cash_account_id;
    elsif new.type = 'transfer' then
      update cash_accounts set current_balance = current_balance + new.amount
        where id = new.cash_account_id;
      update cash_accounts set current_balance = current_balance - new.amount
        where id = new.target_cash_account_id;
    elsif new.type = 'adjustment' then
      update cash_accounts set current_balance = current_balance - new.amount
        where id = new.cash_account_id;
    end if;
  end if;

  return new;
end;
$$ language plpgsql;

create trigger trg_transactions_balance
  after insert or update on transactions
  for each row execute function fn_apply_cash_balance();

-- 13.4 Helper: cek permission user (default role + override), README bagian 7-9
create or replace function fn_has_permission(
  p_user_id uuid,
  p_permission_key text,
  p_organization_id uuid,
  p_event_id uuid default null
) returns boolean as $$
declare
  v_override boolean;
  v_default  boolean;
begin
  -- 1. Cek override langsung di user_permissions (menang atas role default)
  select up.allowed into v_override
  from user_permissions up
  join permissions p on p.id = up.permission_id
  where up.user_id = p_user_id
    and up.organization_id = p_organization_id
    and p.key = p_permission_key
    and (
      up.scope = 'ALL'
      or (up.scope = 'EVENT' and up.event_id = p_event_id)
    )
  order by (up.scope = 'EVENT') desc -- override event lebih spesifik menang
  limit 1;

  if v_override is not null then
    return v_override;
  end if;

  -- 2. Fallback ke permission default dari role
  select bool_or(rp.allowed) into v_default
  from user_roles ur
  join role_permissions rp on rp.role_id = ur.role_id
  join permissions p on p.id = rp.permission_id
  where ur.user_id = p_user_id
    and ur.organization_id = p_organization_id
    and p.key = p_permission_key;

  return coalesce(v_default, false);
end;
$$ language plpgsql stable security definer;

-- =====================================================================
-- 14. ROW LEVEL SECURITY (README bagian 10)
-- =====================================================================

alter table organizations enable row level security;
alter table profiles enable row level security;
alter table organization_members enable row level security;
alter table user_roles enable row level security;
alter table user_permissions enable row level security;
alter table cash_accounts enable row level security;
alter table categories enable row level security;
alter table events enable row level security;
alter table budgets enable row level security;
alter table budget_items enable row level security;
alter table transactions enable row level security;
alter table documents enable row level security;
alter table logistics_items enable row level security;
alter table logistics_documents enable row level security;
alter table approval_requests enable row level security;
alter table notifications enable row level security;
alter table audit_logs enable row level security;

-- Anggota organisasi hanya bisa melihat data organisasinya sendiri
create policy p_org_members_select on organization_members
  for select using (
    exists (
      select 1 from organization_members m
      where m.organization_id = organization_members.organization_id
        and m.user_id = auth.uid()
    )
  );

-- Contoh policy: lihat transaksi hanya jika:
--  - user anggota organization tersebut, DAN
--  - punya permission transaction.view (ALL atau EVENT sesuai event_id transaksi)
create policy p_transactions_select on transactions
  for select using (
    exists (
      select 1 from organization_members m
      where m.organization_id = transactions.organization_id
        and m.user_id = auth.uid()
    )
    and fn_has_permission(auth.uid(), 'transaction.view', organization_id, event_id)
  );

create policy p_transactions_insert on transactions
  for insert with check (
    fn_has_permission(auth.uid(), 'transaction.create', organization_id, event_id)
  );

create policy p_transactions_update on transactions
  for update using (
    fn_has_permission(auth.uid(), 'transaction.update', organization_id, event_id)
    -- scope OWN: hanya boleh edit transaksi yang ia buat sendiri
    or (created_by = auth.uid())
  );

create policy p_transactions_delete on transactions
  for delete using (
    fn_has_permission(auth.uid(), 'transaction.delete', organization_id, event_id)
  );

-- Pola yang sama diterapkan pada budgets/budget_items (rab.*),
-- events (event.*), logistics_items (logistics.*), documents (document.*),
-- dengan mengganti permission key sesuai README bagian 6.
-- Contoh untuk events:
create policy p_events_select on events
  for select using (
    exists (
      select 1 from organization_members m
      where m.organization_id = events.organization_id
        and m.user_id = auth.uid()
    )
  );

create policy p_events_modify on events
  for all using (
    fn_has_permission(auth.uid(), 'event.update', organization_id, id)
  ) with check (
    fn_has_permission(auth.uid(), 'event.update', organization_id, id)
  );

-- Notifikasi: user hanya boleh melihat notifikasi miliknya atau broadcast org
create policy p_notifications_select on notifications
  for select using (
    user_id = auth.uid()
    or (
      user_id is null
      and exists (
        select 1 from organization_members m
        where m.organization_id = notifications.organization_id
          and m.user_id = auth.uid()
      )
    )
  );

-- =====================================================================
-- 15. VIEWS - untuk kebutuhan Dashboard & UI (menyesuaikan desain)
-- =====================================================================

-- 15.1 Ringkasan dashboard: Saldo Kas, Pemasukan, Pengeluaran, Event Aktif
create view v_dashboard_summary as
select
  ca.organization_id,
  sum(ca.current_balance) as total_saldo_kas,
  coalesce((
    select sum(amount) from transactions t
    where t.organization_id = ca.organization_id
      and t.type = 'income' and t.status = 'COMPLETED'
  ), 0) as total_pemasukan,
  coalesce((
    select sum(amount) from transactions t
    where t.organization_id = ca.organization_id
      and t.type = 'expense' and t.status = 'COMPLETED'
  ), 0) as total_pengeluaran,
  (
    select count(*) from events e
    where e.organization_id = ca.organization_id and e.status = 'ACTIVE'
  ) as event_aktif
from cash_accounts ca
group by ca.organization_id;

-- 15.2 Ringkasan arus kas harian (grafik "Ringkasan Arus Kas")
create view v_cash_flow_daily as
select
  organization_id,
  date_trunc('day', transaction_date)::date as tanggal,
  sum(amount) filter (where type = 'income') as pemasukan,
  sum(amount) filter (where type = 'expense') as pengeluaran
from transactions
where status = 'COMPLETED'
group by organization_id, date_trunc('day', transaction_date)::date;

-- 15.3 Ringkasan per event (kartu Event: budget, realisasi, %)
create view v_event_summary as
select
  e.id as event_id,
  e.organization_id,
  e.name,
  e.status,
  e.start_date,
  e.end_date,
  coalesce(b.total, e.budget, 0) as total_budget,
  coalesce((
    select sum(t.amount) from transactions t
    where t.event_id = e.id and t.type = 'expense' and t.status = 'COMPLETED'
  ), 0) as realisasi,
  coalesce((
    select sum(t.amount) from transactions t
    where t.event_id = e.id and t.type = 'income' and t.status = 'COMPLETED'
  ), 0) as pemasukan,
  case when coalesce(b.total, e.budget, 0) > 0 then
    round(
      coalesce((
        select sum(t.amount) from transactions t
        where t.event_id = e.id and t.type = 'expense' and t.status = 'COMPLETED'
      ), 0) / coalesce(b.total, e.budget, 0) * 100, 1
    )
  else 0 end as persentase_realisasi
from events e
left join budgets b on b.event_id = e.id and b.status = 'APPROVED';

-- 15.4 Rincian RAB per kategori (layar "RAB - Rincian")
create view v_budget_category_breakdown as
select
  bi.budget_id,
  b.event_id,
  c.id as category_id,
  c.name as category_name,
  sum(bi.total) as anggaran_kategori,
  coalesce((
    select sum(t.amount) from transactions t
    where t.event_id = b.event_id
      and t.category_id = c.id
      and t.type = 'expense'
      and t.status = 'COMPLETED'
  ), 0) as realisasi_kategori
from budget_items bi
join budgets b on b.id = bi.budget_id
left join categories c on c.id = bi.category_id
group by bi.budget_id, b.event_id, c.id, c.name;

-- 15.5 Jumlah persetujuan pending per user (badge menu "Persetujuan")
create view v_pending_approvals_count as
select approver_id as user_id, organization_id, count(*) as pending_count
from approval_requests
where status = 'PENDING'
group by approver_id, organization_id;

-- =====================================================================
-- 16. SEED DATA (opsional - contoh sesuai README & desain)
-- =====================================================================

insert into roles (name, description, is_system) values
  ('Superadmin', 'Kewenangan tertinggi, mengelola seluruh sistem', true),
  ('Admin', 'Administrasi umum', true),
  ('Pembina', 'Monitoring dan approval, tanpa hak edit langsung', true),
  ('Ketua OSIS', 'Monitoring dan approval kegiatan', true),
  ('Bendahara', 'Mengelola transaksi keuangan, event, dan RAB', true),
  ('Logistik', 'Mendokumentasikan barang, tanpa akses data keuangan sensitif', true),
  ('Sekretaris', 'Administrasi dokumen dan kegiatan', true),
  ('Anggota', 'Akses terbatas sesuai penugasan', true),
  ('Viewer', 'Hanya dapat melihat data', true);

insert into permissions (key, name, module) values
  ('dashboard.view', 'Lihat Dashboard', 'dashboard'),
  ('user.view', 'Lihat User', 'user'),
  ('user.create', 'Tambah User', 'user'),
  ('user.update', 'Edit User', 'user'),
  ('user.delete', 'Hapus User', 'user'),
  ('user.permission', 'Kelola Permission User', 'user'),
  ('transaction.view', 'Lihat Transaksi', 'transaction'),
  ('transaction.create', 'Tambah Transaksi', 'transaction'),
  ('transaction.update', 'Edit Transaksi', 'transaction'),
  ('transaction.delete', 'Hapus Transaksi', 'transaction'),
  ('transaction.approve', 'Approve Transaksi', 'transaction'),
  ('event.view', 'Lihat Event', 'event'),
  ('event.create', 'Tambah Event', 'event'),
  ('event.update', 'Edit Event', 'event'),
  ('event.delete', 'Hapus Event', 'event'),
  ('event.approve', 'Approve Event', 'event'),
  ('rab.view', 'Lihat RAB', 'rab'),
  ('rab.create', 'Tambah RAB', 'rab'),
  ('rab.update', 'Edit RAB', 'rab'),
  ('rab.delete', 'Hapus RAB', 'rab'),
  ('rab.submit', 'Submit RAB', 'rab'),
  ('rab.approve', 'Approve RAB', 'rab'),
  ('document.view', 'Lihat Dokumen', 'document'),
  ('document.upload', 'Upload Dokumen', 'document'),
  ('document.delete', 'Hapus Dokumen', 'document'),
  ('report.view', 'Lihat Laporan', 'report'),
  ('report.export', 'Export Laporan', 'report'),
  ('report.print', 'Cetak Laporan', 'report'),
  ('backup.create', 'Buat Backup', 'backup'),
  ('backup.restore', 'Restore Backup', 'backup'),
  ('backup.view', 'Lihat Backup', 'backup'),
  ('logistics.view', 'Lihat Logistik', 'logistics'),
  ('logistics.upload', 'Upload Dokumentasi Logistik', 'logistics'),
  ('logistics.update', 'Update Status Logistik', 'logistics');

-- Role template default untuk Bendahara (README bagian 8)
insert into role_permissions (role_id, permission_id, allowed)
select r.id, p.id, true
from roles r, permissions p
where r.name = 'Bendahara'
  and p.key in (
    'dashboard.view',
    'transaction.view', 'transaction.create', 'transaction.update',
    'document.upload',
    'event.view', 'event.create', 'event.update',
    'rab.view', 'rab.create', 'rab.update', 'rab.submit',
    'report.view', 'report.export'
  );

insert into role_permissions (role_id, permission_id, allowed)
select r.id, p.id, false
from roles r, permissions p
where r.name = 'Bendahara' and p.key = 'transaction.delete';

-- Contoh kategori sesuai desain
-- (jalankan setelah organizations terisi, ganti :org_id sesuai kebutuhan)
-- insert into categories (organization_id, name, type) values
--   (:org_id, 'Konsumsi', 'expense'),
--   (:org_id, 'Perlengkapan', 'expense'),
--   (:org_id, 'Dekorasi', 'expense'),
--   (:org_id, 'Lain-lain', 'expense'),
--   (:org_id, 'ATK', 'expense'),
--   (:org_id, 'Sewa Peralatan', 'expense'),
--   (:org_id, 'Dana Sekolah', 'income'),
--   (:org_id, 'Dana Sponsor', 'income'),
--   (:org_id, 'Dana Kelas', 'income');

-- =====================================================================
-- SELESAI
-- =====================================================================
-- Catatan implementasi lanjutan:
--   - Tambahkan policy RLS serupa (select/insert/update/delete) untuk
--     budgets, budget_items, logistics_items, logistics_documents, documents
--     dengan pola yang sama seperti transactions/events di atas.
--   - fn_has_permission dapat diperluas untuk scope 'OWN' secara generik
--     bila diperlukan lintas tabel.
--   - Backup JSON (README bagian 19) sebaiknya dijalankan lewat Supabase
--     Edge Function terjadwal yang men-generate JSON dari tabel-tabel di
--     atas lalu mengunggahnya ke Google Drive - bukan lewat query langsung
--     dari Flutter.
-- =====================================================================
