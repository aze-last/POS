# SPEC: Banana POS (Flutter, Android, offline)

Baseline for the AI coder and the code reviewer. If code contradicts this file, the code is wrong unless this file is updated first.

## 1. Scope

- Single-user Android app (Flutter/Dart), portrait only, English UI.
- Offline-first. No backend, no login, no analytics. The ONLY allowed network activity is checking for and downloading updates from public GitHub Releases.
- No API keys, tokens, or secrets anywhere in the app or repo. Unauthenticated public requests only. If cloud sync is ever added, the database must sit behind a backend. Never put keys or DB credentials in client code.
- Products are sold BY THE KILO ONLY.
- Starter products: Cardava, Binanggay, Tundan, Sab-a, Mundo, Lube. User can add, edit, archive, and reorder later.
- Used one-handed at a market stall: large touch targets, high contrast, readable in sunlight.
- Out of scope for v1: utang (partial payment), digital scale, photos, multi-user, cloud sync, multi-currency.

## 2. Tech

- Flutter + Dart, Material 3.
- Local SQLite via `drift` (preferred) or `sqflite`.
- State: Riverpod (preferred) or Provider.
- Layers: `data/` (DB, repositories), `domain/` (money, weight, payout logic, pure Dart, no Flutter imports), `ui/`.
- All money and payout math lives in `domain/` and is unit tested.

## 3. Numeric rules (non-negotiable)

- Weight: INTEGER grams. Money: INTEGER centavos. Never `double` for either.
- Weight input is two fields: `kg` and `g`. Valid g: 0-999. Total grams = kg*1000 + g. Reject 0 total grams. Show the parsed value ("1.300 kg") before confirming.
- Line value (centavos) = round_half_up(price_per_kg_centavos * grams / 1000), integer arithmetic only.
  - Example: 1300 g at P25.00/kg (2500 centavos) = 3250 = P32.50.
  - Rounding to the centavo happens ONCE per line. Sale exact total = sum of rounded line values.
- Line capital cost uses the same formula with the snapshotted capital per kg.
- NO auto-rounding to whole pesos. Exact values are shown with decimals (P32.50).
- User types the final "Amount to charge". It is prefilled with the exact total. Two buttons: "Round down" and "Round up" to whole pesos. User decides.
- Charged < exact total = discount. Record it and show it on the receipt.
- Discount allocation across lines: proportional to line value, using the largest-remainder method so the allocated pieces sum EXACTLY to the total discount (no lost centavos). Charged share of a line = line value - allocated discount.
- Format helper: centavos to "P1,234.50". One shared function, used everywhere.

## 4. Data model

```
products(id, name, default_price_centavos, capital_centavos, sort_order, archived)
capital_history(id, product_id, old_centavos, new_centavos, changed_at)
sales(id, created_at, exact_total_centavos, charged_centavos, paid_centavos,
      change_centavos, voided)
sale_items(id, sale_id, product_id, product_name_snapshot, grams,
           price_per_kg_centavos, capital_per_kg_centavos)
expenses(id, date, type, amount_centavos, note, product_id?, grams?,
         capital_per_kg_centavos?)       -- type: transport | spoilage | other
restock_purchases(id, date, amount_centavos, note)
payouts(id, date, to_parents_centavos, salary_centavos, reserve_centavos, locked)
settings(salary_mode, salary_percent_basis_points, fixed_daily_salary_centavos)
```

- Archive products, never hard-delete them (old sales must stay intact).
- Every sale item SNAPSHOTS price and capital at sale time. Past profit is never recomputed from current capital.
- Spoilage expense: amount_centavos = round_half_up(capital_per_kg * grams / 1000), with product_id, grams, and capital snapshot stored.
- Use DB transactions for multi-row writes (sale + items, payout + lock).
- Index on `sales.created_at`, `expenses.date`.

## 5. Screens and behavior

### 5.1 Main (POS)
- Grid of uniform cards, one per active product (name, current price/kg), ordered by sort_order. Plain cards, not bento.
- Tap card opens a bottom sheet: kg field, g field, price/kg field prefilled with product default and editable FOR THIS SALE ONLY (does not change the product), live line value, "Add to cart".
- Persistent cart bar: item count + total. Tap opens the cart.
- Cart: lines (product, kg/g, price/kg, line value) with edit and remove; exact total; editable "Amount to charge" + Round down/up; "Amount paid" field; quick-cash buttons 50, 100, 200, 500, 1000 plus manual typing; live Change = paid - charged.
- "Complete sale" disabled if paid < charged. Empty cart cannot be completed.
- On complete: save in one transaction, show receipt-style summary (exact total, discount, charged, paid, change), clear cart.
- Cart survives app backgrounding (persist draft cart locally).

### 5.2 Products (full CRUD)
- Add, edit, archive, restore, drag-reorder.
- Fields: name (unique among active), default price/kg, capital/kg.
- Capital is shown prominently in the list: "Capital: P__/kg".
- Capital edits write a capital_history row. Per-product history view. Latest = active.
- Confirm before archive.

### 5.3 Sales history
- Grouped by day, expandable to lines. Date filter.
- Per sale: exact total, charged, discount, paid, change, profit.
- Edit or void a sale. Void keeps the record, flags it, excludes it from all totals. Confirm first.
- Editing or voiding a sale on a day whose payout is locked requires "Reopen" first.

### 5.4 Expenses and Losses
- Quick add by type: transport, other (amount + note), spoilage (product + kg/g + optional note).
- List per day, edit/delete with confirmation. Reachable from Daily Summary.

### 5.5 Daily Summary (selected day)
- Total charged, total capital cost, gross profit, number of sales, total discounts, total kg per product.
- Payout section (see section 6).

### 5.6 Parents' Balance
- Running view: total restock spend (restock_purchases), total returned to parents (locked payouts), outstanding balance = restock spend - returned.
- Manual entry for restock purchases.

### 5.7 Settings
- Salary mode (percent | fixed), percent (default 30%, editable, stored as basis points), fixed daily salary.
- Backup export/import entry points.

## 6. Payout logic (per selected day, all integer centavos, voided sales excluded)

```
1. sales          = sum(charged_centavos)
2. capital_sold   = sum(line capital cost of sold items)
3. gross_profit   = sales - capital_sold
4. spoilage       = sum(expenses where type = spoilage)
   other_expenses = sum(expenses where type != spoilage)
5. net_profit     = gross_profit - spoilage - other_expenses     (may be negative; show red)
6. to_parents     = capital_sold + spoilage                       (suggested)
7. salary:
     percent mode: max(0, net_profit) * salary_percent
     fixed mode:   min(fixed_daily_salary, max(0, net_profit)); warn if capped
8. reserve        = sales - to_parents - salary - other_expenses
                    if < 0 show "Shortfall" in red, never hide it
```

- Spoilage is subtracted once (inside to_parents), not twice. Tests must cover this.
- Salary percent math: integer with basis points; round_half_up to the centavo.
- Editable override fields for to_parents and salary. Show difference from the suggestion.
- "Mark as paid out" saves ACTUAL amounts to `payouts` and locks the day. "Reopen" unlocks it.
- The default 30% is a placeholder, not advice. The user tunes it after real data.

## 7. Backup (required)

- Export ALL tables to one JSON file through the Android share sheet. Include a `schema_version`.
- Import/restore from that file with validation. Warn that it replaces current data. Confirm first.
- Reminder nudge to export weekly (in-app banner, no network).
- Local data loss on phone loss or reset is the main risk of this app. Do not remove backup.

## 8. Validation rules

- No negative or empty numeric inputs. No 0 g lines. g in 0-999.
- Price and capital must be > 0.
- Paid and charged are integer centavos. Charged must be > 0.
- Confirm before any delete, void, import, or reopen.
- Number inputs use numeric keyboards.

## 9. Tests (must exist and pass)

- 1300 g @ P25.00 = 3250 centavos. 0 g rejected. 999 g. Large kg values.
- Rounding at fractional centavos (e.g. 1301 g @ P25.99, half-up).
- Round down / round up whole-peso buttons.
- Discount allocation sums exactly to the total discount across 1, 2, 3, and 7 lines.
- Capital snapshot: change capital after a sale, old profit unchanged.
- Payout: normal day, loss day (negative net), spoilage-only day, discount day, fixed salary above net profit, manual override difference, voided sale excluded, locked day edit blocked.
- Backup: export then import round-trips to identical data.

## 10. Reviewer checklist

- [ ] No `double`/`float` for money or weight anywhere.
- [ ] No secrets or API tokens in repo; network calls strictly limited to unauthenticated GitHub Releases update checks and downloads over HTTPS.
- [ ] Single money formatter and single rounding function.
- [ ] Snapshots stored on sale items and spoilage; no profit recomputed from live capital.
- [ ] Voided sales excluded from every total.
- [ ] DB writes that touch multiple rows use transactions.
- [ ] Domain layer has no Flutter imports and has tests.
- [ ] Destructive actions have confirmation.
- [ ] Locked payout days cannot be silently modified.
- [ ] Backup includes every table and a schema version.
- [ ] In-app updates verify SHA-256 checksum and host allowlist before installing.

## 11. Delivery order

1. Project setup, DB, domain money/weight logic + tests.
2. Products screen + capital history.
3. POS + cart + receipt.
4. Sales history + void/edit.
5. Expenses, Daily Summary, Payout, Parents' Balance, Settings.
6. Backup/restore.
7. Update checker, in-app update install, release workflow, and AGENTS.md.

Stop after each step for manual testing. Do not start a step before the previous one passes tests.

## 12. Open assumptions (change here if wrong)

- Cash only. Utang is blocked in v1. [assumption]
- Parents are repaid capital of sold items plus spoilage before salary. [assumption]
- Salary default is 30% of net profit. [placeholder]
- Fully offline, no sync. [assumption]
