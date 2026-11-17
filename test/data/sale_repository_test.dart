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

    test('editSale recomputes line value, exact total, discount, change, and profit when grams change, preserving capital snapshot', () async {
      final products = await db.getAllActiveProducts();
      final cardava = products.firstWhere(
        (p) => p.name == 'Cardava',
      ); // Price 3000, Cap 2000

      // Original sale: 1000g @ 3000/kg = 3000 centavos, Charged 3000, Paid 3000, Profit 1000
      final original = await repository.completeSale(
        lines: [
          SaleLineInput(
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(1000),
            pricePerKgCentavos: 3000,
            capitalPerKgCentavos: 2000,
          ),
        ],
        chargedCentavos: 3000,
        paidCentavos: 3000,
      );

      final originalItem = original.items.single;

      // Edit sale: change grams from 1000g to 2000g, charge 5500 (500 discount), paid 6000
      final editedResult = await repository.editSale(
        saleId: original.sale.id,
        newLines: [
          SaleLineInput(
            originalItemId: originalItem.id,
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(2000),
            pricePerKgCentavos: 3000,
            capitalPerKgCentavos: 9999, // Intentional dummy: should be ignored in favor of snapshot 2000
          ),
        ],
        chargedCentavos: 5500,
        paidCentavos: 6000,
        reason: 'Customer requested 1 more kilo with discount',
      );

      // Line value: 2000g @ 3000 = 6000 centavos
      expect(editedResult.sale.exactTotalCentavos, equals(6000));
      expect(editedResult.sale.chargedCentavos, equals(5500));
      expect(editedResult.discountCentavos, equals(500));
      expect(editedResult.sale.paidCentavos, equals(6000));
      expect(editedResult.sale.changeCentavos, equals(500));
      expect(editedResult.sale.editCount, equals(1));
      expect(editedResult.sale.editedAt != null, isTrue);

      // Capital snapshot must remain 2000 (not 9999)
      final editedItem = editedResult.items.single;
      expect(editedItem.capitalPerKgCentavos, equals(2000));
      expect(editedItem.grams, equals(2000));

      // Profit recomputed from snapshot: 5500 charged - (2000g @ 2000/kg = 4000) = 1500 centavos
      final details = await repository.getSalesWithDetails();
      expect(details.single.profitCentavos, equals(1500));

      // Audit trail must be recorded in sale_edits
      final edits = await repository.getSaleEdits(original.sale.id);
      expect(edits.length, equals(1));
      expect(
        edits.single.reason,
        equals('Customer requested 1 more kilo with discount'),
      );
      expect(
        edits.single.beforeJson.contains('"exact_total_centavos":3000'),
        isTrue,
      );
      expect(
        edits.single.afterJson.contains('"exact_total_centavos":6000'),
        isTrue,
      );
    });

    test(
      'editSale uses current catalog capital for new or changed product lines',
      () async {
        final products = await db.getAllActiveProducts();
        final cardava = products.firstWhere((p) => p.name == 'Cardava');
        final tundan = products.firstWhere(
          (p) => p.name == 'Tundan',
        ); // Cap 3000

        // Original sale with Cardava
        final original = await repository.completeSale(
          lines: [
            SaleLineInput(
              productId: cardava.id,
              productName: cardava.name,
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          ],
          chargedCentavos: 3000,
          paidCentavos: 3000,
        );

        final originalItem = original.items.single;

        // Update Tundan catalog capital to 3500
        await (db.update(db.products)..where((p) => p.id.equals(tundan.id)))
            .write(const ProductsCompanion(capitalCentavos: Value(3500)));

        // Edit sale: change line from Cardava to Tundan
        final editedResult = await repository.editSale(
          saleId: original.sale.id,
          newLines: [
            SaleLineInput(
              originalItemId: originalItem.id, // was Cardava
              productId: tundan.id, // now changed to Tundan
              productName: tundan.name,
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 4000,
              capitalPerKgCentavos: 0,
            ),
            // Also add a new line of Cardava (new line: must use current catalog capital)
            SaleLineInput(
              originalItemId: null,
              productId: cardava.id,
              productName: cardava.name,
              weight: Weight.fromGrams(500),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 0,
            ),
          ],
          chargedCentavos: 5500,
          paidCentavos: 6000,
        );

        // Changed line (Tundan) must snapshot current catalog capital 3500
        final tundanItem = editedResult.items.firstWhere(
          (i) => i.productId == tundan.id,
        );
        expect(tundanItem.capitalPerKgCentavos, equals(3500));

        // Newly added line (Cardava) snapshots current catalog capital 2000
        final cardavaItem = editedResult.items.firstWhere(
          (i) => i.productId == cardava.id,
        );
        expect(cardavaItem.capitalPerKgCentavos, equals(2000));
      },
    );

    test('editSale preserves profit of untouched lines when catalog capital changed post-sale', () async {
      final products = await db.getAllActiveProducts();
      final cardava = products.firstWhere(
        (p) => p.name == 'Cardava',
      ); // Cap 2000

      // Original sale
      final original = await repository.completeSale(
        lines: [
          SaleLineInput(
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(1000),
            pricePerKgCentavos: 3000,
            capitalPerKgCentavos: 2000,
          ),
        ],
        chargedCentavos: 3000,
        paidCentavos: 3000,
      );

      // Catalog capital changed AFTER sale to 2800
      await (db.update(db.products)..where((p) => p.id.equals(cardava.id)))
          .write(const ProductsCompanion(capitalCentavos: Value(2800)));

      // Edit sale: only adjust paid amount without touching line
      final originalItem = original.items.single;
      await repository.editSale(
        saleId: original.sale.id,
        newLines: [
          SaleLineInput(
            originalItemId: originalItem.id,
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(1000),
            pricePerKgCentavos: 3000,
            capitalPerKgCentavos: 9999,
          ),
        ],
        chargedCentavos: 3000,
        paidCentavos: 5000,
      );

      // Capital snapshot must still be 2000 and profit must still be 1000
      final details = await repository.getSalesWithDetails();
      expect(details.single.items.single.capitalPerKgCentavos, equals(2000));
      expect(details.single.profitCentavos, equals(1000));
    });

    test(
      'removing lines down to 1 is allowed; removing last line is blocked',
      () async {
        final products = await db.getAllActiveProducts();
        final cardava = products.first;
        final tundan = products[1];

        // 2-line sale
        final original = await repository.completeSale(
          lines: [
            SaleLineInput(
              productId: cardava.id,
              productName: cardava.name,
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
            SaleLineInput(
              productId: tundan.id,
              productName: tundan.name,
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 4000,
              capitalPerKgCentavos: 3000,
            ),
          ],
          chargedCentavos: 7000,
          paidCentavos: 7000,
        );

        // Remove 1 line -> 1 line remaining -> valid
        final edit1 = await repository.editSale(
          saleId: original.sale.id,
          newLines: [
            SaleLineInput(
              originalItemId: original.items.first.id,
              productId: cardava.id,
              productName: cardava.name,
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          ],
          chargedCentavos: 3000,
          paidCentavos: 3000,
        );
        expect(edit1.items.length, equals(1));

        // Attempt to remove all lines (0 lines) -> must throw
        await expectLater(
          repository.editSale(
            saleId: original.sale.id,
            newLines: [],
            chargedCentavos: 1000,
            paidCentavos: 1000,
          ),
          throwsArgumentError,
        );
      },
    );

    test('edit with discount allocates across 1, 2, 3, and 7 lines summing exactly to discount', () async {
      final products = await db.getAllActiveProducts();
      final cardava = products.first;

      for (final lineCount in [1, 2, 3, 7]) {
        final original = await repository.completeSale(
          lines: [
            for (int i = 0; i < lineCount; i++)
              SaleLineInput(
                productId: cardava.id,
                productName: cardava.name,
                weight: Weight.fromGrams(1000 + i * 100),
                pricePerKgCentavos: 3000,
                capitalPerKgCentavos: 2000,
              ),
          ],
          chargedCentavos: 3000 * lineCount,
          paidCentavos: 3000 * lineCount + 1000,
        );

        final exactTotal = original.sale.exactTotalCentavos;
        final chargedWithDiscount = exactTotal - 350; // 350 centavos discount

        final editResult = await repository.editSale(
          saleId: original.sale.id,
          newLines: [
            for (final item in original.items)
              SaleLineInput(
                originalItemId: item.id,
                productId: item.productId,
                productName: item.productNameSnapshot,
                weight: Weight.fromGrams(item.grams),
                pricePerKgCentavos: item.pricePerKgCentavos,
                capitalPerKgCentavos: item.capitalPerKgCentavos,
              ),
          ],
          chargedCentavos: chargedWithDiscount,
          paidCentavos: exactTotal,
        );

        expect(editResult.discountCentavos, equals(350));
      }
    });

    test('edit that makes paid < charged is rejected', () async {
      final products = await db.getAllActiveProducts();
      final cardava = products.first;

      final original = await repository.completeSale(
        lines: [
          SaleLineInput(
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(1000),
            pricePerKgCentavos: 3000,
            capitalPerKgCentavos: 2000,
          ),
        ],
        chargedCentavos: 3000,
        paidCentavos: 3000,
      );

      await expectLater(
        repository.editSale(
          saleId: original.sale.id,
          newLines: [
            SaleLineInput(
              originalItemId: original.items.single.id,
              productId: cardava.id,
              productName: cardava.name,
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          ],
          chargedCentavos: 3000,
          paidCentavos: 2500, // paid < charged
        ),
        throwsArgumentError,
      );
    });

    test('chained edits: editing then editing again records 2 chronological sale_edits rows', () async {
      final products = await db.getAllActiveProducts();
      final cardava = products.first;

      final original = await repository.completeSale(
        lines: [
          SaleLineInput(
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(1000),
            pricePerKgCentavos: 3000,
            capitalPerKgCentavos: 2000,
          ),
        ],
        chargedCentavos: 3000,
        paidCentavos: 3000,
      );

      // Edit 1
      await repository.editSale(
        saleId: original.sale.id,
        newLines: [
          SaleLineInput(
            originalItemId: original.items.single.id,
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(1500),
            pricePerKgCentavos: 3000,
            capitalPerKgCentavos: 2000,
          ),
        ],
        chargedCentavos: 4500,
        paidCentavos: 5000,
        reason: 'Added 500g',
      );

      // Edit 2
      final edit1Items = await (db.select(
        db.saleItems,
      )..where((i) => i.saleId.equals(original.sale.id))).get();
      await repository.editSale(
        saleId: original.sale.id,
        newLines: [
          SaleLineInput(
            originalItemId: edit1Items.single.id,
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(2000),
            pricePerKgCentavos: 3000,
            capitalPerKgCentavos: 2000,
          ),
        ],
        chargedCentavos: 6000,
        paidCentavos: 6000,
        reason: 'Added another 500g',
      );

      final sale = await (db.select(
        db.sales,
      )..where((s) => s.id.equals(original.sale.id))).getSingle();
      expect(sale.editCount, equals(2));

      final edits = await repository.getSaleEdits(original.sale.id);
      expect(edits.length, equals(2));
      expect(edits[0].reason, equals('Added another 500g'));
      expect(edits[1].reason, equals('Added 500g'));
    });

    test('transaction rollback: mid-save failure keeps database completely unchanged', () async {
      final products = await db.getAllActiveProducts();
      final cardava = products.first;

      final original = await repository.completeSale(
        lines: [
          SaleLineInput(
            productId: cardava.id,
            productName: cardava.name,
            weight: Weight.fromGrams(1000),
            pricePerKgCentavos: 3000,
            capitalPerKgCentavos: 2000,
          ),
        ],
        chargedCentavos: 3000,
        paidCentavos: 3000,
      );

      // Intentionally pass an invalid line (0g) which throws ArgumentError during validation
      try {
        await repository.editSale(
          saleId: original.sale.id,
          newLines: [
            SaleLineInput(
              productId: cardava.id,
              productName: cardava.name,
              weight: Weight.fromGrams(0), // INVALID
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          ],
          chargedCentavos: 3000,
          paidCentavos: 3000,
        );
      } catch (_) {}

      // Verify sale and items are unchanged, and no sale_edits were written
      final saleAfter = await (db.select(
        db.sales,
      )..where((s) => s.id.equals(original.sale.id))).getSingle();
      expect(saleAfter.editCount, equals(0));
      expect(saleAfter.exactTotalCentavos, equals(3000));

      final edits = await repository.getSaleEdits(original.sale.id);
      expect(edits.isEmpty, isTrue);
    });

    test(
      'voided sale cannot be edited; edited sale can still be voided',
      () async {
        final products = await db.getAllActiveProducts();
        final cardava = products.first;

        final original = await repository.completeSale(
          lines: [
            SaleLineInput(
              productId: cardava.id,
              productName: cardava.name,
              weight: Weight.fromGrams(1000),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          ],
          chargedCentavos: 3000,
          paidCentavos: 3000,
        );

        // 1. Edit the sale first
        await repository.editSale(
          saleId: original.sale.id,
          newLines: [
            SaleLineInput(
              originalItemId: original.items.single.id,
              productId: cardava.id,
              productName: cardava.name,
              weight: Weight.fromGrams(1500),
              pricePerKgCentavos: 3000,
              capitalPerKgCentavos: 2000,
            ),
          ],
          chargedCentavos: 4500,
          paidCentavos: 5000,
        );

        // 2. Void the edited sale -> Allowed
        await repository.voidSale(original.sale.id);
        final voidedSale = await repository.getSaleById(original.sale.id);
        expect(voidedSale!.sale.voided, isTrue);
        expect(voidedSale.sale.editCount, equals(1));

        // 3. Attempting to edit a voided sale -> Blocked
        await expectLater(
          repository.editSale(
            saleId: original.sale.id,
            newLines: [
              SaleLineInput(
                productId: cardava.id,
                productName: cardava.name,
                weight: Weight.fromGrams(2000),
                pricePerKgCentavos: 3000,
                capitalPerKgCentavos: 2000,
              ),
            ],
            chargedCentavos: 6000,
            paidCentavos: 6000,
          ),
          throwsStateError,
        );
      },
    );
  });
}
