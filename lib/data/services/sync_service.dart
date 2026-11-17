import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../config/supabase_config.dart';
import '../database/app_database.dart';

enum SyncStatus { disabled, idle, syncing, success, error }

class SyncStateInfo {
  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final String? errorMessage;
  final int pendingOutboxCount;

  const SyncStateInfo({
    required this.status,
    this.lastSyncedAt,
    this.errorMessage,
    this.pendingOutboxCount = 0,
  });

  bool get isConfigured => status != SyncStatus.disabled;
}

/// Service handling bidirectional offline-first sync between Drift SQLite and Supabase.
class SyncService {
  final AppDatabase _db;
  final SupabaseClient? _clientOverride;
  final _uuid = const Uuid();

  SyncStatus _currentStatus = SyncStatus.idle;
  DateTime? _lastSyncedAt;
  String? _lastError;

  SyncService(this._db, [this._clientOverride]);

  SupabaseClient? get _client {
    if (_clientOverride != null) return _clientOverride;
    if (!SupabaseConfig.isConfigured) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get isConfigured => _client != null;

  SyncStateInfo get currentState => SyncStateInfo(
    status: !isConfigured ? SyncStatus.disabled : _currentStatus,
    lastSyncedAt: _lastSyncedAt,
    errorMessage: _lastError,
  );

  /// Generates a new UUID v4 string.
  String generateUuid() => _uuid.v4();

  /// Enqueues an entity change to the local outbox.
  Future<void> enqueueOutbox({
    required String entityType,
    required String entitySyncId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    await _db
        .into(_db.outboxItems)
        .insert(
          OutboxItemsCompanion.insert(
            entityType: entityType,
            entitySyncId: entitySyncId,
            action: action,
            payloadJson: jsonEncode(payload),
            createdAt: DateTime.now().toUtc(),
          ),
        );
  }

  /// Triggers a full bidirectional synchronization run.
  Future<SyncStateInfo> sync() async {
    final client = _client;
    if (client == null) {
      _currentStatus = SyncStatus.disabled;
      return currentState;
    }

    _currentStatus = SyncStatus.syncing;
    _lastError = null;

    try {
      // 1. Backfill any local records lacking syncIds
      await _backfillMissingSyncIds();

      // 2. Push local pending changes to Supabase
      await _pushChanges(client);

      // 3. Pull remote changes from Supabase
      await _pullChanges(client);

      _lastSyncedAt = DateTime.now().toUtc();
      _currentStatus = SyncStatus.success;

      // Update sync state table
      await _db
          .into(_db.syncStates)
          .insertOnConflictUpdate(
            SyncStatesCompanion.insert(
              id: const Value(1),
              lastSyncedAt: Value(_lastSyncedAt),
              lastSyncStatus: const Value('success'),
            ),
          );

      return currentState;
    } catch (e, st) {
      debugPrint('[sync] error during synchronization: $e\n$st');
      _currentStatus = SyncStatus.error;
      _lastError = e.toString();

      await _db
          .into(_db.syncStates)
          .insertOnConflictUpdate(
            SyncStatesCompanion.insert(
              id: const Value(1),
              lastSyncedAt: Value(_lastSyncedAt),
              lastSyncStatus: const Value('error'),
              lastErrorMessage: Value(_lastError),
            ),
          );

      return currentState;
    }
  }

  /// Ensures all existing local records have UUID syncIds.
  Future<void> _backfillMissingSyncIds() async {
    // Products
    final prods = await (_db.select(
      _db.products,
    )..where((tbl) => tbl.syncId.isNull())).get();
    for (final p in prods) {
      final syncId = generateUuid();
      await (_db.update(
        _db.products,
      )..where((tbl) => tbl.id.equals(p.id))).write(
        ProductsCompanion(
          syncId: Value(syncId),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await enqueueOutbox(
        entityType: 'products',
        entitySyncId: syncId,
        action: 'upsert',
        payload: {
          'id': syncId,
          'name': p.name,
          'default_price_centavos': p.defaultPriceCentavos,
          'capital_centavos': p.capitalCentavos,
          'sort_order': p.sortOrder,
          'archived': p.archived,
          'image_path': p.imagePath,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
    }

    // Sales
    final unSyncedSales = await (_db.select(
      _db.sales,
    )..where((tbl) => tbl.syncId.isNull())).get();
    for (final s in unSyncedSales) {
      final syncId = generateUuid();
      await (_db.update(_db.sales)..where((tbl) => tbl.id.equals(s.id))).write(
        SalesCompanion(
          syncId: Value(syncId),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await enqueueOutbox(
        entityType: 'sales',
        entitySyncId: syncId,
        action: 'upsert',
        payload: {
          'id': syncId,
          'created_at': s.createdAt.toUtc().toIso8601String(),
          'exact_total_centavos': s.exactTotalCentavos,
          'charged_centavos': s.chargedCentavos,
          'paid_centavos': s.paidCentavos,
          'change_centavos': s.changeCentavos,
          'voided': s.voided,
          'edited_at': s.editedAt?.toUtc().toIso8601String(),
          'edit_count': s.editCount,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
    }

    // Settings
    final settingsList = await (_db.select(
      _db.settings,
    )..where((tbl) => tbl.syncId.isNull())).get();
    for (final s in settingsList) {
      final syncId = generateUuid();
      await (_db.update(
        _db.settings,
      )..where((tbl) => tbl.id.equals(s.id))).write(
        SettingsCompanion(
          syncId: Value(syncId),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
      await enqueueOutbox(
        entityType: 'settings',
        entitySyncId: syncId,
        action: 'upsert',
        payload: {
          'id': syncId,
          'salary_mode': s.salaryMode,
          'salary_percent_basis_points': s.salaryPercentBasisPoints,
          'fixed_daily_salary_centavos': s.fixedDailySalaryCentavos,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
    }
  }

  /// Pushes all queued outbox records to Supabase.
  Future<void> _pushChanges(SupabaseClient client) async {
    final pending = await _db.select(_db.outboxItems).get();
    if (pending.isEmpty) return;

    for (final item in pending) {
      final payload = jsonDecode(item.payloadJson) as Map<String, dynamic>;
      final table = item.entityType;

      if (table == 'sale_edits') {
        await client.from(table).insert(payload);
      } else {
        await client.from(table).upsert(payload);
      }

      // Delete processed outbox item
      await (_db.delete(
        _db.outboxItems,
      )..where((tbl) => tbl.id.equals(item.id))).go();
    }
  }

  /// Pulls updated records from Supabase and applies them to local SQLite.
  Future<void> _pullChanges(SupabaseClient client) async {
    final lastSync = _lastSyncedAt;
    final lastSyncIso = lastSync?.toIso8601String();

    // 1. Pull Products
    var prodQuery = client.from('products').select();
    if (lastSyncIso != null) {
      prodQuery = prodQuery.gt('updated_at', lastSyncIso);
    }
    final remoteProds = await prodQuery;
    for (final p in remoteProds) {
      final remoteSyncId = p['id'] as String;
      final existing = await (_db.select(
        _db.products,
      )..where((tbl) => tbl.syncId.equals(remoteSyncId))).getSingleOrNull();

      if (existing != null) {
        await (_db.update(
          _db.products,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          ProductsCompanion(
            name: Value(p['name'] as String),
            defaultPriceCentavos: Value(p['default_price_centavos'] as int),
            capitalCentavos: Value(p['capital_centavos'] as int),
            sortOrder: Value(p['sort_order'] as int? ?? 0),
            archived: Value(p['archived'] as bool? ?? false),
            updatedAt: Value(DateTime.parse(p['updated_at'] as String)),
          ),
        );
      } else {
        await _db
            .into(_db.products)
            .insert(
              ProductsCompanion.insert(
                syncId: Value(remoteSyncId),
                name: p['name'] as String,
                defaultPriceCentavos: p['default_price_centavos'] as int,
                capitalCentavos: p['capital_centavos'] as int,
                sortOrder: Value(p['sort_order'] as int? ?? 0),
                archived: Value(p['archived'] as bool? ?? false),
                updatedAt: Value(DateTime.parse(p['updated_at'] as String)),
              ),
            );
      }
    }

    // 2. Pull Sales
    var salesQuery = client.from('sales').select();
    if (lastSyncIso != null) {
      salesQuery = salesQuery.gt('updated_at', lastSyncIso);
    }
    final remoteSales = await salesQuery;
    for (final s in remoteSales) {
      final remoteSyncId = s['id'] as String;
      final existing = await (_db.select(
        _db.sales,
      )..where((tbl) => tbl.syncId.equals(remoteSyncId))).getSingleOrNull();

      final createdAt = DateTime.parse(s['created_at'] as String);
      final editedAt = s['edited_at'] != null
          ? DateTime.parse(s['edited_at'] as String)
          : null;

      if (existing != null) {
        await (_db.update(
          _db.sales,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          SalesCompanion(
            exactTotalCentavos: Value(s['exact_total_centavos'] as int),
            chargedCentavos: Value(s['charged_centavos'] as int),
            paidCentavos: Value(s['paid_centavos'] as int),
            changeCentavos: Value(s['change_centavos'] as int),
            voided: Value(s['voided'] as bool? ?? false),
            editedAt: Value(editedAt),
            editCount: Value(s['edit_count'] as int? ?? 0),
            updatedAt: Value(DateTime.parse(s['updated_at'] as String)),
          ),
        );
      } else {
        await _db
            .into(_db.sales)
            .insert(
              SalesCompanion.insert(
                syncId: Value(remoteSyncId),
                createdAt: createdAt,
                exactTotalCentavos: s['exact_total_centavos'] as int,
                chargedCentavos: s['charged_centavos'] as int,
                paidCentavos: s['paid_centavos'] as int,
                changeCentavos: s['change_centavos'] as int,
                voided: Value(s['voided'] as bool? ?? false),
                editedAt: Value(editedAt),
                editCount: Value(s['edit_count'] as int? ?? 0),
                updatedAt: Value(DateTime.parse(s['updated_at'] as String)),
              ),
            );
      }
    }

    // 3. Pull Sale Edits (append-only ledger)
    var editsQuery = client.from('sale_edits').select();
    if (lastSyncIso != null) {
      editsQuery = editsQuery.gt('created_at', lastSyncIso);
    }
    final remoteEdits = await editsQuery;
    for (final e in remoteEdits) {
      final remoteSyncId = e['id'] as String;
      final existing = await (_db.select(
        _db.saleEdits,
      )..where((tbl) => tbl.syncId.equals(remoteSyncId))).getSingleOrNull();

      if (existing == null) {
        // Look up corresponding local sale by sale_id UUID
        final saleUuid = e['sale_id'] as String;
        final localSale = await (_db.select(
          _db.sales,
        )..where((tbl) => tbl.syncId.equals(saleUuid))).getSingleOrNull();

        if (localSale != null) {
          await _db
              .into(_db.saleEdits)
              .insert(
                SaleEditsCompanion.insert(
                  syncId: Value(remoteSyncId),
                  saleId: localSale.id,
                  editedAt: DateTime.parse(e['edited_at'] as String),
                  beforeJson: jsonEncode(e['before_json']),
                  afterJson: jsonEncode(e['after_json']),
                  reason: Value(e['reason'] as String?),
                ),
              );
        }
      }
    }

    // 4. Pull Expenses
    var expQuery = client.from('expenses').select();
    if (lastSyncIso != null) {
      expQuery = expQuery.gt('updated_at', lastSyncIso);
    }
    final remoteExpenses = await expQuery;
    for (final ex in remoteExpenses) {
      final remoteSyncId = ex['id'] as String;
      final existing = await (_db.select(
        _db.expenses,
      )..where((tbl) => tbl.syncId.equals(remoteSyncId))).getSingleOrNull();

      int? localProductId;
      if (ex['product_id'] != null) {
        final prod =
            await (_db.select(_db.products)..where(
                  (tbl) => tbl.syncId.equals(ex['product_id'] as String),
                ))
                .getSingleOrNull();
        localProductId = prod?.id;
      }

      if (existing != null) {
        await (_db.update(
          _db.expenses,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          ExpensesCompanion(
            amountCentavos: Value(ex['amount_centavos'] as int),
            note: Value(ex['note'] as String?),
            grams: Value(ex['grams'] as int?),
            capitalPerKgCentavos: Value(ex['capital_per_kg_centavos'] as int?),
            updatedAt: Value(DateTime.parse(ex['updated_at'] as String)),
          ),
        );
      } else {
        await _db
            .into(_db.expenses)
            .insert(
              ExpensesCompanion.insert(
                syncId: Value(remoteSyncId),
                date: DateTime.parse(ex['date'] as String),
                type: ex['type'] as String,
                amountCentavos: ex['amount_centavos'] as int,
                note: Value(ex['note'] as String?),
                productId: Value(localProductId),
                grams: Value(ex['grams'] as int?),
                capitalPerKgCentavos: Value(
                  ex['capital_per_kg_centavos'] as int?,
                ),
                updatedAt: Value(DateTime.parse(ex['updated_at'] as String)),
              ),
            );
      }
    }

    // 5. Pull Payouts
    var payoutQuery = client.from('payouts').select();
    if (lastSyncIso != null) {
      payoutQuery = payoutQuery.gt('updated_at', lastSyncIso);
    }
    final remotePayouts = await payoutQuery;
    for (final py in remotePayouts) {
      final remoteSyncId = py['id'] as String;
      final existing = await (_db.select(
        _db.payouts,
      )..where((tbl) => tbl.syncId.equals(remoteSyncId))).getSingleOrNull();

      if (existing != null) {
        await (_db.update(
          _db.payouts,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          PayoutsCompanion(
            toParentsCentavos: Value(py['to_parents_centavos'] as int),
            salaryCentavos: Value(py['salary_centavos'] as int),
            reserveCentavos: Value(py['reserve_centavos'] as int),
            locked: Value(py['locked'] as bool? ?? false),
            updatedAt: Value(DateTime.parse(py['updated_at'] as String)),
          ),
        );
      } else {
        await _db
            .into(_db.payouts)
            .insert(
              PayoutsCompanion.insert(
                syncId: Value(remoteSyncId),
                date: DateTime.parse(py['date'] as String),
                toParentsCentavos: py['to_parents_centavos'] as int,
                salaryCentavos: py['salary_centavos'] as int,
                reserveCentavos: py['reserve_centavos'] as int,
                locked: Value(py['locked'] as bool? ?? false),
                updatedAt: Value(DateTime.parse(py['updated_at'] as String)),
              ),
            );
      }
    }
  }
}
