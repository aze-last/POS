# PLAN.md — Banana POS (Flutter Android Offline-First)

## 1. Spec & Objective
- **Problem**: Build a 100% offline-first, single-user point-of-sale Android app for selling bananas by weight (per kilo) at market stalls, with strict integer-only arithmetic, transaction safety, and parent capital recovery tracking.
- **Hypothesis**: Replacing floating-point math with exact integer grams and centavos, coupled with an immutable snapshot ledger, will eliminate calculation discrepancies, preserve historical margins, and streamline daily payouts.
- **Invariants & Constraints**:
  - Offline-first: network calls strictly limited to unauthenticated GitHub Releases update checks and downloads over HTTPS. Zero analytics, zero telemetry, zero tokens/secrets.
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
- **Gate**: `diff-scan.ps1` green; 0 floating point usage; network calls limited strictly to GitHub Releases updates. Passed.

---

### Phase 7 — Update Checker, In-App Update Install & Release Workflow [DONE]
- **Phase Goal**: Provide secure, unauthenticated in-app update checks and APK installation from public GitHub Releases, signed release automation, and AGENTS.md documentation.
- **Reviewer Checkpoint 7**: Ready for Code Review.

#### T7.1: Semantic Versioning & Update Service Engine [DONE]
- **Files**: `lib/domain/models/app_version.dart`, `lib/data/services/update_service.dart`, `test/domain/app_version_test.dart`, `test/data/update_service_test.dart`
- **Write Surface**: Update domain and data services.
- **Gate**: Semver compare unit tests; HTTP mock tests for parsing, allowlist, 24h throttling, and SHA-256 verification. Passed.

#### T7.2: In-App Installer & Android Platform Channel [DONE]
- **Files**: `lib/data/services/app_installer.dart`, `android/app/src/main/kotlin/com/banana/pos/MainActivity.kt`, `android/app/src/main/AndroidManifest.xml`, `android/app/src/main/res/xml/filepaths.xml`
- **Write Surface**: Platform channel and Android manifest.
- **Gate**: Unknown apps permission detection, settings deep link, and FileProvider intent launching. Passed.

#### T7.3: Update UI & Presentation [DONE]
- **Files**: `lib/presentation/screens/settings/update_dialog.dart`, `lib/presentation/screens/pos/pos_screen.dart`, `lib/presentation/screens/settings/settings_screen.dart`, `lib/presentation/providers/update_providers.dart`
- **Write Surface**: Update UI dialog, banner, and settings widgets.
- **Gate**: Non-interruptive banner when cart has items; dialog when cart is empty; manual check feedback. Passed.

#### T7.4: Release Signing & Scripts Automation [DONE]
- **Files**: `android/app/build.gradle.kts`, `scripts/release.ps1`, `scripts/release.sh`, `AGENTS.md`, `CLAUDE.md`
- **Write Surface**: Release build configuration and scripts.
- **Gate**: Release APK builds and signs cleanly; keystore in .gitignore. Passed.

---

### Phase 8 — Review Findings & Defect Remediation [DONE]
- **Phase Goal**: Systematically resolve all 50 findings (17 blocking, 33 advisory) identified across Phases 1–7 in `REVIEW_PROGRESS.html`.

#### TR.1: Phase 1 Remediation [DONE]
- **Findings**:
  - `p1-1` (blocking): Add failing multi-row transactional rollback test where 2nd write fails and assert 1st write is rolled back.
  - `p1-2` (advisory): Decouple pure Dart domain tests from `flutter_test` by importing `package:test/test.dart`.
  - `p1-3` (advisory): Wire Money model or use throughout formatting/domain logic.
  - `p1-4` (advisory): Enforce positive pricePerKgCentavos in `PricingCalculator.computeLineValue`.
- **Files**: `test/data/database_test.dart`, `test/domain/**`, `lib/domain/models/money.dart`, `lib/domain/services/pricing_calculator.dart`
- **Gate**: Domain tests run with pure Dart test runner; rollback verified; `diff-scan.ps1` green. Passed.

#### TR.2: Phase 2 Remediation [DONE]
- **Findings**:
  - `p2-1` (blocking): Pass actual row index to `ReorderableDragStartListener` in `products_screen.dart:245`.
  - `p2-2` (blocking): Invalidate `capitalHistoryProvider` after capital edits.
  - `p2-3` (advisory): Route product screen centavos rendering through `formatMoney`.
  - `p2-4` (advisory): Expand drag handle hit target to at least 48 dp.
  - `p2-5` (advisory): Unify product validation between form dialog and repository.
  - `p2-6` (advisory): Clean up / inline pass-through `addProduct`.
  - `p2-7` (advisory): Reassign deterministic `sortOrder` on product restore.
  - `p2-8` (advisory): Add widget tests covering add, edit, and reorder flows.
  - `p2-9` (advisory): Await SnackBar undo archive call and handle failures.
- **Files**: `lib/presentation/screens/products/**`, `lib/presentation/providers/product_providers.dart`, `lib/data/repositories/product_repository.dart`, `test/presentation/products_screen_test.dart`
- **Gate**: Product tests pass; drag reordering works; `diff-scan.ps1` green. Passed.

#### TR.3: Phase 3 Remediation [DONE]
- **Findings**:
  - `p3-1` (blocking): Resync / reset charged amount in `cart_sheet.dart` when a line is removed.
  - `p3-2` (blocking): Replace `(grams / 1000).toStringAsFixed(3)` double math with integer division/remainder or `formatWeight`.
  - `p3-3` (blocking): Replace inline line value rounding in `receipt_dialog.dart` with `PricingCalculator.computeLineValue`.
  - `p3-4` (blocking): Wire and render per-line largest-remainder discount allocation in cart sheet and receipt.
  - `p3-5` (advisory): Add fallback in `cart_sheet.dart:226` when product is archived.
  - `p3-6` (advisory): Serialize draft cart saving and gate save-on-change until initial load completes.
  - `p3-7` (advisory): Consolidate currency formatting in `cart_sheet.dart` to `formatMoney`.
  - `p3-8` (advisory): Move draft persistence out of provider into `CartDraftService` in `lib/data/services/`.
- **Files**: `lib/presentation/screens/pos/**`, `lib/presentation/providers/cart_provider.dart`, `lib/data/services/cart_draft_service.dart`, `lib/domain/utils/formatters.dart`
- **Gate**: Zero double in weight path; single rounding function; `diff-scan.ps1` green. Passed.

#### TR.4: Phase 4 Remediation [DONE]
- **Findings**:
  - `p4-1` (blocking): Add sale edit path (`editSale`) preserving untouched line snapshots.
  - `p4-2` (advisory): Confirm void before reopening locked day, or atomic void with check.
  - `p4-3` (advisory): Fetch all items for sales in one query to eliminate N+1.
  - `p4-4` (advisory): Enforce locked-day check inside the same transaction as void/edit.
- **Files**: `lib/data/repositories/sale_repository.dart`, `lib/presentation/screens/sales/**`
- **Gate**: Sale editing tested; N+1 eliminated; `diff-scan.ps1` green. Passed.

#### TR.5: Phase 5 Remediation [DONE]
- **Findings**:
  - `p5-1` (blocking): Read salary mode, basis points, and fixed salary from user settings in `payout_section.dart`.
  - `p5-2` (blocking): Enforce grams boundary `g <= 999` in `add_expense_dialog.dart`.
  - `p5-3` (blocking): Render `totalDiscountsCentavos` in `daily_summary_screen.dart`.
  - `p5-4` (advisory): Split centavos using integer division and remainder in `payout_section.dart`.
  - `p5-5` (advisory): Reject `saveAndLockPayout` if day is locked unless explicitly reopened.
  - `p5-6` (advisory): Soft-archive restock purchase instead of hard delete, and enforce day lock.
- **Files**: `lib/presentation/screens/summary/**`, `lib/presentation/screens/expenses/**`, `lib/data/repositories/payout_repository.dart`, `lib/data/repositories/restock_repository.dart`
- **Gate**: Payout settings respected; 0-999g enforced; `diff-scan.ps1` green. Passed.

#### TR.6: Phase 6 Remediation [DONE]
- **Findings**:
  - `p6-1` (advisory): Resync settings controllers when settings state updates after backup restore.
- **Files**: `lib/presentation/screens/settings/settings_screen.dart`
- **Gate**: Controller sync on restore verified; `diff-scan.ps1` green. Passed.

#### TR.7: Phase 7 Remediation [DONE]
- **Findings**:
  - `p7-1` (blocking): Do not prematurely delete APK in `update_dialog.dart`; treat `installApk` false return as error.
  - `p7-2` (blocking): Sanitize download filename using `p.basename` and enforce `.apk` extension.
  - `p7-3` (blocking): Disable auto-redirects, re-validate Location headers against host allowlist, cap hops.
  - `p7-4` (blocking): Re-check `canRequestPackageInstalls` upon `AppLifecycleState.resumed` before firing install.
  - `p7-5` (blocking): Document update behavior in `spec.md` Section 8.
  - `p7-6` (blocking): Amend stale offline invariants and add Phase 7/8 in `PLAN.md`.
  - `p7-7` (advisory): Add timeouts (15s) and maximum file size caps (150MB) to download.
  - `p7-8` (advisory): Persist 24h throttle timestamp only after successful release check response.
  - `p7-9` (advisory): Differentiate manual check errors from "You're up to date".
  - `p7-10` (advisory): Require checksum asset name to match `$apkName.sha256`.
  - `p7-11` (advisory): Narrow host allowlist and require release download path prefix.
  - `p7-12` (advisory): Add re-entrancy guard before first await in `update_dialog.dart`.
  - `p7-13` (advisory): Limit FileProvider to `<cache-path name="updates" path="updates/" />`.
  - `p7-14` (advisory): Require `key.properties` for release builds with explicit Gradle error.
  - `p7-15` (advisory): In release scripts, run tests first, and validate both `key.properties` and keystore.
  - `p7-16` (advisory): Show persistent failure state inside update dialog on error/cancel.
  - `p7-17` (advisory): Add `+BUILD` version test and off-allowlist asset test in `update_service_test.dart`.
  - `p7-18` (advisory): Propagate platform channel errors in `app_installer.dart`.
- **Files**: `lib/data/services/update_service.dart`, `lib/presentation/screens/settings/update_dialog.dart`, `lib/data/services/app_installer.dart`, `android/app/src/main/res/xml/filepaths.xml`, `android/app/build.gradle.kts`, `scripts/release.ps1`, `scripts/release.sh`, `test/data/update_service_test.dart`
- **Gate**: All 18 update findings resolved; `diff-scan.ps1` green. Passed.

---

### Phase 8 — Sale Editing & Immutable Audit Trail (`sale_edits`) [IN PROGRESS]
- **Phase Goal**: Allow editing non-voided sales from Sales History with pure-Dart recalculation, unchanged capital snapshot preservation, locked day guards, and an immutable `sale_edits` audit trail.
- **Reviewer Checkpoint 8**: Ready for Code Review.

#### T8.1: Drift Schema & Migration v2
- **Files**: `lib/data/database/tables.dart`, `lib/data/database/app_database.dart`
- **Details**: Add `editedAt` and `editCount` to `Sales`; define `SaleEdits` table (`id`, `saleId`, `editedAt`, `beforeJson`, `afterJson`, `reason`); bump schemaVersion to 2 with `onUpgrade` step. Run `build_runner`.

#### T8.2: Backup Service Schema v2 & Backward Compatibility
- **Files**: `lib/data/services/backup_service.dart`, `test/data/backup_service_test.dart`
- **Details**: Export/import `sale_edits` and new `sales` fields (`edited_at`, `edit_count`); bump schema_version to 2; test round-trip and backward compatibility for v1 backups.

#### T8.3: Sale Repository Atomic Edit & Capital Rules
- **Files**: `lib/data/repositories/sale_repository.dart`, `test/data/sale_repository_test.dart`
- **Details**: Implement atomic transaction for `editSale`: verify day is not locked; enforce >= 1 line; reuse original capital snapshot for same-product lines; fetch current catalog capital for new/changed product lines; allocate discount via `PricingCalculator`; store before/after JSON; increment `editCount` and set `editedAt`; commit in one transaction.

#### T8.4: Sales History UI & Audit Badge
- **Files**: `lib/presentation/screens/sales/sales_history_screen.dart`, `lib/presentation/screens/sales/sale_detail_sheet.dart`
- **Details**: Add "Edited" badge to edited sales; add "Edit" action button next to "Void"; tap badge/action opens audit history modal showing before/after diffs; locked-day guard prompts "This day is paid out. Reopen it first." with Reopen confirmation.

#### T8.5: Edit Sale Dialog
- **Files**: `lib/presentation/screens/sales/edit_sale_dialog.dart`
- **Details**: Full-featured cart/payment UI prefilled with original sale lines, charged amount, paid amount; reuse weighing bottom sheet and domain money math; enforce >= 1 line; dirty state tracking disables Save when unchanged; prompt "Discard changes?" on back/cancel; optional reason input.

#### T8.6: Daily Summary Reopen Warning & Edit Counter
- **Files**: `lib/presentation/screens/summary/daily_summary_screen.dart`, `lib/presentation/screens/summary/payout_section.dart`
- **Details**: Render "N sales edited today"; if a day's sales were edited after a payout was locked and reopened, show top warning banner: "Sales changed since this day was paid out. Review the payout before marking it again." with previously saved vs new suggested amounts.

#### T8.7: Unit, Repository & Widget Tests
- **Files**: `test/data/database_test.dart`, `test/data/sale_repository_test.dart`, `test/data/backup_service_test.dart`, `test/presentation/sales_history_screen_test.dart`, `test/presentation/daily_summary_screen_test.dart`
- **Details**: Test all edge cases in spec.md section 10. Pass `diff-scan.ps1`.

---

## 3. Edge Cases & Safety
1. **Fractional Centavo Rounding**: Round half-up applied strictly once per line.
2. **Discount Allocation**: Largest-remainder distribution guarantees sum of line discounts equals total discount with zero lost centavos.
3. **Loss Day Handling**: When net profit < 0, net profit displayed in red, salary = 0, reserve shortfall prominently flagged.
4. **Update Isolation**: Network access restricted strictly to public GitHub Releases update checks and verified SHA-256 APK downloads over HTTPS. No other network calls permitted.
