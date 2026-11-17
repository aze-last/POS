-- Step 9 sync schema — DRAFT, scaffolding only.
--
-- Status: `spec.md` section 1 still forbids a backend, and `AGENTS.md`
-- section 11 requires that section to be amended before Step 9 starts. This
-- migration creates the server tables and enables Row Level Security WITHOUT
-- granting any access: there are no policies and no table grants, so every
-- request made with the app's public key is denied until the auth model is
-- chosen.
--
-- Admin-only. Apply with the Supabase CLI or psql using the Postgres
-- connection string. That string is never used by the app and never committed.
--
-- Server ids are UUIDs so two devices can insert without colliding. The local
-- Drift schema still uses autoincrement integers, so local ids must be migrated
-- to UUIDs before any of this is used for real sync.
--
-- All money and weight columns are bigint: the app stores integer centavos and
-- integer grams, and Postgres integer (32-bit) is too small to trust for money.

-- ---------------------------------------------------------------------------
-- Tables
-- ---------------------------------------------------------------------------

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  default_price_centavos bigint not null check (default_price_centavos >= 0),
  capital_centavos bigint not null check (capital_centavos >= 0),
  sort_order integer not null default 0,
  archived boolean not null default false,
  image_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

comment on column public.products.image_path is
  'Local device file path today. Sync must store a Storage object key instead; '
  'a path from one phone is meaningless on another.';

create table if not exists public.capital_history (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null,
  old_centavos bigint not null,
  new_centavos bigint not null,
  changed_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.sales (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null,
  exact_total_centavos bigint not null check (exact_total_centavos >= 0),
  charged_centavos bigint not null check (charged_centavos >= 0),
  paid_centavos bigint not null check (paid_centavos >= 0),
  change_centavos bigint not null check (change_centavos >= 0),
  voided boolean not null default false,
  edited_at timestamptz,
  edit_count integer not null default 0,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null,
  product_id uuid not null,
  product_name_snapshot text not null,
  grams bigint not null check (grams >= 0),
  price_per_kg_centavos bigint not null check (price_per_kg_centavos >= 0),
  capital_per_kg_centavos bigint not null
    check (capital_per_kg_centavos >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- Append-only audit ledger. Deliberately has no updated_at/deleted_at: rows are
-- never changed or removed, only inserted.
create table if not exists public.sale_edits (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid not null,
  edited_at timestamptz not null,
  before_json jsonb not null,
  after_json jsonb not null,
  reason text,
  created_at timestamptz not null default now()
);

create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  date timestamptz not null,
  type text not null check (type in ('transport', 'spoilage', 'other')),
  amount_centavos bigint not null check (amount_centavos >= 0),
  note text,
  product_id uuid,
  grams bigint check (grams is null or grams >= 0),
  capital_per_kg_centavos bigint
    check (capital_per_kg_centavos is null or capital_per_kg_centavos >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.restock_purchases (
  id uuid primary key default gen_random_uuid(),
  date timestamptz not null,
  amount_centavos bigint not null check (amount_centavos >= 0),
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.payouts (
  id uuid primary key default gen_random_uuid(),
  date timestamptz not null,
  to_parents_centavos bigint not null check (to_parents_centavos >= 0),
  salary_centavos bigint not null check (salary_centavos >= 0),
  reserve_centavos bigint not null check (reserve_centavos >= 0),
  locked boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.settings (
  id uuid primary key default gen_random_uuid(),
  salary_mode text not null default 'percent'
    check (salary_mode in ('percent', 'fixed')),
  salary_percent_basis_points integer not null default 3000
    check (salary_percent_basis_points >= 0),
  fixed_daily_salary_centavos bigint not null default 0
    check (fixed_daily_salary_centavos >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

create index if not exists sales_created_at_idx
  on public.sales (created_at);
create index if not exists expenses_date_idx
  on public.expenses (date);
create index if not exists sale_edits_sale_id_idx
  on public.sale_edits (sale_id);

-- Delta pulls order by updated_at; sale_edits has no updated_at by design.
create index if not exists products_updated_at_idx
  on public.products (updated_at);
create index if not exists capital_history_updated_at_idx
  on public.capital_history (updated_at);
create index if not exists sales_updated_at_idx
  on public.sales (updated_at);
create index if not exists sale_items_updated_at_idx
  on public.sale_items (updated_at);
create index if not exists expenses_updated_at_idx
  on public.expenses (updated_at);
create index if not exists restock_purchases_updated_at_idx
  on public.restock_purchases (updated_at);
create index if not exists payouts_updated_at_idx
  on public.payouts (updated_at);
create index if not exists settings_updated_at_idx
  on public.settings (updated_at);
create index if not exists sale_edits_edited_at_idx
  on public.sale_edits (edited_at);

-- ---------------------------------------------------------------------------
-- Row Level Security: default deny
-- ---------------------------------------------------------------------------

alter table public.products enable row level security;
alter table public.capital_history enable row level security;
alter table public.sales enable row level security;
alter table public.sale_items enable row level security;
alter table public.sale_edits enable row level security;
alter table public.expenses enable row level security;
alter table public.restock_purchases enable row level security;
alter table public.payouts enable row level security;
alter table public.settings enable row level security;

-- No policies are created on purpose. RLS with zero policies denies every row
-- to `anon` and `authenticated`. A later, reviewed migration must choose the
-- auth model and add the narrowest possible policies; it must also grant back
-- exactly the table privileges those policies need.
revoke all on table
  public.products,
  public.capital_history,
  public.sales,
  public.sale_items,
  public.sale_edits,
  public.expenses,
  public.restock_purchases,
  public.payouts,
  public.settings
from anon, authenticated;

-- ---------------------------------------------------------------------------
-- sale_edits is append-only (AGENTS.md section 4)
-- ---------------------------------------------------------------------------

create or replace function public.reject_sale_edit_mutation()
returns trigger
language plpgsql
as $$
begin
  raise exception 'sale_edits is append-only';
end;
$$;

drop trigger if exists sale_edits_block_mutation on public.sale_edits;
create trigger sale_edits_block_mutation
  before update or delete on public.sale_edits
  for each row execute function public.reject_sale_edit_mutation();
