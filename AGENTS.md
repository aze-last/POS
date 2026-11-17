# AGENTS.md

## 1. Project Summary
Banana POS: offline-first Flutter/Android point-of-sale app for selling bananas by weight (per kilo) at market stalls. Single user / paired devices, no login. Network activity is strictly limited to: (1) GitHub Releases update checks, and (2) optional offline-first multi-device Supabase cloud sync (Step 9).

## 2. Source of Truth
Read `spec.md` first. `spec.md` is the source of truth; update it before changing behavior. If code contradicts it, the code is wrong.

## 3. Tech Stack & Architecture
- Flutter / Dart, Material 3, portrait only.
- `lib/domain/`: Pure Dart models (`Weight`, `Money`, `AppVersion`, `PricingCalculator`, `PayoutCalculator`). Zero Flutter imports. Fully unit tested.
- `lib/data/`: Drift SQLite (`app_database.dart`, `tables.dart`), repositories, and services (`backup_service.dart`, `update_service.dart`, `sync_service.dart`, `app_installer.dart`).
- `lib/presentation/`: Screens, widgets, Riverpod providers (`lib/presentation/providers/`).
- `lib/config/update_config.dart`: Single source of truth for GitHub coordinates (`githubOwner`, `githubRepo`).
- `lib/config/supabase_config.dart`: Compile-time Supabase project URL + public key (`--dart-define` / `--dart-define-from-file` only). Rejects Postgres and admin credentials. Sync stays off unless both values validate.
- `supabase/`: Migrations for Supabase schema and RLS policies (anon/authenticated with append-only sale_edits).

## 4. Hard Invariants
- Money is integer centavos; weight is integer grams. Zero `double`/`float` for money or weight.
- One rounding function: `round_half_up(price * grams / 1000)` applied once per line via `PricingCalculator`.
- One currency formatter: `formatMoney` in `lib/domain/utils/formatters.dart`.
- Discount allocation uses the largest-remainder method; allocated pieces sum exactly to the total discount.
- Spoilage is subtracted once in payout math (inside to_parents).
- Sale items and spoilage snapshot product name, price, and capital at transaction time. Past profit is never recomputed from current capital.
- Sale edits: `sale_edits` is an immutable, append-only audit trail recording `before_json` and `after_json` for header and all lines in integer centavos and grams. No UI path can delete edit history.
- Line unchanged in product on edit KEEPS its original `capital_per_kg_centavos` snapshot. Lines with a changed product or newly added lines snapshot CURRENT catalog capital.
- Voided sales kept for audit, flagged, and excluded from all totals.
- A day with a locked payout blocks sale edit and void until Reopen.
- Soft-archive products; never hard-delete. Multi-row writes must use transactions.
- No secrets, tokens, or admin keys in repo/client. Public unauthenticated GitHub releases & public anon Supabase keys only.

## 5. Commands
- Run: `flutter run`
- Test: `flutter test`
- Analyze: `flutter analyze`
- Format: `dart format .`
- Gate: `powershell -NoProfile -ExecutionPolicy Bypass -File .\.agents\team\diff-scan.ps1`
- Build Release: `flutter build apk --release`

## 6. Versioning & Release Workflow
- Format: `MAJOR.MINOR.PATCH+BUILD` in `pubspec.yaml` (e.g. `1.0.0+1`). `BUILD` is `versionCode` and strictly increases.
- Trigger phrases: ONLY bump version when instructed: `"update the installer"`, `"release"`, or `"new version"`.
- Rule: Default to PATCH bump (unless minor or major requested); always `BUILD+1`.
- Tag must equal the pubspec version with a leading v (e.g. `v1.0.0`).
- Automation: Run `.\scripts\release.ps1` (Windows) or `./scripts/release.sh` (Linux/macOS).
  - Updates `pubspec.yaml` and `CHANGELOG.md`.
  - Runs test suite and builds signed release APK (`releases/banana-pos-vX.Y.Z.apk`).
  - Generates cryptographic checksum (`releases/banana-pos-vX.Y.Z.apk.sha256`).
  - Outputs exact GitHub release command (`gh release create ...`).
- Never push, tag, or publish releases automatically.

## 7. Keystore & Signing Setup
- Release signing is configured in `android/app/build.gradle.kts` via `android/key.properties`.
- Both `key.properties` and `*.keystore` are strictly in `.gitignore` and must NEVER be committed.
- Configuration in `android/key.properties`:
  ```properties
  storePassword=<SECRET>
  keyPassword=<SECRET>
  keyAlias=banana_pos_key
  storeFile=app/release.keystore
  ```
- **CRITICAL WARNING**: The user must back up `release.keystore` and `key.properties` offline. If lost, existing installs cannot be updated and will require an uninstall that deletes local data!
- Release builds strictly fail if `key.properties` or the keystore file is missing; no debug fallback.
- `applicationId = "com.banana.pos"` is permanently fixed.

## 8. Current Status Checklist
- [x] Step 1: Project setup, DB, domain money/weight logic + tests.
- [x] Step 2: Products screen + capital history.
- [x] Step 3: POS + cart + receipt.
- [x] Step 4: Sales history + void/edit.
- [x] Step 5: Expenses, Daily Summary, Payout, Parents' Balance, Settings.
- [x] Step 6: Backup/restore.
- [x] Step 7: Update checker, in-app update install, release workflow, and AGENTS.md.
- [x] Step 8: Edit sale from Sales History with audit trail (`sale_edits`), capital snapshot preservation, locked day guard/banner, backup v2, and tests.
- [ ] Step 9: Multi-device Supabase sync.

## 9. Manual Test Plan
1. Build and install version 1.0.0 on the phone.
2. Bump to 1.0.1 using the release workflow (`.\scripts\release.ps1`) and publish on GitHub with APK and .sha256 assets.
3. Open 1.0.0 and check that the banner/dialog appears, download is verified, Android prompts to install, and data is still intact after updating.
4. Confirm "Check for updates" in Settings says "You're up to date!" on 1.0.1.

## 10. Decisions Log
- 2026-11-15: Initial 6-phase offline architecture and spec established.
- 2026-11-16: Spec amended to allow HTTPS unauthenticated network requests strictly for GitHub Releases update checks and APK downloads.
- 2026-11-16: Spec amended for Edit sale from Sales History with immutable `sale_edits` audit trail, capital snapshot rules, and locked day reopen flow.
- 2026-11-16: Numbering finalized: Edit sale is Step 8, Supabase sync is Step 9 (`spec.md` Section 11, `AGENTS.md` Sections 8 & 11).
- 2026-11-16: Updated `spec.md` Section 2 layer path from `ui/` to `lib/presentation/` to match codebase.
- 2026-11-16: Added hard invariants to `AGENTS.md` Section 4: largest-remainder discount allocation, single spoilage deduction in payout, and locked payout edit/void guard.
- 2026-11-16: Added release workflow rule to `AGENTS.md` Section 6: tag must equal pubspec version with leading `v`.
- 2026-11-16: Added Step 9 Supabase sync security notes to `AGENTS.md` Section 11 (RLS on all tables, anon key only via dart-define/gitignored env, service_role prohibited; spec.md Section 1 amendment pending Step 9).
- 2026-11-16: Added daily expense salary tracking & remaining salary warning feature to `spec.md` §5.4.
- 2026-11-16: Added product photo capture & upload (schema v3 with nullable imagePath, local app storage, visual POS cards, and weighing bottom sheet header).
- 2026-11-16: Added Option A scale-style single-stream weight input with on-screen stall keypad, stream parsing, and quick chips.
- 2026-11-16: Added inert Supabase client scaffolding for Step 9: `supabase_flutter`, validated `--dart-define` config, bootstrap that no-ops when unconfigured, and a draft RLS migration with zero policies. No sync behavior; `spec.md` §1 amendment still pending.
- 2026-11-17: Added variety deletion in edit dialog & catalog; unreferenced items permanently deleted, referenced items soft-archived to protect historical sales integrity.
- 2026-11-17: Multi-device product photo syncing enabled: photos are serialized as compact base64 JPEG in cloud sync, decoded and cached into local storage on receiving devices for 100% offline access.

## 11. Multi-Device Supabase Sync Design Notes (Step 9)
- `sale_edits` is append-only and syncs like other append-only tables (UUID ids).
- When sales and sale_items are edited on two devices simultaneously: last write wins by `updated_at`, but both `sale_edits` rows are preserved so audit history is never lost.
- Removed lines use `deleted_at` (soft-delete), never hard delete. Multi-row sync writes must commit to the outbox in the same transaction.
- Editing is blocked on any day that the local device has locked, even if the sale was pulled from another device.
- Security Notes for Step 9:
  - Row Level Security (RLS) enabled on every table.
  - Only the Supabase URL and anon key in the app, supplied via `--dart-define` or a gitignored env file.
  - `service_role` key never in app, repo, scripts, logs, or chat.
  - Note: `spec.md` section 1 and the "no secrets" invariant must be amended when Step 9 starts.
- Scaffolding status (2026-11-16): `supabase/migrations/20261116090000_step9_sync_schema.sql` creates the sync tables with RLS enabled and **no policies** (default deny) plus an append-only trigger on `sale_edits`. `lib/config/supabase_config.dart` validates build-time credentials and the bootstrap performs no queries. Local integer primary keys still must become UUIDs before real sync.
