# PLAN.md — Banana POS (Flutter Android Offline-First)

## 1. Spec & Objective
- **Problem**: Build a 100% offline-first, single-user point-of-sale Android app for selling bananas by weight (per kilo) at market stalls, with strict integer-only arithmetic, transaction safety, and parent capital recovery tracking.
- **Hypothesis**: Replacing floating-point math with exact integer grams and centavos, coupled with an immutable snapshot ledger, will eliminate calculation discrepancies, preserve historical margins, and streamline daily payouts.
- **Invariants & Constraints**:
  - Offline-first: zero network permissions in `AndroidManifest.xml`, no analytics, no HTTP clients.
  - Money & Weight: strictly integer centavos and integer grams. `double`/`float` are banned.
  - Snapshots: sale items and spoilage snapshot price and capital at transaction time.
  - Day locks: locked payout days cannot be edited or voided without explicit "Reopen Day".
  - Mechanical gate: every phase must pass `.agents/team/diff-scan.ps1` (0 lint warnings, clean format, all tests passing).

---

## 2. Phased Execution Roadmap

### Phase 1 — Project Foundation, Domain Math & Offline Drift Database [COMPLETED - GREEN]
- **Phase Goal**: Establish pure Dart domain logic with 100% unit tests, zero-double money/weight arithmetic, and transactional SQLite database.
- **Reviewer Checkpoint 1**: Ready for Code Review.

#### T1.1: Project Scaffolding & Android Setup [DONE]
- **Files**: `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, `lib/main.dart`
- **Write Surface**: Project initialization files.
- **Gate**: Flutter Android project compiles, internet permission absent, portrait orientation locked. Passed.

#### T1.2: Domain Money & Weight Models with Pure Arithmetic [DONE]
- **Files**: `lib/domain/models/weight.dart`, `lib/domain/models/money.dart`, `lib/domain/utils/formatters.dart`, `lib/domain/services/pricing_calculator.dart`, `test/domain/weight_test.dart`, `test/domain/money_test.dart`, `test/domain/pricing_calculator_test.dart`
- **Write Surface**: `lib/domain/**`, `test/domain/**`
- **Test**:
  - `1300 g @ P25.00/kg = 3250 centavos`
  - Rejection of 0g, boundary 999g, large kg values.
  - Half-up centavo rounding (e.g. `1301 g @ P25.99/kg`).
  - Largest-remainder discount allocation across 1, 2, 3, and 7 lines.
  - Peso round up / round down.
- **Gate**: Pure Dart (no Flutter imports), all 22 domain tests green. Passed.

#### T1.3: Data Layer: Drift SQLite Schema & Transactions [DONE]
- **Files**: `lib/data/database/app_database.dart`, `lib/data/database/tables.dart`, `test/data/database_test.dart`
- **Write Surface**: `lib/data/**`, `test/data/**`
- **Test**:
  - Schema creation for all 8 tables (`products`, `capital_history`, `sales`, `sale_items`, `expenses`, `restock_purchases`, `payouts`, `settings`).
  - Starter seed for initial 6 banana products.
  - Multi-row transactional write rollback test.
- **Gate**: Code generated via build_runner, migrations pass, database tests green. Passed.

---

### Phase 2 — Product Catalog, Pricing & Capital History [COMPLETED - GREEN]
- **Phase Goal**: Full CRUD for active products, soft-archiving, drag reordering, and immutable capital history logging.
- **Reviewer Checkpoint 2**: Ready for Code Review.

#### T2.1: Product Repository & State Management [DONE]
- **Files**: `lib/data/repositories/product_repository.dart`, `lib/presentation/providers/product_providers.dart`
- **Write Surface**: Product data layer and providers.
- **Gate**: Repository unit tests pass; active/archived separation verified; duplicate name detection verified; immutable capital history verified. Passed.

#### T2.2: Product Management UI & Capital History Viewer [DONE]
- **Files**: `lib/presentation/screens/products/products_screen.dart`, `lib/presentation/screens/products/product_form_dialog.dart`, `lib/presentation/screens/products/capital_history_sheet.dart`
- **Write Surface**: Products presentation screens.
- **Gate**: Add/Edit/Archive works; capital changes write to `capital_history`; past sales unaffected; reordering works; confirmation dialogs implemented. Passed.

---

### Phase 3 — POS Grid, Weighing Input, Cart & Atomic Checkout [COMPLETED - GREEN]
- **Phase Goal**: Fast one-handed stall checkout, live weight parsing, persistent draft cart, and atomic transaction completion.
- **Reviewer Checkpoint 3**: Ready for Code Review.

#### T3.1: POS Product Grid & Weighing Modal [DONE]
- **Files**: `lib/presentation/screens/pos/pos_screen.dart`, `lib/presentation/screens/pos/weighing_bottom_sheet.dart`
- **Write Surface**: POS grid and weighing entry.
- **Gate**: Tap opens bottom sheet; kg/g inputs validate integer bounds; live line total renders accurately; quick-weight shortcut chips (+0.5kg, +1.0kg, +2.0kg) allow rapid 1-tap entry. Passed.

#### T3.2: Persistent Cart & Local Draft Recovery [DONE]
- **Files**: `lib/presentation/providers/cart_provider.dart`, `lib/presentation/screens/pos/cart_sheet.dart`
- **Write Surface**: Cart state and UI.
- **Gate**: Draft cart persists across app backgrounding / restarts; round up/down whole peso buttons adjust amount to charge; largest-remainder discount allocation displayed. Passed.

#### T3.3: Checkout Payment, Cash Shortcuts & Atomic Sale Transaction [DONE]
- **Files**: `lib/presentation/screens/pos/cart_sheet.dart`, `lib/presentation/screens/pos/receipt_dialog.dart`, `lib/data/repositories/sale_repository.dart`
- **Write Surface**: Checkout flow and sale repository.
- **Gate**: Quick cash buttons (50, 100, 200, 500, 1000, exact) compute live change; disabled when paid < charged; atomic insert of sale + items snapshots in single transaction; clean receipt summary. Passed.

---

### Phase 4 — Sales History, Audit Trail & Payout Lock Safeguards [DONE]
- **Phase Goal**: Historical traceability, voiding safety, day-grouping, and preventing edits to locked days.
- **Reviewer Checkpoint 4**: User reviews sales history, void flags, and locked payout restrictions.

#### T4.1: Sales History Screen & Line Breakdown [DONE]
- **Files**: `lib/presentation/screens/sales/sales_history_screen.dart`, `lib/presentation/screens/sales/sale_detail_sheet.dart`
- **Write Surface**: Sales presentation screens.
- **Gate**: Sales grouped by day; profit computed from snapshotted capital. Passed.

#### T4.2: Safe Void & Day-Lock Enforcement [DONE]
- **Files**: `lib/data/repositories/sale_repository.dart`, `lib/presentation/screens/sales/void_confirmation_dialog.dart`
- **Write Surface**: Void logic and safeguards.
- **Gate**: Void sets `voided=1` with confirmation; excluded from all totals; blocked if day payout is locked unless reopened. Passed.

---

### Phase 5 — Losses, Daily Summary, Payout Engine & Parents' Balance [DONE]
- **Phase Goal**: Spoilage accounting, daily financial settlement, parent capital repayment, and reserve shortfall tracking.
- **Reviewer Checkpoint 5**: User reviews payout math edge cases, spoilage deduction, and parents' running balance.

#### T5.1: Expenses & Spoilage Tracking [DONE]
- **Files**: `lib/presentation/screens/expenses/expenses_screen.dart`, `lib/presentation/screens/expenses/add_expense_dialog.dart`, `lib/data/repositories/expense_repository.dart`
- **Write Surface**: Expenses data and UI.
- **Gate**: Transport/other/spoilage entries; spoilage snapshots capital per kg and weight in grams. Passed.

#### T5.2: Daily Summary & Payout Engine [DONE]
- **Files**: `lib/domain/services/payout_calculator.dart`, `lib/presentation/screens/summary/daily_summary_screen.dart`, `lib/presentation/screens/summary/payout_section.dart`
- **Write Surface**: Payout calculation and UI.
- **Gate**: All 8 formula steps verified; spoilage subtracted once; salary capping respected; shortfall highlighted in red; mark as paid out locks day. Passed.

#### T5.3: Parents' Balance Ledger [DONE]
- **Files**: `lib/presentation/screens/parents/parents_balance_screen.dart`, `lib/data/repositories/restock_repository.dart`
- **Write Surface**: Parents balance screen and repository.
- **Gate**: Restock spend vs returned balance computed accurately. Passed.

---

### Phase 6 — Settings, Complete Database Backup/Restore & Final Polish [DONE]
- **Phase Goal**: System configuration, disaster recovery, weekly nudge, and outdoor readability.
- **Reviewer Checkpoint 6**: Final sign-off against full spec checklist.

#### T6.1: Settings Management [DONE]
- **Files**: `lib/presentation/screens/settings/settings_screen.dart`
- **Write Surface**: Settings screen and preferences.
- **Gate**: Salary mode toggle (percent basis points vs fixed daily centavos). Passed.

#### T6.2: Offline JSON Backup & Restore Engine [DONE]
- **Files**: `lib/data/services/backup_service.dart`, `lib/presentation/screens/settings/backup_view.dart`, `test/data/backup_service_test.dart`
- **Write Surface**: Backup service and test.
- **Gate**: Export serializes all 8 tables with `schema_version`; import restores identically with overwrite confirmation. Passed.

#### T6.3: UI Ergonomics, Accessibility & Spec Compliance Audit [DONE]
- **Files**: Entire application review against `spec.md` Section 10 checklist.
- **Gate**: `diff-scan.ps1` green; 0 floating point usage; zero network dependencies. Passed.

---

## 3. Edge Cases & Safety
1. **Fractional Centavo Rounding**: Round half-up applied strictly once per line.
2. **Discount Allocation**: Largest-remainder distribution guarantees sum of line discounts equals total discount with zero lost centavos.
3. **Loss Day Handling**: When net profit < 0, net profit displayed in red, salary = 0, reserve shortfall prominently flagged.
4. **Offline Isolation**: Complete absence of network libraries and permissions in Android manifest.
