# Supabase (Step 9) — scaffolding only

This directory is **not** an approved Step 9 implementation. `spec.md` §1 still
says the app has no backend, and `AGENTS.md` §11 says §1 plus the no-secrets
invariant must be amended before Step 9 starts. Treat everything here as a
reviewable starting point, not as permission to ship sync.

## What exists

- `migrations/20261116090000_step9_sync_schema.sql` — server tables matching the
  Drift schema, with UUID ids, `updated_at`/`deleted_at` sync columns, indexes,
  RLS enabled on all nine tables, and an append-only trigger on `sale_edits`.
- `lib/config/supabase_config.dart` — reads `SUPABASE_URL` and a public key from
  build-time defines and rejects admin credentials.
- `lib/data/services/supabase_bootstrap.dart` — starts the client only when the
  config validates. It performs no queries.

## What deliberately does not exist

**No RLS policies.** With RLS enabled and zero policies, every request made with
the app's public key is denied. That is the correct default: the public key is
shipped inside the APK, so it is extractable. Any policy that grants `anon`
access grants it to anyone who pulls the key out of the APK. Before policies can
exist, Step 9 must pick one of:

1. **Supabase Auth per device** (anonymous session or email), plus a household
   membership table so two devices can see the same rows. Policies scope rows by
   `auth.uid()` or membership.
2. **A backend** that owns the database credentials and exposes only the sync
   operations the app needs. This is what `spec.md` §1 currently asks for.

Do not add a "public" policy to make the client work. That leaks every sale,
expense, and payout to anyone with the APK.

**No client sync code.** Writes, the outbox, conflict resolution, and UUID
migration of the local schema are all still open.

## Local setup (client)

```sh
cp .env.example .env        # then fill in the URL and public key
flutter run --dart-define-from-file=.env
```

`.env` is gitignored. Without the defines the app is unchanged and fully
offline; sync stays off.

## Admin setup (never from the app)

```sh
npx supabase link --project-ref <project-ref>
npx supabase db push
```

The direct Postgres connection string is for these commands only. It is an
admin credential — do not put it in `.env`, the app, a script, a log, or chat.

## Known blockers before real sync

- Local Drift primary keys are `INTEGER AUTOINCREMENT`. Two devices will mint
  the same ids. They must move to UUIDs first.
- `products.image_path` is a local file path. Sync needs a Storage object key,
  or photos must be excluded from sync.
- Device clocks drive `updated_at`, so last-write-wins can pick the wrong
  winner when a phone's clock is wrong. Decide whether the server stamps time.
- Backup v2 (local JSON) and a server sync are different mechanisms. Restoring a
  backup on a second device will duplicate rows unless it imports with the same
  UUIDs.
