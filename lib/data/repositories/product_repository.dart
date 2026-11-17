import 'package:drift/drift.dart';

import '../../domain/models/product_validator.dart';
import '../database/app_database.dart';

/// Exception thrown when product data violates business rules.
class ProductValidationException implements Exception {
  final String message;
  const ProductValidationException(this.message);

  @override
  String toString() => message;
}

/// Repository managing product catalog, pricing, and immutable capital history.
///
/// Adheres strictly to:
/// - No hard deletes (soft-archive only, preserving historical sales)
/// - Capital updates write to `capital_history`
/// - Price and capital must be strictly > 0
/// - Product names must be unique among active products (case-insensitively)
class ProductRepository {
  final AppDatabase _db;

  ProductRepository(this._db);

  /// Fetches all active products ordered by sortOrder.
  Future<List<Product>> getActiveProducts() {
    return (_db.select(_db.products)
          ..where((p) => p.archived.equals(false))
          ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
        .get();
  }

  /// Streams active products for real-time reactive UI updates.
  Stream<List<Product>> watchActiveProducts() {
    return (_db.select(_db.products)
          ..where((p) => p.archived.equals(false))
          ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
        .watch();
  }

  /// Fetches all archived products.
  Future<List<Product>> getArchivedProducts() {
    return (_db.select(_db.products)
          ..where((p) => p.archived.equals(true))
          ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
        .get();
  }

  /// Streams archived products for reactive updates.
  Stream<List<Product>> watchArchivedProducts() {
    return (_db.select(_db.products)
          ..where((p) => p.archived.equals(true))
          ..orderBy([(p) => OrderingTerm(expression: p.sortOrder)]))
        .watch();
  }

  /// Retrieves a single product by ID.
  Future<Product?> getProductById(int id) {
    return (_db.select(
      _db.products,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// Creates a new product at the end of the catalog.
  Future<Product> createProduct({
    required String name,
    required int defaultPriceCentavos,
    required int capitalCentavos,
    String? imagePath,
  }) async {
    final nameErr = ProductValidator.validateName(name);
    if (nameErr != null) throw ProductValidationException(nameErr);

    final priceErr = ProductValidator.validatePriceCentavos(
      defaultPriceCentavos,
    );
    if (priceErr != null) throw ProductValidationException(priceErr);

    final capErr = ProductValidator.validateCapitalCentavos(capitalCentavos);
    if (capErr != null) throw ProductValidationException(capErr);

    final cleanName = name.trim();

    // Name must be unique among ACTIVE products (case-insensitive check)
    final active = await getActiveProducts();
    final lowerName = cleanName.toLowerCase();
    if (active.any((p) => p.name.toLowerCase() == lowerName)) {
      throw ProductValidationException(
        'An active product with the name "$cleanName" already exists',
      );
    }

    // Determine next sort order
    final maxSortOrderResult = await _db
        .customSelect(
          'SELECT MAX(sort_order) as max_order FROM products WHERE archived = 0',
        )
        .getSingleOrNull();
    final nextSortOrder =
        (maxSortOrderResult?.data['max_order'] as int? ?? -1) + 1;

    final id = await _db
        .into(_db.products)
        .insert(
          ProductsCompanion.insert(
            name: cleanName,
            defaultPriceCentavos: defaultPriceCentavos,
            capitalCentavos: capitalCentavos,
            sortOrder: Value(nextSortOrder),
            archived: const Value(false),
            imagePath: Value(imagePath),
          ),
        );

    return (await getProductById(id))!;
  }

  /// Updates product details. If capital changes, records an immutable entry in capital_history.
  Future<Product> updateProduct({
    required int id,
    required String name,
    required int defaultPriceCentavos,
    required int capitalCentavos,
    String? imagePath,
    bool updateImage = false,
  }) async {
    final nameErr = ProductValidator.validateName(name);
    if (nameErr != null) throw ProductValidationException(nameErr);

    final priceErr = ProductValidator.validatePriceCentavos(
      defaultPriceCentavos,
    );
    if (priceErr != null) throw ProductValidationException(priceErr);

    final capErr = ProductValidator.validateCapitalCentavos(capitalCentavos);
    if (capErr != null) throw ProductValidationException(capErr);

    final cleanName = name.trim();

    final current = await getProductById(id);
    if (current == null) {
      throw ProductValidationException('Product with id $id not found');
    }

    // Name must be unique among other active products (case-insensitive)
    final active = await getActiveProducts();
    final lowerName = cleanName.toLowerCase();
    if (active.any((p) => p.id != id && p.name.toLowerCase() == lowerName)) {
      throw ProductValidationException(
        'Another active product named "$cleanName" already exists',
      );
    }

    await _db.transaction(() async {
      // If capital changed, record history (Spec Section 5.2)
      if (current.capitalCentavos != capitalCentavos) {
        await _db
            .into(_db.capitalHistory)
            .insert(
              CapitalHistoryCompanion.insert(
                productId: id,
                oldCentavos: current.capitalCentavos,
                newCentavos: capitalCentavos,
                changedAt: DateTime.now(),
              ),
            );
      }

      // Update product record
      await (_db.update(_db.products)..where((p) => p.id.equals(id))).write(
        ProductsCompanion(
          name: Value(cleanName),
          defaultPriceCentavos: Value(defaultPriceCentavos),
          capitalCentavos: Value(capitalCentavos),
          imagePath: updateImage ? Value(imagePath) : const Value.absent(),
        ),
      );
    });

    return (await getProductById(id))!;
  }

  /// Soft-archives product (never hard-deletes).
  Future<void> archiveProduct(int id) async {
    await (_db.update(_db.products)..where((p) => p.id.equals(id))).write(
      const ProductsCompanion(archived: Value(true)),
    );
  }

  /// Restores an archived product to the active catalog at the end of sort order.
  Future<void> restoreProduct(int id) async {
    final product = await getProductById(id);
    if (product == null) return;

    // Check if another active product already took this name (case-insensitive)
    final active = await getActiveProducts();
    final lowerName = product.name.toLowerCase();
    if (active.any((p) => p.name.toLowerCase() == lowerName)) {
      throw ProductValidationException(
        'Cannot restore: An active product with the name "${product.name}" already exists',
      );
    }

    final maxSortOrderResult = await _db
        .customSelect(
          'SELECT MAX(sort_order) as max_order FROM products WHERE archived = 0',
        )
        .getSingleOrNull();
    final nextSortOrder =
        (maxSortOrderResult?.data['max_order'] as int? ?? -1) + 1;

    await (_db.update(_db.products)..where((p) => p.id.equals(id))).write(
      ProductsCompanion(
        archived: const Value(false),
        sortOrder: Value(nextSortOrder),
      ),
    );
  }

  /// Updates the sort_order of active products after validating the list.
  Future<void> reorderProducts(List<int> orderedIds) async {
    final active = await getActiveProducts();
    final activeIds = active.map((p) => p.id).toSet();

    if (orderedIds.length != active.length ||
        orderedIds.toSet().length != orderedIds.length ||
        !orderedIds.every(activeIds.contains)) {
      throw const ProductValidationException(
        'Reorder list must contain all active product IDs exactly once',
      );
    }

    await _db.transaction(() async {
      for (int i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.products)
              ..where((p) => p.id.equals(orderedIds[i])))
            .write(ProductsCompanion(sortOrder: Value(i)));
      }
    });
  }

  /// Retrieves the capital change history for a product.
  Future<List<CapitalHistoryData>> getCapitalHistory(int productId) {
    return (_db.select(_db.capitalHistory)
          ..where((h) => h.productId.equals(productId))
          ..orderBy([
            (h) =>
                OrderingTerm(expression: h.changedAt, mode: OrderingMode.desc),
            (h) => OrderingTerm(expression: h.id, mode: OrderingMode.desc),
          ]))
        .get();
  }
}
