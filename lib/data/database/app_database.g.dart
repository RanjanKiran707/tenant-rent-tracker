// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TenantsTable extends Tenants with TableInfo<$TenantsTable, TenantRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TenantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _createdOnMeta = const VerificationMeta(
    'createdOn',
  );
  @override
  late final GeneratedColumn<DateTime> createdOn = GeneratedColumn<DateTime>(
    'created_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    false,
    check: () => ComparableExpr(dueDay).isBetweenValues(1, 31),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _startMonthMeta = const VerificationMeta(
    'startMonth',
  );
  @override
  late final GeneratedColumn<String> startMonth = GeneratedColumn<String>(
    'start_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMonthMeta = const VerificationMeta(
    'deletedMonth',
  );
  @override
  late final GeneratedColumn<String> deletedMonth = GeneratedColumn<String>(
    'deleted_month',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    name,
    createdOn,
    dueDay,
    startMonth,
    deletedMonth,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tenants';
  @override
  VerificationContext validateIntegrity(
    Insertable<TenantRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_on')) {
      context.handle(
        _createdOnMeta,
        createdOn.isAcceptableOrUnknown(data['created_on']!, _createdOnMeta),
      );
    } else if (isInserting) {
      context.missing(_createdOnMeta);
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    }
    if (data.containsKey('start_month')) {
      context.handle(
        _startMonthMeta,
        startMonth.isAcceptableOrUnknown(data['start_month']!, _startMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_startMonthMeta);
    }
    if (data.containsKey('deleted_month')) {
      context.handle(
        _deletedMonthMeta,
        deletedMonth.isAcceptableOrUnknown(
          data['deleted_month']!,
          _deletedMonthMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  TenantRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TenantRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_on'],
      )!,
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day'],
      )!,
      startMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_month'],
      )!,
      deletedMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_month'],
      ),
    );
  }

  @override
  $TenantsTable createAlias(String alias) {
    return $TenantsTable(attachedDatabase, alias);
  }
}

class TenantRow extends DataClass implements Insertable<TenantRow> {
  final String uuid;
  final String name;
  final DateTime createdOn;
  final int dueDay;
  final String startMonth;

  /// null = active, set = deleted (archived).
  final String? deletedMonth;
  const TenantRow({
    required this.uuid,
    required this.name,
    required this.createdOn,
    required this.dueDay,
    required this.startMonth,
    this.deletedMonth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    map['created_on'] = Variable<DateTime>(createdOn);
    map['due_day'] = Variable<int>(dueDay);
    map['start_month'] = Variable<String>(startMonth);
    if (!nullToAbsent || deletedMonth != null) {
      map['deleted_month'] = Variable<String>(deletedMonth);
    }
    return map;
  }

  TenantsCompanion toCompanion(bool nullToAbsent) {
    return TenantsCompanion(
      uuid: Value(uuid),
      name: Value(name),
      createdOn: Value(createdOn),
      dueDay: Value(dueDay),
      startMonth: Value(startMonth),
      deletedMonth: deletedMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedMonth),
    );
  }

  factory TenantRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TenantRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      createdOn: serializer.fromJson<DateTime>(json['createdOn']),
      dueDay: serializer.fromJson<int>(json['dueDay']),
      startMonth: serializer.fromJson<String>(json['startMonth']),
      deletedMonth: serializer.fromJson<String?>(json['deletedMonth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'createdOn': serializer.toJson<DateTime>(createdOn),
      'dueDay': serializer.toJson<int>(dueDay),
      'startMonth': serializer.toJson<String>(startMonth),
      'deletedMonth': serializer.toJson<String?>(deletedMonth),
    };
  }

  TenantRow copyWith({
    String? uuid,
    String? name,
    DateTime? createdOn,
    int? dueDay,
    String? startMonth,
    Value<String?> deletedMonth = const Value.absent(),
  }) => TenantRow(
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    createdOn: createdOn ?? this.createdOn,
    dueDay: dueDay ?? this.dueDay,
    startMonth: startMonth ?? this.startMonth,
    deletedMonth: deletedMonth.present ? deletedMonth.value : this.deletedMonth,
  );
  TenantRow copyWithCompanion(TenantsCompanion data) {
    return TenantRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      createdOn: data.createdOn.present ? data.createdOn.value : this.createdOn,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      startMonth: data.startMonth.present
          ? data.startMonth.value
          : this.startMonth,
      deletedMonth: data.deletedMonth.present
          ? data.deletedMonth.value
          : this.deletedMonth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TenantRow(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('createdOn: $createdOn, ')
          ..write('dueDay: $dueDay, ')
          ..write('startMonth: $startMonth, ')
          ..write('deletedMonth: $deletedMonth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, name, createdOn, dueDay, startMonth, deletedMonth);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TenantRow &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.createdOn == this.createdOn &&
          other.dueDay == this.dueDay &&
          other.startMonth == this.startMonth &&
          other.deletedMonth == this.deletedMonth);
}

class TenantsCompanion extends UpdateCompanion<TenantRow> {
  final Value<String> uuid;
  final Value<String> name;
  final Value<DateTime> createdOn;
  final Value<int> dueDay;
  final Value<String> startMonth;
  final Value<String?> deletedMonth;
  final Value<int> rowid;
  const TenantsCompanion({
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.createdOn = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.startMonth = const Value.absent(),
    this.deletedMonth = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TenantsCompanion.insert({
    required String uuid,
    required String name,
    required DateTime createdOn,
    this.dueDay = const Value.absent(),
    required String startMonth,
    this.deletedMonth = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       name = Value(name),
       createdOn = Value(createdOn),
       startMonth = Value(startMonth);
  static Insertable<TenantRow> custom({
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<DateTime>? createdOn,
    Expression<int>? dueDay,
    Expression<String>? startMonth,
    Expression<String>? deletedMonth,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (createdOn != null) 'created_on': createdOn,
      if (dueDay != null) 'due_day': dueDay,
      if (startMonth != null) 'start_month': startMonth,
      if (deletedMonth != null) 'deleted_month': deletedMonth,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TenantsCompanion copyWith({
    Value<String>? uuid,
    Value<String>? name,
    Value<DateTime>? createdOn,
    Value<int>? dueDay,
    Value<String>? startMonth,
    Value<String?>? deletedMonth,
    Value<int>? rowid,
  }) {
    return TenantsCompanion(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      createdOn: createdOn ?? this.createdOn,
      dueDay: dueDay ?? this.dueDay,
      startMonth: startMonth ?? this.startMonth,
      deletedMonth: deletedMonth ?? this.deletedMonth,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdOn.present) {
      map['created_on'] = Variable<DateTime>(createdOn.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (startMonth.present) {
      map['start_month'] = Variable<String>(startMonth.value);
    }
    if (deletedMonth.present) {
      map['deleted_month'] = Variable<String>(deletedMonth.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TenantsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('createdOn: $createdOn, ')
          ..write('dueDay: $dueDay, ')
          ..write('startMonth: $startMonth, ')
          ..write('deletedMonth: $deletedMonth, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RentHistoriesTable extends RentHistories
    with TableInfo<$RentHistoriesTable, RentHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RentHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantUuidMeta = const VerificationMeta(
    'tenantUuid',
  );
  @override
  late final GeneratedColumn<String> tenantUuid = GeneratedColumn<String>(
    'tenant_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tenants (uuid)',
    ),
  );
  static const VerificationMeta _effectiveFromMonthMeta =
      const VerificationMeta('effectiveFromMonth');
  @override
  late final GeneratedColumn<String> effectiveFromMonth =
      GeneratedColumn<String>(
        'effective_from_month',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    check: () => ComparableExpr(amount).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    tenantUuid,
    effectiveFromMonth,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rent_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<RentHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('tenant_uuid')) {
      context.handle(
        _tenantUuidMeta,
        tenantUuid.isAcceptableOrUnknown(data['tenant_uuid']!, _tenantUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantUuidMeta);
    }
    if (data.containsKey('effective_from_month')) {
      context.handle(
        _effectiveFromMonthMeta,
        effectiveFromMonth.isAcceptableOrUnknown(
          data['effective_from_month']!,
          _effectiveFromMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMonthMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tenantUuid, effectiveFromMonth},
  ];
  @override
  RentHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RentHistoryRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      tenantUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_uuid'],
      )!,
      effectiveFromMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_from_month'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $RentHistoriesTable createAlias(String alias) {
    return $RentHistoriesTable(attachedDatabase, alias);
  }
}

class RentHistoryRow extends DataClass implements Insertable<RentHistoryRow> {
  final String uuid;
  final String tenantUuid;
  final String effectiveFromMonth;
  final int amount;
  const RentHistoryRow({
    required this.uuid,
    required this.tenantUuid,
    required this.effectiveFromMonth,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['tenant_uuid'] = Variable<String>(tenantUuid);
    map['effective_from_month'] = Variable<String>(effectiveFromMonth);
    map['amount'] = Variable<int>(amount);
    return map;
  }

  RentHistoriesCompanion toCompanion(bool nullToAbsent) {
    return RentHistoriesCompanion(
      uuid: Value(uuid),
      tenantUuid: Value(tenantUuid),
      effectiveFromMonth: Value(effectiveFromMonth),
      amount: Value(amount),
    );
  }

  factory RentHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RentHistoryRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      tenantUuid: serializer.fromJson<String>(json['tenantUuid']),
      effectiveFromMonth: serializer.fromJson<String>(
        json['effectiveFromMonth'],
      ),
      amount: serializer.fromJson<int>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'tenantUuid': serializer.toJson<String>(tenantUuid),
      'effectiveFromMonth': serializer.toJson<String>(effectiveFromMonth),
      'amount': serializer.toJson<int>(amount),
    };
  }

  RentHistoryRow copyWith({
    String? uuid,
    String? tenantUuid,
    String? effectiveFromMonth,
    int? amount,
  }) => RentHistoryRow(
    uuid: uuid ?? this.uuid,
    tenantUuid: tenantUuid ?? this.tenantUuid,
    effectiveFromMonth: effectiveFromMonth ?? this.effectiveFromMonth,
    amount: amount ?? this.amount,
  );
  RentHistoryRow copyWithCompanion(RentHistoriesCompanion data) {
    return RentHistoryRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      tenantUuid: data.tenantUuid.present
          ? data.tenantUuid.value
          : this.tenantUuid,
      effectiveFromMonth: data.effectiveFromMonth.present
          ? data.effectiveFromMonth.value
          : this.effectiveFromMonth,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RentHistoryRow(')
          ..write('uuid: $uuid, ')
          ..write('tenantUuid: $tenantUuid, ')
          ..write('effectiveFromMonth: $effectiveFromMonth, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, tenantUuid, effectiveFromMonth, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RentHistoryRow &&
          other.uuid == this.uuid &&
          other.tenantUuid == this.tenantUuid &&
          other.effectiveFromMonth == this.effectiveFromMonth &&
          other.amount == this.amount);
}

class RentHistoriesCompanion extends UpdateCompanion<RentHistoryRow> {
  final Value<String> uuid;
  final Value<String> tenantUuid;
  final Value<String> effectiveFromMonth;
  final Value<int> amount;
  final Value<int> rowid;
  const RentHistoriesCompanion({
    this.uuid = const Value.absent(),
    this.tenantUuid = const Value.absent(),
    this.effectiveFromMonth = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RentHistoriesCompanion.insert({
    required String uuid,
    required String tenantUuid,
    required String effectiveFromMonth,
    required int amount,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       tenantUuid = Value(tenantUuid),
       effectiveFromMonth = Value(effectiveFromMonth),
       amount = Value(amount);
  static Insertable<RentHistoryRow> custom({
    Expression<String>? uuid,
    Expression<String>? tenantUuid,
    Expression<String>? effectiveFromMonth,
    Expression<int>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (tenantUuid != null) 'tenant_uuid': tenantUuid,
      if (effectiveFromMonth != null)
        'effective_from_month': effectiveFromMonth,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RentHistoriesCompanion copyWith({
    Value<String>? uuid,
    Value<String>? tenantUuid,
    Value<String>? effectiveFromMonth,
    Value<int>? amount,
    Value<int>? rowid,
  }) {
    return RentHistoriesCompanion(
      uuid: uuid ?? this.uuid,
      tenantUuid: tenantUuid ?? this.tenantUuid,
      effectiveFromMonth: effectiveFromMonth ?? this.effectiveFromMonth,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (tenantUuid.present) {
      map['tenant_uuid'] = Variable<String>(tenantUuid.value);
    }
    if (effectiveFromMonth.present) {
      map['effective_from_month'] = Variable<String>(effectiveFromMonth.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RentHistoriesCompanion(')
          ..write('uuid: $uuid, ')
          ..write('tenantUuid: $tenantUuid, ')
          ..write('effectiveFromMonth: $effectiveFromMonth, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RentRecordsTable extends RentRecords
    with TableInfo<$RentRecordsTable, RentRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RentRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantUuidMeta = const VerificationMeta(
    'tenantUuid',
  );
  @override
  late final GeneratedColumn<String> tenantUuid = GeneratedColumn<String>(
    'tenant_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tenants (uuid)',
    ),
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requiredAmountMeta = const VerificationMeta(
    'requiredAmount',
  );
  @override
  late final GeneratedColumn<int> requiredAmount = GeneratedColumn<int>(
    'required_amount',
    aliasedName,
    false,
    check: () => ComparableExpr(requiredAmount).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    tenantUuid,
    month,
    requiredAmount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rent_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<RentRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('tenant_uuid')) {
      context.handle(
        _tenantUuidMeta,
        tenantUuid.isAcceptableOrUnknown(data['tenant_uuid']!, _tenantUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantUuidMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('required_amount')) {
      context.handle(
        _requiredAmountMeta,
        requiredAmount.isAcceptableOrUnknown(
          data['required_amount']!,
          _requiredAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requiredAmountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tenantUuid, month},
  ];
  @override
  RentRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RentRecordRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      tenantUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_uuid'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      requiredAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}required_amount'],
      )!,
    );
  }

  @override
  $RentRecordsTable createAlias(String alias) {
    return $RentRecordsTable(attachedDatabase, alias);
  }
}

class RentRecordRow extends DataClass implements Insertable<RentRecordRow> {
  final String uuid;
  final String tenantUuid;
  final String month;

  /// Snapshot of the rent for that month.
  final int requiredAmount;
  const RentRecordRow({
    required this.uuid,
    required this.tenantUuid,
    required this.month,
    required this.requiredAmount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['tenant_uuid'] = Variable<String>(tenantUuid);
    map['month'] = Variable<String>(month);
    map['required_amount'] = Variable<int>(requiredAmount);
    return map;
  }

  RentRecordsCompanion toCompanion(bool nullToAbsent) {
    return RentRecordsCompanion(
      uuid: Value(uuid),
      tenantUuid: Value(tenantUuid),
      month: Value(month),
      requiredAmount: Value(requiredAmount),
    );
  }

  factory RentRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RentRecordRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      tenantUuid: serializer.fromJson<String>(json['tenantUuid']),
      month: serializer.fromJson<String>(json['month']),
      requiredAmount: serializer.fromJson<int>(json['requiredAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'tenantUuid': serializer.toJson<String>(tenantUuid),
      'month': serializer.toJson<String>(month),
      'requiredAmount': serializer.toJson<int>(requiredAmount),
    };
  }

  RentRecordRow copyWith({
    String? uuid,
    String? tenantUuid,
    String? month,
    int? requiredAmount,
  }) => RentRecordRow(
    uuid: uuid ?? this.uuid,
    tenantUuid: tenantUuid ?? this.tenantUuid,
    month: month ?? this.month,
    requiredAmount: requiredAmount ?? this.requiredAmount,
  );
  RentRecordRow copyWithCompanion(RentRecordsCompanion data) {
    return RentRecordRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      tenantUuid: data.tenantUuid.present
          ? data.tenantUuid.value
          : this.tenantUuid,
      month: data.month.present ? data.month.value : this.month,
      requiredAmount: data.requiredAmount.present
          ? data.requiredAmount.value
          : this.requiredAmount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RentRecordRow(')
          ..write('uuid: $uuid, ')
          ..write('tenantUuid: $tenantUuid, ')
          ..write('month: $month, ')
          ..write('requiredAmount: $requiredAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, tenantUuid, month, requiredAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RentRecordRow &&
          other.uuid == this.uuid &&
          other.tenantUuid == this.tenantUuid &&
          other.month == this.month &&
          other.requiredAmount == this.requiredAmount);
}

class RentRecordsCompanion extends UpdateCompanion<RentRecordRow> {
  final Value<String> uuid;
  final Value<String> tenantUuid;
  final Value<String> month;
  final Value<int> requiredAmount;
  final Value<int> rowid;
  const RentRecordsCompanion({
    this.uuid = const Value.absent(),
    this.tenantUuid = const Value.absent(),
    this.month = const Value.absent(),
    this.requiredAmount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RentRecordsCompanion.insert({
    required String uuid,
    required String tenantUuid,
    required String month,
    required int requiredAmount,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       tenantUuid = Value(tenantUuid),
       month = Value(month),
       requiredAmount = Value(requiredAmount);
  static Insertable<RentRecordRow> custom({
    Expression<String>? uuid,
    Expression<String>? tenantUuid,
    Expression<String>? month,
    Expression<int>? requiredAmount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (tenantUuid != null) 'tenant_uuid': tenantUuid,
      if (month != null) 'month': month,
      if (requiredAmount != null) 'required_amount': requiredAmount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RentRecordsCompanion copyWith({
    Value<String>? uuid,
    Value<String>? tenantUuid,
    Value<String>? month,
    Value<int>? requiredAmount,
    Value<int>? rowid,
  }) {
    return RentRecordsCompanion(
      uuid: uuid ?? this.uuid,
      tenantUuid: tenantUuid ?? this.tenantUuid,
      month: month ?? this.month,
      requiredAmount: requiredAmount ?? this.requiredAmount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (tenantUuid.present) {
      map['tenant_uuid'] = Variable<String>(tenantUuid.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (requiredAmount.present) {
      map['required_amount'] = Variable<int>(requiredAmount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RentRecordsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('tenantUuid: $tenantUuid, ')
          ..write('month: $month, ')
          ..write('requiredAmount: $requiredAmount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments
    with TableInfo<$PaymentsTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rentRecordUuidMeta = const VerificationMeta(
    'rentRecordUuid',
  );
  @override
  late final GeneratedColumn<String> rentRecordUuid = GeneratedColumn<String>(
    'rent_record_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rent_records (uuid)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    check: () => ComparableExpr(amount).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidOnMeta = const VerificationMeta('paidOn');
  @override
  late final GeneratedColumn<String> paidOn = GeneratedColumn<String>(
    'paid_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdOnMeta = const VerificationMeta(
    'createdOn',
  );
  @override
  late final GeneratedColumn<DateTime> createdOn = GeneratedColumn<DateTime>(
    'created_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    uuid,
    rentRecordUuid,
    amount,
    paidOn,
    createdOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('rent_record_uuid')) {
      context.handle(
        _rentRecordUuidMeta,
        rentRecordUuid.isAcceptableOrUnknown(
          data['rent_record_uuid']!,
          _rentRecordUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rentRecordUuidMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('paid_on')) {
      context.handle(
        _paidOnMeta,
        paidOn.isAcceptableOrUnknown(data['paid_on']!, _paidOnMeta),
      );
    } else if (isInserting) {
      context.missing(_paidOnMeta);
    }
    if (data.containsKey('created_on')) {
      context.handle(
        _createdOnMeta,
        createdOn.isAcceptableOrUnknown(data['created_on']!, _createdOnMeta),
      );
    } else if (isInserting) {
      context.missing(_createdOnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
      )!,
      rentRecordUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rent_record_uuid'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      paidOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_on'],
      )!,
      createdOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_on'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final String uuid;
  final String rentRecordUuid;
  final int amount;
  final String paidOn;
  final DateTime createdOn;
  const PaymentRow({
    required this.uuid,
    required this.rentRecordUuid,
    required this.amount,
    required this.paidOn,
    required this.createdOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['rent_record_uuid'] = Variable<String>(rentRecordUuid);
    map['amount'] = Variable<int>(amount);
    map['paid_on'] = Variable<String>(paidOn);
    map['created_on'] = Variable<DateTime>(createdOn);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      uuid: Value(uuid),
      rentRecordUuid: Value(rentRecordUuid),
      amount: Value(amount),
      paidOn: Value(paidOn),
      createdOn: Value(createdOn),
    );
  }

  factory PaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      uuid: serializer.fromJson<String>(json['uuid']),
      rentRecordUuid: serializer.fromJson<String>(json['rentRecordUuid']),
      amount: serializer.fromJson<int>(json['amount']),
      paidOn: serializer.fromJson<String>(json['paidOn']),
      createdOn: serializer.fromJson<DateTime>(json['createdOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'rentRecordUuid': serializer.toJson<String>(rentRecordUuid),
      'amount': serializer.toJson<int>(amount),
      'paidOn': serializer.toJson<String>(paidOn),
      'createdOn': serializer.toJson<DateTime>(createdOn),
    };
  }

  PaymentRow copyWith({
    String? uuid,
    String? rentRecordUuid,
    int? amount,
    String? paidOn,
    DateTime? createdOn,
  }) => PaymentRow(
    uuid: uuid ?? this.uuid,
    rentRecordUuid: rentRecordUuid ?? this.rentRecordUuid,
    amount: amount ?? this.amount,
    paidOn: paidOn ?? this.paidOn,
    createdOn: createdOn ?? this.createdOn,
  );
  PaymentRow copyWithCompanion(PaymentsCompanion data) {
    return PaymentRow(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      rentRecordUuid: data.rentRecordUuid.present
          ? data.rentRecordUuid.value
          : this.rentRecordUuid,
      amount: data.amount.present ? data.amount.value : this.amount,
      paidOn: data.paidOn.present ? data.paidOn.value : this.paidOn,
      createdOn: data.createdOn.present ? data.createdOn.value : this.createdOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('uuid: $uuid, ')
          ..write('rentRecordUuid: $rentRecordUuid, ')
          ..write('amount: $amount, ')
          ..write('paidOn: $paidOn, ')
          ..write('createdOn: $createdOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(uuid, rentRecordUuid, amount, paidOn, createdOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.uuid == this.uuid &&
          other.rentRecordUuid == this.rentRecordUuid &&
          other.amount == this.amount &&
          other.paidOn == this.paidOn &&
          other.createdOn == this.createdOn);
}

class PaymentsCompanion extends UpdateCompanion<PaymentRow> {
  final Value<String> uuid;
  final Value<String> rentRecordUuid;
  final Value<int> amount;
  final Value<String> paidOn;
  final Value<DateTime> createdOn;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.uuid = const Value.absent(),
    this.rentRecordUuid = const Value.absent(),
    this.amount = const Value.absent(),
    this.paidOn = const Value.absent(),
    this.createdOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String uuid,
    required String rentRecordUuid,
    required int amount,
    required String paidOn,
    required DateTime createdOn,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       rentRecordUuid = Value(rentRecordUuid),
       amount = Value(amount),
       paidOn = Value(paidOn),
       createdOn = Value(createdOn);
  static Insertable<PaymentRow> custom({
    Expression<String>? uuid,
    Expression<String>? rentRecordUuid,
    Expression<int>? amount,
    Expression<String>? paidOn,
    Expression<DateTime>? createdOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (rentRecordUuid != null) 'rent_record_uuid': rentRecordUuid,
      if (amount != null) 'amount': amount,
      if (paidOn != null) 'paid_on': paidOn,
      if (createdOn != null) 'created_on': createdOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? uuid,
    Value<String>? rentRecordUuid,
    Value<int>? amount,
    Value<String>? paidOn,
    Value<DateTime>? createdOn,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      uuid: uuid ?? this.uuid,
      rentRecordUuid: rentRecordUuid ?? this.rentRecordUuid,
      amount: amount ?? this.amount,
      paidOn: paidOn ?? this.paidOn,
      createdOn: createdOn ?? this.createdOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (rentRecordUuid.present) {
      map['rent_record_uuid'] = Variable<String>(rentRecordUuid.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (paidOn.present) {
      map['paid_on'] = Variable<String>(paidOn.value);
    }
    if (createdOn.present) {
      map['created_on'] = Variable<DateTime>(createdOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('rentRecordUuid: $rentRecordUuid, ')
          ..write('amount: $amount, ')
          ..write('paidOn: $paidOn, ')
          ..write('createdOn: $createdOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TenantsTable tenants = $TenantsTable(this);
  late final $RentHistoriesTable rentHistories = $RentHistoriesTable(this);
  late final $RentRecordsTable rentRecords = $RentRecordsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tenants,
    rentHistories,
    rentRecords,
    payments,
  ];
}

typedef $$TenantsTableCreateCompanionBuilder =
    TenantsCompanion Function({
      required String uuid,
      required String name,
      required DateTime createdOn,
      Value<int> dueDay,
      required String startMonth,
      Value<String?> deletedMonth,
      Value<int> rowid,
    });
typedef $$TenantsTableUpdateCompanionBuilder =
    TenantsCompanion Function({
      Value<String> uuid,
      Value<String> name,
      Value<DateTime> createdOn,
      Value<int> dueDay,
      Value<String> startMonth,
      Value<String?> deletedMonth,
      Value<int> rowid,
    });

final class $$TenantsTableReferences
    extends BaseReferences<_$AppDatabase, $TenantsTable, TenantRow> {
  $$TenantsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RentHistoriesTable, List<RentHistoryRow>>
  _rentHistoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rentHistories,
    aliasName: $_aliasNameGenerator(
      db.tenants.uuid,
      db.rentHistories.tenantUuid,
    ),
  );

  $$RentHistoriesTableProcessedTableManager get rentHistoriesRefs {
    final manager = $$RentHistoriesTableTableManager(
      $_db,
      $_db.rentHistories,
    ).filter((f) => f.tenantUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_rentHistoriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RentRecordsTable, List<RentRecordRow>>
  _rentRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rentRecords,
    aliasName: $_aliasNameGenerator(db.tenants.uuid, db.rentRecords.tenantUuid),
  );

  $$RentRecordsTableProcessedTableManager get rentRecordsRefs {
    final manager = $$RentRecordsTableTableManager(
      $_db,
      $_db.rentRecords,
    ).filter((f) => f.tenantUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!));

    final cache = $_typedResult.readTableOrNull(_rentRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TenantsTableFilterComposer
    extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdOn => $composableBuilder(
    column: $table.createdOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedMonth => $composableBuilder(
    column: $table.deletedMonth,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> rentHistoriesRefs(
    Expression<bool> Function($$RentHistoriesTableFilterComposer f) f,
  ) {
    final $$RentHistoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.rentHistories,
      getReferencedColumn: (t) => t.tenantUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RentHistoriesTableFilterComposer(
            $db: $db,
            $table: $db.rentHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rentRecordsRefs(
    Expression<bool> Function($$RentRecordsTableFilterComposer f) f,
  ) {
    final $$RentRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.rentRecords,
      getReferencedColumn: (t) => t.tenantUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RentRecordsTableFilterComposer(
            $db: $db,
            $table: $db.rentRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TenantsTableOrderingComposer
    extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdOn => $composableBuilder(
    column: $table.createdOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedMonth => $composableBuilder(
    column: $table.deletedMonth,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TenantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TenantsTable> {
  $$TenantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdOn =>
      $composableBuilder(column: $table.createdOn, builder: (column) => column);

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deletedMonth => $composableBuilder(
    column: $table.deletedMonth,
    builder: (column) => column,
  );

  Expression<T> rentHistoriesRefs<T extends Object>(
    Expression<T> Function($$RentHistoriesTableAnnotationComposer a) f,
  ) {
    final $$RentHistoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.rentHistories,
      getReferencedColumn: (t) => t.tenantUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RentHistoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.rentHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rentRecordsRefs<T extends Object>(
    Expression<T> Function($$RentRecordsTableAnnotationComposer a) f,
  ) {
    final $$RentRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.rentRecords,
      getReferencedColumn: (t) => t.tenantUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RentRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.rentRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TenantsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TenantsTable,
          TenantRow,
          $$TenantsTableFilterComposer,
          $$TenantsTableOrderingComposer,
          $$TenantsTableAnnotationComposer,
          $$TenantsTableCreateCompanionBuilder,
          $$TenantsTableUpdateCompanionBuilder,
          (TenantRow, $$TenantsTableReferences),
          TenantRow,
          PrefetchHooks Function({bool rentHistoriesRefs, bool rentRecordsRefs})
        > {
  $$TenantsTableTableManager(_$AppDatabase db, $TenantsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TenantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TenantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TenantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdOn = const Value.absent(),
                Value<int> dueDay = const Value.absent(),
                Value<String> startMonth = const Value.absent(),
                Value<String?> deletedMonth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TenantsCompanion(
                uuid: uuid,
                name: name,
                createdOn: createdOn,
                dueDay: dueDay,
                startMonth: startMonth,
                deletedMonth: deletedMonth,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                required String name,
                required DateTime createdOn,
                Value<int> dueDay = const Value.absent(),
                required String startMonth,
                Value<String?> deletedMonth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TenantsCompanion.insert(
                uuid: uuid,
                name: name,
                createdOn: createdOn,
                dueDay: dueDay,
                startMonth: startMonth,
                deletedMonth: deletedMonth,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TenantsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({rentHistoriesRefs = false, rentRecordsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (rentHistoriesRefs) db.rentHistories,
                    if (rentRecordsRefs) db.rentRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (rentHistoriesRefs)
                        await $_getPrefetchedData<
                          TenantRow,
                          $TenantsTable,
                          RentHistoryRow
                        >(
                          currentTable: table,
                          referencedTable: $$TenantsTableReferences
                              ._rentHistoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TenantsTableReferences(
                                db,
                                table,
                                p0,
                              ).rentHistoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tenantUuid == item.uuid,
                              ),
                          typedResults: items,
                        ),
                      if (rentRecordsRefs)
                        await $_getPrefetchedData<
                          TenantRow,
                          $TenantsTable,
                          RentRecordRow
                        >(
                          currentTable: table,
                          referencedTable: $$TenantsTableReferences
                              ._rentRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TenantsTableReferences(
                                db,
                                table,
                                p0,
                              ).rentRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tenantUuid == item.uuid,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TenantsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TenantsTable,
      TenantRow,
      $$TenantsTableFilterComposer,
      $$TenantsTableOrderingComposer,
      $$TenantsTableAnnotationComposer,
      $$TenantsTableCreateCompanionBuilder,
      $$TenantsTableUpdateCompanionBuilder,
      (TenantRow, $$TenantsTableReferences),
      TenantRow,
      PrefetchHooks Function({bool rentHistoriesRefs, bool rentRecordsRefs})
    >;
typedef $$RentHistoriesTableCreateCompanionBuilder =
    RentHistoriesCompanion Function({
      required String uuid,
      required String tenantUuid,
      required String effectiveFromMonth,
      required int amount,
      Value<int> rowid,
    });
typedef $$RentHistoriesTableUpdateCompanionBuilder =
    RentHistoriesCompanion Function({
      Value<String> uuid,
      Value<String> tenantUuid,
      Value<String> effectiveFromMonth,
      Value<int> amount,
      Value<int> rowid,
    });

final class $$RentHistoriesTableReferences
    extends BaseReferences<_$AppDatabase, $RentHistoriesTable, RentHistoryRow> {
  $$RentHistoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TenantsTable _tenantUuidTable(_$AppDatabase db) =>
      db.tenants.createAlias(
        $_aliasNameGenerator(db.rentHistories.tenantUuid, db.tenants.uuid),
      );

  $$TenantsTableProcessedTableManager get tenantUuid {
    final $_column = $_itemColumn<String>('tenant_uuid')!;

    final manager = $$TenantsTableTableManager(
      $_db,
      $_db.tenants,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tenantUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RentHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $RentHistoriesTable> {
  $$RentHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveFromMonth => $composableBuilder(
    column: $table.effectiveFromMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  $$TenantsTableFilterComposer get tenantUuid {
    final $$TenantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantUuid,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TenantsTableFilterComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RentHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RentHistoriesTable> {
  $$RentHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveFromMonth => $composableBuilder(
    column: $table.effectiveFromMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  $$TenantsTableOrderingComposer get tenantUuid {
    final $$TenantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantUuid,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TenantsTableOrderingComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RentHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RentHistoriesTable> {
  $$RentHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get effectiveFromMonth => $composableBuilder(
    column: $table.effectiveFromMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$TenantsTableAnnotationComposer get tenantUuid {
    final $$TenantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantUuid,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TenantsTableAnnotationComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RentHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RentHistoriesTable,
          RentHistoryRow,
          $$RentHistoriesTableFilterComposer,
          $$RentHistoriesTableOrderingComposer,
          $$RentHistoriesTableAnnotationComposer,
          $$RentHistoriesTableCreateCompanionBuilder,
          $$RentHistoriesTableUpdateCompanionBuilder,
          (RentHistoryRow, $$RentHistoriesTableReferences),
          RentHistoryRow,
          PrefetchHooks Function({bool tenantUuid})
        > {
  $$RentHistoriesTableTableManager(_$AppDatabase db, $RentHistoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RentHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RentHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RentHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<String> tenantUuid = const Value.absent(),
                Value<String> effectiveFromMonth = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RentHistoriesCompanion(
                uuid: uuid,
                tenantUuid: tenantUuid,
                effectiveFromMonth: effectiveFromMonth,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                required String tenantUuid,
                required String effectiveFromMonth,
                required int amount,
                Value<int> rowid = const Value.absent(),
              }) => RentHistoriesCompanion.insert(
                uuid: uuid,
                tenantUuid: tenantUuid,
                effectiveFromMonth: effectiveFromMonth,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RentHistoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tenantUuid = false}) {
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
                    if (tenantUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tenantUuid,
                                referencedTable: $$RentHistoriesTableReferences
                                    ._tenantUuidTable(db),
                                referencedColumn: $$RentHistoriesTableReferences
                                    ._tenantUuidTable(db)
                                    .uuid,
                              )
                              as T;
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

typedef $$RentHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RentHistoriesTable,
      RentHistoryRow,
      $$RentHistoriesTableFilterComposer,
      $$RentHistoriesTableOrderingComposer,
      $$RentHistoriesTableAnnotationComposer,
      $$RentHistoriesTableCreateCompanionBuilder,
      $$RentHistoriesTableUpdateCompanionBuilder,
      (RentHistoryRow, $$RentHistoriesTableReferences),
      RentHistoryRow,
      PrefetchHooks Function({bool tenantUuid})
    >;
typedef $$RentRecordsTableCreateCompanionBuilder =
    RentRecordsCompanion Function({
      required String uuid,
      required String tenantUuid,
      required String month,
      required int requiredAmount,
      Value<int> rowid,
    });
typedef $$RentRecordsTableUpdateCompanionBuilder =
    RentRecordsCompanion Function({
      Value<String> uuid,
      Value<String> tenantUuid,
      Value<String> month,
      Value<int> requiredAmount,
      Value<int> rowid,
    });

final class $$RentRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $RentRecordsTable, RentRecordRow> {
  $$RentRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TenantsTable _tenantUuidTable(_$AppDatabase db) =>
      db.tenants.createAlias(
        $_aliasNameGenerator(db.rentRecords.tenantUuid, db.tenants.uuid),
      );

  $$TenantsTableProcessedTableManager get tenantUuid {
    final $_column = $_itemColumn<String>('tenant_uuid')!;

    final manager = $$TenantsTableTableManager(
      $_db,
      $_db.tenants,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tenantUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<PaymentRow>>
  _paymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: $_aliasNameGenerator(
      db.rentRecords.uuid,
      db.payments.rentRecordUuid,
    ),
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager($_db, $_db.payments).filter(
      (f) => f.rentRecordUuid.uuid.sqlEquals($_itemColumn<String>('uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RentRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $RentRecordsTable> {
  $$RentRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requiredAmount => $composableBuilder(
    column: $table.requiredAmount,
    builder: (column) => ColumnFilters(column),
  );

  $$TenantsTableFilterComposer get tenantUuid {
    final $$TenantsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantUuid,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TenantsTableFilterComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.rentRecordUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RentRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $RentRecordsTable> {
  $$RentRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requiredAmount => $composableBuilder(
    column: $table.requiredAmount,
    builder: (column) => ColumnOrderings(column),
  );

  $$TenantsTableOrderingComposer get tenantUuid {
    final $$TenantsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantUuid,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TenantsTableOrderingComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RentRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RentRecordsTable> {
  $$RentRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get requiredAmount => $composableBuilder(
    column: $table.requiredAmount,
    builder: (column) => column,
  );

  $$TenantsTableAnnotationComposer get tenantUuid {
    final $$TenantsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tenantUuid,
      referencedTable: $db.tenants,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TenantsTableAnnotationComposer(
            $db: $db,
            $table: $db.tenants,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.uuid,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.rentRecordUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RentRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RentRecordsTable,
          RentRecordRow,
          $$RentRecordsTableFilterComposer,
          $$RentRecordsTableOrderingComposer,
          $$RentRecordsTableAnnotationComposer,
          $$RentRecordsTableCreateCompanionBuilder,
          $$RentRecordsTableUpdateCompanionBuilder,
          (RentRecordRow, $$RentRecordsTableReferences),
          RentRecordRow,
          PrefetchHooks Function({bool tenantUuid, bool paymentsRefs})
        > {
  $$RentRecordsTableTableManager(_$AppDatabase db, $RentRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RentRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RentRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RentRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<String> tenantUuid = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<int> requiredAmount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RentRecordsCompanion(
                uuid: uuid,
                tenantUuid: tenantUuid,
                month: month,
                requiredAmount: requiredAmount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                required String tenantUuid,
                required String month,
                required int requiredAmount,
                Value<int> rowid = const Value.absent(),
              }) => RentRecordsCompanion.insert(
                uuid: uuid,
                tenantUuid: tenantUuid,
                month: month,
                requiredAmount: requiredAmount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RentRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tenantUuid = false, paymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (paymentsRefs) db.payments],
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
                    if (tenantUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tenantUuid,
                                referencedTable: $$RentRecordsTableReferences
                                    ._tenantUuidTable(db),
                                referencedColumn: $$RentRecordsTableReferences
                                    ._tenantUuidTable(db)
                                    .uuid,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (paymentsRefs)
                    await $_getPrefetchedData<
                      RentRecordRow,
                      $RentRecordsTable,
                      PaymentRow
                    >(
                      currentTable: table,
                      referencedTable: $$RentRecordsTableReferences
                          ._paymentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RentRecordsTableReferences(
                            db,
                            table,
                            p0,
                          ).paymentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.rentRecordUuid == item.uuid,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RentRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RentRecordsTable,
      RentRecordRow,
      $$RentRecordsTableFilterComposer,
      $$RentRecordsTableOrderingComposer,
      $$RentRecordsTableAnnotationComposer,
      $$RentRecordsTableCreateCompanionBuilder,
      $$RentRecordsTableUpdateCompanionBuilder,
      (RentRecordRow, $$RentRecordsTableReferences),
      RentRecordRow,
      PrefetchHooks Function({bool tenantUuid, bool paymentsRefs})
    >;
typedef $$PaymentsTableCreateCompanionBuilder =
    PaymentsCompanion Function({
      required String uuid,
      required String rentRecordUuid,
      required int amount,
      required String paidOn,
      required DateTime createdOn,
      Value<int> rowid,
    });
typedef $$PaymentsTableUpdateCompanionBuilder =
    PaymentsCompanion Function({
      Value<String> uuid,
      Value<String> rentRecordUuid,
      Value<int> amount,
      Value<String> paidOn,
      Value<DateTime> createdOn,
      Value<int> rowid,
    });

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, PaymentRow> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RentRecordsTable _rentRecordUuidTable(_$AppDatabase db) =>
      db.rentRecords.createAlias(
        $_aliasNameGenerator(db.payments.rentRecordUuid, db.rentRecords.uuid),
      );

  $$RentRecordsTableProcessedTableManager get rentRecordUuid {
    final $_column = $_itemColumn<String>('rent_record_uuid')!;

    final manager = $$RentRecordsTableTableManager(
      $_db,
      $_db.rentRecords,
    ).filter((f) => f.uuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rentRecordUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdOn => $composableBuilder(
    column: $table.createdOn,
    builder: (column) => ColumnFilters(column),
  );

  $$RentRecordsTableFilterComposer get rentRecordUuid {
    final $$RentRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rentRecordUuid,
      referencedTable: $db.rentRecords,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RentRecordsTableFilterComposer(
            $db: $db,
            $table: $db.rentRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paidOn => $composableBuilder(
    column: $table.paidOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdOn => $composableBuilder(
    column: $table.createdOn,
    builder: (column) => ColumnOrderings(column),
  );

  $$RentRecordsTableOrderingComposer get rentRecordUuid {
    final $$RentRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rentRecordUuid,
      referencedTable: $db.rentRecords,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RentRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.rentRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get paidOn =>
      $composableBuilder(column: $table.paidOn, builder: (column) => column);

  GeneratedColumn<DateTime> get createdOn =>
      $composableBuilder(column: $table.createdOn, builder: (column) => column);

  $$RentRecordsTableAnnotationComposer get rentRecordUuid {
    final $$RentRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rentRecordUuid,
      referencedTable: $db.rentRecords,
      getReferencedColumn: (t) => t.uuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RentRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.rentRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          PaymentRow,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (PaymentRow, $$PaymentsTableReferences),
          PaymentRow,
          PrefetchHooks Function({bool rentRecordUuid})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<String> rentRecordUuid = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> paidOn = const Value.absent(),
                Value<DateTime> createdOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                uuid: uuid,
                rentRecordUuid: rentRecordUuid,
                amount: amount,
                paidOn: paidOn,
                createdOn: createdOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                required String rentRecordUuid,
                required int amount,
                required String paidOn,
                required DateTime createdOn,
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                uuid: uuid,
                rentRecordUuid: rentRecordUuid,
                amount: amount,
                paidOn: paidOn,
                createdOn: createdOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rentRecordUuid = false}) {
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
                    if (rentRecordUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.rentRecordUuid,
                                referencedTable: $$PaymentsTableReferences
                                    ._rentRecordUuidTable(db),
                                referencedColumn: $$PaymentsTableReferences
                                    ._rentRecordUuidTable(db)
                                    .uuid,
                              )
                              as T;
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

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      PaymentRow,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (PaymentRow, $$PaymentsTableReferences),
      PaymentRow,
      PrefetchHooks Function({bool rentRecordUuid})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TenantsTableTableManager get tenants =>
      $$TenantsTableTableManager(_db, _db.tenants);
  $$RentHistoriesTableTableManager get rentHistories =>
      $$RentHistoriesTableTableManager(_db, _db.rentHistories);
  $$RentRecordsTableTableManager get rentRecords =>
      $$RentRecordsTableTableManager(_db, _db.rentRecords);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
}
