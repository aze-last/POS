// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultPriceCentavosMeta =
      const VerificationMeta('defaultPriceCentavos');
  @override
  late final GeneratedColumn<int> defaultPriceCentavos = GeneratedColumn<int>(
    'default_price_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capitalCentavosMeta = const VerificationMeta(
    'capitalCentavos',
  );
  @override
  late final GeneratedColumn<int> capitalCentavos = GeneratedColumn<int>(
    'capital_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    defaultPriceCentavos,
    capitalCentavos,
    sortOrder,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('default_price_centavos')) {
      context.handle(
        _defaultPriceCentavosMeta,
        defaultPriceCentavos.isAcceptableOrUnknown(
          data['default_price_centavos']!,
          _defaultPriceCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultPriceCentavosMeta);
    }
    if (data.containsKey('capital_centavos')) {
      context.handle(
        _capitalCentavosMeta,
        capitalCentavos.isAcceptableOrUnknown(
          data['capital_centavos']!,
          _capitalCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_capitalCentavosMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      defaultPriceCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_price_centavos'],
      )!,
      capitalCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capital_centavos'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final int id;
  final String name;
  final int defaultPriceCentavos;
  final int capitalCentavos;
  final int sortOrder;
  final bool archived;
  const Product({
    required this.id,
    required this.name,
    required this.defaultPriceCentavos,
    required this.capitalCentavos,
    required this.sortOrder,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['default_price_centavos'] = Variable<int>(defaultPriceCentavos);
    map['capital_centavos'] = Variable<int>(capitalCentavos);
    map['sort_order'] = Variable<int>(sortOrder);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      defaultPriceCentavos: Value(defaultPriceCentavos),
      capitalCentavos: Value(capitalCentavos),
      sortOrder: Value(sortOrder),
      archived: Value(archived),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      defaultPriceCentavos: serializer.fromJson<int>(
        json['defaultPriceCentavos'],
      ),
      capitalCentavos: serializer.fromJson<int>(json['capitalCentavos']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'defaultPriceCentavos': serializer.toJson<int>(defaultPriceCentavos),
      'capitalCentavos': serializer.toJson<int>(capitalCentavos),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    int? defaultPriceCentavos,
    int? capitalCentavos,
    int? sortOrder,
    bool? archived,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    defaultPriceCentavos: defaultPriceCentavos ?? this.defaultPriceCentavos,
    capitalCentavos: capitalCentavos ?? this.capitalCentavos,
    sortOrder: sortOrder ?? this.sortOrder,
    archived: archived ?? this.archived,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      defaultPriceCentavos: data.defaultPriceCentavos.present
          ? data.defaultPriceCentavos.value
          : this.defaultPriceCentavos,
      capitalCentavos: data.capitalCentavos.present
          ? data.capitalCentavos.value
          : this.capitalCentavos,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultPriceCentavos: $defaultPriceCentavos, ')
          ..write('capitalCentavos: $capitalCentavos, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    defaultPriceCentavos,
    capitalCentavos,
    sortOrder,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.defaultPriceCentavos == this.defaultPriceCentavos &&
          other.capitalCentavos == this.capitalCentavos &&
          other.sortOrder == this.sortOrder &&
          other.archived == this.archived);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> defaultPriceCentavos;
  final Value<int> capitalCentavos;
  final Value<int> sortOrder;
  final Value<bool> archived;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultPriceCentavos = const Value.absent(),
    this.capitalCentavos = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archived = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int defaultPriceCentavos,
    required int capitalCentavos,
    this.sortOrder = const Value.absent(),
    this.archived = const Value.absent(),
  }) : name = Value(name),
       defaultPriceCentavos = Value(defaultPriceCentavos),
       capitalCentavos = Value(capitalCentavos);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? defaultPriceCentavos,
    Expression<int>? capitalCentavos,
    Expression<int>? sortOrder,
    Expression<bool>? archived,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (defaultPriceCentavos != null)
        'default_price_centavos': defaultPriceCentavos,
      if (capitalCentavos != null) 'capital_centavos': capitalCentavos,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (archived != null) 'archived': archived,
    });
  }

  ProductsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? defaultPriceCentavos,
    Value<int>? capitalCentavos,
    Value<int>? sortOrder,
    Value<bool>? archived,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultPriceCentavos: defaultPriceCentavos ?? this.defaultPriceCentavos,
      capitalCentavos: capitalCentavos ?? this.capitalCentavos,
      sortOrder: sortOrder ?? this.sortOrder,
      archived: archived ?? this.archived,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (defaultPriceCentavos.present) {
      map['default_price_centavos'] = Variable<int>(defaultPriceCentavos.value);
    }
    if (capitalCentavos.present) {
      map['capital_centavos'] = Variable<int>(capitalCentavos.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultPriceCentavos: $defaultPriceCentavos, ')
          ..write('capitalCentavos: $capitalCentavos, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }
}

class $CapitalHistoryTable extends CapitalHistory
    with TableInfo<$CapitalHistoryTable, CapitalHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapitalHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _oldCentavosMeta = const VerificationMeta(
    'oldCentavos',
  );
  @override
  late final GeneratedColumn<int> oldCentavos = GeneratedColumn<int>(
    'old_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _newCentavosMeta = const VerificationMeta(
    'newCentavos',
  );
  @override
  late final GeneratedColumn<int> newCentavos = GeneratedColumn<int>(
    'new_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changedAtMeta = const VerificationMeta(
    'changedAt',
  );
  @override
  late final GeneratedColumn<DateTime> changedAt = GeneratedColumn<DateTime>(
    'changed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    oldCentavos,
    newCentavos,
    changedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capital_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<CapitalHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('old_centavos')) {
      context.handle(
        _oldCentavosMeta,
        oldCentavos.isAcceptableOrUnknown(
          data['old_centavos']!,
          _oldCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_oldCentavosMeta);
    }
    if (data.containsKey('new_centavos')) {
      context.handle(
        _newCentavosMeta,
        newCentavos.isAcceptableOrUnknown(
          data['new_centavos']!,
          _newCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_newCentavosMeta);
    }
    if (data.containsKey('changed_at')) {
      context.handle(
        _changedAtMeta,
        changedAt.isAcceptableOrUnknown(data['changed_at']!, _changedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_changedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CapitalHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CapitalHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      oldCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}old_centavos'],
      )!,
      newCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}new_centavos'],
      )!,
      changedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}changed_at'],
      )!,
    );
  }

  @override
  $CapitalHistoryTable createAlias(String alias) {
    return $CapitalHistoryTable(attachedDatabase, alias);
  }
}

class CapitalHistoryData extends DataClass
    implements Insertable<CapitalHistoryData> {
  final int id;
  final int productId;
  final int oldCentavos;
  final int newCentavos;
  final DateTime changedAt;
  const CapitalHistoryData({
    required this.id,
    required this.productId,
    required this.oldCentavos,
    required this.newCentavos,
    required this.changedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['old_centavos'] = Variable<int>(oldCentavos);
    map['new_centavos'] = Variable<int>(newCentavos);
    map['changed_at'] = Variable<DateTime>(changedAt);
    return map;
  }

  CapitalHistoryCompanion toCompanion(bool nullToAbsent) {
    return CapitalHistoryCompanion(
      id: Value(id),
      productId: Value(productId),
      oldCentavos: Value(oldCentavos),
      newCentavos: Value(newCentavos),
      changedAt: Value(changedAt),
    );
  }

  factory CapitalHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CapitalHistoryData(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      oldCentavos: serializer.fromJson<int>(json['oldCentavos']),
      newCentavos: serializer.fromJson<int>(json['newCentavos']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'oldCentavos': serializer.toJson<int>(oldCentavos),
      'newCentavos': serializer.toJson<int>(newCentavos),
      'changedAt': serializer.toJson<DateTime>(changedAt),
    };
  }

  CapitalHistoryData copyWith({
    int? id,
    int? productId,
    int? oldCentavos,
    int? newCentavos,
    DateTime? changedAt,
  }) => CapitalHistoryData(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    oldCentavos: oldCentavos ?? this.oldCentavos,
    newCentavos: newCentavos ?? this.newCentavos,
    changedAt: changedAt ?? this.changedAt,
  );
  CapitalHistoryData copyWithCompanion(CapitalHistoryCompanion data) {
    return CapitalHistoryData(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      oldCentavos: data.oldCentavos.present
          ? data.oldCentavos.value
          : this.oldCentavos,
      newCentavos: data.newCentavos.present
          ? data.newCentavos.value
          : this.newCentavos,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapitalHistoryData(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('oldCentavos: $oldCentavos, ')
          ..write('newCentavos: $newCentavos, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, productId, oldCentavos, newCentavos, changedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapitalHistoryData &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.oldCentavos == this.oldCentavos &&
          other.newCentavos == this.newCentavos &&
          other.changedAt == this.changedAt);
}

class CapitalHistoryCompanion extends UpdateCompanion<CapitalHistoryData> {
  final Value<int> id;
  final Value<int> productId;
  final Value<int> oldCentavos;
  final Value<int> newCentavos;
  final Value<DateTime> changedAt;
  const CapitalHistoryCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.oldCentavos = const Value.absent(),
    this.newCentavos = const Value.absent(),
    this.changedAt = const Value.absent(),
  });
  CapitalHistoryCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    required int oldCentavos,
    required int newCentavos,
    required DateTime changedAt,
  }) : productId = Value(productId),
       oldCentavos = Value(oldCentavos),
       newCentavos = Value(newCentavos),
       changedAt = Value(changedAt);
  static Insertable<CapitalHistoryData> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<int>? oldCentavos,
    Expression<int>? newCentavos,
    Expression<DateTime>? changedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (oldCentavos != null) 'old_centavos': oldCentavos,
      if (newCentavos != null) 'new_centavos': newCentavos,
      if (changedAt != null) 'changed_at': changedAt,
    });
  }

  CapitalHistoryCompanion copyWith({
    Value<int>? id,
    Value<int>? productId,
    Value<int>? oldCentavos,
    Value<int>? newCentavos,
    Value<DateTime>? changedAt,
  }) {
    return CapitalHistoryCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      oldCentavos: oldCentavos ?? this.oldCentavos,
      newCentavos: newCentavos ?? this.newCentavos,
      changedAt: changedAt ?? this.changedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (oldCentavos.present) {
      map['old_centavos'] = Variable<int>(oldCentavos.value);
    }
    if (newCentavos.present) {
      map['new_centavos'] = Variable<int>(newCentavos.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<DateTime>(changedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapitalHistoryCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('oldCentavos: $oldCentavos, ')
          ..write('newCentavos: $newCentavos, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exactTotalCentavosMeta =
      const VerificationMeta('exactTotalCentavos');
  @override
  late final GeneratedColumn<int> exactTotalCentavos = GeneratedColumn<int>(
    'exact_total_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chargedCentavosMeta = const VerificationMeta(
    'chargedCentavos',
  );
  @override
  late final GeneratedColumn<int> chargedCentavos = GeneratedColumn<int>(
    'charged_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidCentavosMeta = const VerificationMeta(
    'paidCentavos',
  );
  @override
  late final GeneratedColumn<int> paidCentavos = GeneratedColumn<int>(
    'paid_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changeCentavosMeta = const VerificationMeta(
    'changeCentavos',
  );
  @override
  late final GeneratedColumn<int> changeCentavos = GeneratedColumn<int>(
    'change_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voidedMeta = const VerificationMeta('voided');
  @override
  late final GeneratedColumn<bool> voided = GeneratedColumn<bool>(
    'voided',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("voided" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    exactTotalCentavos,
    chargedCentavos,
    paidCentavos,
    changeCentavos,
    voided,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('exact_total_centavos')) {
      context.handle(
        _exactTotalCentavosMeta,
        exactTotalCentavos.isAcceptableOrUnknown(
          data['exact_total_centavos']!,
          _exactTotalCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exactTotalCentavosMeta);
    }
    if (data.containsKey('charged_centavos')) {
      context.handle(
        _chargedCentavosMeta,
        chargedCentavos.isAcceptableOrUnknown(
          data['charged_centavos']!,
          _chargedCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chargedCentavosMeta);
    }
    if (data.containsKey('paid_centavos')) {
      context.handle(
        _paidCentavosMeta,
        paidCentavos.isAcceptableOrUnknown(
          data['paid_centavos']!,
          _paidCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paidCentavosMeta);
    }
    if (data.containsKey('change_centavos')) {
      context.handle(
        _changeCentavosMeta,
        changeCentavos.isAcceptableOrUnknown(
          data['change_centavos']!,
          _changeCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_changeCentavosMeta);
    }
    if (data.containsKey('voided')) {
      context.handle(
        _voidedMeta,
        voided.isAcceptableOrUnknown(data['voided']!, _voidedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      exactTotalCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exact_total_centavos'],
      )!,
      chargedCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}charged_centavos'],
      )!,
      paidCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid_centavos'],
      )!,
      changeCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}change_centavos'],
      )!,
      voided: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}voided'],
      )!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final int id;
  final DateTime createdAt;
  final int exactTotalCentavos;
  final int chargedCentavos;
  final int paidCentavos;
  final int changeCentavos;
  final bool voided;
  const Sale({
    required this.id,
    required this.createdAt,
    required this.exactTotalCentavos,
    required this.chargedCentavos,
    required this.paidCentavos,
    required this.changeCentavos,
    required this.voided,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['exact_total_centavos'] = Variable<int>(exactTotalCentavos);
    map['charged_centavos'] = Variable<int>(chargedCentavos);
    map['paid_centavos'] = Variable<int>(paidCentavos);
    map['change_centavos'] = Variable<int>(changeCentavos);
    map['voided'] = Variable<bool>(voided);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      exactTotalCentavos: Value(exactTotalCentavos),
      chargedCentavos: Value(chargedCentavos),
      paidCentavos: Value(paidCentavos),
      changeCentavos: Value(changeCentavos),
      voided: Value(voided),
    );
  }

  factory Sale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      exactTotalCentavos: serializer.fromJson<int>(json['exactTotalCentavos']),
      chargedCentavos: serializer.fromJson<int>(json['chargedCentavos']),
      paidCentavos: serializer.fromJson<int>(json['paidCentavos']),
      changeCentavos: serializer.fromJson<int>(json['changeCentavos']),
      voided: serializer.fromJson<bool>(json['voided']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'exactTotalCentavos': serializer.toJson<int>(exactTotalCentavos),
      'chargedCentavos': serializer.toJson<int>(chargedCentavos),
      'paidCentavos': serializer.toJson<int>(paidCentavos),
      'changeCentavos': serializer.toJson<int>(changeCentavos),
      'voided': serializer.toJson<bool>(voided),
    };
  }

  Sale copyWith({
    int? id,
    DateTime? createdAt,
    int? exactTotalCentavos,
    int? chargedCentavos,
    int? paidCentavos,
    int? changeCentavos,
    bool? voided,
  }) => Sale(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    exactTotalCentavos: exactTotalCentavos ?? this.exactTotalCentavos,
    chargedCentavos: chargedCentavos ?? this.chargedCentavos,
    paidCentavos: paidCentavos ?? this.paidCentavos,
    changeCentavos: changeCentavos ?? this.changeCentavos,
    voided: voided ?? this.voided,
  );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      exactTotalCentavos: data.exactTotalCentavos.present
          ? data.exactTotalCentavos.value
          : this.exactTotalCentavos,
      chargedCentavos: data.chargedCentavos.present
          ? data.chargedCentavos.value
          : this.chargedCentavos,
      paidCentavos: data.paidCentavos.present
          ? data.paidCentavos.value
          : this.paidCentavos,
      changeCentavos: data.changeCentavos.present
          ? data.changeCentavos.value
          : this.changeCentavos,
      voided: data.voided.present ? data.voided.value : this.voided,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('exactTotalCentavos: $exactTotalCentavos, ')
          ..write('chargedCentavos: $chargedCentavos, ')
          ..write('paidCentavos: $paidCentavos, ')
          ..write('changeCentavos: $changeCentavos, ')
          ..write('voided: $voided')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    exactTotalCentavos,
    chargedCentavos,
    paidCentavos,
    changeCentavos,
    voided,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.exactTotalCentavos == this.exactTotalCentavos &&
          other.chargedCentavos == this.chargedCentavos &&
          other.paidCentavos == this.paidCentavos &&
          other.changeCentavos == this.changeCentavos &&
          other.voided == this.voided);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<int> exactTotalCentavos;
  final Value<int> chargedCentavos;
  final Value<int> paidCentavos;
  final Value<int> changeCentavos;
  final Value<bool> voided;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.exactTotalCentavos = const Value.absent(),
    this.chargedCentavos = const Value.absent(),
    this.paidCentavos = const Value.absent(),
    this.changeCentavos = const Value.absent(),
    this.voided = const Value.absent(),
  });
  SalesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required int exactTotalCentavos,
    required int chargedCentavos,
    required int paidCentavos,
    required int changeCentavos,
    this.voided = const Value.absent(),
  }) : createdAt = Value(createdAt),
       exactTotalCentavos = Value(exactTotalCentavos),
       chargedCentavos = Value(chargedCentavos),
       paidCentavos = Value(paidCentavos),
       changeCentavos = Value(changeCentavos);
  static Insertable<Sale> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<int>? exactTotalCentavos,
    Expression<int>? chargedCentavos,
    Expression<int>? paidCentavos,
    Expression<int>? changeCentavos,
    Expression<bool>? voided,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (exactTotalCentavos != null)
        'exact_total_centavos': exactTotalCentavos,
      if (chargedCentavos != null) 'charged_centavos': chargedCentavos,
      if (paidCentavos != null) 'paid_centavos': paidCentavos,
      if (changeCentavos != null) 'change_centavos': changeCentavos,
      if (voided != null) 'voided': voided,
    });
  }

  SalesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<int>? exactTotalCentavos,
    Value<int>? chargedCentavos,
    Value<int>? paidCentavos,
    Value<int>? changeCentavos,
    Value<bool>? voided,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      exactTotalCentavos: exactTotalCentavos ?? this.exactTotalCentavos,
      chargedCentavos: chargedCentavos ?? this.chargedCentavos,
      paidCentavos: paidCentavos ?? this.paidCentavos,
      changeCentavos: changeCentavos ?? this.changeCentavos,
      voided: voided ?? this.voided,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (exactTotalCentavos.present) {
      map['exact_total_centavos'] = Variable<int>(exactTotalCentavos.value);
    }
    if (chargedCentavos.present) {
      map['charged_centavos'] = Variable<int>(chargedCentavos.value);
    }
    if (paidCentavos.present) {
      map['paid_centavos'] = Variable<int>(paidCentavos.value);
    }
    if (changeCentavos.present) {
      map['change_centavos'] = Variable<int>(changeCentavos.value);
    }
    if (voided.present) {
      map['voided'] = Variable<bool>(voided.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('exactTotalCentavos: $exactTotalCentavos, ')
          ..write('chargedCentavos: $chargedCentavos, ')
          ..write('paidCentavos: $paidCentavos, ')
          ..write('changeCentavos: $changeCentavos, ')
          ..write('voided: $voided')
          ..write(')'))
        .toString();
  }
}

class $SaleItemsTable extends SaleItems
    with TableInfo<$SaleItemsTable, SaleItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<int> saleId = GeneratedColumn<int>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _productNameSnapshotMeta =
      const VerificationMeta('productNameSnapshot');
  @override
  late final GeneratedColumn<String> productNameSnapshot =
      GeneratedColumn<String>(
        'product_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<int> grams = GeneratedColumn<int>(
    'grams',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerKgCentavosMeta =
      const VerificationMeta('pricePerKgCentavos');
  @override
  late final GeneratedColumn<int> pricePerKgCentavos = GeneratedColumn<int>(
    'price_per_kg_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capitalPerKgCentavosMeta =
      const VerificationMeta('capitalPerKgCentavos');
  @override
  late final GeneratedColumn<int> capitalPerKgCentavos = GeneratedColumn<int>(
    'capital_per_kg_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    saleId,
    productId,
    productNameSnapshot,
    grams,
    pricePerKgCentavos,
    capitalPerKgCentavos,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name_snapshot')) {
      context.handle(
        _productNameSnapshotMeta,
        productNameSnapshot.isAcceptableOrUnknown(
          data['product_name_snapshot']!,
          _productNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameSnapshotMeta);
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    } else if (isInserting) {
      context.missing(_gramsMeta);
    }
    if (data.containsKey('price_per_kg_centavos')) {
      context.handle(
        _pricePerKgCentavosMeta,
        pricePerKgCentavos.isAcceptableOrUnknown(
          data['price_per_kg_centavos']!,
          _pricePerKgCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerKgCentavosMeta);
    }
    if (data.containsKey('capital_per_kg_centavos')) {
      context.handle(
        _capitalPerKgCentavosMeta,
        capitalPerKgCentavos.isAcceptableOrUnknown(
          data['capital_per_kg_centavos']!,
          _capitalPerKgCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_capitalPerKgCentavosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sale_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      productNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name_snapshot'],
      )!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grams'],
      )!,
      pricePerKgCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_per_kg_centavos'],
      )!,
      capitalPerKgCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capital_per_kg_centavos'],
      )!,
    );
  }

  @override
  $SaleItemsTable createAlias(String alias) {
    return $SaleItemsTable(attachedDatabase, alias);
  }
}

class SaleItem extends DataClass implements Insertable<SaleItem> {
  final int id;
  final int saleId;
  final int productId;
  final String productNameSnapshot;
  final int grams;
  final int pricePerKgCentavos;
  final int capitalPerKgCentavos;
  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productNameSnapshot,
    required this.grams,
    required this.pricePerKgCentavos,
    required this.capitalPerKgCentavos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sale_id'] = Variable<int>(saleId);
    map['product_id'] = Variable<int>(productId);
    map['product_name_snapshot'] = Variable<String>(productNameSnapshot);
    map['grams'] = Variable<int>(grams);
    map['price_per_kg_centavos'] = Variable<int>(pricePerKgCentavos);
    map['capital_per_kg_centavos'] = Variable<int>(capitalPerKgCentavos);
    return map;
  }

  SaleItemsCompanion toCompanion(bool nullToAbsent) {
    return SaleItemsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      productId: Value(productId),
      productNameSnapshot: Value(productNameSnapshot),
      grams: Value(grams),
      pricePerKgCentavos: Value(pricePerKgCentavos),
      capitalPerKgCentavos: Value(capitalPerKgCentavos),
    );
  }

  factory SaleItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItem(
      id: serializer.fromJson<int>(json['id']),
      saleId: serializer.fromJson<int>(json['saleId']),
      productId: serializer.fromJson<int>(json['productId']),
      productNameSnapshot: serializer.fromJson<String>(
        json['productNameSnapshot'],
      ),
      grams: serializer.fromJson<int>(json['grams']),
      pricePerKgCentavos: serializer.fromJson<int>(json['pricePerKgCentavos']),
      capitalPerKgCentavos: serializer.fromJson<int>(
        json['capitalPerKgCentavos'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'saleId': serializer.toJson<int>(saleId),
      'productId': serializer.toJson<int>(productId),
      'productNameSnapshot': serializer.toJson<String>(productNameSnapshot),
      'grams': serializer.toJson<int>(grams),
      'pricePerKgCentavos': serializer.toJson<int>(pricePerKgCentavos),
      'capitalPerKgCentavos': serializer.toJson<int>(capitalPerKgCentavos),
    };
  }

  SaleItem copyWith({
    int? id,
    int? saleId,
    int? productId,
    String? productNameSnapshot,
    int? grams,
    int? pricePerKgCentavos,
    int? capitalPerKgCentavos,
  }) => SaleItem(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
    grams: grams ?? this.grams,
    pricePerKgCentavos: pricePerKgCentavos ?? this.pricePerKgCentavos,
    capitalPerKgCentavos: capitalPerKgCentavos ?? this.capitalPerKgCentavos,
  );
  SaleItem copyWithCompanion(SaleItemsCompanion data) {
    return SaleItem(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productNameSnapshot: data.productNameSnapshot.present
          ? data.productNameSnapshot.value
          : this.productNameSnapshot,
      grams: data.grams.present ? data.grams.value : this.grams,
      pricePerKgCentavos: data.pricePerKgCentavos.present
          ? data.pricePerKgCentavos.value
          : this.pricePerKgCentavos,
      capitalPerKgCentavos: data.capitalPerKgCentavos.present
          ? data.capitalPerKgCentavos.value
          : this.capitalPerKgCentavos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItem(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('grams: $grams, ')
          ..write('pricePerKgCentavos: $pricePerKgCentavos, ')
          ..write('capitalPerKgCentavos: $capitalPerKgCentavos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    saleId,
    productId,
    productNameSnapshot,
    grams,
    pricePerKgCentavos,
    capitalPerKgCentavos,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItem &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.productNameSnapshot == this.productNameSnapshot &&
          other.grams == this.grams &&
          other.pricePerKgCentavos == this.pricePerKgCentavos &&
          other.capitalPerKgCentavos == this.capitalPerKgCentavos);
}

class SaleItemsCompanion extends UpdateCompanion<SaleItem> {
  final Value<int> id;
  final Value<int> saleId;
  final Value<int> productId;
  final Value<String> productNameSnapshot;
  final Value<int> grams;
  final Value<int> pricePerKgCentavos;
  final Value<int> capitalPerKgCentavos;
  const SaleItemsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productNameSnapshot = const Value.absent(),
    this.grams = const Value.absent(),
    this.pricePerKgCentavos = const Value.absent(),
    this.capitalPerKgCentavos = const Value.absent(),
  });
  SaleItemsCompanion.insert({
    this.id = const Value.absent(),
    required int saleId,
    required int productId,
    required String productNameSnapshot,
    required int grams,
    required int pricePerKgCentavos,
    required int capitalPerKgCentavos,
  }) : saleId = Value(saleId),
       productId = Value(productId),
       productNameSnapshot = Value(productNameSnapshot),
       grams = Value(grams),
       pricePerKgCentavos = Value(pricePerKgCentavos),
       capitalPerKgCentavos = Value(capitalPerKgCentavos);
  static Insertable<SaleItem> custom({
    Expression<int>? id,
    Expression<int>? saleId,
    Expression<int>? productId,
    Expression<String>? productNameSnapshot,
    Expression<int>? grams,
    Expression<int>? pricePerKgCentavos,
    Expression<int>? capitalPerKgCentavos,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (productNameSnapshot != null)
        'product_name_snapshot': productNameSnapshot,
      if (grams != null) 'grams': grams,
      if (pricePerKgCentavos != null)
        'price_per_kg_centavos': pricePerKgCentavos,
      if (capitalPerKgCentavos != null)
        'capital_per_kg_centavos': capitalPerKgCentavos,
    });
  }

  SaleItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? saleId,
    Value<int>? productId,
    Value<String>? productNameSnapshot,
    Value<int>? grams,
    Value<int>? pricePerKgCentavos,
    Value<int>? capitalPerKgCentavos,
  }) {
    return SaleItemsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      grams: grams ?? this.grams,
      pricePerKgCentavos: pricePerKgCentavos ?? this.pricePerKgCentavos,
      capitalPerKgCentavos: capitalPerKgCentavos ?? this.capitalPerKgCentavos,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<int>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (productNameSnapshot.present) {
      map['product_name_snapshot'] = Variable<String>(
        productNameSnapshot.value,
      );
    }
    if (grams.present) {
      map['grams'] = Variable<int>(grams.value);
    }
    if (pricePerKgCentavos.present) {
      map['price_per_kg_centavos'] = Variable<int>(pricePerKgCentavos.value);
    }
    if (capitalPerKgCentavos.present) {
      map['capital_per_kg_centavos'] = Variable<int>(
        capitalPerKgCentavos.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('grams: $grams, ')
          ..write('pricePerKgCentavos: $pricePerKgCentavos, ')
          ..write('capitalPerKgCentavos: $capitalPerKgCentavos')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentavosMeta = const VerificationMeta(
    'amountCentavos',
  );
  @override
  late final GeneratedColumn<int> amountCentavos = GeneratedColumn<int>(
    'amount_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<int> grams = GeneratedColumn<int>(
    'grams',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capitalPerKgCentavosMeta =
      const VerificationMeta('capitalPerKgCentavos');
  @override
  late final GeneratedColumn<int> capitalPerKgCentavos = GeneratedColumn<int>(
    'capital_per_kg_centavos',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    type,
    amountCentavos,
    note,
    productId,
    grams,
    capitalPerKgCentavos,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount_centavos')) {
      context.handle(
        _amountCentavosMeta,
        amountCentavos.isAcceptableOrUnknown(
          data['amount_centavos']!,
          _amountCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentavosMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    }
    if (data.containsKey('capital_per_kg_centavos')) {
      context.handle(
        _capitalPerKgCentavosMeta,
        capitalPerKgCentavos.isAcceptableOrUnknown(
          data['capital_per_kg_centavos']!,
          _capitalPerKgCentavosMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amountCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_centavos'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      ),
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grams'],
      ),
      capitalPerKgCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capital_per_kg_centavos'],
      ),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final DateTime date;
  final String type;
  final int amountCentavos;
  final String? note;
  final int? productId;
  final int? grams;
  final int? capitalPerKgCentavos;
  const Expense({
    required this.id,
    required this.date,
    required this.type,
    required this.amountCentavos,
    this.note,
    this.productId,
    this.grams,
    this.capitalPerKgCentavos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<String>(type);
    map['amount_centavos'] = Variable<int>(amountCentavos);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<int>(productId);
    }
    if (!nullToAbsent || grams != null) {
      map['grams'] = Variable<int>(grams);
    }
    if (!nullToAbsent || capitalPerKgCentavos != null) {
      map['capital_per_kg_centavos'] = Variable<int>(capitalPerKgCentavos);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      date: Value(date),
      type: Value(type),
      amountCentavos: Value(amountCentavos),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      grams: grams == null && nullToAbsent
          ? const Value.absent()
          : Value(grams),
      capitalPerKgCentavos: capitalPerKgCentavos == null && nullToAbsent
          ? const Value.absent()
          : Value(capitalPerKgCentavos),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      amountCentavos: serializer.fromJson<int>(json['amountCentavos']),
      note: serializer.fromJson<String?>(json['note']),
      productId: serializer.fromJson<int?>(json['productId']),
      grams: serializer.fromJson<int?>(json['grams']),
      capitalPerKgCentavos: serializer.fromJson<int?>(
        json['capitalPerKgCentavos'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'amountCentavos': serializer.toJson<int>(amountCentavos),
      'note': serializer.toJson<String?>(note),
      'productId': serializer.toJson<int?>(productId),
      'grams': serializer.toJson<int?>(grams),
      'capitalPerKgCentavos': serializer.toJson<int?>(capitalPerKgCentavos),
    };
  }

  Expense copyWith({
    int? id,
    DateTime? date,
    String? type,
    int? amountCentavos,
    Value<String?> note = const Value.absent(),
    Value<int?> productId = const Value.absent(),
    Value<int?> grams = const Value.absent(),
    Value<int?> capitalPerKgCentavos = const Value.absent(),
  }) => Expense(
    id: id ?? this.id,
    date: date ?? this.date,
    type: type ?? this.type,
    amountCentavos: amountCentavos ?? this.amountCentavos,
    note: note.present ? note.value : this.note,
    productId: productId.present ? productId.value : this.productId,
    grams: grams.present ? grams.value : this.grams,
    capitalPerKgCentavos: capitalPerKgCentavos.present
        ? capitalPerKgCentavos.value
        : this.capitalPerKgCentavos,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      amountCentavos: data.amountCentavos.present
          ? data.amountCentavos.value
          : this.amountCentavos,
      note: data.note.present ? data.note.value : this.note,
      productId: data.productId.present ? data.productId.value : this.productId,
      grams: data.grams.present ? data.grams.value : this.grams,
      capitalPerKgCentavos: data.capitalPerKgCentavos.present
          ? data.capitalPerKgCentavos.value
          : this.capitalPerKgCentavos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('amountCentavos: $amountCentavos, ')
          ..write('note: $note, ')
          ..write('productId: $productId, ')
          ..write('grams: $grams, ')
          ..write('capitalPerKgCentavos: $capitalPerKgCentavos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    type,
    amountCentavos,
    note,
    productId,
    grams,
    capitalPerKgCentavos,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.date == this.date &&
          other.type == this.type &&
          other.amountCentavos == this.amountCentavos &&
          other.note == this.note &&
          other.productId == this.productId &&
          other.grams == this.grams &&
          other.capitalPerKgCentavos == this.capitalPerKgCentavos);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<int> amountCentavos;
  final Value<String?> note;
  final Value<int?> productId;
  final Value<int?> grams;
  final Value<int?> capitalPerKgCentavos;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.amountCentavos = const Value.absent(),
    this.note = const Value.absent(),
    this.productId = const Value.absent(),
    this.grams = const Value.absent(),
    this.capitalPerKgCentavos = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String type,
    required int amountCentavos,
    this.note = const Value.absent(),
    this.productId = const Value.absent(),
    this.grams = const Value.absent(),
    this.capitalPerKgCentavos = const Value.absent(),
  }) : date = Value(date),
       type = Value(type),
       amountCentavos = Value(amountCentavos);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<int>? amountCentavos,
    Expression<String>? note,
    Expression<int>? productId,
    Expression<int>? grams,
    Expression<int>? capitalPerKgCentavos,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (amountCentavos != null) 'amount_centavos': amountCentavos,
      if (note != null) 'note': note,
      if (productId != null) 'product_id': productId,
      if (grams != null) 'grams': grams,
      if (capitalPerKgCentavos != null)
        'capital_per_kg_centavos': capitalPerKgCentavos,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<String>? type,
    Value<int>? amountCentavos,
    Value<String?>? note,
    Value<int?>? productId,
    Value<int?>? grams,
    Value<int?>? capitalPerKgCentavos,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      amountCentavos: amountCentavos ?? this.amountCentavos,
      note: note ?? this.note,
      productId: productId ?? this.productId,
      grams: grams ?? this.grams,
      capitalPerKgCentavos: capitalPerKgCentavos ?? this.capitalPerKgCentavos,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amountCentavos.present) {
      map['amount_centavos'] = Variable<int>(amountCentavos.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (grams.present) {
      map['grams'] = Variable<int>(grams.value);
    }
    if (capitalPerKgCentavos.present) {
      map['capital_per_kg_centavos'] = Variable<int>(
        capitalPerKgCentavos.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('amountCentavos: $amountCentavos, ')
          ..write('note: $note, ')
          ..write('productId: $productId, ')
          ..write('grams: $grams, ')
          ..write('capitalPerKgCentavos: $capitalPerKgCentavos')
          ..write(')'))
        .toString();
  }
}

class $RestockPurchasesTable extends RestockPurchases
    with TableInfo<$RestockPurchasesTable, RestockPurchase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RestockPurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentavosMeta = const VerificationMeta(
    'amountCentavos',
  );
  @override
  late final GeneratedColumn<int> amountCentavos = GeneratedColumn<int>(
    'amount_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, amountCentavos, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'restock_purchases';
  @override
  VerificationContext validateIntegrity(
    Insertable<RestockPurchase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount_centavos')) {
      context.handle(
        _amountCentavosMeta,
        amountCentavos.isAcceptableOrUnknown(
          data['amount_centavos']!,
          _amountCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentavosMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RestockPurchase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RestockPurchase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      amountCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_centavos'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $RestockPurchasesTable createAlias(String alias) {
    return $RestockPurchasesTable(attachedDatabase, alias);
  }
}

class RestockPurchase extends DataClass implements Insertable<RestockPurchase> {
  final int id;
  final DateTime date;
  final int amountCentavos;
  final String? note;
  const RestockPurchase({
    required this.id,
    required this.date,
    required this.amountCentavos,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['amount_centavos'] = Variable<int>(amountCentavos);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  RestockPurchasesCompanion toCompanion(bool nullToAbsent) {
    return RestockPurchasesCompanion(
      id: Value(id),
      date: Value(date),
      amountCentavos: Value(amountCentavos),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory RestockPurchase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RestockPurchase(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      amountCentavos: serializer.fromJson<int>(json['amountCentavos']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'amountCentavos': serializer.toJson<int>(amountCentavos),
      'note': serializer.toJson<String?>(note),
    };
  }

  RestockPurchase copyWith({
    int? id,
    DateTime? date,
    int? amountCentavos,
    Value<String?> note = const Value.absent(),
  }) => RestockPurchase(
    id: id ?? this.id,
    date: date ?? this.date,
    amountCentavos: amountCentavos ?? this.amountCentavos,
    note: note.present ? note.value : this.note,
  );
  RestockPurchase copyWithCompanion(RestockPurchasesCompanion data) {
    return RestockPurchase(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      amountCentavos: data.amountCentavos.present
          ? data.amountCentavos.value
          : this.amountCentavos,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RestockPurchase(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amountCentavos: $amountCentavos, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, amountCentavos, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RestockPurchase &&
          other.id == this.id &&
          other.date == this.date &&
          other.amountCentavos == this.amountCentavos &&
          other.note == this.note);
}

class RestockPurchasesCompanion extends UpdateCompanion<RestockPurchase> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> amountCentavos;
  final Value<String?> note;
  const RestockPurchasesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.amountCentavos = const Value.absent(),
    this.note = const Value.absent(),
  });
  RestockPurchasesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int amountCentavos,
    this.note = const Value.absent(),
  }) : date = Value(date),
       amountCentavos = Value(amountCentavos);
  static Insertable<RestockPurchase> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? amountCentavos,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (amountCentavos != null) 'amount_centavos': amountCentavos,
      if (note != null) 'note': note,
    });
  }

  RestockPurchasesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? amountCentavos,
    Value<String?>? note,
  }) {
    return RestockPurchasesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      amountCentavos: amountCentavos ?? this.amountCentavos,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amountCentavos.present) {
      map['amount_centavos'] = Variable<int>(amountCentavos.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RestockPurchasesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amountCentavos: $amountCentavos, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $PayoutsTable extends Payouts with TableInfo<$PayoutsTable, Payout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toParentsCentavosMeta = const VerificationMeta(
    'toParentsCentavos',
  );
  @override
  late final GeneratedColumn<int> toParentsCentavos = GeneratedColumn<int>(
    'to_parents_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salaryCentavosMeta = const VerificationMeta(
    'salaryCentavos',
  );
  @override
  late final GeneratedColumn<int> salaryCentavos = GeneratedColumn<int>(
    'salary_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reserveCentavosMeta = const VerificationMeta(
    'reserveCentavos',
  );
  @override
  late final GeneratedColumn<int> reserveCentavos = GeneratedColumn<int>(
    'reserve_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    toParentsCentavos,
    salaryCentavos,
    reserveCentavos,
    locked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payout> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('to_parents_centavos')) {
      context.handle(
        _toParentsCentavosMeta,
        toParentsCentavos.isAcceptableOrUnknown(
          data['to_parents_centavos']!,
          _toParentsCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toParentsCentavosMeta);
    }
    if (data.containsKey('salary_centavos')) {
      context.handle(
        _salaryCentavosMeta,
        salaryCentavos.isAcceptableOrUnknown(
          data['salary_centavos']!,
          _salaryCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_salaryCentavosMeta);
    }
    if (data.containsKey('reserve_centavos')) {
      context.handle(
        _reserveCentavosMeta,
        reserveCentavos.isAcceptableOrUnknown(
          data['reserve_centavos']!,
          _reserveCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reserveCentavosMeta);
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payout(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      toParentsCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_parents_centavos'],
      )!,
      salaryCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salary_centavos'],
      )!,
      reserveCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reserve_centavos'],
      )!,
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
    );
  }

  @override
  $PayoutsTable createAlias(String alias) {
    return $PayoutsTable(attachedDatabase, alias);
  }
}

class Payout extends DataClass implements Insertable<Payout> {
  final int id;
  final DateTime date;
  final int toParentsCentavos;
  final int salaryCentavos;
  final int reserveCentavos;
  final bool locked;
  const Payout({
    required this.id,
    required this.date,
    required this.toParentsCentavos,
    required this.salaryCentavos,
    required this.reserveCentavos,
    required this.locked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['to_parents_centavos'] = Variable<int>(toParentsCentavos);
    map['salary_centavos'] = Variable<int>(salaryCentavos);
    map['reserve_centavos'] = Variable<int>(reserveCentavos);
    map['locked'] = Variable<bool>(locked);
    return map;
  }

  PayoutsCompanion toCompanion(bool nullToAbsent) {
    return PayoutsCompanion(
      id: Value(id),
      date: Value(date),
      toParentsCentavos: Value(toParentsCentavos),
      salaryCentavos: Value(salaryCentavos),
      reserveCentavos: Value(reserveCentavos),
      locked: Value(locked),
    );
  }

  factory Payout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payout(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      toParentsCentavos: serializer.fromJson<int>(json['toParentsCentavos']),
      salaryCentavos: serializer.fromJson<int>(json['salaryCentavos']),
      reserveCentavos: serializer.fromJson<int>(json['reserveCentavos']),
      locked: serializer.fromJson<bool>(json['locked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'toParentsCentavos': serializer.toJson<int>(toParentsCentavos),
      'salaryCentavos': serializer.toJson<int>(salaryCentavos),
      'reserveCentavos': serializer.toJson<int>(reserveCentavos),
      'locked': serializer.toJson<bool>(locked),
    };
  }

  Payout copyWith({
    int? id,
    DateTime? date,
    int? toParentsCentavos,
    int? salaryCentavos,
    int? reserveCentavos,
    bool? locked,
  }) => Payout(
    id: id ?? this.id,
    date: date ?? this.date,
    toParentsCentavos: toParentsCentavos ?? this.toParentsCentavos,
    salaryCentavos: salaryCentavos ?? this.salaryCentavos,
    reserveCentavos: reserveCentavos ?? this.reserveCentavos,
    locked: locked ?? this.locked,
  );
  Payout copyWithCompanion(PayoutsCompanion data) {
    return Payout(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      toParentsCentavos: data.toParentsCentavos.present
          ? data.toParentsCentavos.value
          : this.toParentsCentavos,
      salaryCentavos: data.salaryCentavos.present
          ? data.salaryCentavos.value
          : this.salaryCentavos,
      reserveCentavos: data.reserveCentavos.present
          ? data.reserveCentavos.value
          : this.reserveCentavos,
      locked: data.locked.present ? data.locked.value : this.locked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payout(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('toParentsCentavos: $toParentsCentavos, ')
          ..write('salaryCentavos: $salaryCentavos, ')
          ..write('reserveCentavos: $reserveCentavos, ')
          ..write('locked: $locked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    toParentsCentavos,
    salaryCentavos,
    reserveCentavos,
    locked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payout &&
          other.id == this.id &&
          other.date == this.date &&
          other.toParentsCentavos == this.toParentsCentavos &&
          other.salaryCentavos == this.salaryCentavos &&
          other.reserveCentavos == this.reserveCentavos &&
          other.locked == this.locked);
}

class PayoutsCompanion extends UpdateCompanion<Payout> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> toParentsCentavos;
  final Value<int> salaryCentavos;
  final Value<int> reserveCentavos;
  final Value<bool> locked;
  const PayoutsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.toParentsCentavos = const Value.absent(),
    this.salaryCentavos = const Value.absent(),
    this.reserveCentavos = const Value.absent(),
    this.locked = const Value.absent(),
  });
  PayoutsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int toParentsCentavos,
    required int salaryCentavos,
    required int reserveCentavos,
    this.locked = const Value.absent(),
  }) : date = Value(date),
       toParentsCentavos = Value(toParentsCentavos),
       salaryCentavos = Value(salaryCentavos),
       reserveCentavos = Value(reserveCentavos);
  static Insertable<Payout> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? toParentsCentavos,
    Expression<int>? salaryCentavos,
    Expression<int>? reserveCentavos,
    Expression<bool>? locked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (toParentsCentavos != null) 'to_parents_centavos': toParentsCentavos,
      if (salaryCentavos != null) 'salary_centavos': salaryCentavos,
      if (reserveCentavos != null) 'reserve_centavos': reserveCentavos,
      if (locked != null) 'locked': locked,
    });
  }

  PayoutsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<int>? toParentsCentavos,
    Value<int>? salaryCentavos,
    Value<int>? reserveCentavos,
    Value<bool>? locked,
  }) {
    return PayoutsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      toParentsCentavos: toParentsCentavos ?? this.toParentsCentavos,
      salaryCentavos: salaryCentavos ?? this.salaryCentavos,
      reserveCentavos: reserveCentavos ?? this.reserveCentavos,
      locked: locked ?? this.locked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (toParentsCentavos.present) {
      map['to_parents_centavos'] = Variable<int>(toParentsCentavos.value);
    }
    if (salaryCentavos.present) {
      map['salary_centavos'] = Variable<int>(salaryCentavos.value);
    }
    if (reserveCentavos.present) {
      map['reserve_centavos'] = Variable<int>(reserveCentavos.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayoutsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('toParentsCentavos: $toParentsCentavos, ')
          ..write('salaryCentavos: $salaryCentavos, ')
          ..write('reserveCentavos: $reserveCentavos, ')
          ..write('locked: $locked')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _salaryModeMeta = const VerificationMeta(
    'salaryMode',
  );
  @override
  late final GeneratedColumn<String> salaryMode = GeneratedColumn<String>(
    'salary_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('percent'),
  );
  static const VerificationMeta _salaryPercentBasisPointsMeta =
      const VerificationMeta('salaryPercentBasisPoints');
  @override
  late final GeneratedColumn<int> salaryPercentBasisPoints =
      GeneratedColumn<int>(
        'salary_percent_basis_points',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(3000),
      );
  static const VerificationMeta _fixedDailySalaryCentavosMeta =
      const VerificationMeta('fixedDailySalaryCentavos');
  @override
  late final GeneratedColumn<int> fixedDailySalaryCentavos =
      GeneratedColumn<int>(
        'fixed_daily_salary_centavos',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    salaryMode,
    salaryPercentBasisPoints,
    fixedDailySalaryCentavos,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('salary_mode')) {
      context.handle(
        _salaryModeMeta,
        salaryMode.isAcceptableOrUnknown(data['salary_mode']!, _salaryModeMeta),
      );
    }
    if (data.containsKey('salary_percent_basis_points')) {
      context.handle(
        _salaryPercentBasisPointsMeta,
        salaryPercentBasisPoints.isAcceptableOrUnknown(
          data['salary_percent_basis_points']!,
          _salaryPercentBasisPointsMeta,
        ),
      );
    }
    if (data.containsKey('fixed_daily_salary_centavos')) {
      context.handle(
        _fixedDailySalaryCentavosMeta,
        fixedDailySalaryCentavos.isAcceptableOrUnknown(
          data['fixed_daily_salary_centavos']!,
          _fixedDailySalaryCentavosMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      salaryMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salary_mode'],
      )!,
      salaryPercentBasisPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}salary_percent_basis_points'],
      )!,
      fixedDailySalaryCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fixed_daily_salary_centavos'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final String salaryMode;
  final int salaryPercentBasisPoints;
  final int fixedDailySalaryCentavos;
  const Setting({
    required this.id,
    required this.salaryMode,
    required this.salaryPercentBasisPoints,
    required this.fixedDailySalaryCentavos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['salary_mode'] = Variable<String>(salaryMode);
    map['salary_percent_basis_points'] = Variable<int>(
      salaryPercentBasisPoints,
    );
    map['fixed_daily_salary_centavos'] = Variable<int>(
      fixedDailySalaryCentavos,
    );
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      salaryMode: Value(salaryMode),
      salaryPercentBasisPoints: Value(salaryPercentBasisPoints),
      fixedDailySalaryCentavos: Value(fixedDailySalaryCentavos),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      salaryMode: serializer.fromJson<String>(json['salaryMode']),
      salaryPercentBasisPoints: serializer.fromJson<int>(
        json['salaryPercentBasisPoints'],
      ),
      fixedDailySalaryCentavos: serializer.fromJson<int>(
        json['fixedDailySalaryCentavos'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'salaryMode': serializer.toJson<String>(salaryMode),
      'salaryPercentBasisPoints': serializer.toJson<int>(
        salaryPercentBasisPoints,
      ),
      'fixedDailySalaryCentavos': serializer.toJson<int>(
        fixedDailySalaryCentavos,
      ),
    };
  }

  Setting copyWith({
    int? id,
    String? salaryMode,
    int? salaryPercentBasisPoints,
    int? fixedDailySalaryCentavos,
  }) => Setting(
    id: id ?? this.id,
    salaryMode: salaryMode ?? this.salaryMode,
    salaryPercentBasisPoints:
        salaryPercentBasisPoints ?? this.salaryPercentBasisPoints,
    fixedDailySalaryCentavos:
        fixedDailySalaryCentavos ?? this.fixedDailySalaryCentavos,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      salaryMode: data.salaryMode.present
          ? data.salaryMode.value
          : this.salaryMode,
      salaryPercentBasisPoints: data.salaryPercentBasisPoints.present
          ? data.salaryPercentBasisPoints.value
          : this.salaryPercentBasisPoints,
      fixedDailySalaryCentavos: data.fixedDailySalaryCentavos.present
          ? data.fixedDailySalaryCentavos.value
          : this.fixedDailySalaryCentavos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('salaryMode: $salaryMode, ')
          ..write('salaryPercentBasisPoints: $salaryPercentBasisPoints, ')
          ..write('fixedDailySalaryCentavos: $fixedDailySalaryCentavos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    salaryMode,
    salaryPercentBasisPoints,
    fixedDailySalaryCentavos,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.salaryMode == this.salaryMode &&
          other.salaryPercentBasisPoints == this.salaryPercentBasisPoints &&
          other.fixedDailySalaryCentavos == this.fixedDailySalaryCentavos);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<String> salaryMode;
  final Value<int> salaryPercentBasisPoints;
  final Value<int> fixedDailySalaryCentavos;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.salaryMode = const Value.absent(),
    this.salaryPercentBasisPoints = const Value.absent(),
    this.fixedDailySalaryCentavos = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.salaryMode = const Value.absent(),
    this.salaryPercentBasisPoints = const Value.absent(),
    this.fixedDailySalaryCentavos = const Value.absent(),
  });
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<String>? salaryMode,
    Expression<int>? salaryPercentBasisPoints,
    Expression<int>? fixedDailySalaryCentavos,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (salaryMode != null) 'salary_mode': salaryMode,
      if (salaryPercentBasisPoints != null)
        'salary_percent_basis_points': salaryPercentBasisPoints,
      if (fixedDailySalaryCentavos != null)
        'fixed_daily_salary_centavos': fixedDailySalaryCentavos,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? salaryMode,
    Value<int>? salaryPercentBasisPoints,
    Value<int>? fixedDailySalaryCentavos,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      salaryMode: salaryMode ?? this.salaryMode,
      salaryPercentBasisPoints:
          salaryPercentBasisPoints ?? this.salaryPercentBasisPoints,
      fixedDailySalaryCentavos:
          fixedDailySalaryCentavos ?? this.fixedDailySalaryCentavos,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (salaryMode.present) {
      map['salary_mode'] = Variable<String>(salaryMode.value);
    }
    if (salaryPercentBasisPoints.present) {
      map['salary_percent_basis_points'] = Variable<int>(
        salaryPercentBasisPoints.value,
      );
    }
    if (fixedDailySalaryCentavos.present) {
      map['fixed_daily_salary_centavos'] = Variable<int>(
        fixedDailySalaryCentavos.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('salaryMode: $salaryMode, ')
          ..write('salaryPercentBasisPoints: $salaryPercentBasisPoints, ')
          ..write('fixedDailySalaryCentavos: $fixedDailySalaryCentavos')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $CapitalHistoryTable capitalHistory = $CapitalHistoryTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleItemsTable saleItems = $SaleItemsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $RestockPurchasesTable restockPurchases = $RestockPurchasesTable(
    this,
  );
  late final $PayoutsTable payouts = $PayoutsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    products,
    capitalHistory,
    sales,
    saleItems,
    expenses,
    restockPurchases,
    payouts,
    settings,
  ];
}

typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  required String name,
  required int defaultPriceCentavos,
  required int capitalCentavos,
  Value<int> sortOrder,
  Value<bool> archived,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> defaultPriceCentavos,
  Value<int> capitalCentavos,
  Value<int> sortOrder,
  Value<bool> archived,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CapitalHistoryTable, List<CapitalHistoryData>>
  _capitalHistoryRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.capitalHistory,
    aliasName: 'products__id__capital_history__product_id',
  );

  $$CapitalHistoryTableProcessedTableManager get capitalHistoryRefs {
    final manager = $$CapitalHistoryTableTableManager(
      $_db,
      $_db.capitalHistory,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_capitalHistoryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SaleItemsTable, List<SaleItem>>
  _saleItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItems,
    aliasName: 'products__id__sale_items__product_id',
  );

  $$SaleItemsTableProcessedTableManager get saleItemsRefs {
    final manager = $$SaleItemsTableTableManager(
      $_db,
      $_db.saleItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'products__id__expenses__product_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultPriceCentavos => $composableBuilder(
    column: $table.defaultPriceCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capitalCentavos => $composableBuilder(
    column: $table.capitalCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> capitalHistoryRefs(
    Expression<bool> Function($$CapitalHistoryTableFilterComposer f) f,
  ) {
    final $$CapitalHistoryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.capitalHistory,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapitalHistoryTableFilterComposer(
            $db: $db,
            $table: $db.capitalHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> saleItemsRefs(
    Expression<bool> Function($$SaleItemsTableFilterComposer f) f,
  ) {
    final $$SaleItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableFilterComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultPriceCentavos => $composableBuilder(
    column: $table.defaultPriceCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capitalCentavos => $composableBuilder(
    column: $table.capitalCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get defaultPriceCentavos => $composableBuilder(
    column: $table.defaultPriceCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capitalCentavos => $composableBuilder(
    column: $table.capitalCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> capitalHistoryRefs<T extends Object>(
    Expression<T> Function($$CapitalHistoryTableAnnotationComposer a) f,
  ) {
    final $$CapitalHistoryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.capitalHistory,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapitalHistoryTableAnnotationComposer(
            $db: $db,
            $table: $db.capitalHistory,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> saleItemsRefs<T extends Object>(
    Expression<T> Function($$SaleItemsTableAnnotationComposer a) f,
  ) {
    final $$SaleItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, $$ProductsTableReferences),
          Product,
          PrefetchHooks Function({
            bool capitalHistoryRefs,
            bool saleItemsRefs,
            bool expensesRefs,
          })
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> defaultPriceCentavos = const Value.absent(),
                Value<int> capitalCentavos = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                name: name,
                defaultPriceCentavos: defaultPriceCentavos,
                capitalCentavos: capitalCentavos,
                sortOrder: sortOrder,
                archived: archived,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int defaultPriceCentavos,
                required int capitalCentavos,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> archived = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                defaultPriceCentavos: defaultPriceCentavos,
                capitalCentavos: capitalCentavos,
                sortOrder: sortOrder,
                archived: archived,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductsTable, Product>(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                capitalHistoryRefs = false,
                saleItemsRefs = false,
                expensesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (capitalHistoryRefs) db.capitalHistory,
                    if (saleItemsRefs) db.saleItems,
                    if (expensesRefs) db.expenses,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (capitalHistoryRefs)
                        await $_getPrefetchedDataByColumns<
                          Product,
                          $ProductsTable,
                          CapitalHistoryData,
                          $CapitalHistoryTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._capitalHistoryRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).capitalHistoryRefs,
                          currentColumn: 'id',
                          referencedColumn: 'product_id',
                          typedResults: items,
                        ),
                      if (saleItemsRefs)
                        await $_getPrefetchedDataByColumns<
                          Product,
                          $ProductsTable,
                          SaleItem,
                          $SaleItemsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._saleItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).saleItemsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'product_id',
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedDataByColumns<
                          Product,
                          $ProductsTable,
                          Expense,
                          $ExpensesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'product_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, $$ProductsTableReferences),
      Product,
      PrefetchHooks Function({
        bool capitalHistoryRefs,
        bool saleItemsRefs,
        bool expensesRefs,
      })
    >;
typedef $$CapitalHistoryTableCreateCompanionBuilder =
    CapitalHistoryCompanion Function({
      Value<int> id,
      required int productId,
      required int oldCentavos,
      required int newCentavos,
      required DateTime changedAt,
    });
typedef $$CapitalHistoryTableUpdateCompanionBuilder =
    CapitalHistoryCompanion Function({
      Value<int> id,
      Value<int> productId,
      Value<int> oldCentavos,
      Value<int> newCentavos,
      Value<DateTime> changedAt,
    });

final class $$CapitalHistoryTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CapitalHistoryTable,
          CapitalHistoryData
        > {
  $$CapitalHistoryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('capital_history__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CapitalHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $CapitalHistoryTable> {
  $$CapitalHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oldCentavos => $composableBuilder(
    column: $table.oldCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get newCentavos => $composableBuilder(
    column: $table.newCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapitalHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $CapitalHistoryTable> {
  $$CapitalHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oldCentavos => $composableBuilder(
    column: $table.oldCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get newCentavos => $composableBuilder(
    column: $table.newCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapitalHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $CapitalHistoryTable> {
  $$CapitalHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get oldCentavos => $composableBuilder(
    column: $table.oldCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get newCentavos => $composableBuilder(
    column: $table.newCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapitalHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CapitalHistoryTable,
          CapitalHistoryData,
          $$CapitalHistoryTableFilterComposer,
          $$CapitalHistoryTableOrderingComposer,
          $$CapitalHistoryTableAnnotationComposer,
          $$CapitalHistoryTableCreateCompanionBuilder,
          $$CapitalHistoryTableUpdateCompanionBuilder,
          (CapitalHistoryData, $$CapitalHistoryTableReferences),
          CapitalHistoryData,
          PrefetchHooks Function({bool productId})
        > {
  $$CapitalHistoryTableTableManager(
    _$AppDatabase db,
    $CapitalHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CapitalHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CapitalHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CapitalHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<int> oldCentavos = const Value.absent(),
                Value<int> newCentavos = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
              }) => CapitalHistoryCompanion(
                id: id,
                productId: productId,
                oldCentavos: oldCentavos,
                newCentavos: newCentavos,
                changedAt: changedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int productId,
                required int oldCentavos,
                required int newCentavos,
                required DateTime changedAt,
              }) => CapitalHistoryCompanion.insert(
                id: id,
                productId: productId,
                oldCentavos: oldCentavos,
                newCentavos: newCentavos,
                changedAt: changedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CapitalHistoryTable, CapitalHistoryData>(table),
                  $$CapitalHistoryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productId,
                        referencedTable: $$CapitalHistoryTableReferences
                            ._productIdTable(db),
                        referencedColumn: $$CapitalHistoryTableReferences
                            ._productIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CapitalHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CapitalHistoryTable,
      CapitalHistoryData,
      $$CapitalHistoryTableFilterComposer,
      $$CapitalHistoryTableOrderingComposer,
      $$CapitalHistoryTableAnnotationComposer,
      $$CapitalHistoryTableCreateCompanionBuilder,
      $$CapitalHistoryTableUpdateCompanionBuilder,
      (CapitalHistoryData, $$CapitalHistoryTableReferences),
      CapitalHistoryData,
      PrefetchHooks Function({bool productId})
    >;
typedef $$SalesTableCreateCompanionBuilder = SalesCompanion Function({
  Value<int> id,
  required DateTime createdAt,
  required int exactTotalCentavos,
  required int chargedCentavos,
  required int paidCentavos,
  required int changeCentavos,
  Value<bool> voided,
});
typedef $$SalesTableUpdateCompanionBuilder = SalesCompanion Function({
  Value<int> id,
  Value<DateTime> createdAt,
  Value<int> exactTotalCentavos,
  Value<int> chargedCentavos,
  Value<int> paidCentavos,
  Value<int> changeCentavos,
  Value<bool> voided,
});

final class $$SalesTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTable, Sale> {
  $$SalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SaleItemsTable, List<SaleItem>>
  _saleItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItems,
    aliasName: 'sales__id__sale_items__sale_id',
  );

  $$SaleItemsTableProcessedTableManager get saleItemsRefs {
    final manager = $$SaleItemsTableTableManager(
      $_db,
      $_db.saleItems,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exactTotalCentavos => $composableBuilder(
    column: $table.exactTotalCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chargedCentavos => $composableBuilder(
    column: $table.chargedCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paidCentavos => $composableBuilder(
    column: $table.paidCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get changeCentavos => $composableBuilder(
    column: $table.changeCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get voided => $composableBuilder(
    column: $table.voided,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> saleItemsRefs(
    Expression<bool> Function($$SaleItemsTableFilterComposer f) f,
  ) {
    final $$SaleItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableFilterComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exactTotalCentavos => $composableBuilder(
    column: $table.exactTotalCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chargedCentavos => $composableBuilder(
    column: $table.chargedCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paidCentavos => $composableBuilder(
    column: $table.paidCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get changeCentavos => $composableBuilder(
    column: $table.changeCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get voided => $composableBuilder(
    column: $table.voided,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get exactTotalCentavos => $composableBuilder(
    column: $table.exactTotalCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chargedCentavos => $composableBuilder(
    column: $table.chargedCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paidCentavos => $composableBuilder(
    column: $table.paidCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get changeCentavos => $composableBuilder(
    column: $table.changeCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get voided =>
      $composableBuilder(column: $table.voided, builder: (column) => column);

  Expression<T> saleItemsRefs<T extends Object>(
    Expression<T> Function($$SaleItemsTableAnnotationComposer a) f,
  ) {
    final $$SaleItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItems,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          Sale,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (Sale, $$SalesTableReferences),
          Sale,
          PrefetchHooks Function({bool saleItemsRefs})
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> exactTotalCentavos = const Value.absent(),
                Value<int> chargedCentavos = const Value.absent(),
                Value<int> paidCentavos = const Value.absent(),
                Value<int> changeCentavos = const Value.absent(),
                Value<bool> voided = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                createdAt: createdAt,
                exactTotalCentavos: exactTotalCentavos,
                chargedCentavos: chargedCentavos,
                paidCentavos: paidCentavos,
                changeCentavos: changeCentavos,
                voided: voided,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime createdAt,
                required int exactTotalCentavos,
                required int chargedCentavos,
                required int paidCentavos,
                required int changeCentavos,
                Value<bool> voided = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                createdAt: createdAt,
                exactTotalCentavos: exactTotalCentavos,
                chargedCentavos: chargedCentavos,
                paidCentavos: paidCentavos,
                changeCentavos: changeCentavos,
                voided: voided,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SalesTable, Sale>(table),
                  $$SalesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (saleItemsRefs) db.saleItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (saleItemsRefs)
                    await $_getPrefetchedDataByColumns<
                      Sale,
                      $SalesTable,
                      SaleItem,
                      $SaleItemsTable
                    >(
                      currentTable: table,
                      referencedTable: $$SalesTableReferences
                          ._saleItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SalesTableReferences(db, table, p0).saleItemsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'sale_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      Sale,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (Sale, $$SalesTableReferences),
      Sale,
      PrefetchHooks Function({bool saleItemsRefs})
    >;
typedef $$SaleItemsTableCreateCompanionBuilder = SaleItemsCompanion Function({
  Value<int> id,
  required int saleId,
  required int productId,
  required String productNameSnapshot,
  required int grams,
  required int pricePerKgCentavos,
  required int capitalPerKgCentavos,
});
typedef $$SaleItemsTableUpdateCompanionBuilder = SaleItemsCompanion Function({
  Value<int> id,
  Value<int> saleId,
  Value<int> productId,
  Value<String> productNameSnapshot,
  Value<int> grams,
  Value<int> pricePerKgCentavos,
  Value<int> capitalPerKgCentavos,
});

final class $$SaleItemsTableReferences
    extends BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItem> {
  $$SaleItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SalesTable _saleIdTable(_$AppDatabase db) =>
      db.sales.createAlias('sale_items__sale_id__sales__id');

  $$SalesTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<int>('sale_id')!;

    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('sale_items__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SaleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePerKgCentavos => $composableBuilder(
    column: $table.pricePerKgCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capitalPerKgCentavos => $composableBuilder(
    column: $table.capitalPerKgCentavos,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesTableFilterComposer get saleId {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePerKgCentavos => $composableBuilder(
    column: $table.pricePerKgCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capitalPerKgCentavos => $composableBuilder(
    column: $table.capitalPerKgCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesTableOrderingComposer get saleId {
    final $$SalesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableOrderingComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<int> get pricePerKgCentavos => $composableBuilder(
    column: $table.pricePerKgCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capitalPerKgCentavos => $composableBuilder(
    column: $table.capitalPerKgCentavos,
    builder: (column) => column,
  );

  $$SalesTableAnnotationComposer get saleId {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleItemsTable,
          SaleItem,
          $$SaleItemsTableFilterComposer,
          $$SaleItemsTableOrderingComposer,
          $$SaleItemsTableAnnotationComposer,
          $$SaleItemsTableCreateCompanionBuilder,
          $$SaleItemsTableUpdateCompanionBuilder,
          (SaleItem, $$SaleItemsTableReferences),
          SaleItem,
          PrefetchHooks Function({bool saleId, bool productId})
        > {
  $$SaleItemsTableTableManager(_$AppDatabase db, $SaleItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> saleId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<String> productNameSnapshot = const Value.absent(),
                Value<int> grams = const Value.absent(),
                Value<int> pricePerKgCentavos = const Value.absent(),
                Value<int> capitalPerKgCentavos = const Value.absent(),
              }) => SaleItemsCompanion(
                id: id,
                saleId: saleId,
                productId: productId,
                productNameSnapshot: productNameSnapshot,
                grams: grams,
                pricePerKgCentavos: pricePerKgCentavos,
                capitalPerKgCentavos: capitalPerKgCentavos,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int saleId,
                required int productId,
                required String productNameSnapshot,
                required int grams,
                required int pricePerKgCentavos,
                required int capitalPerKgCentavos,
              }) => SaleItemsCompanion.insert(
                id: id,
                saleId: saleId,
                productId: productId,
                productNameSnapshot: productNameSnapshot,
                grams: grams,
                pricePerKgCentavos: pricePerKgCentavos,
                capitalPerKgCentavos: capitalPerKgCentavos,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleItemsTable, SaleItem>(table),
                  $$SaleItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (saleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.saleId,
                        referencedTable: $$SaleItemsTableReferences
                            ._saleIdTable(db),
                        referencedColumn: $$SaleItemsTableReferences
                            ._saleIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (productId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productId,
                        referencedTable: $$SaleItemsTableReferences
                            ._productIdTable(db),
                        referencedColumn: $$SaleItemsTableReferences
                            ._productIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SaleItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleItemsTable,
      SaleItem,
      $$SaleItemsTableFilterComposer,
      $$SaleItemsTableOrderingComposer,
      $$SaleItemsTableAnnotationComposer,
      $$SaleItemsTableCreateCompanionBuilder,
      $$SaleItemsTableUpdateCompanionBuilder,
      (SaleItem, $$SaleItemsTableReferences),
      SaleItem,
      PrefetchHooks Function({bool saleId, bool productId})
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  required DateTime date,
  required String type,
  required int amountCentavos,
  Value<String?> note,
  Value<int?> productId,
  Value<int?> grams,
  Value<int?> capitalPerKgCentavos,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> type,
  Value<int> amountCentavos,
  Value<String?> note,
  Value<int?> productId,
  Value<int?> grams,
  Value<int?> capitalPerKgCentavos,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('expenses__product_id__products__id');

  $$ProductsTableProcessedTableManager? get productId {
    final $_column = $_itemColumn<int>('product_id');
    if ($_column == null) return null;
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCentavos => $composableBuilder(
    column: $table.amountCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capitalPerKgCentavos => $composableBuilder(
    column: $table.capitalPerKgCentavos,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCentavos => $composableBuilder(
    column: $table.amountCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capitalPerKgCentavos => $composableBuilder(
    column: $table.capitalPerKgCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountCentavos => $composableBuilder(
    column: $table.amountCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<int> get capitalPerKgCentavos => $composableBuilder(
    column: $table.capitalPerKgCentavos,
    builder: (column) => column,
  );

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({bool productId})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> amountCentavos = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<int?> grams = const Value.absent(),
                Value<int?> capitalPerKgCentavos = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                date: date,
                type: type,
                amountCentavos: amountCentavos,
                note: note,
                productId: productId,
                grams: grams,
                capitalPerKgCentavos: capitalPerKgCentavos,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required String type,
                required int amountCentavos,
                Value<String?> note = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<int?> grams = const Value.absent(),
                Value<int?> capitalPerKgCentavos = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                date: date,
                type: type,
                amountCentavos: amountCentavos,
                note: note,
                productId: productId,
                grams: grams,
                capitalPerKgCentavos: capitalPerKgCentavos,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, Expense>(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.productId,
                        referencedTable: $$ExpensesTableReferences
                            ._productIdTable(db),
                        referencedColumn: $$ExpensesTableReferences
                            ._productIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({bool productId})
    >;
typedef $$RestockPurchasesTableCreateCompanionBuilder =
    RestockPurchasesCompanion Function({
      Value<int> id,
      required DateTime date,
      required int amountCentavos,
      Value<String?> note,
    });
typedef $$RestockPurchasesTableUpdateCompanionBuilder =
    RestockPurchasesCompanion Function({
      Value<int> id,
      Value<DateTime> date,
      Value<int> amountCentavos,
      Value<String?> note,
    });

class $$RestockPurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $RestockPurchasesTable> {
  $$RestockPurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCentavos => $composableBuilder(
    column: $table.amountCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RestockPurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $RestockPurchasesTable> {
  $$RestockPurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCentavos => $composableBuilder(
    column: $table.amountCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RestockPurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RestockPurchasesTable> {
  $$RestockPurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amountCentavos => $composableBuilder(
    column: $table.amountCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$RestockPurchasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RestockPurchasesTable,
          RestockPurchase,
          $$RestockPurchasesTableFilterComposer,
          $$RestockPurchasesTableOrderingComposer,
          $$RestockPurchasesTableAnnotationComposer,
          $$RestockPurchasesTableCreateCompanionBuilder,
          $$RestockPurchasesTableUpdateCompanionBuilder,
          (
            RestockPurchase,
            BaseReferences<
              _$AppDatabase,
              $RestockPurchasesTable,
              RestockPurchase
            >,
          ),
          RestockPurchase,
          PrefetchHooks Function()
        > {
  $$RestockPurchasesTableTableManager(
    _$AppDatabase db,
    $RestockPurchasesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RestockPurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RestockPurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RestockPurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> amountCentavos = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => RestockPurchasesCompanion(
                id: id,
                date: date,
                amountCentavos: amountCentavos,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int amountCentavos,
                Value<String?> note = const Value.absent(),
              }) => RestockPurchasesCompanion.insert(
                id: id,
                date: date,
                amountCentavos: amountCentavos,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RestockPurchasesTable, RestockPurchase>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RestockPurchasesTable,
                    RestockPurchase
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RestockPurchasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RestockPurchasesTable,
      RestockPurchase,
      $$RestockPurchasesTableFilterComposer,
      $$RestockPurchasesTableOrderingComposer,
      $$RestockPurchasesTableAnnotationComposer,
      $$RestockPurchasesTableCreateCompanionBuilder,
      $$RestockPurchasesTableUpdateCompanionBuilder,
      (
        RestockPurchase,
        BaseReferences<_$AppDatabase, $RestockPurchasesTable, RestockPurchase>,
      ),
      RestockPurchase,
      PrefetchHooks Function()
    >;
typedef $$PayoutsTableCreateCompanionBuilder = PayoutsCompanion Function({
  Value<int> id,
  required DateTime date,
  required int toParentsCentavos,
  required int salaryCentavos,
  required int reserveCentavos,
  Value<bool> locked,
});
typedef $$PayoutsTableUpdateCompanionBuilder = PayoutsCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<int> toParentsCentavos,
  Value<int> salaryCentavos,
  Value<int> reserveCentavos,
  Value<bool> locked,
});

class $$PayoutsTableFilterComposer
    extends Composer<_$AppDatabase, $PayoutsTable> {
  $$PayoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toParentsCentavos => $composableBuilder(
    column: $table.toParentsCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salaryCentavos => $composableBuilder(
    column: $table.salaryCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reserveCentavos => $composableBuilder(
    column: $table.reserveCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PayoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $PayoutsTable> {
  $$PayoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toParentsCentavos => $composableBuilder(
    column: $table.toParentsCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salaryCentavos => $composableBuilder(
    column: $table.salaryCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reserveCentavos => $composableBuilder(
    column: $table.reserveCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PayoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayoutsTable> {
  $$PayoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get toParentsCentavos => $composableBuilder(
    column: $table.toParentsCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get salaryCentavos => $composableBuilder(
    column: $table.salaryCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reserveCentavos => $composableBuilder(
    column: $table.reserveCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);
}

class $$PayoutsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayoutsTable,
          Payout,
          $$PayoutsTableFilterComposer,
          $$PayoutsTableOrderingComposer,
          $$PayoutsTableAnnotationComposer,
          $$PayoutsTableCreateCompanionBuilder,
          $$PayoutsTableUpdateCompanionBuilder,
          (Payout, BaseReferences<_$AppDatabase, $PayoutsTable, Payout>),
          Payout,
          PrefetchHooks Function()
        > {
  $$PayoutsTableTableManager(_$AppDatabase db, $PayoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> toParentsCentavos = const Value.absent(),
                Value<int> salaryCentavos = const Value.absent(),
                Value<int> reserveCentavos = const Value.absent(),
                Value<bool> locked = const Value.absent(),
              }) => PayoutsCompanion(
                id: id,
                date: date,
                toParentsCentavos: toParentsCentavos,
                salaryCentavos: salaryCentavos,
                reserveCentavos: reserveCentavos,
                locked: locked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required int toParentsCentavos,
                required int salaryCentavos,
                required int reserveCentavos,
                Value<bool> locked = const Value.absent(),
              }) => PayoutsCompanion.insert(
                id: id,
                date: date,
                toParentsCentavos: toParentsCentavos,
                salaryCentavos: salaryCentavos,
                reserveCentavos: reserveCentavos,
                locked: locked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PayoutsTable, Payout>(table),
                  BaseReferences<_$AppDatabase, $PayoutsTable, Payout>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PayoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayoutsTable,
      Payout,
      $$PayoutsTableFilterComposer,
      $$PayoutsTableOrderingComposer,
      $$PayoutsTableAnnotationComposer,
      $$PayoutsTableCreateCompanionBuilder,
      $$PayoutsTableUpdateCompanionBuilder,
      (Payout, BaseReferences<_$AppDatabase, $PayoutsTable, Payout>),
      Payout,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<String> salaryMode,
  Value<int> salaryPercentBasisPoints,
  Value<int> fixedDailySalaryCentavos,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<String> salaryMode,
  Value<int> salaryPercentBasisPoints,
  Value<int> fixedDailySalaryCentavos,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salaryMode => $composableBuilder(
    column: $table.salaryMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salaryPercentBasisPoints => $composableBuilder(
    column: $table.salaryPercentBasisPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fixedDailySalaryCentavos => $composableBuilder(
    column: $table.fixedDailySalaryCentavos,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salaryMode => $composableBuilder(
    column: $table.salaryMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salaryPercentBasisPoints => $composableBuilder(
    column: $table.salaryPercentBasisPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fixedDailySalaryCentavos => $composableBuilder(
    column: $table.fixedDailySalaryCentavos,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get salaryMode => $composableBuilder(
    column: $table.salaryMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get salaryPercentBasisPoints => $composableBuilder(
    column: $table.salaryPercentBasisPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fixedDailySalaryCentavos => $composableBuilder(
    column: $table.fixedDailySalaryCentavos,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          Setting,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> salaryMode = const Value.absent(),
                Value<int> salaryPercentBasisPoints = const Value.absent(),
                Value<int> fixedDailySalaryCentavos = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                salaryMode: salaryMode,
                salaryPercentBasisPoints: salaryPercentBasisPoints,
                fixedDailySalaryCentavos: fixedDailySalaryCentavos,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> salaryMode = const Value.absent(),
                Value<int> salaryPercentBasisPoints = const Value.absent(),
                Value<int> fixedDailySalaryCentavos = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                salaryMode: salaryMode,
                salaryPercentBasisPoints: salaryPercentBasisPoints,
                fixedDailySalaryCentavos: fixedDailySalaryCentavos,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, Setting>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, Setting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      Setting,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
      Setting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$CapitalHistoryTableTableManager get capitalHistory =>
      $$CapitalHistoryTableTableManager(_db, _db.capitalHistory);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleItemsTableTableManager get saleItems =>
      $$SaleItemsTableTableManager(_db, _db.saleItems);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$RestockPurchasesTableTableManager get restockPurchases =>
      $$RestockPurchasesTableTableManager(_db, _db.restockPurchases);
  $$PayoutsTableTableManager get payouts =>
      $$PayoutsTableTableManager(_db, _db.payouts);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
