# AGENTS.md

## 1. Project Summary
Banana POS: offline-first Flutter/Android point-of-sale app for selling bananas by weight (per kilo) at market stalls. Single user, no backend, no login. The ONLY allowed network activity is checking for and downloading updates from public GitHub Releases.

## 2. Source of Truth
Read `spec.md` first. `spec.md` is the source of truth; update it before changing behavior. If code contradicts it, the code is wrong.

## 3. Tech Stack & Architecture
- Flutter / Dart, Material 3, portrait only.
- `lib/domain/`: Pure Dart models (`Weight`, `Money`, `AppVersion`, `PricingCalculator`, `PayoutCalculator`). Zero Flutter imports. Fully unit tested.
- `lib/data/`: Drift SQLite (`app_database.dart`, `tables.dart`), repositories, and services (`backup_service.dart`, `update_service.dart`, `app_installer.dart`).
- `lib/presentation/`: Screens, widgets, Riverpod providers (`lib/presentation/providers/`).
- `lib/config/update_config.dart`: Single source of truth for GitHub coordinates (`githubOwner`, `githubRepo`).

## 4. Hard Invariants
- Money is integer centavos; weight is integer grams. Zero `double`/`float` for money or weight.
- One rounding function: `round_half_up(price * grams / 1000)` applied once per line via `PricingCalculator`.
- One currency formatter: `formatMoney` in `lib/domain/utils/formatters.dart`.
- Sale items and spoilage snapshot product name, price, and capital at transaction time. Past profit is never recomputed from current capital.
- Voided sales kept for audit, flagged, and excluded from all totals.
- Soft-archive products; never hard-delete. Multi-row writes must use transactions.
- No secrets, tokens, or API keys in the repo or client. Unauthenticated public requests only.

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

## 9. Manual Test Plan
1. Build and install version 1.0.0 on the phone.
2. Bump to 1.0.1 using the release workflow (`.\scripts\release.ps1`) and publish on GitHub with APK and .sha256 assets.
3. Open 1.0.0 and check that the banner/dialog appears, download is verified, Android prompts to install, and data is still intact after updating.
4. Confirm "Check for updates" in Settings says "You're up to date!" on 1.0.1.

## 10. Decisions Log
- 2026-11-15: Initial 6-phase offline architecture and spec established.
- 2026-11-16: Spec amended to allow HTTPS unauthenticated network requests strictly for GitHub Releases update checks and APK downloads.
