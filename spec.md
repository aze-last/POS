# SPEC: Banana POS (Flutter, Android, offline)

Baseline for the AI coder and the code reviewer. If code contradicts this file, the code is wrong unless this file is updated first.

## 1. Scope

- Single-user / paired-device Android app (Flutter/Dart), portrait only, English UI.
- Offline-first. The app functions 100% offline at the market stall. Network activity is strictly limited to:
  1. Checking for and downloading app updates from public GitHub Releases over unauthenticated HTTPS.
  2. Multi-device cloud sync (Step 9) over HTTPS via Supabase REST/Realtime APIs using compile-time public credentials (`--dart-define-from-file=.env` with project URL and `SUPABASE_ANON_KEY`/publishable key).
- Security & Secrets: No secrets, admin tokens, or Postgres connection strings in the repo or client. All Supabase tables enforce Row Level Security (RLS). Secret keys (`sb_secret_`, `service_role`) are strictly prohibited and rejected by `SupabaseConfig`.
- Products are sold BY THE KILO ONLY.
- Starter products: Cardava, Binanggay, Tundan, Sab-a, Mundo, Lube. User can add, edit, archive, and reorder later.
- Used one-handed at a market stall: large touch targets, high contrast, readable in sunlight.
- Out of scope for v1: utang (partial payment), digital scale, multi-currency.

## 2. Tech

- Flutter + Dart, Material 3.
- Local SQLite via `drift` (preferred) or `sqflite`.
- State: Riverpod (preferred) or Provider.
- Layers: `lib/data/` (DB, repositories), `lib/domain/` (money, weight, payout logic, pure Dart, no Flutter imports), `lib/presentation/` (screens, widgets, providers).
- All money and payout math lives in `domain/` and is unit tested.

## 3. Numeric rules (non-negotiable)

- Weight: INTEGER grams. Money: INTEGER centavos. Never `double` for either.
- Weight input: Scale-style single-stream input with large on-screen keypad (0-9, dot, backspace) and quick-addition chips (+0.5kg, +1.0kg, +2.0kg, Clear). Numbers stream directly into exact grams (e.g. `1.35` -> 1,350 g, `1350` -> 1,350 g, `0.5` -> 500 g, `2` -> 2,000 g). Reject 0 total grams or negative weights. Show the parsed value ("1.350 kg (1,350 g)") before confirming.
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
products(id, name, default_price_centavos, capital_centavos, sort_order, archived, image_path?)
capital_history(id, product_id, old_centavos, new_centavos, changed_at)
sales(id, created_at, exact_total_centavos, charged_centavos, paid_centavos,
      change_centavos, voided, edited_at?, edit_count)
sale_items(id, sale_id, product_id, product_name_snapshot, grams,
           price_per_kg_centavos, capital_per_kg_centavos)
sale_edits(id, sale_id, edited_at, before_json, after_json, reason?)
expenses(id, date, type, amount_centavos, note, product_id?, grams?,
         capital_per_kg_centavos?)       -- type: transport | spoilage | other
restock_purchases(id, date, amount_centavos, note)
payouts(id, date, to_parents_centavos, salary_centavos, reserve_centavos, locked)
settings(salary_mode, salary_percent_basis_points, fixed_daily_salary_centavos)
```

- Archive products, never hard-delete them (old sales must stay intact).
- Every sale item SNAPSHOTS price and capital at sale time. Past profit is never recomputed from current capital.
- Sale edits: `sale_edits` is an immutable, append-only audit trail recording `before_json` and `after_json` for header and all lines in integer centavos and grams. No UI path can delete edit history.
- Line unchanged in product on edit KEEPS its original `capital_per_kg_centavos` snapshot. Lines with a changed product or newly added lines snapshot CURRENT catalog capital.
- Spoilage expense: amount_centavos = round_half_up(capital_per_kg * grams / 1000), with product_id, grams, and capital snapshot stored.
- Use DB transactions for multi-row writes (sale + items, sale update + items + sale_edits, payout + lock).
- Index on `sales.created_at`, `expenses.date`, `sale_edits.sale_id`.

## 5. Screens and behavior

### 5.1 Main (POS)
- Grid of uniform cards, one per active product (prominent product photo with eco fallback placeholder, variety name, current price/kg, and capital/kg), ordered by sort_order. Plain cards, not bento.
- Tap card opens a bottom sheet: product photo and variety name header, kg field, g field, price/kg field prefilled with product default and editable FOR THIS SALE ONLY (does not change the product), live line value, "Add to cart".
- Persistent cart bar: item count + total. Tap opens the cart.
- Cart: lines (product, kg/g, price/kg, line value) with edit and remove; exact total; editable "Amount to charge" + Round down/up; "Amount paid" field; quick-cash buttons 50, 100, 200, 500, 1000 plus manual typing; live Change = paid - charged.
- "Complete sale" disabled if paid < charged. Empty cart cannot be completed.
- On complete: save in one transaction, show receipt-style summary (exact total, discount, charged, paid, change), clear cart.
- Cart survives app backgrounding (persist draft cart locally).

### 5.2 Products (full CRUD)
- Add, edit, archive, restore, drag-reorder.
- Fields: name (unique among active), default price/kg, capital/kg, optional product photo (camera capture or gallery pick, compressed and saved to local app documents directory).
- Product photo thumbnail displayed in active catalog and archived lists.
- Capital is shown prominently in the list: "Capital: P__/kg".
- Capital edits write a capital_history row. Per-product history view. Latest = active.
- Confirm before archive.

### 5.3 Sales history
- Grouped by day, expandable to lines. Date filter.
- Per sale: exact total, charged, discount, paid, change, profit.
- In Sales History, every non-voided sale gets an "Edit" action (next to Void).
- Edit opens the same cart/payment UI used for new sales, prefilled with the sale's lines, charged amount, and paid amount. REUSE existing bottom sheet, cart widgets, and domain functions. Do not write a second copy of any money math.
- Editable: add a line, remove a line, change product, kg/g, price per kg on a line, "Amount to charge" (with Round down/Round up), "Amount paid".
- Not editable: original `created_at`, sale id. A sale must keep at least one line (to remove everything, use Void; removing the last line is blocked).
- Cancel/back with unsaved changes prompts "Discard changes?".
- Save button is disabled until something actually changed, and until all validation passes (no 0 g, paid >= charged, charged > 0).
- "Edited" badge shown on edited sales (`edit_count > 0`). Tapping badge or viewing sale details shows edit history with before/after comparison: totals, lines, charged, paid, change, profit.
- Edits can never be deleted from the UI.
- Locked payout days: If the sale's day has a locked payout, Edit is blocked with "This day is paid out. Reopen it first." and a Reopen button (existing confirm flow).
- After a reopened day's sale is edited, Daily Summary shows a warning banner: "Sales changed since this day was paid out. Review the payout before marking it again." with previously saved payout amounts next to new suggested amounts.
- Daily Summary shows a small count: "N sales edited today".
- Voided sales cannot be edited. Void keeps the record, flags it, excludes it from all totals. Confirm first. Editing an edited sale is permitted; voiding an edited sale is permitted.

### 5.4 Expenses and Losses
- Quick add by type: transport, other (amount + note), spoilage (product + kg/g + optional note).
- List per day, edit/delete with confirmation. Reachable from Daily Summary and main navigation.
- **Daily Salary & Expense Tracking**:
  - The Expenses screen displays the day's financial health: target/earned daily salary, total expenses & losses deducted, and net remaining salary available for the day.
  - **Warning on Salary Impact**:
    - Low/Capped Salary Warning: If expenses and spoilage reduce net profit below the fixed daily salary target (or if remaining salary is capped), display an amber warning with the shortfall and remaining salary.
    - Zero Salary Alert: If expenses and losses exceed gross profit (remaining salary is ₱0), display a prominent red alert that no salary is left for the day.
  - **Live Impact Preview on Add Expense**: The Add Expense dialog calculates and previews the impact of the expense on remaining salary in real time, warning the user if the expense will reduce or exhaust their remaining salary for that day.

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

## 7. Backup & In-App Updates

### 7.1 Offline Backup (required)
- Export ALL tables to one JSON file through the Android share sheet. Include a `schema_version` (schema version 3 includes `image_path` on products).
- Import/restore from that file with validation. Warn that it replaces current data. Confirm first.
- Reminder nudge to export weekly (in-app banner, no network).
- Local data loss on phone loss or reset is the main risk of this app. Do not remove backup.

### 7.2 In-App Updates & Releases
- **Scope & Transport**: The ONLY network call allowed in the entire app is unauthenticated HTTPS to public GitHub Releases (`api.github.com/repos/{owner}/{repo}/releases/latest`). No API keys, tokens, or credentials anywhere.
- **Trigger & Cadence**: Auto-check runs on app start throttled to at most once per 24 hours (persisted metadata). Manual "Check for updates" in Settings runs immediately on demand.
- **Version Evaluation**: Compares release tag (`vX.Y.Z`) against installed version using strict semver (`1.0.10 > 1.0.9`). Drafts, pre-releases, malformed tags, and older versions are strictly ignored (no downgrades).
- **Presentation Rule**: Never interrupt an ongoing sale. If the POS cart has items, display a non-blocking dismissible top banner. If the cart is empty, display an update modal dialog showing version comparison and release notes.
- **User Actions**:
  - "Update now": Prompts optional backup export, downloads APK with progress bar, verifies checksum, and launches system installer.
  - "Later": Dismisses the prompt until next check.
  - "Skip this version": Persists the skipped version tag and suppresses auto-check prompts for it.
- **Security & Integrity**:
  - Host allowlist: Only `github.com`, `api.github.com`, `objects.githubusercontent.com`, and `release-assets.githubusercontent.com` over HTTPS. Redirects must be re-checked against the allowlist.
  - Download filename sanitization: Paths must not escape the update cache directory (`p.basename` + `.apk` extension required).
  - Checksum: Every update requires a corresponding `.apk.sha256` asset matching the exact APK filename (`$apkName.sha256`). The SHA-256 hash of the downloaded APK is computed and verified against this checksum. If missing or mismatched, the APK is immediately deleted and install is aborted.
- **Installer & Permission Flow**:
  - Uses Android `FileProvider` (`<cache-path name="updates" path="updates/" />`) and `REQUEST_INSTALL_PACKAGES`.
  - Android 8.0+ checks `canRequestPackageInstalls()`. If missing, deep-links to Android "Install unknown apps" settings; upon returning (`AppLifecycleState.resumed`), re-checks permission before launching install intent.
  - Inform the user that Android will show its own system confirmation dialog.
  - Cached update APKs are cleaned up on app launch.

## 8. Validation rules & Recalculation on Save

- No negative or empty numeric inputs. No 0 g lines. g in 0-999.
- Price and capital must be > 0.
- Paid and charged are integer centavos. Charged must be > 0. `paid >= charged`.
- Confirm before any delete, void, import, or reopen.
- Number inputs use numeric keyboards.
- **Sale Edit Validation**:
  - A sale must retain at least 1 line (removing the last remaining line is blocked; user must use Void instead).
  - Save button is disabled until at least one field/line has changed from the original, and all validation passes.
  - Cancel/back with unsaved changes prompts "Discard changes?".
  - Multi-row write (updating `sales`, deleting/inserting `sale_items`, inserting `sale_edits`) executes strictly in ONE database transaction. If any part fails, nothing changes.
- **Recalculation on Save (Pure Dart Domain Layer, Integer Centavos Only)**:
  - Line value: `round_half_up(price_per_kg * grams / 1000)`.
  - Exact total: sum of all line values.
  - Discount: `exact_total - charged`. Allocated across lines via largest-remainder algorithm (`PricingCalculator.allocateDiscount`).
  - Change: `paid - charged`.
  - Capital snapshots:
    - Line unchanged in product: KEEP its original `capital_per_kg_centavos` snapshot, even if grams or price changed.
    - Line with a changed product, or newly added line: snapshot that product's CURRENT `capital_centavos` from the database.
    - Never recompute old profit from live capital for untouched product lines.
  - Profit: recomputed from the line snapshots after the edit.

## 9. Tests (must exist and pass)

- 1300 g @ P25.00 = 3250 centavos. 0 g rejected. 999 g. Large kg values.
- Rounding at fractional centavos (e.g. 1301 g @ P25.99, half-up).
- Round down / round up whole-peso buttons.
- Discount allocation sums exactly to the total discount across 1, 2, 3, and 7 lines.
- Capital snapshot: change capital after a sale, old profit unchanged.
- Payout: normal day, loss day (negative net), spoilage-only day, discount day, fixed salary above net profit, manual override difference, voided sale excluded, locked day edit blocked.
- Backup: export then import round-trips to identical data.
- **Sale Edit Tests**:
  - Change grams on a line: line value, exact total, discount, change, and profit recompute correctly; capital snapshot unchanged.
  - Change a line's product: new line uses current catalog capital. Add a line: uses current catalog capital.
  - Remove a line: remaining lines recalculate; removing the last line is blocked.
  - Edit with discount: largest-remainder allocation still sums exactly to the discount (1, 2, 3, 7 lines).
  - Capital changed after original sale, then sale edited without touching that line: profit for that untouched line remains unchanged.
  - Edit that makes paid < charged is rejected.
  - Edit blocked on locked day; allowed after Reopen; warning banner shows in Daily Summary with previously saved vs new suggested amounts.
  - Edit then edit again: two `sale_edits` rows chained correctly with chronological `edited_at`.
  - Transaction rollback: simulate a failure mid-save, verify nothing changes.
  - Voided sale cannot be edited. Edited sale can still be voided.
  - Backup round-trip retains `sale_edits` and schema version 2; backward compatibility verified for version 1 backups.

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
- [ ] Edit reuses existing domain money functions, no duplicated math.
- [ ] Every edit writes a sale_edits row in the same transaction.
- [ ] No UI path deletes a sale_edits row.
- [ ] Locked days cannot be edited without Reopen.

## 11. Delivery order

1. Project setup, DB, domain money/weight logic + tests.
2. Products screen + capital history.
3. POS + cart + receipt.
4. Sales history + void/edit.
5. Expenses, Daily Summary, Payout, Parents' Balance, Settings.
6. Backup/restore.
7. Update checker, in-app update install, release workflow, and AGENTS.md.
8. Edit sale from Sales History with audit trail (`sale_edits`), capital snapshot preservation, locked day guard/banner, backup v2, and tests.
9. Multi-device Supabase sync.

Stop after each step for manual testing. Do not start a step before the previous one passes tests.

## 12. Open assumptions (change here if wrong)

- Cash only. Utang is blocked in v1. [assumption]
- Parents are repaid capital of sold items plus spoilage before salary. [assumption]
- Salary default is 30% of net profit. [placeholder]
- Multi-device sync: offline-first with Supabase cloud sync (Step 9).
