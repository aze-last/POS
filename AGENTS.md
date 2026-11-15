# AGENTS.md

Banana POS: offline-first Flutter/Android point-of-sale app for selling bananas by the kilo. Single user, no backend, no login, no network calls.

## Source of truth

Read in this order; earlier files win:

1. `spec.md` — product, numeric, and payout contract. If code contradicts it, the code is wrong unless the spec is updated first.
2. `PLAN.md` — phased build contract. Work only inside the current phase's declared write surface.
3. `.agents/rules.md` — standing agent rules (TDD, no hard deletes, gate discipline).

Do not start a phase before the previous one passes the gate.

## Non-negotiable numeric rules

- Weight is `int` grams. Money is `int` centavos. Never `double`/`float` for either.
- Line value = `round_half_up(pricePerKgCentavos * grams / 1000)`, integer-only, rounded once per line. Use `PricingCalculator` in `lib/domain/services/pricing_calculator.dart`; do not re-derive this math.
- Discounts use largest-remainder allocation so line discounts sum exactly to the total.
- Format centavos with the single formatter in `lib/domain/utils/formatters.dart`. Do not add a second one.
- No automatic rounding to whole pesos. The user picks round up/down at checkout.

## Layout

- `lib/domain/` — pure Dart, no Flutter imports, fully unit tested.
- `lib/data/` — Drift database (`app_database.dart`, `tables.dart`) and repositories.
- `lib/presentation/` — screens, widgets, Riverpod providers.
- `lib/data/database/app_database.g.dart` is generated. Change `tables.dart` or `app_database.dart`, then run `dart run build_runner build --delete-conflicting-outputs`. Never hand-edit it.

## Data invariants

- Archive products; never hard-delete. Old sales must stay intact.
- Sale items snapshot product name, price, and capital. Never recompute past profit from current capital.
- Capital edits write a `capital_history` row; price-only edits do not.
- Multi-row writes go in a `transaction`.
- Product names are unique among active products, case-insensitively.

## Gate (must be green before review)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\.agents\team\diff-scan.ps1
```

Linux/macOS twin: `.agents/team/diff-scan.sh`. It runs `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test`, plus allowlist, secret, and destructive-command checks. Exit 0 = GREEN, exit 1 = BLOCK. `-GateOnly` skips lint and tests.

Prefix shell commands with `rtk` per `.agents/rules.md` (e.g. `rtk git status`, `rtk flutter test`).

## Testing

- Tests use in-memory Drift: `AppDatabase(NativeDatabase.memory())`. Close the database in `tearDown`.
- Domain tests stay pure Dart. Do not import Flutter into `lib/domain/`.
- If `flutter test` fails to start with a locked `build/native_assets/windows/sqlite3.dll`, kill stale `dart`/`flutter_tester` processes and rerun.

## UI constraints

- Portrait only, English UI, Material 3. Used one-handed at a market stall: large touch targets, high contrast, readable in sunlight.
- Confirm before any destructive action (archive, void, import, reopen).

## Dependencies

Present: `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`, `flutter_riverpod`, `intl`, `share_plus`, `file_picker`. There is no HTTP client and no network permission in the Android manifest; keep it that way.
