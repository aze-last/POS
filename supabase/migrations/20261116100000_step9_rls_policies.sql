-- Step 9: Row Level Security (RLS) Policies & Role Grants
--
-- Enables authenticated and anon clients (using the app's publishable key)
-- to read and synchronize stall data while strictly preserving integrity:
-- 1. `sale_edits` remains immutable (INSERT and SELECT only; updates and deletes rejected).
-- 2. Automatically updates `updated_at` timestamps on mutations for reliable delta sync.
-- 3. Grants the minimal necessary permissions to `anon` and `authenticated`.

-- ---------------------------------------------------------------------------
-- 1. Updated-at trigger helper
-- ---------------------------------------------------------------------------

create or replace function public.handle_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Attach triggers to all mutable tables
drop trigger if exists set_products_updated_at on public.products;
create trigger set_products_updated_at
  before update on public.products
  for each row execute function public.handle_updated_at();

drop trigger if exists set_capital_history_updated_at on public.capital_history;
create trigger set_capital_history_updated_at
  before update on public.capital_history
  for each row execute function public.handle_updated_at();

drop trigger if exists set_sales_updated_at on public.sales;
create trigger set_sales_updated_at
  before update on public.sales
  for each row execute function public.handle_updated_at();

drop trigger if exists set_sale_items_updated_at on public.sale_items;
create trigger set_sale_items_updated_at
  before update on public.sale_items
  for each row execute function public.handle_updated_at();

drop trigger if exists set_expenses_updated_at on public.expenses;
create trigger set_expenses_updated_at
  before update on public.expenses
  for each row execute function public.handle_updated_at();

drop trigger if exists set_restock_purchases_updated_at on public.restock_purchases;
create trigger set_restock_purchases_updated_at
  before update on public.restock_purchases
  for each row execute function public.handle_updated_at();

drop trigger if exists set_payouts_updated_at on public.payouts;
create trigger set_payouts_updated_at
  before update on public.payouts
  for each row execute function public.handle_updated_at();

drop trigger if exists set_settings_updated_at on public.settings;
create trigger set_settings_updated_at
  before update on public.settings
  for each row execute function public.handle_updated_at();

-- ---------------------------------------------------------------------------
-- 2. Table Grants to anon & authenticated
-- ---------------------------------------------------------------------------

grant select, insert, update, delete on table
  public.products,
  public.capital_history,
  public.sales,
  public.sale_items,
  public.expenses,
  public.restock_purchases,
  public.payouts,
  public.settings
to anon, authenticated;

-- sale_edits is strictly append-only (SELECT and INSERT only)
grant select, insert on table
  public.sale_edits
to anon, authenticated;

-- ---------------------------------------------------------------------------
-- 3. Row Level Security Policies
-- ---------------------------------------------------------------------------

-- Products
drop policy if exists "Enable read access for all clients" on public.products;
create policy "Enable read access for all clients"
  on public.products for select to anon, authenticated using (true);

drop policy if exists "Enable insert access for all clients" on public.products;
create policy "Enable insert access for all clients"
  on public.products for insert to anon, authenticated with check (true);

drop policy if exists "Enable update access for all clients" on public.products;
create policy "Enable update access for all clients"
  on public.products for update to anon, authenticated using (true) with check (true);

-- Capital History
drop policy if exists "Enable read access for all clients" on public.capital_history;
create policy "Enable read access for all clients"
  on public.capital_history for select to anon, authenticated using (true);

drop policy if exists "Enable insert access for all clients" on public.capital_history;
create policy "Enable insert access for all clients"
  on public.capital_history for insert to anon, authenticated with check (true);

drop policy if exists "Enable update access for all clients" on public.capital_history;
create policy "Enable update access for all clients"
  on public.capital_history for update to anon, authenticated using (true) with check (true);

-- Sales
drop policy if exists "Enable read access for all clients" on public.sales;
create policy "Enable read access for all clients"
  on public.sales for select to anon, authenticated using (true);

drop policy if exists "Enable insert access for all clients" on public.sales;
create policy "Enable insert access for all clients"
  on public.sales for insert to anon, authenticated with check (true);

drop policy if exists "Enable update access for all clients" on public.sales;
create policy "Enable update access for all clients"
  on public.sales for update to anon, authenticated using (true) with check (true);

-- Sale Items
drop policy if exists "Enable read access for all clients" on public.sale_items;
create policy "Enable read access for all clients"
  on public.sale_items for select to anon, authenticated using (true);

drop policy if exists "Enable insert access for all clients" on public.sale_items;
create policy "Enable insert access for all clients"
  on public.sale_items for insert to anon, authenticated with check (true);

drop policy if exists "Enable update access for all clients" on public.sale_items;
create policy "Enable update access for all clients"
  on public.sale_items for update to anon, authenticated using (true) with check (true);

-- Sale Edits (append-only ledger)
drop policy if exists "Enable read access for all clients" on public.sale_edits;
create policy "Enable read access for all clients"
  on public.sale_edits for select to anon, authenticated using (true);

drop policy if exists "Enable insert access for all clients" on public.sale_edits;
create policy "Enable insert access for all clients"
  on public.sale_edits for insert to anon, authenticated with check (true);

-- Expenses
drop policy if exists "Enable read access for all clients" on public.expenses;
create policy "Enable read access for all clients"
  on public.expenses for select to anon, authenticated using (true);

drop policy if exists "Enable insert access for all clients" on public.expenses;
create policy "Enable insert access for all clients"
  on public.expenses for insert to anon, authenticated with check (true);

drop policy if exists "Enable update access for all clients" on public.expenses;
create policy "Enable update access for all clients"
  on public.expenses for update to anon, authenticated using (true) with check (true);

-- Restock Purchases
drop policy if exists "Enable read access for all clients" on public.restock_purchases;
create policy "Enable read access for all clients"
  on public.restock_purchases for select to anon, authenticated using (true);

drop policy if exists "Enable insert access for all clients" on public.restock_purchases;
create policy "Enable insert access for all clients"
  on public.restock_purchases for insert to anon, authenticated with check (true);

drop policy if exists "Enable update access for all clients" on public.restock_purchases;
create policy "Enable update access for all clients"
  on public.restock_purchases for update to anon, authenticated using (true) with check (true);

-- Payouts
drop policy if exists "Enable read access for all clients" on public.payouts;
create policy "Enable read access for all clients"
  on public.payouts for select to anon, authenticated using (true);

drop policy if exists "Enable insert access for all clients" on public.payouts;
create policy "Enable insert access for all clients"
  on public.payouts for insert to anon, authenticated with check (true);

drop policy if exists "Enable update access for all clients" on public.payouts;
create policy "Enable update access for all clients"
  on public.payouts for update to anon, authenticated using (true) with check (true);

-- Settings
drop policy if exists "Enable read access for all clients" on public.settings;
create policy "Enable read access for all clients"
  on public.settings for select to anon, authenticated using (true);

drop policy if exists "Enable insert access for all clients" on public.settings;
create policy "Enable insert access for all clients"
  on public.settings for insert to anon, authenticated with check (true);

drop policy if exists "Enable update access for all clients" on public.settings;
create policy "Enable update access for all clients"
  on public.settings for update to anon, authenticated using (true) with check (true);
