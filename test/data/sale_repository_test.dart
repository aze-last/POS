import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos/data/database/app_database.dart';
import 'package:pos/data/repositories/sale_repository.dart';
import 'package:pos/domain/models/weight.dart';

void main() {
  late AppDatabase db;
  late SaleRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = SaleRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SaleRepository', () {
    test('completes sale with snapshots and correct change in a single transaction', () async {
      final products = await db.getAllActiveProducts();
      final cardava = products.firstWhere(
        (p) => p.name == 'Cardava',
      ); // P30.00/kg, Cap 20.00
      final tundan = products.firstWhere(
        (p) => p.name == 'Tundan',
      ); // P40.00/kg, Cap 30.00

      final saleResult = await repository.completeSale(
        lines: [
          SaleLineInput(
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(1300),
            pricePerKgCentavos: 3000,
            capitalPerKgCentavos: cardava.capitalCentavos,
          ),
          SaleLineInput(
            productId: tundan.id,
            productName: tundan.name,
            weight: Weight.fromGrams(500),
            pricePerKgCentavos: 4000,
            capitalPerKgCentavos: tundan.capitalCentavos,
          ),
        ],
        chargedCentavos: 5900,
        paidCentavos: 10000,
      );

      expect(saleResult.sale.exactTotalCentavos, equals(5900));
      expect(saleResult.sale.chargedCentavos, equals(5900));
      expect(saleResult.sale.paidCentavos, equals(10000));
      expect(saleResult.sale.changeCentavos, equals(4100));
      expect(saleResult.sale.voided, isFalse);
      expect(saleResult.items.length, equals(2));

      final item1 = saleResult.items.firstWhere(
        (i) => i.productId == cardava.id,
      );
      expect(item1.productNameSnapshot, equals('Cardava'));
      expect(item1.grams, equals(1300));
      expect(item1.pricePerKgCentavos, equals(3000));
      expect(item1.capitalPerKgCentavos, equals(2000));

      final item2 = saleResult.items.firstWhere(
        (i) => i.productId == tundan.id,
      );
      expect(item2.productNameSnapshot, equals('Tundan'));
      expect(item2.grams, equals(500));
      expect(item2.pricePerKgCentavos, equals(4000));
      expect(item2.capitalPerKgCentavos, equals(3000));
    });

    test('records discount and allocates across lines proportionally using largest-remainder', () async {
      final products = await db.getAllActiveProducts();
      final cardava = products.firstWhere((p) => p.name == 'Cardava');

      final result = await repository.completeSale(
        lines: [
          SaleLineInput(
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(1000),
            pricePerKgCentavos: 3000,
            capitalPerKgCentavos: cardava.capitalCentavos,
          ),
        ],
        chargedCentavos: 2900,
        paidCentavos: 3000,
      );

      expect(result.sale.exactTotalCentavos, equals(3000));
      expect(result.sale.chargedCentavos, equals(2900));
      expect(result.discountCentavos, equals(100));
      expect(result.sale.changeCentavos, equals(100));
    });

    test('rejects sale completion if paid < charged or empty lines', () async {
      expect(
        () => repository.completeSale(
          lines: [],
          chargedCentavos: 1000,
          paidCentavos: 1000,
        ),
        throwsArgumentError,
      );

      final products = await db.getAllActiveProducts();
      final cardava = products.first;

      expect(
        () => repository.completeSale(
          lines: [
            SaleLineInput(
              productId: cardava.id,
              productName: cardava.name,
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: cardava.capitalCentavos,
            ),
          ],
          chargedCentavos: 3000,
          paidCentavos: 2000,
        ),
        throwsArgumentError,
      );
    });

    test('future catalog updates do not alter past sale item snapshot prices or capital', () async {
      final products = await db.getAllActiveProducts();
      final cardava = products.firstWhere((p) => p.name == 'Cardava');

      final result = await repository.completeSale(
        lines: [
          SaleLineInput(
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(1000),
            pricePerKgCentavos: cardava.defaultPriceCentavos,
            capitalPerKgCentavos: cardava.capitalCentavos,
          ),
        ],
        chargedCentavos: cardava.defaultPriceCentavos,
        paidCentavos: cardava.defaultPriceCentavos,
      );

      await (db.update(
        db.products,
      )..where((p) => p.id.equals(cardava.id))).write(
        const ProductsCompanion(
          defaultPriceCentavos: Value(9999),
          capitalCentavos: Value(8888),
        ),
      );

      final storedItems = await (db.select(
        db.saleItems,
      )..where((i) => i.saleId.equals(result.sale.id))).get();
      expect(storedItems.single.pricePerKgCentavos, equals(3000));
      expect(storedItems.single.capitalPerKgCentavos, equals(2000));
      expect(storedItems.single.productNameSnapshot, equals('Cardava'));
    });

    test('retrieves sales with details and computes profit from snapshotted capital', () async {
      final products = await db.getAllActiveProducts();
      final cardava = products.firstWhere(
        (p) => p.name == 'Cardava',
      ); // Price 3000, Cap 2000

      // Sale 1: 1000g Cardava @ 3000. Capital cost = 2000. Profit = 3000 - 2000 = 1000 centavos
      await repository.completeSale(
        lines: [
          SaleLineInput(
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(1000),
            pricePerKgCentavos: 3000,
            capitalPerKgCentavos: cardava.capitalCentavos,
          ),
        ],
        chargedCentavos: 3000,
        paidCentavos: 3000,
      );

      final salesWithDetails = await repository.getSalesWithDetails();
      expect(salesWithDetails.length, equals(1));
      final detail = salesWithDetails.first;
      expect(detail.sale.chargedCentavos, equals(3000));
      expect(detail.totalCapitalCentavos, equals(2000));
      expect(detail.profitCentavos, equals(1000));
      expect(detail.sale.voided, isFalse);
    });

    test('voids a sale and flags it without hard-deleting record', () async {
      final products = await db.getAllActiveProducts();
      final cardava = products.first;

      final result = await repository.completeSale(
        lines: [
          SaleLineInput(
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(1000),
            pricePerKgCentavos: cardava.defaultPriceCentavos,
            capitalPerKgCentavos: cardava.capitalCentavos,
          ),
        ],
        chargedCentavos: cardava.defaultPriceCentavos,
        paidCentavos: cardava.defaultPriceCentavos,
      );

      await repository.voidSale(result.sale.id);

      final sales = await repository.getSalesWithDetails();
      expect(sales.length, equals(1));
      expect(sales.first.sale.voided, isTrue);

      // Verify the record and its items are still in SQLite (not deleted)
      final rawSale = await (db.select(
        db.sales,
      )..where((s) => s.id.equals(result.sale.id))).getSingle();
      expect(rawSale.voided, isTrue);
      final rawItems = await (db.select(
        db.saleItems,
      )..where((i) => i.saleId.equals(result.sale.id))).get();
      expect(rawItems.length, equals(1));
    });

    test('prevents voiding or editing sales when day payout is locked unless reopened', () async {
      final products = await db.getAllActiveProducts();
      final cardava = products.first;
      final saleDate = DateTime(2026, 11, 15, 10, 0);

      final result = await repository.completeSale(
        lines: [
          SaleLineInput(
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(1000),
            pricePerKgCentavos: cardava.defaultPriceCentavos,
            capitalPerKgCentavos: cardava.capitalCentavos,
          ),
        ],
        chargedCentavos: cardava.defaultPriceCentavos,
        paidCentavos: cardava.defaultPriceCentavos,
        createdAt: saleDate,
      );

      // Lock the day in payouts table
      await db
          .into(db.payouts)
          .insert(
            PayoutsCompanion.insert(
              date: DateTime(2026, 11, 15),
              toParentsCentavos: 2000,
              salaryCentavos: 500,
              reserveCentavos: 500,
              locked: const Value(true),
            ),
          );

      expect(await repository.isDayLocked(saleDate), isTrue);

      // Voiding must fail with SaleModificationLockedException
      await expectLater(
        repository.voidSale(result.sale.id),
        throwsA(isA<SaleModificationLockedException>()),
      );

      // Reopen day
      await repository.reopenDay(saleDate);
      expect(await repository.isDayLocked(saleDate), isFalse);

      // Now voiding succeeds
      await repository.voidSale(result.sale.id);
      final updated = await repository.getSaleById(result.sale.id);
      expect(updated!.sale.voided, isTrue);
    });
  });
}
