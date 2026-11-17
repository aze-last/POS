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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    name,
    defaultPriceCentavos,
    capitalCentavos,
    sortOrder,
    archived,
    imagePath,
    updatedAt,
    deletedAt,
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
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
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
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
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final int id;
  final String? syncId;
  final String name;
  final int defaultPriceCentavos;
  final int capitalCentavos;
  final int sortOrder;
  final bool archived;
  final String? imagePath;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const Product({
    required this.id,
    this.syncId,
    required this.name,
    required this.defaultPriceCentavos,
    required this.capitalCentavos,
    required this.sortOrder,
    required this.archived,
    this.imagePath,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    map['name'] = Variable<String>(name);
    map['default_price_centavos'] = Variable<int>(defaultPriceCentavos);
    map['capital_centavos'] = Variable<int>(capitalCentavos);
    map['sort_order'] = Variable<int>(sortOrder);
    map['archived'] = Variable<bool>(archived);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      syncId: syncId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncId),
      name: Value(name),
      defaultPriceCentavos: Value(defaultPriceCentavos),
      capitalCentavos: Value(capitalCentavos),
      sortOrder: Value(sortOrder),
      archived: Value(archived),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      name: serializer.fromJson<String>(json['name']),
      defaultPriceCentavos: serializer.fromJson<int>(
        json['defaultPriceCentavos'],
      ),
      capitalCentavos: serializer.fromJson<int>(json['capitalCentavos']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      archived: serializer.fromJson<bool>(json['archived']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String?>(syncId),
      'name': serializer.toJson<String>(name),
      'defaultPriceCentavos': serializer.toJson<int>(defaultPriceCentavos),
      'capitalCentavos': serializer.toJson<int>(capitalCentavos),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'archived': serializer.toJson<bool>(archived),
      'imagePath': serializer.toJson<String?>(imagePath),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Product copyWith({
    int? id,
    Value<String?> syncId = const Value.absent(),
    String? name,
    int? defaultPriceCentavos,
    int? capitalCentavos,
    int? sortOrder,
    bool? archived,
    Value<String?> imagePath = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Product(
    id: id ?? this.id,
    syncId: syncId.present ? syncId.value : this.syncId,
    name: name ?? this.name,
    defaultPriceCentavos: defaultPriceCentavos ?? this.defaultPriceCentavos,
    capitalCentavos: capitalCentavos ?? this.capitalCentavos,
    sortOrder: sortOrder ?? this.sortOrder,
    archived: archived ?? this.archived,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      name: data.name.present ? data.name.value : this.name,
      defaultPriceCentavos: data.defaultPriceCentavos.present
          ? data.defaultPriceCentavos.value
          : this.defaultPriceCentavos,
      capitalCentavos: data.capitalCentavos.present
          ? data.capitalCentavos.value
          : this.capitalCentavos,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      archived: data.archived.present ? data.archived.value : this.archived,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('name: $name, ')
          ..write('defaultPriceCentavos: $defaultPriceCentavos, ')
          ..write('capitalCentavos: $capitalCentavos, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archived: $archived, ')
          ..write('imagePath: $imagePath, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    name,
    defaultPriceCentavos,
    capitalCentavos,
    sortOrder,
    archived,
    imagePath,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.name == this.name &&
          other.defaultPriceCentavos == this.defaultPriceCentavos &&
          other.capitalCentavos == this.capitalCentavos &&
          other.sortOrder == this.sortOrder &&
          other.archived == this.archived &&
          other.imagePath == this.imagePath &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<String?> syncId;
  final Value<String> name;
  final Value<int> defaultPriceCentavos;
  final Value<int> capitalCentavos;
  final Value<int> sortOrder;
  final Value<bool> archived;
  final Value<String?> imagePath;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultPriceCentavos = const Value.absent(),
    this.capitalCentavos = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archived = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    required String name,
    required int defaultPriceCentavos,
    required int capitalCentavos,
    this.sortOrder = const Value.absent(),
    this.archived = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : name = Value(name),
       defaultPriceCentavos = Value(defaultPriceCentavos),
       capitalCentavos = Value(capitalCentavos);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<String>? name,
    Expression<int>? defaultPriceCentavos,
    Expression<int>? capitalCentavos,
    Expression<int>? sortOrder,
    Expression<bool>? archived,
    Expression<String>? imagePath,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (name != null) 'name': name,
      if (defaultPriceCentavos != null)
        'default_price_centavos': defaultPriceCentavos,
      if (capitalCentavos != null) 'capital_centavos': capitalCentavos,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (archived != null) 'archived': archived,
      if (imagePath != null) 'image_path': imagePath,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  ProductsCompanion copyWith({
    Value<int>? id,
    Value<String?>? syncId,
    Value<String>? name,
    Value<int>? defaultPriceCentavos,
    Value<int>? capitalCentavos,
    Value<int>? sortOrder,
    Value<bool>? archived,
    Value<String?>? imagePath,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      name: name ?? this.name,
      defaultPriceCentavos: defaultPriceCentavos ?? this.defaultPriceCentavos,
      capitalCentavos: capitalCentavos ?? this.capitalCentavos,
      sortOrder: sortOrder ?? this.sortOrder,
      archived: archived ?? this.archived,
      imagePath: imagePath ?? this.imagePath,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
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
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('name: $name, ')
          ..write('defaultPriceCentavos: $defaultPriceCentavos, ')
          ..write('capitalCentavos: $capitalCentavos, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archived: $archived, ')
          ..write('imagePath: $imagePath, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    productId,
    oldCentavos,
    newCentavos,
    changedAt,
    updatedAt,
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
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
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
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
  final String? syncId;
  final int productId;
  final int oldCentavos;
  final int newCentavos;
  final DateTime changedAt;
  final DateTime? updatedAt;
  const CapitalHistoryData({
    required this.id,
    this.syncId,
    required this.productId,
    required this.oldCentavos,
    required this.newCentavos,
    required this.changedAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    map['product_id'] = Variable<int>(productId);
    map['old_centavos'] = Variable<int>(oldCentavos);
    map['new_centavos'] = Variable<int>(newCentavos);
    map['changed_at'] = Variable<DateTime>(changedAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  CapitalHistoryCompanion toCompanion(bool nullToAbsent) {
    return CapitalHistoryCompanion(
      id: Value(id),
      syncId: syncId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncId),
      productId: Value(productId),
      oldCentavos: Value(oldCentavos),
      newCentavos: Value(newCentavos),
      changedAt: Value(changedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory CapitalHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CapitalHistoryData(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      productId: serializer.fromJson<int>(json['productId']),
      oldCentavos: serializer.fromJson<int>(json['oldCentavos']),
      newCentavos: serializer.fromJson<int>(json['newCentavos']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String?>(syncId),
      'productId': serializer.toJson<int>(productId),
      'oldCentavos': serializer.toJson<int>(oldCentavos),
      'newCentavos': serializer.toJson<int>(newCentavos),
      'changedAt': serializer.toJson<DateTime>(changedAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  CapitalHistoryData copyWith({
    int? id,
    Value<String?> syncId = const Value.absent(),
    int? productId,
    int? oldCentavos,
    int? newCentavos,
    DateTime? changedAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => CapitalHistoryData(
    id: id ?? this.id,
    syncId: syncId.present ? syncId.value : this.syncId,
    productId: productId ?? this.productId,
    oldCentavos: oldCentavos ?? this.oldCentavos,
    newCentavos: newCentavos ?? this.newCentavos,
    changedAt: changedAt ?? this.changedAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  CapitalHistoryData copyWithCompanion(CapitalHistoryCompanion data) {
    return CapitalHistoryData(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      productId: data.productId.present ? data.productId.value : this.productId,
      oldCentavos: data.oldCentavos.present
          ? data.oldCentavos.value
          : this.oldCentavos,
      newCentavos: data.newCentavos.present
          ? data.newCentavos.value
          : this.newCentavos,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapitalHistoryData(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('productId: $productId, ')
          ..write('oldCentavos: $oldCentavos, ')
          ..write('newCentavos: $newCentavos, ')
          ..write('changedAt: $changedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    productId,
    oldCentavos,
    newCentavos,
    changedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapitalHistoryData &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.productId == this.productId &&
          other.oldCentavos == this.oldCentavos &&
          other.newCentavos == this.newCentavos &&
          other.changedAt == this.changedAt &&
          other.updatedAt == this.updatedAt);
}

class CapitalHistoryCompanion extends UpdateCompanion<CapitalHistoryData> {
  final Value<int> id;
  final Value<String?> syncId;
  final Value<int> productId;
  final Value<int> oldCentavos;
  final Value<int> newCentavos;
  final Value<DateTime> changedAt;
  final Value<DateTime?> updatedAt;
  const CapitalHistoryCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.productId = const Value.absent(),
    this.oldCentavos = const Value.absent(),
    this.newCentavos = const Value.absent(),
    this.changedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CapitalHistoryCompanion.insert({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    required int productId,
    required int oldCentavos,
    required int newCentavos,
    required DateTime changedAt,
    this.updatedAt = const Value.absent(),
  }) : productId = Value(productId),
       oldCentavos = Value(oldCentavos),
       newCentavos = Value(newCentavos),
       changedAt = Value(changedAt);
  static Insertable<CapitalHistoryData> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? productId,
    Expression<int>? oldCentavos,
    Expression<int>? newCentavos,
    Expression<DateTime>? changedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (productId != null) 'product_id': productId,
      if (oldCentavos != null) 'old_centavos': oldCentavos,
      if (newCentavos != null) 'new_centavos': newCentavos,
      if (changedAt != null) 'changed_at': changedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CapitalHistoryCompanion copyWith({
    Value<int>? id,
    Value<String?>? syncId,
    Value<int>? productId,
    Value<int>? oldCentavos,
    Value<int>? newCentavos,
    Value<DateTime>? changedAt,
    Value<DateTime?>? updatedAt,
  }) {
    return CapitalHistoryCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      productId: productId ?? this.productId,
      oldCentavos: oldCentavos ?? this.oldCentavos,
      newCentavos: newCentavos ?? this.newCentavos,
      changedAt: changedAt ?? this.changedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapitalHistoryCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('productId: $productId, ')
          ..write('oldCentavos: $oldCentavos, ')
          ..write('newCentavos: $newCentavos, ')
          ..write('changedAt: $changedAt, ')
          ..write('updatedAt: $updatedAt')
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
    'edited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _editCountMeta = const VerificationMeta(
    'editCount',
  );
  @override
  late final GeneratedColumn<int> editCount = GeneratedColumn<int>(
    'edit_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    createdAt,
    exactTotalCentavos,
    chargedCentavos,
    paidCentavos,
    changeCentavos,
    voided,
    editedAt,
    editCount,
    updatedAt,
    deletedAt,
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
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
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    }
    if (data.containsKey('edit_count')) {
      context.handle(
        _editCountMeta,
        editCount.isAcceptableOrUnknown(data['edit_count']!, _editCountMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
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
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}edited_at'],
      ),
      editCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}edit_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final int id;
  final String? syncId;
  final DateTime createdAt;
  final int exactTotalCentavos;
  final int chargedCentavos;
  final int paidCentavos;
  final int changeCentavos;
  final bool voided;
  final DateTime? editedAt;
  final int editCount;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const Sale({
    required this.id,
    this.syncId,
    required this.createdAt,
    required this.exactTotalCentavos,
    required this.chargedCentavos,
    required this.paidCentavos,
    required this.changeCentavos,
    required this.voided,
    this.editedAt,
    required this.editCount,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['exact_total_centavos'] = Variable<int>(exactTotalCentavos);
    map['charged_centavos'] = Variable<int>(chargedCentavos);
    map['paid_centavos'] = Variable<int>(paidCentavos);
    map['change_centavos'] = Variable<int>(changeCentavos);
    map['voided'] = Variable<bool>(voided);
    if (!nullToAbsent || editedAt != null) {
      map['edited_at'] = Variable<DateTime>(editedAt);
    }
    map['edit_count'] = Variable<int>(editCount);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      syncId: syncId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncId),
      createdAt: Value(createdAt),
      exactTotalCentavos: Value(exactTotalCentavos),
      chargedCentavos: Value(chargedCentavos),
      paidCentavos: Value(paidCentavos),
      changeCentavos: Value(changeCentavos),
      voided: Value(voided),
      editedAt: editedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(editedAt),
      editCount: Value(editCount),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Sale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      exactTotalCentavos: serializer.fromJson<int>(json['exactTotalCentavos']),
      chargedCentavos: serializer.fromJson<int>(json['chargedCentavos']),
      paidCentavos: serializer.fromJson<int>(json['paidCentavos']),
      changeCentavos: serializer.fromJson<int>(json['changeCentavos']),
      voided: serializer.fromJson<bool>(json['voided']),
      editedAt: serializer.fromJson<DateTime?>(json['editedAt']),
      editCount: serializer.fromJson<int>(json['editCount']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String?>(syncId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'exactTotalCentavos': serializer.toJson<int>(exactTotalCentavos),
      'chargedCentavos': serializer.toJson<int>(chargedCentavos),
      'paidCentavos': serializer.toJson<int>(paidCentavos),
      'changeCentavos': serializer.toJson<int>(changeCentavos),
      'voided': serializer.toJson<bool>(voided),
      'editedAt': serializer.toJson<DateTime?>(editedAt),
      'editCount': serializer.toJson<int>(editCount),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Sale copyWith({
    int? id,
    Value<String?> syncId = const Value.absent(),
    DateTime? createdAt,
    int? exactTotalCentavos,
    int? chargedCentavos,
    int? paidCentavos,
    int? changeCentavos,
    bool? voided,
    Value<DateTime?> editedAt = const Value.absent(),
    int? editCount,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Sale(
    id: id ?? this.id,
    syncId: syncId.present ? syncId.value : this.syncId,
    createdAt: createdAt ?? this.createdAt,
    exactTotalCentavos: exactTotalCentavos ?? this.exactTotalCentavos,
    chargedCentavos: chargedCentavos ?? this.chargedCentavos,
    paidCentavos: paidCentavos ?? this.paidCentavos,
    changeCentavos: changeCentavos ?? this.changeCentavos,
    voided: voided ?? this.voided,
    editedAt: editedAt.present ? editedAt.value : this.editedAt,
    editCount: editCount ?? this.editCount,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
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
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      editCount: data.editCount.present ? data.editCount.value : this.editCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('exactTotalCentavos: $exactTotalCentavos, ')
          ..write('chargedCentavos: $chargedCentavos, ')
          ..write('paidCentavos: $paidCentavos, ')
          ..write('changeCentavos: $changeCentavos, ')
          ..write('voided: $voided, ')
          ..write('editedAt: $editedAt, ')
          ..write('editCount: $editCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    createdAt,
    exactTotalCentavos,
    chargedCentavos,
    paidCentavos,
    changeCentavos,
    voided,
    editedAt,
    editCount,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.createdAt == this.createdAt &&
          other.exactTotalCentavos == this.exactTotalCentavos &&
          other.chargedCentavos == this.chargedCentavos &&
          other.paidCentavos == this.paidCentavos &&
          other.changeCentavos == this.changeCentavos &&
          other.voided == this.voided &&
          other.editedAt == this.editedAt &&
          other.editCount == this.editCount &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<int> id;
  final Value<String?> syncId;
  final Value<DateTime> createdAt;
  final Value<int> exactTotalCentavos;
  final Value<int> chargedCentavos;
  final Value<int> paidCentavos;
  final Value<int> changeCentavos;
  final Value<bool> voided;
  final Value<DateTime?> editedAt;
  final Value<int> editCount;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.exactTotalCentavos = const Value.absent(),
    this.chargedCentavos = const Value.absent(),
    this.paidCentavos = const Value.absent(),
    this.changeCentavos = const Value.absent(),
    this.voided = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.editCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  SalesCompanion.insert({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    required DateTime createdAt,
    required int exactTotalCentavos,
    required int chargedCentavos,
    required int paidCentavos,
    required int changeCentavos,
    this.voided = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.editCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : createdAt = Value(createdAt),
       exactTotalCentavos = Value(exactTotalCentavos),
       chargedCentavos = Value(chargedCentavos),
       paidCentavos = Value(paidCentavos),
       changeCentavos = Value(changeCentavos);
  static Insertable<Sale> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<DateTime>? createdAt,
    Expression<int>? exactTotalCentavos,
    Expression<int>? chargedCentavos,
    Expression<int>? paidCentavos,
    Expression<int>? changeCentavos,
    Expression<bool>? voided,
    Expression<DateTime>? editedAt,
    Expression<int>? editCount,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (createdAt != null) 'created_at': createdAt,
      if (exactTotalCentavos != null)
        'exact_total_centavos': exactTotalCentavos,
      if (chargedCentavos != null) 'charged_centavos': chargedCentavos,
      if (paidCentavos != null) 'paid_centavos': paidCentavos,
      if (changeCentavos != null) 'change_centavos': changeCentavos,
      if (voided != null) 'voided': voided,
      if (editedAt != null) 'edited_at': editedAt,
      if (editCount != null) 'edit_count': editCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  SalesCompanion copyWith({
    Value<int>? id,
    Value<String?>? syncId,
    Value<DateTime>? createdAt,
    Value<int>? exactTotalCentavos,
    Value<int>? chargedCentavos,
    Value<int>? paidCentavos,
    Value<int>? changeCentavos,
    Value<bool>? voided,
    Value<DateTime?>? editedAt,
    Value<int>? editCount,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      createdAt: createdAt ?? this.createdAt,
      exactTotalCentavos: exactTotalCentavos ?? this.exactTotalCentavos,
      chargedCentavos: chargedCentavos ?? this.chargedCentavos,
      paidCentavos: paidCentavos ?? this.paidCentavos,
      changeCentavos: changeCentavos ?? this.changeCentavos,
      voided: voided ?? this.voided,
      editedAt: editedAt ?? this.editedAt,
      editCount: editCount ?? this.editCount,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
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
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    if (editCount.present) {
      map['edit_count'] = Variable<int>(editCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('createdAt: $createdAt, ')
          ..write('exactTotalCentavos: $exactTotalCentavos, ')
          ..write('chargedCentavos: $chargedCentavos, ')
          ..write('paidCentavos: $paidCentavos, ')
          ..write('changeCentavos: $changeCentavos, ')
          ..write('voided: $voided, ')
          ..write('editedAt: $editedAt, ')
          ..write('editCount: $editCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    saleId,
    productId,
    productNameSnapshot,
    grams,
    pricePerKgCentavos,
    capitalPerKgCentavos,
    updatedAt,
    deletedAt,
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
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
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SaleItemsTable createAlias(String alias) {
    return $SaleItemsTable(attachedDatabase, alias);
  }
}

class SaleItem extends DataClass implements Insertable<SaleItem> {
  final int id;
  final String? syncId;
  final int saleId;
  final int productId;
  final String productNameSnapshot;
  final int grams;
  final int pricePerKgCentavos;
  final int capitalPerKgCentavos;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const SaleItem({
    required this.id,
    this.syncId,
    required this.saleId,
    required this.productId,
    required this.productNameSnapshot,
    required this.grams,
    required this.pricePerKgCentavos,
    required this.capitalPerKgCentavos,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    map['sale_id'] = Variable<int>(saleId);
    map['product_id'] = Variable<int>(productId);
    map['product_name_snapshot'] = Variable<String>(productNameSnapshot);
    map['grams'] = Variable<int>(grams);
    map['price_per_kg_centavos'] = Variable<int>(pricePerKgCentavos);
    map['capital_per_kg_centavos'] = Variable<int>(capitalPerKgCentavos);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SaleItemsCompanion toCompanion(bool nullToAbsent) {
    return SaleItemsCompanion(
      id: Value(id),
      syncId: syncId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncId),
      saleId: Value(saleId),
      productId: Value(productId),
      productNameSnapshot: Value(productNameSnapshot),
      grams: Value(grams),
      pricePerKgCentavos: Value(pricePerKgCentavos),
      capitalPerKgCentavos: Value(capitalPerKgCentavos),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SaleItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItem(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String?>(json['syncId']),
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
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String?>(syncId),
      'saleId': serializer.toJson<int>(saleId),
      'productId': serializer.toJson<int>(productId),
      'productNameSnapshot': serializer.toJson<String>(productNameSnapshot),
      'grams': serializer.toJson<int>(grams),
      'pricePerKgCentavos': serializer.toJson<int>(pricePerKgCentavos),
      'capitalPerKgCentavos': serializer.toJson<int>(capitalPerKgCentavos),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  SaleItem copyWith({
    int? id,
    Value<String?> syncId = const Value.absent(),
    int? saleId,
    int? productId,
    String? productNameSnapshot,
    int? grams,
    int? pricePerKgCentavos,
    int? capitalPerKgCentavos,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => SaleItem(
    id: id ?? this.id,
    syncId: syncId.present ? syncId.value : this.syncId,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
    grams: grams ?? this.grams,
    pricePerKgCentavos: pricePerKgCentavos ?? this.pricePerKgCentavos,
    capitalPerKgCentavos: capitalPerKgCentavos ?? this.capitalPerKgCentavos,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SaleItem copyWithCompanion(SaleItemsCompanion data) {
    return SaleItem(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
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
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItem(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('grams: $grams, ')
          ..write('pricePerKgCentavos: $pricePerKgCentavos, ')
          ..write('capitalPerKgCentavos: $capitalPerKgCentavos, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    saleId,
    productId,
    productNameSnapshot,
    grams,
    pricePerKgCentavos,
    capitalPerKgCentavos,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItem &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.productNameSnapshot == this.productNameSnapshot &&
          other.grams == this.grams &&
          other.pricePerKgCentavos == this.pricePerKgCentavos &&
          other.capitalPerKgCentavos == this.capitalPerKgCentavos &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class SaleItemsCompanion extends UpdateCompanion<SaleItem> {
  final Value<int> id;
  final Value<String?> syncId;
  final Value<int> saleId;
  final Value<int> productId;
  final Value<String> productNameSnapshot;
  final Value<int> grams;
  final Value<int> pricePerKgCentavos;
  final Value<int> capitalPerKgCentavos;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const SaleItemsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productNameSnapshot = const Value.absent(),
    this.grams = const Value.absent(),
    this.pricePerKgCentavos = const Value.absent(),
    this.capitalPerKgCentavos = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  SaleItemsCompanion.insert({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    required int saleId,
    required int productId,
    required String productNameSnapshot,
    required int grams,
    required int pricePerKgCentavos,
    required int capitalPerKgCentavos,
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : saleId = Value(saleId),
       productId = Value(productId),
       productNameSnapshot = Value(productNameSnapshot),
       grams = Value(grams),
       pricePerKgCentavos = Value(pricePerKgCentavos),
       capitalPerKgCentavos = Value(capitalPerKgCentavos);
  static Insertable<SaleItem> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? saleId,
    Expression<int>? productId,
    Expression<String>? productNameSnapshot,
    Expression<int>? grams,
    Expression<int>? pricePerKgCentavos,
    Expression<int>? capitalPerKgCentavos,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (productNameSnapshot != null)
        'product_name_snapshot': productNameSnapshot,
      if (grams != null) 'grams': grams,
      if (pricePerKgCentavos != null)
        'price_per_kg_centavos': pricePerKgCentavos,
      if (capitalPerKgCentavos != null)
        'capital_per_kg_centavos': capitalPerKgCentavos,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  SaleItemsCompanion copyWith({
    Value<int>? id,
    Value<String?>? syncId,
    Value<int>? saleId,
    Value<int>? productId,
    Value<String>? productNameSnapshot,
    Value<int>? grams,
    Value<int>? pricePerKgCentavos,
    Value<int>? capitalPerKgCentavos,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return SaleItemsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      grams: grams ?? this.grams,
      pricePerKgCentavos: pricePerKgCentavos ?? this.pricePerKgCentavos,
      capitalPerKgCentavos: capitalPerKgCentavos ?? this.capitalPerKgCentavos,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('grams: $grams, ')
          ..write('pricePerKgCentavos: $pricePerKgCentavos, ')
          ..write('capitalPerKgCentavos: $capitalPerKgCentavos, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $SaleEditsTable extends SaleEdits
    with TableInfo<$SaleEditsTable, SaleEdit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleEditsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _editedAtMeta = const VerificationMeta(
    'editedAt',
  );
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
    'edited_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beforeJsonMeta = const VerificationMeta(
    'beforeJson',
  );
  @override
  late final GeneratedColumn<String> beforeJson = GeneratedColumn<String>(
    'before_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _afterJsonMeta = const VerificationMeta(
    'afterJson',
  );
  @override
  late final GeneratedColumn<String> afterJson = GeneratedColumn<String>(
    'after_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    saleId,
    editedAt,
    beforeJson,
    afterJson,
    reason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_edits';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleEdit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('edited_at')) {
      context.handle(
        _editedAtMeta,
        editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_editedAtMeta);
    }
    if (data.containsKey('before_json')) {
      context.handle(
        _beforeJsonMeta,
        beforeJson.isAcceptableOrUnknown(data['before_json']!, _beforeJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_beforeJsonMeta);
    }
    if (data.containsKey('after_json')) {
      context.handle(
        _afterJsonMeta,
        afterJson.isAcceptableOrUnknown(data['after_json']!, _afterJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_afterJsonMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleEdit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleEdit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sale_id'],
      )!,
      editedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}edited_at'],
      )!,
      beforeJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before_json'],
      )!,
      afterJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_json'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
    );
  }

  @override
  $SaleEditsTable createAlias(String alias) {
    return $SaleEditsTable(attachedDatabase, alias);
  }
}

class SaleEdit extends DataClass implements Insertable<SaleEdit> {
  final int id;
  final String? syncId;
  final int saleId;
  final DateTime editedAt;
  final String beforeJson;
  final String afterJson;
  final String? reason;
  const SaleEdit({
    required this.id,
    this.syncId,
    required this.saleId,
    required this.editedAt,
    required this.beforeJson,
    required this.afterJson,
    this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    map['sale_id'] = Variable<int>(saleId);
    map['edited_at'] = Variable<DateTime>(editedAt);
    map['before_json'] = Variable<String>(beforeJson);
    map['after_json'] = Variable<String>(afterJson);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    return map;
  }

  SaleEditsCompanion toCompanion(bool nullToAbsent) {
    return SaleEditsCompanion(
      id: Value(id),
      syncId: syncId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncId),
      saleId: Value(saleId),
      editedAt: Value(editedAt),
      beforeJson: Value(beforeJson),
      afterJson: Value(afterJson),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
    );
  }

  factory SaleEdit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleEdit(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      saleId: serializer.fromJson<int>(json['saleId']),
      editedAt: serializer.fromJson<DateTime>(json['editedAt']),
      beforeJson: serializer.fromJson<String>(json['beforeJson']),
      afterJson: serializer.fromJson<String>(json['afterJson']),
      reason: serializer.fromJson<String?>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String?>(syncId),
      'saleId': serializer.toJson<int>(saleId),
      'editedAt': serializer.toJson<DateTime>(editedAt),
      'beforeJson': serializer.toJson<String>(beforeJson),
      'afterJson': serializer.toJson<String>(afterJson),
      'reason': serializer.toJson<String?>(reason),
    };
  }

  SaleEdit copyWith({
    int? id,
    Value<String?> syncId = const Value.absent(),
    int? saleId,
    DateTime? editedAt,
    String? beforeJson,
    String? afterJson,
    Value<String?> reason = const Value.absent(),
  }) => SaleEdit(
    id: id ?? this.id,
    syncId: syncId.present ? syncId.value : this.syncId,
    saleId: saleId ?? this.saleId,
    editedAt: editedAt ?? this.editedAt,
    beforeJson: beforeJson ?? this.beforeJson,
    afterJson: afterJson ?? this.afterJson,
    reason: reason.present ? reason.value : this.reason,
  );
  SaleEdit copyWithCompanion(SaleEditsCompanion data) {
    return SaleEdit(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      editedAt: data.editedAt.present ? data.editedAt.value : this.editedAt,
      beforeJson: data.beforeJson.present
          ? data.beforeJson.value
          : this.beforeJson,
      afterJson: data.afterJson.present ? data.afterJson.value : this.afterJson,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleEdit(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('saleId: $saleId, ')
          ..write('editedAt: $editedAt, ')
          ..write('beforeJson: $beforeJson, ')
          ..write('afterJson: $afterJson, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, syncId, saleId, editedAt, beforeJson, afterJson, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleEdit &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.saleId == this.saleId &&
          other.editedAt == this.editedAt &&
          other.beforeJson == this.beforeJson &&
          other.afterJson == this.afterJson &&
          other.reason == this.reason);
}

class SaleEditsCompanion extends UpdateCompanion<SaleEdit> {
  final Value<int> id;
  final Value<String?> syncId;
  final Value<int> saleId;
  final Value<DateTime> editedAt;
  final Value<String> beforeJson;
  final Value<String> afterJson;
  final Value<String?> reason;
  const SaleEditsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.saleId = const Value.absent(),
    this.editedAt = const Value.absent(),
    this.beforeJson = const Value.absent(),
    this.afterJson = const Value.absent(),
    this.reason = const Value.absent(),
  });
  SaleEditsCompanion.insert({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    required int saleId,
    required DateTime editedAt,
    required String beforeJson,
    required String afterJson,
    this.reason = const Value.absent(),
  }) : saleId = Value(saleId),
       editedAt = Value(editedAt),
       beforeJson = Value(beforeJson),
       afterJson = Value(afterJson);
  static Insertable<SaleEdit> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<int>? saleId,
    Expression<DateTime>? editedAt,
    Expression<String>? beforeJson,
    Expression<String>? afterJson,
    Expression<String>? reason,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (saleId != null) 'sale_id': saleId,
      if (editedAt != null) 'edited_at': editedAt,
      if (beforeJson != null) 'before_json': beforeJson,
      if (afterJson != null) 'after_json': afterJson,
      if (reason != null) 'reason': reason,
    });
  }

  SaleEditsCompanion copyWith({
    Value<int>? id,
    Value<String?>? syncId,
    Value<int>? saleId,
    Value<DateTime>? editedAt,
    Value<String>? beforeJson,
    Value<String>? afterJson,
    Value<String?>? reason,
  }) {
    return SaleEditsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      saleId: saleId ?? this.saleId,
      editedAt: editedAt ?? this.editedAt,
      beforeJson: beforeJson ?? this.beforeJson,
      afterJson: afterJson ?? this.afterJson,
      reason: reason ?? this.reason,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<int>(saleId.value);
    }
    if (editedAt.present) {
      map['edited_at'] = Variable<DateTime>(editedAt.value);
    }
    if (beforeJson.present) {
      map['before_json'] = Variable<String>(beforeJson.value);
    }
    if (afterJson.present) {
      map['after_json'] = Variable<String>(afterJson.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleEditsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('saleId: $saleId, ')
          ..write('editedAt: $editedAt, ')
          ..write('beforeJson: $beforeJson, ')
          ..write('afterJson: $afterJson, ')
          ..write('reason: $reason')
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    date,
    type,
    amountCentavos,
    note,
    productId,
    grams,
    capitalPerKgCentavos,
    updatedAt,
    deletedAt,
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
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
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
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
  final String? syncId;
  final DateTime date;
  final String type;
  final int amountCentavos;
  final String? note;
  final int? productId;
  final int? grams;
  final int? capitalPerKgCentavos;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const Expense({
    required this.id,
    this.syncId,
    required this.date,
    required this.type,
    required this.amountCentavos,
    this.note,
    this.productId,
    this.grams,
    this.capitalPerKgCentavos,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
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
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      syncId: syncId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncId),
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
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      amountCentavos: serializer.fromJson<int>(json['amountCentavos']),
      note: serializer.fromJson<String?>(json['note']),
      productId: serializer.fromJson<int?>(json['productId']),
      grams: serializer.fromJson<int?>(json['grams']),
      capitalPerKgCentavos: serializer.fromJson<int?>(
        json['capitalPerKgCentavos'],
      ),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String?>(syncId),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'amountCentavos': serializer.toJson<int>(amountCentavos),
      'note': serializer.toJson<String?>(note),
      'productId': serializer.toJson<int?>(productId),
      'grams': serializer.toJson<int?>(grams),
      'capitalPerKgCentavos': serializer.toJson<int?>(capitalPerKgCentavos),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Expense copyWith({
    int? id,
    Value<String?> syncId = const Value.absent(),
    DateTime? date,
    String? type,
    int? amountCentavos,
    Value<String?> note = const Value.absent(),
    Value<int?> productId = const Value.absent(),
    Value<int?> grams = const Value.absent(),
    Value<int?> capitalPerKgCentavos = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Expense(
    id: id ?? this.id,
    syncId: syncId.present ? syncId.value : this.syncId,
    date: date ?? this.date,
    type: type ?? this.type,
    amountCentavos: amountCentavos ?? this.amountCentavos,
    note: note.present ? note.value : this.note,
    productId: productId.present ? productId.value : this.productId,
    grams: grams.present ? grams.value : this.grams,
    capitalPerKgCentavos: capitalPerKgCentavos.present
        ? capitalPerKgCentavos.value
        : this.capitalPerKgCentavos,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
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
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('amountCentavos: $amountCentavos, ')
          ..write('note: $note, ')
          ..write('productId: $productId, ')
          ..write('grams: $grams, ')
          ..write('capitalPerKgCentavos: $capitalPerKgCentavos, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    date,
    type,
    amountCentavos,
    note,
    productId,
    grams,
    capitalPerKgCentavos,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.date == this.date &&
          other.type == this.type &&
          other.amountCentavos == this.amountCentavos &&
          other.note == this.note &&
          other.productId == this.productId &&
          other.grams == this.grams &&
          other.capitalPerKgCentavos == this.capitalPerKgCentavos &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<String?> syncId;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<int> amountCentavos;
  final Value<String?> note;
  final Value<int?> productId;
  final Value<int?> grams;
  final Value<int?> capitalPerKgCentavos;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.amountCentavos = const Value.absent(),
    this.note = const Value.absent(),
    this.productId = const Value.absent(),
    this.grams = const Value.absent(),
    this.capitalPerKgCentavos = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    required DateTime date,
    required String type,
    required int amountCentavos,
    this.note = const Value.absent(),
    this.productId = const Value.absent(),
    this.grams = const Value.absent(),
    this.capitalPerKgCentavos = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : date = Value(date),
       type = Value(type),
       amountCentavos = Value(amountCentavos);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<int>? amountCentavos,
    Expression<String>? note,
    Expression<int>? productId,
    Expression<int>? grams,
    Expression<int>? capitalPerKgCentavos,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (amountCentavos != null) 'amount_centavos': amountCentavos,
      if (note != null) 'note': note,
      if (productId != null) 'product_id': productId,
      if (grams != null) 'grams': grams,
      if (capitalPerKgCentavos != null)
        'capital_per_kg_centavos': capitalPerKgCentavos,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<String?>? syncId,
    Value<DateTime>? date,
    Value<String>? type,
    Value<int>? amountCentavos,
    Value<String?>? note,
    Value<int?>? productId,
    Value<int?>? grams,
    Value<int?>? capitalPerKgCentavos,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      date: date ?? this.date,
      type: type ?? this.type,
      amountCentavos: amountCentavos ?? this.amountCentavos,
      note: note ?? this.note,
      productId: productId ?? this.productId,
      grams: grams ?? this.grams,
      capitalPerKgCentavos: capitalPerKgCentavos ?? this.capitalPerKgCentavos,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('amountCentavos: $amountCentavos, ')
          ..write('note: $note, ')
          ..write('productId: $productId, ')
          ..write('grams: $grams, ')
          ..write('capitalPerKgCentavos: $capitalPerKgCentavos, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    date,
    amountCentavos,
    note,
    updatedAt,
    deletedAt,
  ];
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
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
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
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
  final String? syncId;
  final DateTime date;
  final int amountCentavos;
  final String? note;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const RestockPurchase({
    required this.id,
    this.syncId,
    required this.date,
    required this.amountCentavos,
    this.note,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    map['date'] = Variable<DateTime>(date);
    map['amount_centavos'] = Variable<int>(amountCentavos);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  RestockPurchasesCompanion toCompanion(bool nullToAbsent) {
    return RestockPurchasesCompanion(
      id: Value(id),
      syncId: syncId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncId),
      date: Value(date),
      amountCentavos: Value(amountCentavos),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory RestockPurchase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RestockPurchase(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      date: serializer.fromJson<DateTime>(json['date']),
      amountCentavos: serializer.fromJson<int>(json['amountCentavos']),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String?>(syncId),
      'date': serializer.toJson<DateTime>(date),
      'amountCentavos': serializer.toJson<int>(amountCentavos),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  RestockPurchase copyWith({
    int? id,
    Value<String?> syncId = const Value.absent(),
    DateTime? date,
    int? amountCentavos,
    Value<String?> note = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => RestockPurchase(
    id: id ?? this.id,
    syncId: syncId.present ? syncId.value : this.syncId,
    date: date ?? this.date,
    amountCentavos: amountCentavos ?? this.amountCentavos,
    note: note.present ? note.value : this.note,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  RestockPurchase copyWithCompanion(RestockPurchasesCompanion data) {
    return RestockPurchase(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      date: data.date.present ? data.date.value : this.date,
      amountCentavos: data.amountCentavos.present
          ? data.amountCentavos.value
          : this.amountCentavos,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RestockPurchase(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('date: $date, ')
          ..write('amountCentavos: $amountCentavos, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, syncId, date, amountCentavos, note, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RestockPurchase &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.date == this.date &&
          other.amountCentavos == this.amountCentavos &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class RestockPurchasesCompanion extends UpdateCompanion<RestockPurchase> {
  final Value<int> id;
  final Value<String?> syncId;
  final Value<DateTime> date;
  final Value<int> amountCentavos;
  final Value<String?> note;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const RestockPurchasesCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.date = const Value.absent(),
    this.amountCentavos = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  RestockPurchasesCompanion.insert({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    required DateTime date,
    required int amountCentavos,
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : date = Value(date),
       amountCentavos = Value(amountCentavos);
  static Insertable<RestockPurchase> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<DateTime>? date,
    Expression<int>? amountCentavos,
    Expression<String>? note,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (date != null) 'date': date,
      if (amountCentavos != null) 'amount_centavos': amountCentavos,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  RestockPurchasesCompanion copyWith({
    Value<int>? id,
    Value<String?>? syncId,
    Value<DateTime>? date,
    Value<int>? amountCentavos,
    Value<String?>? note,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return RestockPurchasesCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      date: date ?? this.date,
      amountCentavos: amountCentavos ?? this.amountCentavos,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RestockPurchasesCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('date: $date, ')
          ..write('amountCentavos: $amountCentavos, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    date,
    toParentsCentavos,
    salaryCentavos,
    reserveCentavos,
    locked,
    updatedAt,
    deletedAt,
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
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
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PayoutsTable createAlias(String alias) {
    return $PayoutsTable(attachedDatabase, alias);
  }
}

class Payout extends DataClass implements Insertable<Payout> {
  final int id;
  final String? syncId;
  final DateTime date;
  final int toParentsCentavos;
  final int salaryCentavos;
  final int reserveCentavos;
  final bool locked;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  const Payout({
    required this.id,
    this.syncId,
    required this.date,
    required this.toParentsCentavos,
    required this.salaryCentavos,
    required this.reserveCentavos,
    required this.locked,
    this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    map['date'] = Variable<DateTime>(date);
    map['to_parents_centavos'] = Variable<int>(toParentsCentavos);
    map['salary_centavos'] = Variable<int>(salaryCentavos);
    map['reserve_centavos'] = Variable<int>(reserveCentavos);
    map['locked'] = Variable<bool>(locked);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PayoutsCompanion toCompanion(bool nullToAbsent) {
    return PayoutsCompanion(
      id: Value(id),
      syncId: syncId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncId),
      date: Value(date),
      toParentsCentavos: Value(toParentsCentavos),
      salaryCentavos: Value(salaryCentavos),
      reserveCentavos: Value(reserveCentavos),
      locked: Value(locked),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Payout.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payout(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      date: serializer.fromJson<DateTime>(json['date']),
      toParentsCentavos: serializer.fromJson<int>(json['toParentsCentavos']),
      salaryCentavos: serializer.fromJson<int>(json['salaryCentavos']),
      reserveCentavos: serializer.fromJson<int>(json['reserveCentavos']),
      locked: serializer.fromJson<bool>(json['locked']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String?>(syncId),
      'date': serializer.toJson<DateTime>(date),
      'toParentsCentavos': serializer.toJson<int>(toParentsCentavos),
      'salaryCentavos': serializer.toJson<int>(salaryCentavos),
      'reserveCentavos': serializer.toJson<int>(reserveCentavos),
      'locked': serializer.toJson<bool>(locked),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Payout copyWith({
    int? id,
    Value<String?> syncId = const Value.absent(),
    DateTime? date,
    int? toParentsCentavos,
    int? salaryCentavos,
    int? reserveCentavos,
    bool? locked,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Payout(
    id: id ?? this.id,
    syncId: syncId.present ? syncId.value : this.syncId,
    date: date ?? this.date,
    toParentsCentavos: toParentsCentavos ?? this.toParentsCentavos,
    salaryCentavos: salaryCentavos ?? this.salaryCentavos,
    reserveCentavos: reserveCentavos ?? this.reserveCentavos,
    locked: locked ?? this.locked,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Payout copyWithCompanion(PayoutsCompanion data) {
    return Payout(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
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
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payout(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('date: $date, ')
          ..write('toParentsCentavos: $toParentsCentavos, ')
          ..write('salaryCentavos: $salaryCentavos, ')
          ..write('reserveCentavos: $reserveCentavos, ')
          ..write('locked: $locked, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    date,
    toParentsCentavos,
    salaryCentavos,
    reserveCentavos,
    locked,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payout &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.date == this.date &&
          other.toParentsCentavos == this.toParentsCentavos &&
          other.salaryCentavos == this.salaryCentavos &&
          other.reserveCentavos == this.reserveCentavos &&
          other.locked == this.locked &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PayoutsCompanion extends UpdateCompanion<Payout> {
  final Value<int> id;
  final Value<String?> syncId;
  final Value<DateTime> date;
  final Value<int> toParentsCentavos;
  final Value<int> salaryCentavos;
  final Value<int> reserveCentavos;
  final Value<bool> locked;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  const PayoutsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.date = const Value.absent(),
    this.toParentsCentavos = const Value.absent(),
    this.salaryCentavos = const Value.absent(),
    this.reserveCentavos = const Value.absent(),
    this.locked = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  PayoutsCompanion.insert({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    required DateTime date,
    required int toParentsCentavos,
    required int salaryCentavos,
    required int reserveCentavos,
    this.locked = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : date = Value(date),
       toParentsCentavos = Value(toParentsCentavos),
       salaryCentavos = Value(salaryCentavos),
       reserveCentavos = Value(reserveCentavos);
  static Insertable<Payout> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<DateTime>? date,
    Expression<int>? toParentsCentavos,
    Expression<int>? salaryCentavos,
    Expression<int>? reserveCentavos,
    Expression<bool>? locked,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (date != null) 'date': date,
      if (toParentsCentavos != null) 'to_parents_centavos': toParentsCentavos,
      if (salaryCentavos != null) 'salary_centavos': salaryCentavos,
      if (reserveCentavos != null) 'reserve_centavos': reserveCentavos,
      if (locked != null) 'locked': locked,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  PayoutsCompanion copyWith({
    Value<int>? id,
    Value<String?>? syncId,
    Value<DateTime>? date,
    Value<int>? toParentsCentavos,
    Value<int>? salaryCentavos,
    Value<int>? reserveCentavos,
    Value<bool>? locked,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return PayoutsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      date: date ?? this.date,
      toParentsCentavos: toParentsCentavos ?? this.toParentsCentavos,
      salaryCentavos: salaryCentavos ?? this.salaryCentavos,
      reserveCentavos: reserveCentavos ?? this.reserveCentavos,
      locked: locked ?? this.locked,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayoutsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('date: $date, ')
          ..write('toParentsCentavos: $toParentsCentavos, ')
          ..write('salaryCentavos: $salaryCentavos, ')
          ..write('reserveCentavos: $reserveCentavos, ')
          ..write('locked: $locked, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
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
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    salaryMode,
    salaryPercentBasisPoints,
    fixedDailySalaryCentavos,
    updatedAt,
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
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
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
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
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
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final String? syncId;
  final String salaryMode;
  final int salaryPercentBasisPoints;
  final int fixedDailySalaryCentavos;
  final DateTime? updatedAt;
  const Setting({
    required this.id,
    this.syncId,
    required this.salaryMode,
    required this.salaryPercentBasisPoints,
    required this.fixedDailySalaryCentavos,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    map['salary_mode'] = Variable<String>(salaryMode);
    map['salary_percent_basis_points'] = Variable<int>(
      salaryPercentBasisPoints,
    );
    map['fixed_daily_salary_centavos'] = Variable<int>(
      fixedDailySalaryCentavos,
    );
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      syncId: syncId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncId),
      salaryMode: Value(salaryMode),
      salaryPercentBasisPoints: Value(salaryPercentBasisPoints),
      fixedDailySalaryCentavos: Value(fixedDailySalaryCentavos),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      salaryMode: serializer.fromJson<String>(json['salaryMode']),
      salaryPercentBasisPoints: serializer.fromJson<int>(
        json['salaryPercentBasisPoints'],
      ),
      fixedDailySalaryCentavos: serializer.fromJson<int>(
        json['fixedDailySalaryCentavos'],
      ),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String?>(syncId),
      'salaryMode': serializer.toJson<String>(salaryMode),
      'salaryPercentBasisPoints': serializer.toJson<int>(
        salaryPercentBasisPoints,
      ),
      'fixedDailySalaryCentavos': serializer.toJson<int>(
        fixedDailySalaryCentavos,
      ),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Setting copyWith({
    int? id,
    Value<String?> syncId = const Value.absent(),
    String? salaryMode,
    int? salaryPercentBasisPoints,
    int? fixedDailySalaryCentavos,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => Setting(
    id: id ?? this.id,
    syncId: syncId.present ? syncId.value : this.syncId,
    salaryMode: salaryMode ?? this.salaryMode,
    salaryPercentBasisPoints:
        salaryPercentBasisPoints ?? this.salaryPercentBasisPoints,
    fixedDailySalaryCentavos:
        fixedDailySalaryCentavos ?? this.fixedDailySalaryCentavos,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      salaryMode: data.salaryMode.present
          ? data.salaryMode.value
          : this.salaryMode,
      salaryPercentBasisPoints: data.salaryPercentBasisPoints.present
          ? data.salaryPercentBasisPoints.value
          : this.salaryPercentBasisPoints,
      fixedDailySalaryCentavos: data.fixedDailySalaryCentavos.present
          ? data.fixedDailySalaryCentavos.value
          : this.fixedDailySalaryCentavos,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('salaryMode: $salaryMode, ')
          ..write('salaryPercentBasisPoints: $salaryPercentBasisPoints, ')
          ..write('fixedDailySalaryCentavos: $fixedDailySalaryCentavos, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    salaryMode,
    salaryPercentBasisPoints,
    fixedDailySalaryCentavos,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.salaryMode == this.salaryMode &&
          other.salaryPercentBasisPoints == this.salaryPercentBasisPoints &&
          other.fixedDailySalaryCentavos == this.fixedDailySalaryCentavos &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<String?> syncId;
  final Value<String> salaryMode;
  final Value<int> salaryPercentBasisPoints;
  final Value<int> fixedDailySalaryCentavos;
  final Value<DateTime?> updatedAt;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.salaryMode = const Value.absent(),
    this.salaryPercentBasisPoints = const Value.absent(),
    this.fixedDailySalaryCentavos = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.salaryMode = const Value.absent(),
    this.salaryPercentBasisPoints = const Value.absent(),
    this.fixedDailySalaryCentavos = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<String>? salaryMode,
    Expression<int>? salaryPercentBasisPoints,
    Expression<int>? fixedDailySalaryCentavos,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (salaryMode != null) 'salary_mode': salaryMode,
      if (salaryPercentBasisPoints != null)
        'salary_percent_basis_points': salaryPercentBasisPoints,
      if (fixedDailySalaryCentavos != null)
        'fixed_daily_salary_centavos': fixedDailySalaryCentavos,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<String?>? syncId,
    Value<String>? salaryMode,
    Value<int>? salaryPercentBasisPoints,
    Value<int>? fixedDailySalaryCentavos,
    Value<DateTime?>? updatedAt,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      salaryMode: salaryMode ?? this.salaryMode,
      salaryPercentBasisPoints:
          salaryPercentBasisPoints ?? this.salaryPercentBasisPoints,
      fixedDailySalaryCentavos:
          fixedDailySalaryCentavos ?? this.fixedDailySalaryCentavos,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('salaryMode: $salaryMode, ')
          ..write('salaryPercentBasisPoints: $salaryPercentBasisPoints, ')
          ..write('fixedDailySalaryCentavos: $fixedDailySalaryCentavos, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $OutboxItemsTable extends OutboxItems
    with TableInfo<$OutboxItemsTable, OutboxItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entitySyncIdMeta = const VerificationMeta(
    'entitySyncId',
  );
  @override
  late final GeneratedColumn<String> entitySyncId = GeneratedColumn<String>(
    'entity_sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entitySyncId,
    action,
    payloadJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_sync_id')) {
      context.handle(
        _entitySyncIdMeta,
        entitySyncId.isAcceptableOrUnknown(
          data['entity_sync_id']!,
          _entitySyncIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entitySyncIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entitySyncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_sync_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxItemsTable createAlias(String alias) {
    return $OutboxItemsTable(attachedDatabase, alias);
  }
}

class OutboxItem extends DataClass implements Insertable<OutboxItem> {
  final int id;
  final String entityType;
  final String entitySyncId;
  final String action;
  final String payloadJson;
  final DateTime createdAt;
  const OutboxItem({
    required this.id,
    required this.entityType,
    required this.entitySyncId,
    required this.action,
    required this.payloadJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_sync_id'] = Variable<String>(entitySyncId);
    map['action'] = Variable<String>(action);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxItemsCompanion toCompanion(bool nullToAbsent) {
    return OutboxItemsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entitySyncId: Value(entitySyncId),
      action: Value(action),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxItem(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entitySyncId: serializer.fromJson<String>(json['entitySyncId']),
      action: serializer.fromJson<String>(json['action']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entitySyncId': serializer.toJson<String>(entitySyncId),
      'action': serializer.toJson<String>(action),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxItem copyWith({
    int? id,
    String? entityType,
    String? entitySyncId,
    String? action,
    String? payloadJson,
    DateTime? createdAt,
  }) => OutboxItem(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entitySyncId: entitySyncId ?? this.entitySyncId,
    action: action ?? this.action,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxItem copyWithCompanion(OutboxItemsCompanion data) {
    return OutboxItem(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entitySyncId: data.entitySyncId.present
          ? data.entitySyncId.value
          : this.entitySyncId,
      action: data.action.present ? data.action.value : this.action,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxItem(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entitySyncId: $entitySyncId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entityType, entitySyncId, action, payloadJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxItem &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entitySyncId == this.entitySyncId &&
          other.action == this.action &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt);
}

class OutboxItemsCompanion extends UpdateCompanion<OutboxItem> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entitySyncId;
  final Value<String> action;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  const OutboxItemsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entitySyncId = const Value.absent(),
    this.action = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OutboxItemsCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entitySyncId,
    required String action,
    required String payloadJson,
    required DateTime createdAt,
  }) : entityType = Value(entityType),
       entitySyncId = Value(entitySyncId),
       action = Value(action),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<OutboxItem> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entitySyncId,
    Expression<String>? action,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entitySyncId != null) 'entity_sync_id': entitySyncId,
      if (action != null) 'action': action,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OutboxItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entitySyncId,
    Value<String>? action,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
  }) {
    return OutboxItemsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entitySyncId: entitySyncId ?? this.entitySyncId,
      action: action ?? this.action,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entitySyncId.present) {
      map['entity_sync_id'] = Variable<String>(entitySyncId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxItemsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entitySyncId: $entitySyncId, ')
          ..write('action: $action, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncStatusMeta = const VerificationMeta(
    'lastSyncStatus',
  );
  @override
  late final GeneratedColumn<String> lastSyncStatus = GeneratedColumn<String>(
    'last_sync_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMessageMeta = const VerificationMeta(
    'lastErrorMessage',
  );
  @override
  late final GeneratedColumn<String> lastErrorMessage = GeneratedColumn<String>(
    'last_error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lastSyncedAt,
    lastSyncStatus,
    lastErrorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_status')) {
      context.handle(
        _lastSyncStatusMeta,
        lastSyncStatus.isAcceptableOrUnknown(
          data['last_sync_status']!,
          _lastSyncStatusMeta,
        ),
      );
    }
    if (data.containsKey('last_error_message')) {
      context.handle(
        _lastErrorMessageMeta,
        lastErrorMessage.isAcceptableOrUnknown(
          data['last_error_message']!,
          _lastErrorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      lastSyncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_status'],
      ),
      lastErrorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_message'],
      ),
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncState extends DataClass implements Insertable<SyncState> {
  final int id;
  final DateTime? lastSyncedAt;
  final String? lastSyncStatus;
  final String? lastErrorMessage;
  const SyncState({
    required this.id,
    this.lastSyncedAt,
    this.lastSyncStatus,
    this.lastErrorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || lastSyncStatus != null) {
      map['last_sync_status'] = Variable<String>(lastSyncStatus);
    }
    if (!nullToAbsent || lastErrorMessage != null) {
      map['last_error_message'] = Variable<String>(lastErrorMessage);
    }
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      id: Value(id),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      lastSyncStatus: lastSyncStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncStatus),
      lastErrorMessage: lastErrorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorMessage),
    );
  }

  factory SyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncState(
      id: serializer.fromJson<int>(json['id']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      lastSyncStatus: serializer.fromJson<String?>(json['lastSyncStatus']),
      lastErrorMessage: serializer.fromJson<String?>(json['lastErrorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'lastSyncStatus': serializer.toJson<String?>(lastSyncStatus),
      'lastErrorMessage': serializer.toJson<String?>(lastErrorMessage),
    };
  }

  SyncState copyWith({
    int? id,
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<String?> lastSyncStatus = const Value.absent(),
    Value<String?> lastErrorMessage = const Value.absent(),
  }) => SyncState(
    id: id ?? this.id,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    lastSyncStatus: lastSyncStatus.present
        ? lastSyncStatus.value
        : this.lastSyncStatus,
    lastErrorMessage: lastErrorMessage.present
        ? lastErrorMessage.value
        : this.lastErrorMessage,
  );
  SyncState copyWithCompanion(SyncStatesCompanion data) {
    return SyncState(
      id: data.id.present ? data.id.value : this.id,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      lastSyncStatus: data.lastSyncStatus.present
          ? data.lastSyncStatus.value
          : this.lastSyncStatus,
      lastErrorMessage: data.lastErrorMessage.present
          ? data.lastErrorMessage.value
          : this.lastErrorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncState(')
          ..write('id: $id, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastSyncStatus: $lastSyncStatus, ')
          ..write('lastErrorMessage: $lastErrorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lastSyncedAt, lastSyncStatus, lastErrorMessage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncState &&
          other.id == this.id &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.lastSyncStatus == this.lastSyncStatus &&
          other.lastErrorMessage == this.lastErrorMessage);
}

class SyncStatesCompanion extends UpdateCompanion<SyncState> {
  final Value<int> id;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> lastSyncStatus;
  final Value<String?> lastErrorMessage;
  const SyncStatesCompanion({
    this.id = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastSyncStatus = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    this.id = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastSyncStatus = const Value.absent(),
    this.lastErrorMessage = const Value.absent(),
  });
  static Insertable<SyncState> custom({
    Expression<int>? id,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? lastSyncStatus,
    Expression<String>? lastErrorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (lastSyncStatus != null) 'last_sync_status': lastSyncStatus,
      if (lastErrorMessage != null) 'last_error_message': lastErrorMessage,
    });
  }

  SyncStatesCompanion copyWith({
    Value<int>? id,
    Value<DateTime?>? lastSyncedAt,
    Value<String?>? lastSyncStatus,
    Value<String?>? lastErrorMessage,
  }) {
    return SyncStatesCompanion(
      id: id ?? this.id,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (lastSyncStatus.present) {
      map['last_sync_status'] = Variable<String>(lastSyncStatus.value);
    }
    if (lastErrorMessage.present) {
      map['last_error_message'] = Variable<String>(lastErrorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('id: $id, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastSyncStatus: $lastSyncStatus, ')
          ..write('lastErrorMessage: $lastErrorMessage')
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
  late final $SaleEditsTable saleEdits = $SaleEditsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $RestockPurchasesTable restockPurchases = $RestockPurchasesTable(
    this,
  );
  late final $PayoutsTable payouts = $PayoutsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $OutboxItemsTable outboxItems = $OutboxItemsTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    products,
    capitalHistory,
    sales,
    saleItems,
    saleEdits,
    expenses,
    restockPurchases,
    payouts,
    settings,
    outboxItems,
    syncStates,
  ];
}

typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  Value<String?> syncId,
  required String name,
  required int defaultPriceCentavos,
  required int capitalCentavos,
  Value<int> sortOrder,
  Value<bool> archived,
  Value<String?> imagePath,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  Value<String?> syncId,
  Value<String> name,
  Value<int> defaultPriceCentavos,
  Value<int> capitalCentavos,
  Value<int> sortOrder,
  Value<bool> archived,
  Value<String?> imagePath,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

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

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

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
                Value<String?> syncId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> defaultPriceCentavos = const Value.absent(),
                Value<int> capitalCentavos = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                syncId: syncId,
                name: name,
                defaultPriceCentavos: defaultPriceCentavos,
                capitalCentavos: capitalCentavos,
                sortOrder: sortOrder,
                archived: archived,
                imagePath: imagePath,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                required String name,
                required int defaultPriceCentavos,
                required int capitalCentavos,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                syncId: syncId,
                name: name,
                defaultPriceCentavos: defaultPriceCentavos,
                capitalCentavos: capitalCentavos,
                sortOrder: sortOrder,
                archived: archived,
                imagePath: imagePath,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
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
      Value<String?> syncId,
      required int productId,
      required int oldCentavos,
      required int newCentavos,
      required DateTime changedAt,
      Value<DateTime?> updatedAt,
    });
typedef $$CapitalHistoryTableUpdateCompanionBuilder =
    CapitalHistoryCompanion Function({
      Value<int> id,
      Value<String?> syncId,
      Value<int> productId,
      Value<int> oldCentavos,
      Value<int> newCentavos,
      Value<DateTime> changedAt,
      Value<DateTime?> updatedAt,
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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
                Value<String?> syncId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<int> oldCentavos = const Value.absent(),
                Value<int> newCentavos = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => CapitalHistoryCompanion(
                id: id,
                syncId: syncId,
                productId: productId,
                oldCentavos: oldCentavos,
                newCentavos: newCentavos,
                changedAt: changedAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                required int productId,
                required int oldCentavos,
                required int newCentavos,
                required DateTime changedAt,
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => CapitalHistoryCompanion.insert(
                id: id,
                syncId: syncId,
                productId: productId,
                oldCentavos: oldCentavos,
                newCentavos: newCentavos,
                changedAt: changedAt,
                updatedAt: updatedAt,
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
  Value<String?> syncId,
  required DateTime createdAt,
  required int exactTotalCentavos,
  required int chargedCentavos,
  required int paidCentavos,
  required int changeCentavos,
  Value<bool> voided,
  Value<DateTime?> editedAt,
  Value<int> editCount,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$SalesTableUpdateCompanionBuilder = SalesCompanion Function({
  Value<int> id,
  Value<String?> syncId,
  Value<DateTime> createdAt,
  Value<int> exactTotalCentavos,
  Value<int> chargedCentavos,
  Value<int> paidCentavos,
  Value<int> changeCentavos,
  Value<bool> voided,
  Value<DateTime?> editedAt,
  Value<int> editCount,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
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

  static MultiTypedResultKey<$SaleEditsTable, List<SaleEdit>>
  _saleEditsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleEdits,
    aliasName: 'sales__id__sale_edits__sale_id',
  );

  $$SaleEditsTableProcessedTableManager get saleEditsRefs {
    final manager = $$SaleEditsTableTableManager(
      $_db,
      $_db.saleEdits,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleEditsRefsTable($_db));
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnFilters<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get editCount => $composableBuilder(
    column: $table.editCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  Expression<bool> saleEditsRefs(
    Expression<bool> Function($$SaleEditsTableFilterComposer f) f,
  ) {
    final $$SaleEditsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleEdits,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleEditsTableFilterComposer(
            $db: $db,
            $table: $db.saleEdits,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnOrderings<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get editCount => $composableBuilder(
    column: $table.editCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

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

  GeneratedColumn<DateTime> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumn<int> get editCount =>
      $composableBuilder(column: $table.editCount, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

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

  Expression<T> saleEditsRefs<T extends Object>(
    Expression<T> Function($$SaleEditsTableAnnotationComposer a) f,
  ) {
    final $$SaleEditsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleEdits,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleEditsTableAnnotationComposer(
            $db: $db,
            $table: $db.saleEdits,
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
          PrefetchHooks Function({bool saleItemsRefs, bool saleEditsRefs})
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
                Value<String?> syncId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> exactTotalCentavos = const Value.absent(),
                Value<int> chargedCentavos = const Value.absent(),
                Value<int> paidCentavos = const Value.absent(),
                Value<int> changeCentavos = const Value.absent(),
                Value<bool> voided = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<int> editCount = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                exactTotalCentavos: exactTotalCentavos,
                chargedCentavos: chargedCentavos,
                paidCentavos: paidCentavos,
                changeCentavos: changeCentavos,
                voided: voided,
                editedAt: editedAt,
                editCount: editCount,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                required DateTime createdAt,
                required int exactTotalCentavos,
                required int chargedCentavos,
                required int paidCentavos,
                required int changeCentavos,
                Value<bool> voided = const Value.absent(),
                Value<DateTime?> editedAt = const Value.absent(),
                Value<int> editCount = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                syncId: syncId,
                createdAt: createdAt,
                exactTotalCentavos: exactTotalCentavos,
                chargedCentavos: chargedCentavos,
                paidCentavos: paidCentavos,
                changeCentavos: changeCentavos,
                voided: voided,
                editedAt: editedAt,
                editCount: editCount,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SalesTable, Sale>(table),
                  $$SalesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({saleItemsRefs = false, saleEditsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (saleItemsRefs) db.saleItems,
                    if (saleEditsRefs) db.saleEdits,
                  ],
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
                              $$SalesTableReferences(
                                db,
                                table,
                                p0,
                              ).saleItemsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'sale_id',
                          typedResults: items,
                        ),
                      if (saleEditsRefs)
                        await $_getPrefetchedDataByColumns<
                          Sale,
                          $SalesTable,
                          SaleEdit,
                          $SaleEditsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SalesTableReferences
                              ._saleEditsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SalesTableReferences(
                                db,
                                table,
                                p0,
                              ).saleEditsRefs,
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
      PrefetchHooks Function({bool saleItemsRefs, bool saleEditsRefs})
    >;
typedef $$SaleItemsTableCreateCompanionBuilder = SaleItemsCompanion Function({
  Value<int> id,
  Value<String?> syncId,
  required int saleId,
  required int productId,
  required String productNameSnapshot,
  required int grams,
  required int pricePerKgCentavos,
  required int capitalPerKgCentavos,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$SaleItemsTableUpdateCompanionBuilder = SaleItemsCompanion Function({
  Value<int> id,
  Value<String?> syncId,
  Value<int> saleId,
  Value<int> productId,
  Value<String> productNameSnapshot,
  Value<int> grams,
  Value<int> pricePerKgCentavos,
  Value<int> capitalPerKgCentavos,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

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
                Value<String?> syncId = const Value.absent(),
                Value<int> saleId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<String> productNameSnapshot = const Value.absent(),
                Value<int> grams = const Value.absent(),
                Value<int> pricePerKgCentavos = const Value.absent(),
                Value<int> capitalPerKgCentavos = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => SaleItemsCompanion(
                id: id,
                syncId: syncId,
                saleId: saleId,
                productId: productId,
                productNameSnapshot: productNameSnapshot,
                grams: grams,
                pricePerKgCentavos: pricePerKgCentavos,
                capitalPerKgCentavos: capitalPerKgCentavos,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                required int saleId,
                required int productId,
                required String productNameSnapshot,
                required int grams,
                required int pricePerKgCentavos,
                required int capitalPerKgCentavos,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => SaleItemsCompanion.insert(
                id: id,
                syncId: syncId,
                saleId: saleId,
                productId: productId,
                productNameSnapshot: productNameSnapshot,
                grams: grams,
                pricePerKgCentavos: pricePerKgCentavos,
                capitalPerKgCentavos: capitalPerKgCentavos,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
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
typedef $$SaleEditsTableCreateCompanionBuilder = SaleEditsCompanion Function({
  Value<int> id,
  Value<String?> syncId,
  required int saleId,
  required DateTime editedAt,
  required String beforeJson,
  required String afterJson,
  Value<String?> reason,
});
typedef $$SaleEditsTableUpdateCompanionBuilder = SaleEditsCompanion Function({
  Value<int> id,
  Value<String?> syncId,
  Value<int> saleId,
  Value<DateTime> editedAt,
  Value<String> beforeJson,
  Value<String> afterJson,
  Value<String?> reason,
});

final class $$SaleEditsTableReferences
    extends BaseReferences<_$AppDatabase, $SaleEditsTable, SaleEdit> {
  $$SaleEditsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SalesTable _saleIdTable(_$AppDatabase db) =>
      db.sales.createAlias('sale_edits__sale_id__sales__id');

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
}

class $$SaleEditsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleEditsTable> {
  $$SaleEditsTableFilterComposer({
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterJson => $composableBuilder(
    column: $table.afterJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
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
}

class $$SaleEditsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleEditsTable> {
  $$SaleEditsTableOrderingComposer({
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get editedAt => $composableBuilder(
    column: $table.editedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterJson => $composableBuilder(
    column: $table.afterJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
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
}

class $$SaleEditsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleEditsTable> {
  $$SaleEditsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get editedAt =>
      $composableBuilder(column: $table.editedAt, builder: (column) => column);

  GeneratedColumn<String> get beforeJson => $composableBuilder(
    column: $table.beforeJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get afterJson =>
      $composableBuilder(column: $table.afterJson, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

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
}

class $$SaleEditsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleEditsTable,
          SaleEdit,
          $$SaleEditsTableFilterComposer,
          $$SaleEditsTableOrderingComposer,
          $$SaleEditsTableAnnotationComposer,
          $$SaleEditsTableCreateCompanionBuilder,
          $$SaleEditsTableUpdateCompanionBuilder,
          (SaleEdit, $$SaleEditsTableReferences),
          SaleEdit,
          PrefetchHooks Function({bool saleId})
        > {
  $$SaleEditsTableTableManager(_$AppDatabase db, $SaleEditsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleEditsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleEditsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleEditsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                Value<int> saleId = const Value.absent(),
                Value<DateTime> editedAt = const Value.absent(),
                Value<String> beforeJson = const Value.absent(),
                Value<String> afterJson = const Value.absent(),
                Value<String?> reason = const Value.absent(),
              }) => SaleEditsCompanion(
                id: id,
                syncId: syncId,
                saleId: saleId,
                editedAt: editedAt,
                beforeJson: beforeJson,
                afterJson: afterJson,
                reason: reason,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                required int saleId,
                required DateTime editedAt,
                required String beforeJson,
                required String afterJson,
                Value<String?> reason = const Value.absent(),
              }) => SaleEditsCompanion.insert(
                id: id,
                syncId: syncId,
                saleId: saleId,
                editedAt: editedAt,
                beforeJson: beforeJson,
                afterJson: afterJson,
                reason: reason,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaleEditsTable, SaleEdit>(table),
                  $$SaleEditsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false}) {
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
                        referencedTable: $$SaleEditsTableReferences
                            ._saleIdTable(db),
                        referencedColumn: $$SaleEditsTableReferences
                            ._saleIdTable(db)
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

typedef $$SaleEditsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleEditsTable,
      SaleEdit,
      $$SaleEditsTableFilterComposer,
      $$SaleEditsTableOrderingComposer,
      $$SaleEditsTableAnnotationComposer,
      $$SaleEditsTableCreateCompanionBuilder,
      $$SaleEditsTableUpdateCompanionBuilder,
      (SaleEdit, $$SaleEditsTableReferences),
      SaleEdit,
      PrefetchHooks Function({bool saleId})
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<String?> syncId,
  required DateTime date,
  required String type,
  required int amountCentavos,
  Value<String?> note,
  Value<int?> productId,
  Value<int?> grams,
  Value<int?> capitalPerKgCentavos,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<int> id,
  Value<String?> syncId,
  Value<DateTime> date,
  Value<String> type,
  Value<int> amountCentavos,
  Value<String?> note,
  Value<int?> productId,
  Value<int?> grams,
  Value<int?> capitalPerKgCentavos,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

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
                Value<String?> syncId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> amountCentavos = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<int?> grams = const Value.absent(),
                Value<int?> capitalPerKgCentavos = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                syncId: syncId,
                date: date,
                type: type,
                amountCentavos: amountCentavos,
                note: note,
                productId: productId,
                grams: grams,
                capitalPerKgCentavos: capitalPerKgCentavos,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                required DateTime date,
                required String type,
                required int amountCentavos,
                Value<String?> note = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<int?> grams = const Value.absent(),
                Value<int?> capitalPerKgCentavos = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                syncId: syncId,
                date: date,
                type: type,
                amountCentavos: amountCentavos,
                note: note,
                productId: productId,
                grams: grams,
                capitalPerKgCentavos: capitalPerKgCentavos,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
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
      Value<String?> syncId,
      required DateTime date,
      required int amountCentavos,
      Value<String?> note,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$RestockPurchasesTableUpdateCompanionBuilder =
    RestockPurchasesCompanion Function({
      Value<int> id,
      Value<String?> syncId,
      Value<DateTime> date,
      Value<int> amountCentavos,
      Value<String?> note,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get amountCentavos => $composableBuilder(
    column: $table.amountCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
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
                Value<String?> syncId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> amountCentavos = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => RestockPurchasesCompanion(
                id: id,
                syncId: syncId,
                date: date,
                amountCentavos: amountCentavos,
                note: note,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                required DateTime date,
                required int amountCentavos,
                Value<String?> note = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => RestockPurchasesCompanion.insert(
                id: id,
                syncId: syncId,
                date: date,
                amountCentavos: amountCentavos,
                note: note,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
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
  Value<String?> syncId,
  required DateTime date,
  required int toParentsCentavos,
  required int salaryCentavos,
  required int reserveCentavos,
  Value<bool> locked,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$PayoutsTableUpdateCompanionBuilder = PayoutsCompanion Function({
  Value<int> id,
  Value<String?> syncId,
  Value<DateTime> date,
  Value<int> toParentsCentavos,
  Value<int> salaryCentavos,
  Value<int> reserveCentavos,
  Value<bool> locked,
  Value<DateTime?> updatedAt,
  Value<DateTime?> deletedAt,
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
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
                Value<String?> syncId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> toParentsCentavos = const Value.absent(),
                Value<int> salaryCentavos = const Value.absent(),
                Value<int> reserveCentavos = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => PayoutsCompanion(
                id: id,
                syncId: syncId,
                date: date,
                toParentsCentavos: toParentsCentavos,
                salaryCentavos: salaryCentavos,
                reserveCentavos: reserveCentavos,
                locked: locked,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                required DateTime date,
                required int toParentsCentavos,
                required int salaryCentavos,
                required int reserveCentavos,
                Value<bool> locked = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => PayoutsCompanion.insert(
                id: id,
                syncId: syncId,
                date: date,
                toParentsCentavos: toParentsCentavos,
                salaryCentavos: salaryCentavos,
                reserveCentavos: reserveCentavos,
                locked: locked,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
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
  Value<String?> syncId,
  Value<String> salaryMode,
  Value<int> salaryPercentBasisPoints,
  Value<int> fixedDailySalaryCentavos,
  Value<DateTime?> updatedAt,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<String?> syncId,
  Value<String> salaryMode,
  Value<int> salaryPercentBasisPoints,
  Value<int> fixedDailySalaryCentavos,
  Value<DateTime?> updatedAt,
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

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
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

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
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
                Value<String?> syncId = const Value.absent(),
                Value<String> salaryMode = const Value.absent(),
                Value<int> salaryPercentBasisPoints = const Value.absent(),
                Value<int> fixedDailySalaryCentavos = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                syncId: syncId,
                salaryMode: salaryMode,
                salaryPercentBasisPoints: salaryPercentBasisPoints,
                fixedDailySalaryCentavos: fixedDailySalaryCentavos,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                Value<String> salaryMode = const Value.absent(),
                Value<int> salaryPercentBasisPoints = const Value.absent(),
                Value<int> fixedDailySalaryCentavos = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                syncId: syncId,
                salaryMode: salaryMode,
                salaryPercentBasisPoints: salaryPercentBasisPoints,
                fixedDailySalaryCentavos: fixedDailySalaryCentavos,
                updatedAt: updatedAt,
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
typedef $$OutboxItemsTableCreateCompanionBuilder =
    OutboxItemsCompanion Function({
      Value<int> id,
      required String entityType,
      required String entitySyncId,
      required String action,
      required String payloadJson,
      required DateTime createdAt,
    });
typedef $$OutboxItemsTableUpdateCompanionBuilder =
    OutboxItemsCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> entitySyncId,
      Value<String> action,
      Value<String> payloadJson,
      Value<DateTime> createdAt,
    });

class $$OutboxItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxItemsTable> {
  $$OutboxItemsTableFilterComposer({
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

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxItemsTable> {
  $$OutboxItemsTableOrderingComposer({
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

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxItemsTable> {
  $$OutboxItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxItemsTable,
          OutboxItem,
          $$OutboxItemsTableFilterComposer,
          $$OutboxItemsTableOrderingComposer,
          $$OutboxItemsTableAnnotationComposer,
          $$OutboxItemsTableCreateCompanionBuilder,
          $$OutboxItemsTableUpdateCompanionBuilder,
          (
            OutboxItem,
            BaseReferences<_$AppDatabase, $OutboxItemsTable, OutboxItem>,
          ),
          OutboxItem,
          PrefetchHooks Function()
        > {
  $$OutboxItemsTableTableManager(_$AppDatabase db, $OutboxItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entitySyncId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => OutboxItemsCompanion(
                id: id,
                entityType: entityType,
                entitySyncId: entitySyncId,
                action: action,
                payloadJson: payloadJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entitySyncId,
                required String action,
                required String payloadJson,
                required DateTime createdAt,
              }) => OutboxItemsCompanion.insert(
                id: id,
                entityType: entityType,
                entitySyncId: entitySyncId,
                action: action,
                payloadJson: payloadJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxItemsTable, OutboxItem>(table),
                  BaseReferences<_$AppDatabase, $OutboxItemsTable, OutboxItem>(
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

typedef $$OutboxItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxItemsTable,
      OutboxItem,
      $$OutboxItemsTableFilterComposer,
      $$OutboxItemsTableOrderingComposer,
      $$OutboxItemsTableAnnotationComposer,
      $$OutboxItemsTableCreateCompanionBuilder,
      $$OutboxItemsTableUpdateCompanionBuilder,
      (
        OutboxItem,
        BaseReferences<_$AppDatabase, $OutboxItemsTable, OutboxItem>,
      ),
      OutboxItem,
      PrefetchHooks Function()
    >;
typedef $$SyncStatesTableCreateCompanionBuilder = SyncStatesCompanion Function({
  Value<int> id,
  Value<DateTime?> lastSyncedAt,
  Value<String?> lastSyncStatus,
  Value<String?> lastErrorMessage,
});
typedef $$SyncStatesTableUpdateCompanionBuilder = SyncStatesCompanion Function({
  Value<int> id,
  Value<DateTime?> lastSyncedAt,
  Value<String?> lastSyncStatus,
  Value<String?> lastErrorMessage,
});

class $$SyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
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

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncStatus => $composableBuilder(
    column: $table.lastSyncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorMessage => $composableBuilder(
    column: $table.lastErrorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncStatus => $composableBuilder(
    column: $table.lastSyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorMessage => $composableBuilder(
    column: $table.lastErrorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncStatus => $composableBuilder(
    column: $table.lastSyncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorMessage => $composableBuilder(
    column: $table.lastErrorMessage,
    builder: (column) => column,
  );
}

class $$SyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStatesTable,
          SyncState,
          $$SyncStatesTableFilterComposer,
          $$SyncStatesTableOrderingComposer,
          $$SyncStatesTableAnnotationComposer,
          $$SyncStatesTableCreateCompanionBuilder,
          $$SyncStatesTableUpdateCompanionBuilder,
          (
            SyncState,
            BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>,
          ),
          SyncState,
          PrefetchHooks Function()
        > {
  $$SyncStatesTableTableManager(_$AppDatabase db, $SyncStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> lastSyncStatus = const Value.absent(),
                Value<String?> lastErrorMessage = const Value.absent(),
              }) => SyncStatesCompanion(
                id: id,
                lastSyncedAt: lastSyncedAt,
                lastSyncStatus: lastSyncStatus,
                lastErrorMessage: lastErrorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> lastSyncStatus = const Value.absent(),
                Value<String?> lastErrorMessage = const Value.absent(),
              }) => SyncStatesCompanion.insert(
                id: id,
                lastSyncedAt: lastSyncedAt,
                lastSyncStatus: lastSyncStatus,
                lastErrorMessage: lastErrorMessage,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStatesTable, SyncState>(table),
                  BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>(
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

typedef $$SyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStatesTable,
      SyncState,
      $$SyncStatesTableFilterComposer,
      $$SyncStatesTableOrderingComposer,
      $$SyncStatesTableAnnotationComposer,
      $$SyncStatesTableCreateCompanionBuilder,
      $$SyncStatesTableUpdateCompanionBuilder,
      (SyncState, BaseReferences<_$AppDatabase, $SyncStatesTable, SyncState>),
      SyncState,
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
  $$SaleEditsTableTableManager get saleEdits =>
      $$SaleEditsTableTableManager(_db, _db.saleEdits);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$RestockPurchasesTableTableManager get restockPurchases =>
      $$RestockPurchasesTableTableManager(_db, _db.restockPurchases);
  $$PayoutsTableTableManager get payouts =>
      $$PayoutsTableTableManager(_db, _db.payouts);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$OutboxItemsTableTableManager get outboxItems =>
      $$OutboxItemsTableTableManager(_db, _db.outboxItems);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
}
