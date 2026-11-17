import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p_path;
import 'package:path_provider/path_provider.dart';
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
      await backfillMissingSyncIds();

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

  /// Ensures all existing local records across all tables have UUID syncIds.
  Future<void> backfillMissingSyncIds() async {
    // 1. Products
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
    }

    // 2. Capital History
    final caps = await (_db.select(
      _db.capitalHistory,
    )..where((tbl) => tbl.syncId.isNull())).get();
    for (final c in caps) {
      final syncId = generateUuid();
      await (_db.update(
        _db.capitalHistory,
      )..where((tbl) => tbl.id.equals(c.id))).write(
        CapitalHistoryCompanion(
          syncId: Value(syncId),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }

    // 3. Sales
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
    }

    // 4. Sale Items
    final unSyncedItems = await (_db.select(
      _db.saleItems,
    )..where((tbl) => tbl.syncId.isNull())).get();
    for (final item in unSyncedItems) {
      final syncId = generateUuid();
      await (_db.update(
        _db.saleItems,
      )..where((tbl) => tbl.id.equals(item.id))).write(
        SaleItemsCompanion(
          syncId: Value(syncId),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }

    // 5. Sale Edits
    final unSyncedEdits = await (_db.select(
      _db.saleEdits,
    )..where((tbl) => tbl.syncId.isNull())).get();
    for (final e in unSyncedEdits) {
      final syncId = generateUuid();
      await (_db.update(_db.saleEdits)..where((tbl) => tbl.id.equals(e.id)))
          .write(SaleEditsCompanion(syncId: Value(syncId)));
    }

    // 6. Expenses
    final unSyncedExpenses = await (_db.select(
      _db.expenses,
    )..where((tbl) => tbl.syncId.isNull())).get();
    for (final ex in unSyncedExpenses) {
      final syncId = generateUuid();
      await (_db.update(
        _db.expenses,
      )..where((tbl) => tbl.id.equals(ex.id))).write(
        ExpensesCompanion(
          syncId: Value(syncId),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }

    // 7. Restock Purchases
    final unSyncedRestocks = await (_db.select(
      _db.restockPurchases,
    )..where((tbl) => tbl.syncId.isNull())).get();
    for (final r in unSyncedRestocks) {
      final syncId = generateUuid();
      await (_db.update(
        _db.restockPurchases,
      )..where((tbl) => tbl.id.equals(r.id))).write(
        RestockPurchasesCompanion(
          syncId: Value(syncId),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }

    // 8. Payouts
    final unSyncedPayouts = await (_db.select(
      _db.payouts,
    )..where((tbl) => tbl.syncId.isNull())).get();
    for (final p in unSyncedPayouts) {
      final syncId = generateUuid();
      await (_db.update(
        _db.payouts,
      )..where((tbl) => tbl.id.equals(p.id))).write(
        PayoutsCompanion(
          syncId: Value(syncId),
          updatedAt: Value(DateTime.now().toUtc()),
        ),
      );
    }

    // 9. Settings
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
    }

    // Ensure products with local images get pushed to cloud with photo data
    final prodsWithImages = await (_db.select(
      _db.products,
    )..where((tbl) => tbl.imagePath.isNotNull())).get();
    for (final p in prodsWithImages) {
      if (p.imagePath != null && !p.imagePath!.startsWith('data:image/')) {
        try {
          final file = File(p.imagePath!);
          if (file.existsSync()) {
            await (_db.update(
              _db.products,
            )..where((tbl) => tbl.id.equals(p.id))).write(
              ProductsCompanion(updatedAt: Value(DateTime.now().toUtc())),
            );
          }
        } catch (_) {}
      }
    }
  }

  Future<Directory> _getImagesDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final dir = Directory(p_path.join(appDir.path, 'product_images'));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    } catch (_) {
      final tempDir = Directory(
        p_path.join(Directory.systemTemp.path, 'banana_pos_product_images'),
      );
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }
      return tempDir;
    }
  }

  /// Pushes all modified local records across all tables to Supabase.
  Future<void> _pushChanges(SupabaseClient client) async {
    const timeout = Duration(seconds: 10);
    final lastSync = _lastSyncedAt;

    // 1. Products
    final prods = await (_db.select(
      _db.products,
    )..where((p) => p.syncId.isNotNull())).get();
    final prodsToPush = lastSync == null
        ? prods
        : prods
              .where(
                (p) => p.updatedAt == null || p.updatedAt!.isAfter(lastSync),
              )
              .toList();
    if (prodsToPush.isNotEmpty) {
      final payload = <Map<String, dynamic>>[];
      for (final p in prodsToPush) {
        String? syncedImagePath;
        if (p.imagePath != null && p.imagePath!.isNotEmpty) {
          if (p.imagePath!.startsWith('data:image/')) {
            syncedImagePath = p.imagePath;
          } else {
            try {
              final file = File(p.imagePath!);
              if (await file.exists()) {
                final bytes = await file.readAsBytes();
                syncedImagePath =
                    'data:image/jpeg;base64,${base64Encode(bytes)}';
              }
            } catch (_) {
              syncedImagePath = null;
            }
          }
        }

        payload.add({
          'id': p.syncId,
          'name': p.name,
          'default_price_centavos': p.defaultPriceCentavos,
          'capital_centavos': p.capitalCentavos,
          'sort_order': p.sortOrder,
          'archived': p.archived,
          'image_path': syncedImagePath,
          'updated_at': (p.updatedAt ?? DateTime.now().toUtc())
              .toIso8601String(),
          'deleted_at': p.deletedAt?.toUtc().toIso8601String(),
        });
      }
      await client.from('products').upsert(payload).timeout(timeout);
    }

    // 2. Capital History
    final caps = await (_db.select(
      _db.capitalHistory,
    )..where((c) => c.syncId.isNotNull())).get();
    final capsToPush = lastSync == null
        ? caps
        : caps
              .where(
                (c) => c.updatedAt == null || c.updatedAt!.isAfter(lastSync),
              )
              .toList();
    if (capsToPush.isNotEmpty) {
      final payload = <Map<String, dynamic>>[];
      for (final c in capsToPush) {
        final prod = await (_db.select(
          _db.products,
        )..where((p) => p.id.equals(c.productId))).getSingleOrNull();
        if (prod?.syncId != null) {
          payload.add({
            'id': c.syncId,
            'product_id': prod!.syncId,
            'old_centavos': c.oldCentavos,
            'new_centavos': c.newCentavos,
            'changed_at': c.changedAt.toUtc().toIso8601String(),
            'updated_at': (c.updatedAt ?? DateTime.now().toUtc())
                .toIso8601String(),
          });
        }
      }
      if (payload.isNotEmpty) {
        await client.from('capital_history').upsert(payload).timeout(timeout);
      }
    }

    // 3. Sales
    final sales = await (_db.select(
      _db.sales,
    )..where((s) => s.syncId.isNotNull())).get();
    final salesToPush = lastSync == null
        ? sales
        : sales
              .where(
                (s) => s.updatedAt == null || s.updatedAt!.isAfter(lastSync),
              )
              .toList();
    if (salesToPush.isNotEmpty) {
      final payload = salesToPush
          .map(
            (s) => {
              'id': s.syncId,
              'created_at': s.createdAt.toUtc().toIso8601String(),
              'exact_total_centavos': s.exactTotalCentavos,
              'charged_centavos': s.chargedCentavos,
              'paid_centavos': s.paidCentavos,
              'change_centavos': s.changeCentavos,
              'voided': s.voided,
              'edited_at': s.editedAt?.toUtc().toIso8601String(),
              'edit_count': s.editCount,
              'updated_at': (s.updatedAt ?? DateTime.now().toUtc())
                  .toIso8601String(),
            },
          )
          .toList();
      await client.from('sales').upsert(payload).timeout(timeout);
    }

    // 4. Sale Items
    final items = await (_db.select(
      _db.saleItems,
    )..where((i) => i.syncId.isNotNull())).get();
    final itemsToPush = lastSync == null
        ? items
        : items
              .where(
                (i) => i.updatedAt == null || i.updatedAt!.isAfter(lastSync),
              )
              .toList();
    if (itemsToPush.isNotEmpty) {
      final payload = <Map<String, dynamic>>[];
      for (final item in itemsToPush) {
        final sale = await (_db.select(
          _db.sales,
        )..where((s) => s.id.equals(item.saleId))).getSingleOrNull();
        final prod = await (_db.select(
          _db.products,
        )..where((p) => p.id.equals(item.productId))).getSingleOrNull();
        if (sale?.syncId != null && prod?.syncId != null) {
          payload.add({
            'id': item.syncId,
            'sale_id': sale!.syncId,
            'product_id': prod!.syncId,
            'product_name_snapshot': item.productNameSnapshot,
            'grams': item.grams,
            'price_per_kg_centavos': item.pricePerKgCentavos,
            'capital_per_kg_centavos': item.capitalPerKgCentavos,
            'updated_at': (item.updatedAt ?? DateTime.now().toUtc())
                .toIso8601String(),
            'deleted_at': item.deletedAt?.toUtc().toIso8601String(),
          });
        }
      }
      if (payload.isNotEmpty) {
        await client.from('sale_items').upsert(payload).timeout(timeout);
      }
    }

    // 5. Sale Edits (append-only)
    final edits = await (_db.select(
      _db.saleEdits,
    )..where((e) => e.syncId.isNotNull())).get();
    final editsToPush = lastSync == null
        ? edits
        : edits.where((e) => e.editedAt.isAfter(lastSync)).toList();
    if (editsToPush.isNotEmpty) {
      final payload = <Map<String, dynamic>>[];
      for (final edit in editsToPush) {
        final sale = await (_db.select(
          _db.sales,
        )..where((s) => s.id.equals(edit.saleId))).getSingleOrNull();
        if (sale?.syncId != null) {
          payload.add({
            'id': edit.syncId,
            'sale_id': sale!.syncId,
            'edited_at': edit.editedAt.toUtc().toIso8601String(),
            'before_json': jsonDecode(edit.beforeJson),
            'after_json': jsonDecode(edit.afterJson),
            'reason': edit.reason,
          });
        }
      }
      if (payload.isNotEmpty) {
        await client.from('sale_edits').upsert(payload).timeout(timeout);
      }
    }

    // 6. Expenses
    final exps = await (_db.select(
      _db.expenses,
    )..where((e) => e.syncId.isNotNull())).get();
    final expsToPush = lastSync == null
        ? exps
        : exps
              .where(
                (e) => e.updatedAt == null || e.updatedAt!.isAfter(lastSync),
              )
              .toList();
    if (expsToPush.isNotEmpty) {
      final payload = <Map<String, dynamic>>[];
      for (final ex in expsToPush) {
        String? prodUuid;
        if (ex.productId != null) {
          final prod = await (_db.select(
            _db.products,
          )..where((p) => p.id.equals(ex.productId!))).getSingleOrNull();
          prodUuid = prod?.syncId;
        }
        payload.add({
          'id': ex.syncId,
          'date': ex.date.toUtc().toIso8601String(),
          'type': ex.type,
          'amount_centavos': ex.amountCentavos,
          'note': ex.note,
          'product_id': prodUuid,
          'grams': ex.grams,
          'capital_per_kg_centavos': ex.capitalPerKgCentavos,
          'updated_at': (ex.updatedAt ?? DateTime.now().toUtc())
              .toIso8601String(),
          'deleted_at': ex.deletedAt?.toUtc().toIso8601String(),
        });
      }
      if (payload.isNotEmpty) {
        await client.from('expenses').upsert(payload).timeout(timeout);
      }
    }

    // 7. Restock Purchases
    final restocks = await (_db.select(
      _db.restockPurchases,
    )..where((r) => r.syncId.isNotNull())).get();
    final restocksToPush = lastSync == null
        ? restocks
        : restocks
              .where(
                (r) => r.updatedAt == null || r.updatedAt!.isAfter(lastSync),
              )
              .toList();
    if (restocksToPush.isNotEmpty) {
      final payload = restocksToPush
          .map(
            (r) => {
              'id': r.syncId,
              'date': r.date.toUtc().toIso8601String(),
              'amount_centavos': r.amountCentavos,
              'note': r.note,
              'updated_at': (r.updatedAt ?? DateTime.now().toUtc())
                  .toIso8601String(),
              'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
            },
          )
          .toList();
      await client.from('restock_purchases').upsert(payload).timeout(timeout);
    }

    // 8. Payouts
    final payouts = await (_db.select(
      _db.payouts,
    )..where((p) => p.syncId.isNotNull())).get();
    final payoutsToPush = lastSync == null
        ? payouts
        : payouts
              .where(
                (p) => p.updatedAt == null || p.updatedAt!.isAfter(lastSync),
              )
              .toList();
    if (payoutsToPush.isNotEmpty) {
      final payload = payoutsToPush
          .map(
            (p) => {
              'id': p.syncId,
              'date': p.date.toUtc().toIso8601String(),
              'to_parents_centavos': p.toParentsCentavos,
              'salary_centavos': p.salaryCentavos,
              'reserve_centavos': p.reserveCentavos,
              'locked': p.locked,
              'updated_at': (p.updatedAt ?? DateTime.now().toUtc())
                  .toIso8601String(),
              'deleted_at': p.deletedAt?.toUtc().toIso8601String(),
            },
          )
          .toList();
      await client.from('payouts').upsert(payload).timeout(timeout);
    }

    // 9. Settings
    final settingsList = await (_db.select(
      _db.settings,
    )..where((s) => s.syncId.isNotNull())).get();
    final settingsToPush = lastSync == null
        ? settingsList
        : settingsList
              .where(
                (s) => s.updatedAt == null || s.updatedAt!.isAfter(lastSync),
              )
              .toList();
    if (settingsToPush.isNotEmpty) {
      final payload = settingsToPush
          .map(
            (s) => {
              'id': s.syncId,
              'salary_mode': s.salaryMode,
              'salary_percent_basis_points': s.salaryPercentBasisPoints,
              'fixed_daily_salary_centavos': s.fixedDailySalaryCentavos,
              'updated_at': (s.updatedAt ?? DateTime.now().toUtc())
                  .toIso8601String(),
            },
          )
          .toList();
      await client.from('settings').upsert(payload).timeout(timeout);
    }

    // Clear processed outbox queue
    await _db.delete(_db.outboxItems).go();
  }

  /// Pulls updated records from Supabase across all tables and applies them to local SQLite.
  Future<void> _pullChanges(SupabaseClient client) async {
    const timeout = Duration(seconds: 10);
    final lastSync = _lastSyncedAt;
    final lastSyncIso = lastSync?.toIso8601String();

    // 1. Pull Products
    var prodQuery = client.from('products').select();
    if (lastSyncIso != null) {
      prodQuery = prodQuery.gt('updated_at', lastSyncIso);
    }
    final remoteProds = await prodQuery.timeout(timeout);
    for (final p in remoteProds) {
      final remoteSyncId = p['id'] as String;
      final existing = await (_db.select(
        _db.products,
      )..where((tbl) => tbl.syncId.equals(remoteSyncId))).getSingleOrNull();

      final updatedAt = DateTime.parse(p['updated_at'] as String);
      final deletedAt = p['deleted_at'] != null
          ? DateTime.parse(p['deleted_at'] as String)
          : null;

      String? resolvedImagePath;
      final remoteImagePath = p['image_path'] as String?;

      if (remoteImagePath != null && remoteImagePath.isNotEmpty) {
        if (remoteImagePath.startsWith('data:image/')) {
          try {
            final commaIdx = remoteImagePath.indexOf(',');
            final base64Data = commaIdx != -1
                ? remoteImagePath.substring(commaIdx + 1)
                : remoteImagePath;
            final imageBytes = base64Decode(base64Data);

            final imagesDir = await _getImagesDirectory();
            final targetFilePath = p_path.join(
              imagesDir.path,
              'product_$remoteSyncId.jpg',
            );
            final targetFile = File(targetFilePath);

            if (!await targetFile.exists() ||
                await targetFile.length() != imageBytes.length) {
              await targetFile.writeAsBytes(imageBytes, flush: true);
            }
            resolvedImagePath = targetFilePath;
          } catch (_) {
            resolvedImagePath = existing?.imagePath;
          }
        } else {
          try {
            if (File(remoteImagePath).existsSync()) {
              resolvedImagePath = remoteImagePath;
            } else {
              resolvedImagePath = null;
            }
          } catch (_) {
            resolvedImagePath = null;
          }
        }
      } else {
        resolvedImagePath = null;
      }

      // Clean up old file if photo was removed or replaced
      if (existing != null &&
          existing.imagePath != null &&
          existing.imagePath != resolvedImagePath) {
        try {
          final oldFile = File(existing.imagePath!);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (_) {}
      }

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
            imagePath: Value(resolvedImagePath),
            updatedAt: Value(updatedAt),
            deletedAt: Value(deletedAt),
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
                imagePath: Value(resolvedImagePath),
                updatedAt: Value(updatedAt),
                deletedAt: Value(deletedAt),
              ),
            );
      }
    }

    // 2. Pull Capital History
    var capsQuery = client.from('capital_history').select();
    if (lastSyncIso != null) {
      capsQuery = capsQuery.gt('updated_at', lastSyncIso);
    }
    final remoteCaps = await capsQuery.timeout(timeout);
    for (final c in remoteCaps) {
      final remoteSyncId = c['id'] as String;
      final prodSyncId = c['product_id'] as String;
      final localProd = await (_db.select(
        _db.products,
      )..where((p) => p.syncId.equals(prodSyncId))).getSingleOrNull();
      if (localProd == null) continue;

      final existing = await (_db.select(
        _db.capitalHistory,
      )..where((tbl) => tbl.syncId.equals(remoteSyncId))).getSingleOrNull();

      if (existing == null) {
        await _db
            .into(_db.capitalHistory)
            .insert(
              CapitalHistoryCompanion.insert(
                syncId: Value(remoteSyncId),
                productId: localProd.id,
                oldCentavos: c['old_centavos'] as int,
                newCentavos: c['new_centavos'] as int,
                changedAt: DateTime.parse(c['changed_at'] as String),
                updatedAt: Value(DateTime.parse(c['updated_at'] as String)),
              ),
            );
      }
    }

    // 3. Pull Sales
    var salesQuery = client.from('sales').select();
    if (lastSyncIso != null) {
      salesQuery = salesQuery.gt('updated_at', lastSyncIso);
    }
    final remoteSales = await salesQuery.timeout(timeout);
    for (final s in remoteSales) {
      final remoteSyncId = s['id'] as String;
      final existing = await (_db.select(
        _db.sales,
      )..where((tbl) => tbl.syncId.equals(remoteSyncId))).getSingleOrNull();

      final createdAt = DateTime.parse(s['created_at'] as String);
      final editedAt = s['edited_at'] != null
          ? DateTime.parse(s['edited_at'] as String)
          : null;
      final updatedAt = DateTime.parse(s['updated_at'] as String);
      final deletedAt = s['deleted_at'] != null
          ? DateTime.parse(s['deleted_at'] as String)
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
            updatedAt: Value(updatedAt),
            deletedAt: Value(deletedAt),
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
                updatedAt: Value(updatedAt),
                deletedAt: Value(deletedAt),
              ),
            );
      }
    }

    // 4. Pull Sale Items
    var itemsQuery = client.from('sale_items').select();
    if (lastSyncIso != null) {
      itemsQuery = itemsQuery.gt('updated_at', lastSyncIso);
    }
    final remoteItems = await itemsQuery.timeout(timeout);
    for (final item in remoteItems) {
      final remoteSyncId = item['id'] as String;
      final saleUuid = item['sale_id'] as String;
      final prodUuid = item['product_id'] as String;

      final localSale = await (_db.select(
        _db.sales,
      )..where((s) => s.syncId.equals(saleUuid))).getSingleOrNull();
      final localProd = await (_db.select(
        _db.products,
      )..where((p) => p.syncId.equals(prodUuid))).getSingleOrNull();
      if (localSale == null || localProd == null) continue;

      final existing = await (_db.select(
        _db.saleItems,
      )..where((tbl) => tbl.syncId.equals(remoteSyncId))).getSingleOrNull();
      final updatedAt = DateTime.parse(item['updated_at'] as String);
      final deletedAt = item['deleted_at'] != null
          ? DateTime.parse(item['deleted_at'] as String)
          : null;

      if (existing != null) {
        await (_db.update(
          _db.saleItems,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          SaleItemsCompanion(
            productNameSnapshot: Value(item['product_name_snapshot'] as String),
            grams: Value(item['grams'] as int),
            pricePerKgCentavos: Value(item['price_per_kg_centavos'] as int),
            capitalPerKgCentavos: Value(item['capital_per_kg_centavos'] as int),
            updatedAt: Value(updatedAt),
            deletedAt: Value(deletedAt),
          ),
        );
      } else {
        await _db
            .into(_db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                syncId: Value(remoteSyncId),
                saleId: localSale.id,
                productId: localProd.id,
                productNameSnapshot: item['product_name_snapshot'] as String,
                grams: item['grams'] as int,
                pricePerKgCentavos: item['price_per_kg_centavos'] as int,
                capitalPerKgCentavos: item['capital_per_kg_centavos'] as int,
                updatedAt: Value(updatedAt),
                deletedAt: Value(deletedAt),
              ),
            );
      }
    }

    // 5. Pull Sale Edits (append-only ledger)
    var editsQuery = client.from('sale_edits').select();
    if (lastSyncIso != null) {
      editsQuery = editsQuery.gt('created_at', lastSyncIso);
    }
    final remoteEdits = await editsQuery.timeout(timeout);
    for (final e in remoteEdits) {
      final remoteSyncId = e['id'] as String;
      final existing = await (_db.select(
        _db.saleEdits,
      )..where((tbl) => tbl.syncId.equals(remoteSyncId))).getSingleOrNull();

      if (existing == null) {
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

    // 6. Pull Expenses
    var expQuery = client.from('expenses').select();
    if (lastSyncIso != null) {
      expQuery = expQuery.gt('updated_at', lastSyncIso);
    }
    final remoteExpenses = await expQuery.timeout(timeout);
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

      final updatedAt = DateTime.parse(ex['updated_at'] as String);
      final deletedAt = ex['deleted_at'] != null
          ? DateTime.parse(ex['deleted_at'] as String)
          : null;

      if (existing != null) {
        await (_db.update(
          _db.expenses,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          ExpensesCompanion(
            amountCentavos: Value(ex['amount_centavos'] as int),
            note: Value(ex['note'] as String?),
            productId: Value(localProductId),
            grams: Value(ex['grams'] as int?),
            capitalPerKgCentavos: Value(ex['capital_per_kg_centavos'] as int?),
            updatedAt: Value(updatedAt),
            deletedAt: Value(deletedAt),
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
                updatedAt: Value(updatedAt),
                deletedAt: Value(deletedAt),
              ),
            );
      }
    }

    // 7. Pull Restock Purchases
    var restockQuery = client.from('restock_purchases').select();
    if (lastSyncIso != null) {
      restockQuery = restockQuery.gt('updated_at', lastSyncIso);
    }
    final remoteRestocks = await restockQuery.timeout(timeout);
    for (final r in remoteRestocks) {
      final remoteSyncId = r['id'] as String;
      final existing = await (_db.select(
        _db.restockPurchases,
      )..where((tbl) => tbl.syncId.equals(remoteSyncId))).getSingleOrNull();

      final updatedAt = DateTime.parse(r['updated_at'] as String);
      final deletedAt = r['deleted_at'] != null
          ? DateTime.parse(r['deleted_at'] as String)
          : null;

      if (existing != null) {
        await (_db.update(
          _db.restockPurchases,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          RestockPurchasesCompanion(
            amountCentavos: Value(r['amount_centavos'] as int),
            note: Value(r['note'] as String?),
            updatedAt: Value(updatedAt),
            deletedAt: Value(deletedAt),
          ),
        );
      } else {
        await _db
            .into(_db.restockPurchases)
            .insert(
              RestockPurchasesCompanion.insert(
                syncId: Value(remoteSyncId),
                date: DateTime.parse(r['date'] as String),
                amountCentavos: r['amount_centavos'] as int,
                note: Value(r['note'] as String?),
                updatedAt: Value(updatedAt),
                deletedAt: Value(deletedAt),
              ),
            );
      }
    }

    // 8. Pull Payouts
    var payoutQuery = client.from('payouts').select();
    if (lastSyncIso != null) {
      payoutQuery = payoutQuery.gt('updated_at', lastSyncIso);
    }
    final remotePayouts = await payoutQuery.timeout(timeout);
    for (final py in remotePayouts) {
      final remoteSyncId = py['id'] as String;
      final existing = await (_db.select(
        _db.payouts,
      )..where((tbl) => tbl.syncId.equals(remoteSyncId))).getSingleOrNull();

      final updatedAt = DateTime.parse(py['updated_at'] as String);
      final deletedAt = py['deleted_at'] != null
          ? DateTime.parse(py['deleted_at'] as String)
          : null;

      if (existing != null) {
        await (_db.update(
          _db.payouts,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          PayoutsCompanion(
            toParentsCentavos: Value(py['to_parents_centavos'] as int),
            salaryCentavos: Value(py['salary_centavos'] as int),
            reserveCentavos: Value(py['reserve_centavos'] as int),
            locked: Value(py['locked'] as bool? ?? false),
            updatedAt: Value(updatedAt),
            deletedAt: Value(deletedAt),
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
                updatedAt: Value(updatedAt),
                deletedAt: Value(deletedAt),
              ),
            );
      }
    }

    // 9. Pull Settings
    var settingsQuery = client.from('settings').select();
    if (lastSyncIso != null) {
      settingsQuery = settingsQuery.gt('updated_at', lastSyncIso);
    }
    final remoteSettings = await settingsQuery.timeout(timeout);
    for (final st in remoteSettings) {
      final remoteSyncId = st['id'] as String;
      final existing = await _db.select(_db.settings).getSingleOrNull();
      final updatedAt = DateTime.parse(st['updated_at'] as String);

      if (existing != null) {
        await (_db.update(
          _db.settings,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          SettingsCompanion(
            syncId: Value(remoteSyncId),
            salaryMode: Value(st['salary_mode'] as String),
            salaryPercentBasisPoints: Value(
              st['salary_percent_basis_points'] as int,
            ),
            fixedDailySalaryCentavos: Value(
              st['fixed_daily_salary_centavos'] as int,
            ),
            updatedAt: Value(updatedAt),
          ),
        );
      }
    }
  }
}
