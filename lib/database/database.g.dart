// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ContactsTable extends Contacts
    with TableInfo<$ContactsTable, ContactEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthdayMeta = const VerificationMeta(
    'birthday',
  );
  @override
  late final GeneratedColumn<DateTime> birthday = GeneratedColumn<DateTime>(
    'birthday',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _picturePathMeta = const VerificationMeta(
    'picturePath',
  );
  @override
  late final GeneratedColumn<String> picturePath = GeneratedColumn<String>(
    'picture_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firstName,
    lastName,
    address,
    birthday,
    latitude,
    longitude,
    phone,
    email,
    picturePath,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContactEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('birthday')) {
      context.handle(
        _birthdayMeta,
        birthday.isAcceptableOrUnknown(data['birthday']!, _birthdayMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('picture_path')) {
      context.handle(
        _picturePathMeta,
        picturePath.isAcceptableOrUnknown(
          data['picture_path']!,
          _picturePathMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContactEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      firstName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}first_name'],
          )!,
      lastName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}last_name'],
          )!,
      address:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}address'],
          )!,
      birthday: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birthday'],
      ),
      latitude:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}latitude'],
          )!,
      longitude:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}longitude'],
          )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      picturePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}picture_path'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class ContactEntry extends DataClass implements Insertable<ContactEntry> {
  final String id;
  final String firstName;
  final String lastName;
  final String address;
  final DateTime? birthday;
  final double latitude;
  final double longitude;
  final String? phone;
  final String? email;
  final String? picturePath;
  final String? notes;
  const ContactEntry({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    this.birthday,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.email,
    this.picturePath,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || birthday != null) {
      map['birthday'] = Variable<DateTime>(birthday);
    }
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || picturePath != null) {
      map['picture_path'] = Variable<String>(picturePath);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: Value(lastName),
      address: Value(address),
      birthday:
          birthday == null && nullToAbsent
              ? const Value.absent()
              : Value(birthday),
      latitude: Value(latitude),
      longitude: Value(longitude),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      picturePath:
          picturePath == null && nullToAbsent
              ? const Value.absent()
              : Value(picturePath),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory ContactEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactEntry(
      id: serializer.fromJson<String>(json['id']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      address: serializer.fromJson<String>(json['address']),
      birthday: serializer.fromJson<DateTime?>(json['birthday']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      picturePath: serializer.fromJson<String?>(json['picturePath']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'address': serializer.toJson<String>(address),
      'birthday': serializer.toJson<DateTime?>(birthday),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'picturePath': serializer.toJson<String?>(picturePath),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ContactEntry copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? address,
    Value<DateTime?> birthday = const Value.absent(),
    double? latitude,
    double? longitude,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> picturePath = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => ContactEntry(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    address: address ?? this.address,
    birthday: birthday.present ? birthday.value : this.birthday,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    picturePath: picturePath.present ? picturePath.value : this.picturePath,
    notes: notes.present ? notes.value : this.notes,
  );
  ContactEntry copyWithCompanion(ContactsCompanion data) {
    return ContactEntry(
      id: data.id.present ? data.id.value : this.id,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      address: data.address.present ? data.address.value : this.address,
      birthday: data.birthday.present ? data.birthday.value : this.birthday,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      picturePath:
          data.picturePath.present ? data.picturePath.value : this.picturePath,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactEntry(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('address: $address, ')
          ..write('birthday: $birthday, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('picturePath: $picturePath, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firstName,
    lastName,
    address,
    birthday,
    latitude,
    longitude,
    phone,
    email,
    picturePath,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactEntry &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.address == this.address &&
          other.birthday == this.birthday &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.picturePath == this.picturePath &&
          other.notes == this.notes);
}

class ContactsCompanion extends UpdateCompanion<ContactEntry> {
  final Value<String> id;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String> address;
  final Value<DateTime?> birthday;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> picturePath;
  final Value<String?> notes;
  final Value<int> rowid;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.address = const Value.absent(),
    this.birthday = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.picturePath = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    required String id,
    required String firstName,
    required String lastName,
    required String address,
    this.birthday = const Value.absent(),
    required double latitude,
    required double longitude,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.picturePath = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       firstName = Value(firstName),
       lastName = Value(lastName),
       address = Value(address),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<ContactEntry> custom({
    Expression<String>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? address,
    Expression<DateTime>? birthday,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? picturePath,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (address != null) 'address': address,
      if (birthday != null) 'birthday': birthday,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (picturePath != null) 'picture_path': picturePath,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith({
    Value<String>? id,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String>? address,
    Value<DateTime?>? birthday,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? picturePath,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return ContactsCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      birthday: birthday ?? this.birthday,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      picturePath: picturePath ?? this.picturePath,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (birthday.present) {
      map['birthday'] = Variable<DateTime>(birthday.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (picturePath.present) {
      map['picture_path'] = Variable<String>(picturePath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('address: $address, ')
          ..write('birthday: $birthday, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('picturePath: $picturePath, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MapInfoEntriesTable extends MapInfoEntries
    with TableInfo<$MapInfoEntriesTable, MapInfoEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MapInfoEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _downloadUrlMeta = const VerificationMeta(
    'downloadUrl',
  );
  @override
  late final GeneratedColumn<String> downloadUrl = GeneratedColumn<String>(
    'download_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isTemporaryMeta = const VerificationMeta(
    'isTemporary',
  );
  @override
  late final GeneratedColumn<bool> isTemporary = GeneratedColumn<bool>(
    'is_temporary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_temporary" IN (0, 1))',
    ),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoomLevelMeta = const VerificationMeta(
    'zoomLevel',
  );
  @override
  late final GeneratedColumn<int> zoomLevel = GeneratedColumn<int>(
    'zoom_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    name,
    filePath,
    downloadUrl,
    isTemporary,
    latitude,
    longitude,
    zoomLevel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'map_info_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MapInfoEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('download_url')) {
      context.handle(
        _downloadUrlMeta,
        downloadUrl.isAcceptableOrUnknown(
          data['download_url']!,
          _downloadUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadUrlMeta);
    }
    if (data.containsKey('is_temporary')) {
      context.handle(
        _isTemporaryMeta,
        isTemporary.isAcceptableOrUnknown(
          data['is_temporary']!,
          _isTemporaryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isTemporaryMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('zoom_level')) {
      context.handle(
        _zoomLevelMeta,
        zoomLevel.isAcceptableOrUnknown(data['zoom_level']!, _zoomLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_zoomLevelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  MapInfoEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MapInfoEntry(
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      filePath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_path'],
          )!,
      downloadUrl:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}download_url'],
          )!,
      isTemporary:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}is_temporary'],
          )!,
      latitude:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}latitude'],
          )!,
      longitude:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}longitude'],
          )!,
      zoomLevel:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}zoom_level'],
          )!,
    );
  }

  @override
  $MapInfoEntriesTable createAlias(String alias) {
    return $MapInfoEntriesTable(attachedDatabase, alias);
  }
}

class MapInfoEntry extends DataClass implements Insertable<MapInfoEntry> {
  final String name;
  final String filePath;
  final String downloadUrl;
  final bool isTemporary;
  final double latitude;
  final double longitude;
  final int zoomLevel;
  const MapInfoEntry({
    required this.name,
    required this.filePath,
    required this.downloadUrl,
    required this.isTemporary,
    required this.latitude,
    required this.longitude,
    required this.zoomLevel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['file_path'] = Variable<String>(filePath);
    map['download_url'] = Variable<String>(downloadUrl);
    map['is_temporary'] = Variable<bool>(isTemporary);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['zoom_level'] = Variable<int>(zoomLevel);
    return map;
  }

  MapInfoEntriesCompanion toCompanion(bool nullToAbsent) {
    return MapInfoEntriesCompanion(
      name: Value(name),
      filePath: Value(filePath),
      downloadUrl: Value(downloadUrl),
      isTemporary: Value(isTemporary),
      latitude: Value(latitude),
      longitude: Value(longitude),
      zoomLevel: Value(zoomLevel),
    );
  }

  factory MapInfoEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MapInfoEntry(
      name: serializer.fromJson<String>(json['name']),
      filePath: serializer.fromJson<String>(json['filePath']),
      downloadUrl: serializer.fromJson<String>(json['downloadUrl']),
      isTemporary: serializer.fromJson<bool>(json['isTemporary']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      zoomLevel: serializer.fromJson<int>(json['zoomLevel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'filePath': serializer.toJson<String>(filePath),
      'downloadUrl': serializer.toJson<String>(downloadUrl),
      'isTemporary': serializer.toJson<bool>(isTemporary),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'zoomLevel': serializer.toJson<int>(zoomLevel),
    };
  }

  MapInfoEntry copyWith({
    String? name,
    String? filePath,
    String? downloadUrl,
    bool? isTemporary,
    double? latitude,
    double? longitude,
    int? zoomLevel,
  }) => MapInfoEntry(
    name: name ?? this.name,
    filePath: filePath ?? this.filePath,
    downloadUrl: downloadUrl ?? this.downloadUrl,
    isTemporary: isTemporary ?? this.isTemporary,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    zoomLevel: zoomLevel ?? this.zoomLevel,
  );
  MapInfoEntry copyWithCompanion(MapInfoEntriesCompanion data) {
    return MapInfoEntry(
      name: data.name.present ? data.name.value : this.name,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      downloadUrl:
          data.downloadUrl.present ? data.downloadUrl.value : this.downloadUrl,
      isTemporary:
          data.isTemporary.present ? data.isTemporary.value : this.isTemporary,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      zoomLevel: data.zoomLevel.present ? data.zoomLevel.value : this.zoomLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MapInfoEntry(')
          ..write('name: $name, ')
          ..write('filePath: $filePath, ')
          ..write('downloadUrl: $downloadUrl, ')
          ..write('isTemporary: $isTemporary, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('zoomLevel: $zoomLevel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    name,
    filePath,
    downloadUrl,
    isTemporary,
    latitude,
    longitude,
    zoomLevel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapInfoEntry &&
          other.name == this.name &&
          other.filePath == this.filePath &&
          other.downloadUrl == this.downloadUrl &&
          other.isTemporary == this.isTemporary &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.zoomLevel == this.zoomLevel);
}

class MapInfoEntriesCompanion extends UpdateCompanion<MapInfoEntry> {
  final Value<String> name;
  final Value<String> filePath;
  final Value<String> downloadUrl;
  final Value<bool> isTemporary;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<int> zoomLevel;
  final Value<int> rowid;
  const MapInfoEntriesCompanion({
    this.name = const Value.absent(),
    this.filePath = const Value.absent(),
    this.downloadUrl = const Value.absent(),
    this.isTemporary = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.zoomLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MapInfoEntriesCompanion.insert({
    required String name,
    required String filePath,
    required String downloadUrl,
    required bool isTemporary,
    required double latitude,
    required double longitude,
    required int zoomLevel,
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       filePath = Value(filePath),
       downloadUrl = Value(downloadUrl),
       isTemporary = Value(isTemporary),
       latitude = Value(latitude),
       longitude = Value(longitude),
       zoomLevel = Value(zoomLevel);
  static Insertable<MapInfoEntry> custom({
    Expression<String>? name,
    Expression<String>? filePath,
    Expression<String>? downloadUrl,
    Expression<bool>? isTemporary,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? zoomLevel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (filePath != null) 'file_path': filePath,
      if (downloadUrl != null) 'download_url': downloadUrl,
      if (isTemporary != null) 'is_temporary': isTemporary,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (zoomLevel != null) 'zoom_level': zoomLevel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MapInfoEntriesCompanion copyWith({
    Value<String>? name,
    Value<String>? filePath,
    Value<String>? downloadUrl,
    Value<bool>? isTemporary,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<int>? zoomLevel,
    Value<int>? rowid,
  }) {
    return MapInfoEntriesCompanion(
      name: name ?? this.name,
      filePath: filePath ?? this.filePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      isTemporary: isTemporary ?? this.isTemporary,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (downloadUrl.present) {
      map['download_url'] = Variable<String>(downloadUrl.value);
    }
    if (isTemporary.present) {
      map['is_temporary'] = Variable<bool>(isTemporary.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (zoomLevel.present) {
      map['zoom_level'] = Variable<int>(zoomLevel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MapInfoEntriesCompanion(')
          ..write('name: $name, ')
          ..write('filePath: $filePath, ')
          ..write('downloadUrl: $downloadUrl, ')
          ..write('isTemporary: $isTemporary, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('zoomLevel: $zoomLevel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GospelProfilesTable extends GospelProfiles
    with TableInfo<$GospelProfilesTable, GospelProfileEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GospelProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _naturalBirthdayMeta = const VerificationMeta(
    'naturalBirthday',
  );
  @override
  late final GeneratedColumn<DateTime> naturalBirthday =
      GeneratedColumn<DateTime>(
        'natural_birthday',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spiritualBirthdayMeta = const VerificationMeta(
    'spiritualBirthday',
  );
  @override
  late final GeneratedColumn<DateTime> spiritualBirthday =
      GeneratedColumn<DateTime>(
        'spiritual_birthday',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    firstName,
    lastName,
    address,
    naturalBirthday,
    phone,
    email,
    spiritualBirthday,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gospel_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<GospelProfileEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('natural_birthday')) {
      context.handle(
        _naturalBirthdayMeta,
        naturalBirthday.isAcceptableOrUnknown(
          data['natural_birthday']!,
          _naturalBirthdayMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('spiritual_birthday')) {
      context.handle(
        _spiritualBirthdayMeta,
        spiritualBirthday.isAcceptableOrUnknown(
          data['spiritual_birthday']!,
          _spiritualBirthdayMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {email};
  @override
  GospelProfileEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GospelProfileEntry(
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      ),
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      naturalBirthday: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}natural_birthday'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      spiritualBirthday: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}spiritual_birthday'],
      ),
    );
  }

  @override
  $GospelProfilesTable createAlias(String alias) {
    return $GospelProfilesTable(attachedDatabase, alias);
  }
}

class GospelProfileEntry extends DataClass
    implements Insertable<GospelProfileEntry> {
  final String? firstName;
  final String? lastName;
  final String? address;
  final DateTime? naturalBirthday;
  final String? phone;
  final String? email;
  final DateTime? spiritualBirthday;
  const GospelProfileEntry({
    this.firstName,
    this.lastName,
    this.address,
    this.naturalBirthday,
    this.phone,
    this.email,
    this.spiritualBirthday,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || firstName != null) {
      map['first_name'] = Variable<String>(firstName);
    }
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || naturalBirthday != null) {
      map['natural_birthday'] = Variable<DateTime>(naturalBirthday);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || spiritualBirthday != null) {
      map['spiritual_birthday'] = Variable<DateTime>(spiritualBirthday);
    }
    return map;
  }

  GospelProfilesCompanion toCompanion(bool nullToAbsent) {
    return GospelProfilesCompanion(
      firstName:
          firstName == null && nullToAbsent
              ? const Value.absent()
              : Value(firstName),
      lastName:
          lastName == null && nullToAbsent
              ? const Value.absent()
              : Value(lastName),
      address:
          address == null && nullToAbsent
              ? const Value.absent()
              : Value(address),
      naturalBirthday:
          naturalBirthday == null && nullToAbsent
              ? const Value.absent()
              : Value(naturalBirthday),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      spiritualBirthday:
          spiritualBirthday == null && nullToAbsent
              ? const Value.absent()
              : Value(spiritualBirthday),
    );
  }

  factory GospelProfileEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GospelProfileEntry(
      firstName: serializer.fromJson<String?>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      address: serializer.fromJson<String?>(json['address']),
      naturalBirthday: serializer.fromJson<DateTime?>(json['naturalBirthday']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      spiritualBirthday: serializer.fromJson<DateTime?>(
        json['spiritualBirthday'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'firstName': serializer.toJson<String?>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'address': serializer.toJson<String?>(address),
      'naturalBirthday': serializer.toJson<DateTime?>(naturalBirthday),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'spiritualBirthday': serializer.toJson<DateTime?>(spiritualBirthday),
    };
  }

  GospelProfileEntry copyWith({
    Value<String?> firstName = const Value.absent(),
    Value<String?> lastName = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<DateTime?> naturalBirthday = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<DateTime?> spiritualBirthday = const Value.absent(),
  }) => GospelProfileEntry(
    firstName: firstName.present ? firstName.value : this.firstName,
    lastName: lastName.present ? lastName.value : this.lastName,
    address: address.present ? address.value : this.address,
    naturalBirthday:
        naturalBirthday.present ? naturalBirthday.value : this.naturalBirthday,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    spiritualBirthday:
        spiritualBirthday.present
            ? spiritualBirthday.value
            : this.spiritualBirthday,
  );
  GospelProfileEntry copyWithCompanion(GospelProfilesCompanion data) {
    return GospelProfileEntry(
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      address: data.address.present ? data.address.value : this.address,
      naturalBirthday:
          data.naturalBirthday.present
              ? data.naturalBirthday.value
              : this.naturalBirthday,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      spiritualBirthday:
          data.spiritualBirthday.present
              ? data.spiritualBirthday.value
              : this.spiritualBirthday,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GospelProfileEntry(')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('address: $address, ')
          ..write('naturalBirthday: $naturalBirthday, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('spiritualBirthday: $spiritualBirthday')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    firstName,
    lastName,
    address,
    naturalBirthday,
    phone,
    email,
    spiritualBirthday,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GospelProfileEntry &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.address == this.address &&
          other.naturalBirthday == this.naturalBirthday &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.spiritualBirthday == this.spiritualBirthday);
}

class GospelProfilesCompanion extends UpdateCompanion<GospelProfileEntry> {
  final Value<String?> firstName;
  final Value<String?> lastName;
  final Value<String?> address;
  final Value<DateTime?> naturalBirthday;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<DateTime?> spiritualBirthday;
  final Value<int> rowid;
  const GospelProfilesCompanion({
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.address = const Value.absent(),
    this.naturalBirthday = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.spiritualBirthday = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GospelProfilesCompanion.insert({
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.address = const Value.absent(),
    this.naturalBirthday = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.spiritualBirthday = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<GospelProfileEntry> custom({
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? address,
    Expression<DateTime>? naturalBirthday,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<DateTime>? spiritualBirthday,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (address != null) 'address': address,
      if (naturalBirthday != null) 'natural_birthday': naturalBirthday,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (spiritualBirthday != null) 'spiritual_birthday': spiritualBirthday,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GospelProfilesCompanion copyWith({
    Value<String?>? firstName,
    Value<String?>? lastName,
    Value<String?>? address,
    Value<DateTime?>? naturalBirthday,
    Value<String?>? phone,
    Value<String?>? email,
    Value<DateTime?>? spiritualBirthday,
    Value<int>? rowid,
  }) {
    return GospelProfilesCompanion(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      naturalBirthday: naturalBirthday ?? this.naturalBirthday,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      spiritualBirthday: spiritualBirthday ?? this.spiritualBirthday,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (naturalBirthday.present) {
      map['natural_birthday'] = Variable<DateTime>(naturalBirthday.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (spiritualBirthday.present) {
      map['spiritual_birthday'] = Variable<DateTime>(spiritualBirthday.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GospelProfilesCompanion(')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('address: $address, ')
          ..write('naturalBirthday: $naturalBirthday, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('spiritualBirthday: $spiritualBirthday, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrayersTable extends Prayers with TableInfo<$PrayersTable, PrayerEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _richTextJsonMeta = const VerificationMeta(
    'richTextJson',
  );
  @override
  late final GeneratedColumn<String> richTextJson = GeneratedColumn<String>(
    'rich_text_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, richTextJson, status, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayers';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('rich_text_json')) {
      context.handle(
        _richTextJsonMeta,
        richTextJson.isAcceptableOrUnknown(
          data['rich_text_json']!,
          _richTextJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_richTextJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrayerEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      richTextJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}rich_text_json'],
          )!,
      status:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}status'],
          )!,
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}timestamp'],
          )!,
    );
  }

  @override
  $PrayersTable createAlias(String alias) {
    return $PrayersTable(attachedDatabase, alias);
  }
}

class PrayerEntry extends DataClass implements Insertable<PrayerEntry> {
  final String id;
  final String richTextJson;
  final String status;
  final DateTime timestamp;
  const PrayerEntry({
    required this.id,
    required this.richTextJson,
    required this.status,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['rich_text_json'] = Variable<String>(richTextJson);
    map['status'] = Variable<String>(status);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  PrayersCompanion toCompanion(bool nullToAbsent) {
    return PrayersCompanion(
      id: Value(id),
      richTextJson: Value(richTextJson),
      status: Value(status),
      timestamp: Value(timestamp),
    );
  }

  factory PrayerEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerEntry(
      id: serializer.fromJson<String>(json['id']),
      richTextJson: serializer.fromJson<String>(json['richTextJson']),
      status: serializer.fromJson<String>(json['status']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'richTextJson': serializer.toJson<String>(richTextJson),
      'status': serializer.toJson<String>(status),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  PrayerEntry copyWith({
    String? id,
    String? richTextJson,
    String? status,
    DateTime? timestamp,
  }) => PrayerEntry(
    id: id ?? this.id,
    richTextJson: richTextJson ?? this.richTextJson,
    status: status ?? this.status,
    timestamp: timestamp ?? this.timestamp,
  );
  PrayerEntry copyWithCompanion(PrayersCompanion data) {
    return PrayerEntry(
      id: data.id.present ? data.id.value : this.id,
      richTextJson:
          data.richTextJson.present
              ? data.richTextJson.value
              : this.richTextJson,
      status: data.status.present ? data.status.value : this.status,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerEntry(')
          ..write('id: $id, ')
          ..write('richTextJson: $richTextJson, ')
          ..write('status: $status, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, richTextJson, status, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerEntry &&
          other.id == this.id &&
          other.richTextJson == this.richTextJson &&
          other.status == this.status &&
          other.timestamp == this.timestamp);
}

class PrayersCompanion extends UpdateCompanion<PrayerEntry> {
  final Value<String> id;
  final Value<String> richTextJson;
  final Value<String> status;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const PrayersCompanion({
    this.id = const Value.absent(),
    this.richTextJson = const Value.absent(),
    this.status = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrayersCompanion.insert({
    required String id,
    required String richTextJson,
    required String status,
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       richTextJson = Value(richTextJson),
       status = Value(status),
       timestamp = Value(timestamp);
  static Insertable<PrayerEntry> custom({
    Expression<String>? id,
    Expression<String>? richTextJson,
    Expression<String>? status,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (richTextJson != null) 'rich_text_json': richTextJson,
      if (status != null) 'status': status,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrayersCompanion copyWith({
    Value<String>? id,
    Value<String>? richTextJson,
    Value<String>? status,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return PrayersCompanion(
      id: id ?? this.id,
      richTextJson: richTextJson ?? this.richTextJson,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (richTextJson.present) {
      map['rich_text_json'] = Variable<String>(richTextJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayersCompanion(')
          ..write('id: $id, ')
          ..write('richTextJson: $richTextJson, ')
          ..write('status: $status, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VerseDataEntriesTable extends VerseDataEntries
    with TableInfo<$VerseDataEntriesTable, VerseDataEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VerseDataEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookNameMeta = const VerificationMeta(
    'bookName',
  );
  @override
  late final GeneratedColumn<String> bookName = GeneratedColumn<String>(
    'book_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<int> verse = GeneratedColumn<int>(
    'verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseTextContentMeta = const VerificationMeta(
    'verseTextContent',
  );
  @override
  late final GeneratedColumn<String> verseTextContent = GeneratedColumn<String>(
    'verse_text_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    bookName,
    chapter,
    verse,
    verseTextContent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verse_data_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<VerseDataEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_name')) {
      context.handle(
        _bookNameMeta,
        bookName.isAcceptableOrUnknown(data['book_name']!, _bookNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bookNameMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse')) {
      context.handle(
        _verseMeta,
        verse.isAcceptableOrUnknown(data['verse']!, _verseMeta),
      );
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('verse_text_content')) {
      context.handle(
        _verseTextContentMeta,
        verseTextContent.isAcceptableOrUnknown(
          data['verse_text_content']!,
          _verseTextContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verseTextContentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookName, chapter, verse};
  @override
  VerseDataEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VerseDataEntry(
      bookName:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}book_name'],
          )!,
      chapter:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}chapter'],
          )!,
      verse:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}verse'],
          )!,
      verseTextContent:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}verse_text_content'],
          )!,
    );
  }

  @override
  $VerseDataEntriesTable createAlias(String alias) {
    return $VerseDataEntriesTable(attachedDatabase, alias);
  }
}

class VerseDataEntry extends DataClass implements Insertable<VerseDataEntry> {
  final String bookName;
  final int chapter;
  final int verse;
  final String verseTextContent;
  const VerseDataEntry({
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.verseTextContent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_name'] = Variable<String>(bookName);
    map['chapter'] = Variable<int>(chapter);
    map['verse'] = Variable<int>(verse);
    map['verse_text_content'] = Variable<String>(verseTextContent);
    return map;
  }

  VerseDataEntriesCompanion toCompanion(bool nullToAbsent) {
    return VerseDataEntriesCompanion(
      bookName: Value(bookName),
      chapter: Value(chapter),
      verse: Value(verse),
      verseTextContent: Value(verseTextContent),
    );
  }

  factory VerseDataEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VerseDataEntry(
      bookName: serializer.fromJson<String>(json['bookName']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verse: serializer.fromJson<int>(json['verse']),
      verseTextContent: serializer.fromJson<String>(json['verseTextContent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookName': serializer.toJson<String>(bookName),
      'chapter': serializer.toJson<int>(chapter),
      'verse': serializer.toJson<int>(verse),
      'verseTextContent': serializer.toJson<String>(verseTextContent),
    };
  }

  VerseDataEntry copyWith({
    String? bookName,
    int? chapter,
    int? verse,
    String? verseTextContent,
  }) => VerseDataEntry(
    bookName: bookName ?? this.bookName,
    chapter: chapter ?? this.chapter,
    verse: verse ?? this.verse,
    verseTextContent: verseTextContent ?? this.verseTextContent,
  );
  VerseDataEntry copyWithCompanion(VerseDataEntriesCompanion data) {
    return VerseDataEntry(
      bookName: data.bookName.present ? data.bookName.value : this.bookName,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verse: data.verse.present ? data.verse.value : this.verse,
      verseTextContent:
          data.verseTextContent.present
              ? data.verseTextContent.value
              : this.verseTextContent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VerseDataEntry(')
          ..write('bookName: $bookName, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('verseTextContent: $verseTextContent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookName, chapter, verse, verseTextContent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VerseDataEntry &&
          other.bookName == this.bookName &&
          other.chapter == this.chapter &&
          other.verse == this.verse &&
          other.verseTextContent == this.verseTextContent);
}

class VerseDataEntriesCompanion extends UpdateCompanion<VerseDataEntry> {
  final Value<String> bookName;
  final Value<int> chapter;
  final Value<int> verse;
  final Value<String> verseTextContent;
  final Value<int> rowid;
  const VerseDataEntriesCompanion({
    this.bookName = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verse = const Value.absent(),
    this.verseTextContent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VerseDataEntriesCompanion.insert({
    required String bookName,
    required int chapter,
    required int verse,
    required String verseTextContent,
    this.rowid = const Value.absent(),
  }) : bookName = Value(bookName),
       chapter = Value(chapter),
       verse = Value(verse),
       verseTextContent = Value(verseTextContent);
  static Insertable<VerseDataEntry> custom({
    Expression<String>? bookName,
    Expression<int>? chapter,
    Expression<int>? verse,
    Expression<String>? verseTextContent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookName != null) 'book_name': bookName,
      if (chapter != null) 'chapter': chapter,
      if (verse != null) 'verse': verse,
      if (verseTextContent != null) 'verse_text_content': verseTextContent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VerseDataEntriesCompanion copyWith({
    Value<String>? bookName,
    Value<int>? chapter,
    Value<int>? verse,
    Value<String>? verseTextContent,
    Value<int>? rowid,
  }) {
    return VerseDataEntriesCompanion(
      bookName: bookName ?? this.bookName,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      verseTextContent: verseTextContent ?? this.verseTextContent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookName.present) {
      map['book_name'] = Variable<String>(bookName.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verse.present) {
      map['verse'] = Variable<int>(verse.value);
    }
    if (verseTextContent.present) {
      map['verse_text_content'] = Variable<String>(verseTextContent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VerseDataEntriesCompanion(')
          ..write('bookName: $bookName, ')
          ..write('chapter: $chapter, ')
          ..write('verse: $verse, ')
          ..write('verseTextContent: $verseTextContent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, BookmarkEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _verseBookMeta = const VerificationMeta(
    'verseBook',
  );
  @override
  late final GeneratedColumn<String> verseBook = GeneratedColumn<String>(
    'verse_book',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseChapterMeta = const VerificationMeta(
    'verseChapter',
  );
  @override
  late final GeneratedColumn<int> verseChapter = GeneratedColumn<int>(
    'verse_chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseVerseMeta = const VerificationMeta(
    'verseVerse',
  );
  @override
  late final GeneratedColumn<int> verseVerse = GeneratedColumn<int>(
    'verse_verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    verseBook,
    verseChapter,
    verseVerse,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('verse_book')) {
      context.handle(
        _verseBookMeta,
        verseBook.isAcceptableOrUnknown(data['verse_book']!, _verseBookMeta),
      );
    } else if (isInserting) {
      context.missing(_verseBookMeta);
    }
    if (data.containsKey('verse_chapter')) {
      context.handle(
        _verseChapterMeta,
        verseChapter.isAcceptableOrUnknown(
          data['verse_chapter']!,
          _verseChapterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verseChapterMeta);
    }
    if (data.containsKey('verse_verse')) {
      context.handle(
        _verseVerseMeta,
        verseVerse.isAcceptableOrUnknown(data['verse_verse']!, _verseVerseMeta),
      );
    } else if (isInserting) {
      context.missing(_verseVerseMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {verseBook, verseChapter, verseVerse};
  @override
  BookmarkEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkEntry(
      verseBook:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}verse_book'],
          )!,
      verseChapter:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}verse_chapter'],
          )!,
      verseVerse:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}verse_verse'],
          )!,
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}timestamp'],
          )!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }
}

class BookmarkEntry extends DataClass implements Insertable<BookmarkEntry> {
  final String verseBook;
  final int verseChapter;
  final int verseVerse;
  final DateTime timestamp;
  const BookmarkEntry({
    required this.verseBook,
    required this.verseChapter,
    required this.verseVerse,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['verse_book'] = Variable<String>(verseBook);
    map['verse_chapter'] = Variable<int>(verseChapter);
    map['verse_verse'] = Variable<int>(verseVerse);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      verseBook: Value(verseBook),
      verseChapter: Value(verseChapter),
      verseVerse: Value(verseVerse),
      timestamp: Value(timestamp),
    );
  }

  factory BookmarkEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkEntry(
      verseBook: serializer.fromJson<String>(json['verseBook']),
      verseChapter: serializer.fromJson<int>(json['verseChapter']),
      verseVerse: serializer.fromJson<int>(json['verseVerse']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'verseBook': serializer.toJson<String>(verseBook),
      'verseChapter': serializer.toJson<int>(verseChapter),
      'verseVerse': serializer.toJson<int>(verseVerse),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  BookmarkEntry copyWith({
    String? verseBook,
    int? verseChapter,
    int? verseVerse,
    DateTime? timestamp,
  }) => BookmarkEntry(
    verseBook: verseBook ?? this.verseBook,
    verseChapter: verseChapter ?? this.verseChapter,
    verseVerse: verseVerse ?? this.verseVerse,
    timestamp: timestamp ?? this.timestamp,
  );
  BookmarkEntry copyWithCompanion(BookmarksCompanion data) {
    return BookmarkEntry(
      verseBook: data.verseBook.present ? data.verseBook.value : this.verseBook,
      verseChapter:
          data.verseChapter.present
              ? data.verseChapter.value
              : this.verseChapter,
      verseVerse:
          data.verseVerse.present ? data.verseVerse.value : this.verseVerse,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkEntry(')
          ..write('verseBook: $verseBook, ')
          ..write('verseChapter: $verseChapter, ')
          ..write('verseVerse: $verseVerse, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(verseBook, verseChapter, verseVerse, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkEntry &&
          other.verseBook == this.verseBook &&
          other.verseChapter == this.verseChapter &&
          other.verseVerse == this.verseVerse &&
          other.timestamp == this.timestamp);
}

class BookmarksCompanion extends UpdateCompanion<BookmarkEntry> {
  final Value<String> verseBook;
  final Value<int> verseChapter;
  final Value<int> verseVerse;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.verseBook = const Value.absent(),
    this.verseChapter = const Value.absent(),
    this.verseVerse = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String verseBook,
    required int verseChapter,
    required int verseVerse,
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  }) : verseBook = Value(verseBook),
       verseChapter = Value(verseChapter),
       verseVerse = Value(verseVerse),
       timestamp = Value(timestamp);
  static Insertable<BookmarkEntry> custom({
    Expression<String>? verseBook,
    Expression<int>? verseChapter,
    Expression<int>? verseVerse,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (verseBook != null) 'verse_book': verseBook,
      if (verseChapter != null) 'verse_chapter': verseChapter,
      if (verseVerse != null) 'verse_verse': verseVerse,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith({
    Value<String>? verseBook,
    Value<int>? verseChapter,
    Value<int>? verseVerse,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return BookmarksCompanion(
      verseBook: verseBook ?? this.verseBook,
      verseChapter: verseChapter ?? this.verseChapter,
      verseVerse: verseVerse ?? this.verseVerse,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (verseBook.present) {
      map['verse_book'] = Variable<String>(verseBook.value);
    }
    if (verseChapter.present) {
      map['verse_chapter'] = Variable<int>(verseChapter.value);
    }
    if (verseVerse.present) {
      map['verse_verse'] = Variable<int>(verseVerse.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('verseBook: $verseBook, ')
          ..write('verseChapter: $verseChapter, ')
          ..write('verseVerse: $verseVerse, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, FavoriteEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _verseBookMeta = const VerificationMeta(
    'verseBook',
  );
  @override
  late final GeneratedColumn<String> verseBook = GeneratedColumn<String>(
    'verse_book',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseChapterMeta = const VerificationMeta(
    'verseChapter',
  );
  @override
  late final GeneratedColumn<int> verseChapter = GeneratedColumn<int>(
    'verse_chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseVerseMeta = const VerificationMeta(
    'verseVerse',
  );
  @override
  late final GeneratedColumn<int> verseVerse = GeneratedColumn<int>(
    'verse_verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    verseBook,
    verseChapter,
    verseVerse,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('verse_book')) {
      context.handle(
        _verseBookMeta,
        verseBook.isAcceptableOrUnknown(data['verse_book']!, _verseBookMeta),
      );
    } else if (isInserting) {
      context.missing(_verseBookMeta);
    }
    if (data.containsKey('verse_chapter')) {
      context.handle(
        _verseChapterMeta,
        verseChapter.isAcceptableOrUnknown(
          data['verse_chapter']!,
          _verseChapterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verseChapterMeta);
    }
    if (data.containsKey('verse_verse')) {
      context.handle(
        _verseVerseMeta,
        verseVerse.isAcceptableOrUnknown(data['verse_verse']!, _verseVerseMeta),
      );
    } else if (isInserting) {
      context.missing(_verseVerseMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {verseBook, verseChapter, verseVerse};
  @override
  FavoriteEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteEntry(
      verseBook:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}verse_book'],
          )!,
      verseChapter:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}verse_chapter'],
          )!,
      verseVerse:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}verse_verse'],
          )!,
      timestamp:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}timestamp'],
          )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteEntry extends DataClass implements Insertable<FavoriteEntry> {
  final String verseBook;
  final int verseChapter;
  final int verseVerse;
  final DateTime timestamp;
  const FavoriteEntry({
    required this.verseBook,
    required this.verseChapter,
    required this.verseVerse,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['verse_book'] = Variable<String>(verseBook);
    map['verse_chapter'] = Variable<int>(verseChapter);
    map['verse_verse'] = Variable<int>(verseVerse);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      verseBook: Value(verseBook),
      verseChapter: Value(verseChapter),
      verseVerse: Value(verseVerse),
      timestamp: Value(timestamp),
    );
  }

  factory FavoriteEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteEntry(
      verseBook: serializer.fromJson<String>(json['verseBook']),
      verseChapter: serializer.fromJson<int>(json['verseChapter']),
      verseVerse: serializer.fromJson<int>(json['verseVerse']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'verseBook': serializer.toJson<String>(verseBook),
      'verseChapter': serializer.toJson<int>(verseChapter),
      'verseVerse': serializer.toJson<int>(verseVerse),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  FavoriteEntry copyWith({
    String? verseBook,
    int? verseChapter,
    int? verseVerse,
    DateTime? timestamp,
  }) => FavoriteEntry(
    verseBook: verseBook ?? this.verseBook,
    verseChapter: verseChapter ?? this.verseChapter,
    verseVerse: verseVerse ?? this.verseVerse,
    timestamp: timestamp ?? this.timestamp,
  );
  FavoriteEntry copyWithCompanion(FavoritesCompanion data) {
    return FavoriteEntry(
      verseBook: data.verseBook.present ? data.verseBook.value : this.verseBook,
      verseChapter:
          data.verseChapter.present
              ? data.verseChapter.value
              : this.verseChapter,
      verseVerse:
          data.verseVerse.present ? data.verseVerse.value : this.verseVerse,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteEntry(')
          ..write('verseBook: $verseBook, ')
          ..write('verseChapter: $verseChapter, ')
          ..write('verseVerse: $verseVerse, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(verseBook, verseChapter, verseVerse, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteEntry &&
          other.verseBook == this.verseBook &&
          other.verseChapter == this.verseChapter &&
          other.verseVerse == this.verseVerse &&
          other.timestamp == this.timestamp);
}

class FavoritesCompanion extends UpdateCompanion<FavoriteEntry> {
  final Value<String> verseBook;
  final Value<int> verseChapter;
  final Value<int> verseVerse;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.verseBook = const Value.absent(),
    this.verseChapter = const Value.absent(),
    this.verseVerse = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String verseBook,
    required int verseChapter,
    required int verseVerse,
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  }) : verseBook = Value(verseBook),
       verseChapter = Value(verseChapter),
       verseVerse = Value(verseVerse),
       timestamp = Value(timestamp);
  static Insertable<FavoriteEntry> custom({
    Expression<String>? verseBook,
    Expression<int>? verseChapter,
    Expression<int>? verseVerse,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (verseBook != null) 'verse_book': verseBook,
      if (verseChapter != null) 'verse_chapter': verseChapter,
      if (verseVerse != null) 'verse_verse': verseVerse,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith({
    Value<String>? verseBook,
    Value<int>? verseChapter,
    Value<int>? verseVerse,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return FavoritesCompanion(
      verseBook: verseBook ?? this.verseBook,
      verseChapter: verseChapter ?? this.verseChapter,
      verseVerse: verseVerse ?? this.verseVerse,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (verseBook.present) {
      map['verse_book'] = Variable<String>(verseBook.value);
    }
    if (verseChapter.present) {
      map['verse_chapter'] = Variable<int>(verseChapter.value);
    }
    if (verseVerse.present) {
      map['verse_verse'] = Variable<int>(verseVerse.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('verseBook: $verseBook, ')
          ..write('verseChapter: $verseChapter, ')
          ..write('verseVerse: $verseVerse, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingsEntry> {
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
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSelectedBookMeta = const VerificationMeta(
    'lastSelectedBook',
  );
  @override
  late final GeneratedColumn<String> lastSelectedBook = GeneratedColumn<String>(
    'last_selected_book',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSelectedChapterMeta =
      const VerificationMeta('lastSelectedChapter');
  @override
  late final GeneratedColumn<int> lastSelectedChapter = GeneratedColumn<int>(
    'last_selected_chapter',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSelectedStudyBookMeta =
      const VerificationMeta('lastSelectedStudyBook');
  @override
  late final GeneratedColumn<String> lastSelectedStudyBook =
      GeneratedColumn<String>(
        'last_selected_study_book',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSelectedStudyChapterMeta =
      const VerificationMeta('lastSelectedStudyChapter');
  @override
  late final GeneratedColumn<int> lastSelectedStudyChapter =
      GeneratedColumn<int>(
        'last_selected_study_chapter',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSelectedMapNameMeta =
      const VerificationMeta('lastSelectedMapName');
  @override
  late final GeneratedColumn<String> lastSelectedMapName =
      GeneratedColumn<String>(
        'last_selected_map_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _selectedStudyFontMeta = const VerificationMeta(
    'selectedStudyFont',
  );
  @override
  late final GeneratedColumn<String> selectedStudyFont =
      GeneratedColumn<String>(
        'selected_study_font',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _selectedStudyFontSizeMeta =
      const VerificationMeta('selectedStudyFontSize');
  @override
  late final GeneratedColumn<double> selectedStudyFontSize =
      GeneratedColumn<double>(
        'selected_study_font_size',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _selectedFontMeta = const VerificationMeta(
    'selectedFont',
  );
  @override
  late final GeneratedColumn<String> selectedFont = GeneratedColumn<String>(
    'selected_font',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedFontSizeMeta = const VerificationMeta(
    'selectedFontSize',
  );
  @override
  late final GeneratedColumn<double> selectedFontSize = GeneratedColumn<double>(
    'selected_font_size',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAutoScrollingEnabledMeta =
      const VerificationMeta('isAutoScrollingEnabled');
  @override
  late final GeneratedColumn<bool> isAutoScrollingEnabled =
      GeneratedColumn<bool>(
        'is_auto_scrolling_enabled',
        aliasedName,
        true,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_auto_scrolling_enabled" IN (0, 1))',
        ),
      );
  static const VerificationMeta _autoScrollModeMeta = const VerificationMeta(
    'autoScrollMode',
  );
  @override
  late final GeneratedColumn<String> autoScrollMode = GeneratedColumn<String>(
    'auto_scroll_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastBibleNoteMeta = const VerificationMeta(
    'lastBibleNote',
  );
  @override
  late final GeneratedColumn<String> lastBibleNote = GeneratedColumn<String>(
    'last_bible_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPersonalNoteMeta = const VerificationMeta(
    'lastPersonalNote',
  );
  @override
  late final GeneratedColumn<String> lastPersonalNote = GeneratedColumn<String>(
    'last_personal_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastStudyNoteMeta = const VerificationMeta(
    'lastStudyNote',
  );
  @override
  late final GeneratedColumn<String> lastStudyNote = GeneratedColumn<String>(
    'last_study_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSearchMeta = const VerificationMeta(
    'lastSearch',
  );
  @override
  late final GeneratedColumn<String> lastSearch = GeneratedColumn<String>(
    'last_search',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    theme,
    lastSelectedBook,
    lastSelectedChapter,
    lastSelectedStudyBook,
    lastSelectedStudyChapter,
    lastSelectedMapName,
    selectedStudyFont,
    selectedStudyFontSize,
    selectedFont,
    selectedFontSize,
    isAutoScrollingEnabled,
    autoScrollMode,
    lastBibleNote,
    lastPersonalNote,
    lastStudyNote,
    lastSearch,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('last_selected_book')) {
      context.handle(
        _lastSelectedBookMeta,
        lastSelectedBook.isAcceptableOrUnknown(
          data['last_selected_book']!,
          _lastSelectedBookMeta,
        ),
      );
    }
    if (data.containsKey('last_selected_chapter')) {
      context.handle(
        _lastSelectedChapterMeta,
        lastSelectedChapter.isAcceptableOrUnknown(
          data['last_selected_chapter']!,
          _lastSelectedChapterMeta,
        ),
      );
    }
    if (data.containsKey('last_selected_study_book')) {
      context.handle(
        _lastSelectedStudyBookMeta,
        lastSelectedStudyBook.isAcceptableOrUnknown(
          data['last_selected_study_book']!,
          _lastSelectedStudyBookMeta,
        ),
      );
    }
    if (data.containsKey('last_selected_study_chapter')) {
      context.handle(
        _lastSelectedStudyChapterMeta,
        lastSelectedStudyChapter.isAcceptableOrUnknown(
          data['last_selected_study_chapter']!,
          _lastSelectedStudyChapterMeta,
        ),
      );
    }
    if (data.containsKey('last_selected_map_name')) {
      context.handle(
        _lastSelectedMapNameMeta,
        lastSelectedMapName.isAcceptableOrUnknown(
          data['last_selected_map_name']!,
          _lastSelectedMapNameMeta,
        ),
      );
    }
    if (data.containsKey('selected_study_font')) {
      context.handle(
        _selectedStudyFontMeta,
        selectedStudyFont.isAcceptableOrUnknown(
          data['selected_study_font']!,
          _selectedStudyFontMeta,
        ),
      );
    }
    if (data.containsKey('selected_study_font_size')) {
      context.handle(
        _selectedStudyFontSizeMeta,
        selectedStudyFontSize.isAcceptableOrUnknown(
          data['selected_study_font_size']!,
          _selectedStudyFontSizeMeta,
        ),
      );
    }
    if (data.containsKey('selected_font')) {
      context.handle(
        _selectedFontMeta,
        selectedFont.isAcceptableOrUnknown(
          data['selected_font']!,
          _selectedFontMeta,
        ),
      );
    }
    if (data.containsKey('selected_font_size')) {
      context.handle(
        _selectedFontSizeMeta,
        selectedFontSize.isAcceptableOrUnknown(
          data['selected_font_size']!,
          _selectedFontSizeMeta,
        ),
      );
    }
    if (data.containsKey('is_auto_scrolling_enabled')) {
      context.handle(
        _isAutoScrollingEnabledMeta,
        isAutoScrollingEnabled.isAcceptableOrUnknown(
          data['is_auto_scrolling_enabled']!,
          _isAutoScrollingEnabledMeta,
        ),
      );
    }
    if (data.containsKey('auto_scroll_mode')) {
      context.handle(
        _autoScrollModeMeta,
        autoScrollMode.isAcceptableOrUnknown(
          data['auto_scroll_mode']!,
          _autoScrollModeMeta,
        ),
      );
    }
    if (data.containsKey('last_bible_note')) {
      context.handle(
        _lastBibleNoteMeta,
        lastBibleNote.isAcceptableOrUnknown(
          data['last_bible_note']!,
          _lastBibleNoteMeta,
        ),
      );
    }
    if (data.containsKey('last_personal_note')) {
      context.handle(
        _lastPersonalNoteMeta,
        lastPersonalNote.isAcceptableOrUnknown(
          data['last_personal_note']!,
          _lastPersonalNoteMeta,
        ),
      );
    }
    if (data.containsKey('last_study_note')) {
      context.handle(
        _lastStudyNoteMeta,
        lastStudyNote.isAcceptableOrUnknown(
          data['last_study_note']!,
          _lastStudyNoteMeta,
        ),
      );
    }
    if (data.containsKey('last_search')) {
      context.handle(
        _lastSearchMeta,
        lastSearch.isAcceptableOrUnknown(data['last_search']!, _lastSearchMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      ),
      lastSelectedBook: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_selected_book'],
      ),
      lastSelectedChapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_selected_chapter'],
      ),
      lastSelectedStudyBook: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_selected_study_book'],
      ),
      lastSelectedStudyChapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_selected_study_chapter'],
      ),
      lastSelectedMapName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_selected_map_name'],
      ),
      selectedStudyFont: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_study_font'],
      ),
      selectedStudyFontSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selected_study_font_size'],
      ),
      selectedFont: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_font'],
      ),
      selectedFontSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}selected_font_size'],
      ),
      isAutoScrollingEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_auto_scrolling_enabled'],
      ),
      autoScrollMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auto_scroll_mode'],
      ),
      lastBibleNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_bible_note'],
      ),
      lastPersonalNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_personal_note'],
      ),
      lastStudyNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_study_note'],
      ),
      lastSearch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_search'],
      ),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingsEntry extends DataClass implements Insertable<SettingsEntry> {
  final int id;
  final String? theme;
  final String? lastSelectedBook;
  final int? lastSelectedChapter;
  final String? lastSelectedStudyBook;
  final int? lastSelectedStudyChapter;
  final String? lastSelectedMapName;
  final String? selectedStudyFont;
  final double? selectedStudyFontSize;
  final String? selectedFont;
  final double? selectedFontSize;
  final bool? isAutoScrollingEnabled;
  final String? autoScrollMode;
  final String? lastBibleNote;
  final String? lastPersonalNote;
  final String? lastStudyNote;
  final String? lastSearch;
  const SettingsEntry({
    required this.id,
    this.theme,
    this.lastSelectedBook,
    this.lastSelectedChapter,
    this.lastSelectedStudyBook,
    this.lastSelectedStudyChapter,
    this.lastSelectedMapName,
    this.selectedStudyFont,
    this.selectedStudyFontSize,
    this.selectedFont,
    this.selectedFontSize,
    this.isAutoScrollingEnabled,
    this.autoScrollMode,
    this.lastBibleNote,
    this.lastPersonalNote,
    this.lastStudyNote,
    this.lastSearch,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || theme != null) {
      map['theme'] = Variable<String>(theme);
    }
    if (!nullToAbsent || lastSelectedBook != null) {
      map['last_selected_book'] = Variable<String>(lastSelectedBook);
    }
    if (!nullToAbsent || lastSelectedChapter != null) {
      map['last_selected_chapter'] = Variable<int>(lastSelectedChapter);
    }
    if (!nullToAbsent || lastSelectedStudyBook != null) {
      map['last_selected_study_book'] = Variable<String>(lastSelectedStudyBook);
    }
    if (!nullToAbsent || lastSelectedStudyChapter != null) {
      map['last_selected_study_chapter'] = Variable<int>(
        lastSelectedStudyChapter,
      );
    }
    if (!nullToAbsent || lastSelectedMapName != null) {
      map['last_selected_map_name'] = Variable<String>(lastSelectedMapName);
    }
    if (!nullToAbsent || selectedStudyFont != null) {
      map['selected_study_font'] = Variable<String>(selectedStudyFont);
    }
    if (!nullToAbsent || selectedStudyFontSize != null) {
      map['selected_study_font_size'] = Variable<double>(selectedStudyFontSize);
    }
    if (!nullToAbsent || selectedFont != null) {
      map['selected_font'] = Variable<String>(selectedFont);
    }
    if (!nullToAbsent || selectedFontSize != null) {
      map['selected_font_size'] = Variable<double>(selectedFontSize);
    }
    if (!nullToAbsent || isAutoScrollingEnabled != null) {
      map['is_auto_scrolling_enabled'] = Variable<bool>(isAutoScrollingEnabled);
    }
    if (!nullToAbsent || autoScrollMode != null) {
      map['auto_scroll_mode'] = Variable<String>(autoScrollMode);
    }
    if (!nullToAbsent || lastBibleNote != null) {
      map['last_bible_note'] = Variable<String>(lastBibleNote);
    }
    if (!nullToAbsent || lastPersonalNote != null) {
      map['last_personal_note'] = Variable<String>(lastPersonalNote);
    }
    if (!nullToAbsent || lastStudyNote != null) {
      map['last_study_note'] = Variable<String>(lastStudyNote);
    }
    if (!nullToAbsent || lastSearch != null) {
      map['last_search'] = Variable<String>(lastSearch);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      theme:
          theme == null && nullToAbsent ? const Value.absent() : Value(theme),
      lastSelectedBook:
          lastSelectedBook == null && nullToAbsent
              ? const Value.absent()
              : Value(lastSelectedBook),
      lastSelectedChapter:
          lastSelectedChapter == null && nullToAbsent
              ? const Value.absent()
              : Value(lastSelectedChapter),
      lastSelectedStudyBook:
          lastSelectedStudyBook == null && nullToAbsent
              ? const Value.absent()
              : Value(lastSelectedStudyBook),
      lastSelectedStudyChapter:
          lastSelectedStudyChapter == null && nullToAbsent
              ? const Value.absent()
              : Value(lastSelectedStudyChapter),
      lastSelectedMapName:
          lastSelectedMapName == null && nullToAbsent
              ? const Value.absent()
              : Value(lastSelectedMapName),
      selectedStudyFont:
          selectedStudyFont == null && nullToAbsent
              ? const Value.absent()
              : Value(selectedStudyFont),
      selectedStudyFontSize:
          selectedStudyFontSize == null && nullToAbsent
              ? const Value.absent()
              : Value(selectedStudyFontSize),
      selectedFont:
          selectedFont == null && nullToAbsent
              ? const Value.absent()
              : Value(selectedFont),
      selectedFontSize:
          selectedFontSize == null && nullToAbsent
              ? const Value.absent()
              : Value(selectedFontSize),
      isAutoScrollingEnabled:
          isAutoScrollingEnabled == null && nullToAbsent
              ? const Value.absent()
              : Value(isAutoScrollingEnabled),
      autoScrollMode:
          autoScrollMode == null && nullToAbsent
              ? const Value.absent()
              : Value(autoScrollMode),
      lastBibleNote:
          lastBibleNote == null && nullToAbsent
              ? const Value.absent()
              : Value(lastBibleNote),
      lastPersonalNote:
          lastPersonalNote == null && nullToAbsent
              ? const Value.absent()
              : Value(lastPersonalNote),
      lastStudyNote:
          lastStudyNote == null && nullToAbsent
              ? const Value.absent()
              : Value(lastStudyNote),
      lastSearch:
          lastSearch == null && nullToAbsent
              ? const Value.absent()
              : Value(lastSearch),
    );
  }

  factory SettingsEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsEntry(
      id: serializer.fromJson<int>(json['id']),
      theme: serializer.fromJson<String?>(json['theme']),
      lastSelectedBook: serializer.fromJson<String?>(json['lastSelectedBook']),
      lastSelectedChapter: serializer.fromJson<int?>(
        json['lastSelectedChapter'],
      ),
      lastSelectedStudyBook: serializer.fromJson<String?>(
        json['lastSelectedStudyBook'],
      ),
      lastSelectedStudyChapter: serializer.fromJson<int?>(
        json['lastSelectedStudyChapter'],
      ),
      lastSelectedMapName: serializer.fromJson<String?>(
        json['lastSelectedMapName'],
      ),
      selectedStudyFont: serializer.fromJson<String?>(
        json['selectedStudyFont'],
      ),
      selectedStudyFontSize: serializer.fromJson<double?>(
        json['selectedStudyFontSize'],
      ),
      selectedFont: serializer.fromJson<String?>(json['selectedFont']),
      selectedFontSize: serializer.fromJson<double?>(json['selectedFontSize']),
      isAutoScrollingEnabled: serializer.fromJson<bool?>(
        json['isAutoScrollingEnabled'],
      ),
      autoScrollMode: serializer.fromJson<String?>(json['autoScrollMode']),
      lastBibleNote: serializer.fromJson<String?>(json['lastBibleNote']),
      lastPersonalNote: serializer.fromJson<String?>(json['lastPersonalNote']),
      lastStudyNote: serializer.fromJson<String?>(json['lastStudyNote']),
      lastSearch: serializer.fromJson<String?>(json['lastSearch']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'theme': serializer.toJson<String?>(theme),
      'lastSelectedBook': serializer.toJson<String?>(lastSelectedBook),
      'lastSelectedChapter': serializer.toJson<int?>(lastSelectedChapter),
      'lastSelectedStudyBook': serializer.toJson<String?>(
        lastSelectedStudyBook,
      ),
      'lastSelectedStudyChapter': serializer.toJson<int?>(
        lastSelectedStudyChapter,
      ),
      'lastSelectedMapName': serializer.toJson<String?>(lastSelectedMapName),
      'selectedStudyFont': serializer.toJson<String?>(selectedStudyFont),
      'selectedStudyFontSize': serializer.toJson<double?>(
        selectedStudyFontSize,
      ),
      'selectedFont': serializer.toJson<String?>(selectedFont),
      'selectedFontSize': serializer.toJson<double?>(selectedFontSize),
      'isAutoScrollingEnabled': serializer.toJson<bool?>(
        isAutoScrollingEnabled,
      ),
      'autoScrollMode': serializer.toJson<String?>(autoScrollMode),
      'lastBibleNote': serializer.toJson<String?>(lastBibleNote),
      'lastPersonalNote': serializer.toJson<String?>(lastPersonalNote),
      'lastStudyNote': serializer.toJson<String?>(lastStudyNote),
      'lastSearch': serializer.toJson<String?>(lastSearch),
    };
  }

  SettingsEntry copyWith({
    int? id,
    Value<String?> theme = const Value.absent(),
    Value<String?> lastSelectedBook = const Value.absent(),
    Value<int?> lastSelectedChapter = const Value.absent(),
    Value<String?> lastSelectedStudyBook = const Value.absent(),
    Value<int?> lastSelectedStudyChapter = const Value.absent(),
    Value<String?> lastSelectedMapName = const Value.absent(),
    Value<String?> selectedStudyFont = const Value.absent(),
    Value<double?> selectedStudyFontSize = const Value.absent(),
    Value<String?> selectedFont = const Value.absent(),
    Value<double?> selectedFontSize = const Value.absent(),
    Value<bool?> isAutoScrollingEnabled = const Value.absent(),
    Value<String?> autoScrollMode = const Value.absent(),
    Value<String?> lastBibleNote = const Value.absent(),
    Value<String?> lastPersonalNote = const Value.absent(),
    Value<String?> lastStudyNote = const Value.absent(),
    Value<String?> lastSearch = const Value.absent(),
  }) => SettingsEntry(
    id: id ?? this.id,
    theme: theme.present ? theme.value : this.theme,
    lastSelectedBook:
        lastSelectedBook.present
            ? lastSelectedBook.value
            : this.lastSelectedBook,
    lastSelectedChapter:
        lastSelectedChapter.present
            ? lastSelectedChapter.value
            : this.lastSelectedChapter,
    lastSelectedStudyBook:
        lastSelectedStudyBook.present
            ? lastSelectedStudyBook.value
            : this.lastSelectedStudyBook,
    lastSelectedStudyChapter:
        lastSelectedStudyChapter.present
            ? lastSelectedStudyChapter.value
            : this.lastSelectedStudyChapter,
    lastSelectedMapName:
        lastSelectedMapName.present
            ? lastSelectedMapName.value
            : this.lastSelectedMapName,
    selectedStudyFont:
        selectedStudyFont.present
            ? selectedStudyFont.value
            : this.selectedStudyFont,
    selectedStudyFontSize:
        selectedStudyFontSize.present
            ? selectedStudyFontSize.value
            : this.selectedStudyFontSize,
    selectedFont: selectedFont.present ? selectedFont.value : this.selectedFont,
    selectedFontSize:
        selectedFontSize.present
            ? selectedFontSize.value
            : this.selectedFontSize,
    isAutoScrollingEnabled:
        isAutoScrollingEnabled.present
            ? isAutoScrollingEnabled.value
            : this.isAutoScrollingEnabled,
    autoScrollMode:
        autoScrollMode.present ? autoScrollMode.value : this.autoScrollMode,
    lastBibleNote:
        lastBibleNote.present ? lastBibleNote.value : this.lastBibleNote,
    lastPersonalNote:
        lastPersonalNote.present
            ? lastPersonalNote.value
            : this.lastPersonalNote,
    lastStudyNote:
        lastStudyNote.present ? lastStudyNote.value : this.lastStudyNote,
    lastSearch: lastSearch.present ? lastSearch.value : this.lastSearch,
  );
  SettingsEntry copyWithCompanion(SettingsCompanion data) {
    return SettingsEntry(
      id: data.id.present ? data.id.value : this.id,
      theme: data.theme.present ? data.theme.value : this.theme,
      lastSelectedBook:
          data.lastSelectedBook.present
              ? data.lastSelectedBook.value
              : this.lastSelectedBook,
      lastSelectedChapter:
          data.lastSelectedChapter.present
              ? data.lastSelectedChapter.value
              : this.lastSelectedChapter,
      lastSelectedStudyBook:
          data.lastSelectedStudyBook.present
              ? data.lastSelectedStudyBook.value
              : this.lastSelectedStudyBook,
      lastSelectedStudyChapter:
          data.lastSelectedStudyChapter.present
              ? data.lastSelectedStudyChapter.value
              : this.lastSelectedStudyChapter,
      lastSelectedMapName:
          data.lastSelectedMapName.present
              ? data.lastSelectedMapName.value
              : this.lastSelectedMapName,
      selectedStudyFont:
          data.selectedStudyFont.present
              ? data.selectedStudyFont.value
              : this.selectedStudyFont,
      selectedStudyFontSize:
          data.selectedStudyFontSize.present
              ? data.selectedStudyFontSize.value
              : this.selectedStudyFontSize,
      selectedFont:
          data.selectedFont.present
              ? data.selectedFont.value
              : this.selectedFont,
      selectedFontSize:
          data.selectedFontSize.present
              ? data.selectedFontSize.value
              : this.selectedFontSize,
      isAutoScrollingEnabled:
          data.isAutoScrollingEnabled.present
              ? data.isAutoScrollingEnabled.value
              : this.isAutoScrollingEnabled,
      autoScrollMode:
          data.autoScrollMode.present
              ? data.autoScrollMode.value
              : this.autoScrollMode,
      lastBibleNote:
          data.lastBibleNote.present
              ? data.lastBibleNote.value
              : this.lastBibleNote,
      lastPersonalNote:
          data.lastPersonalNote.present
              ? data.lastPersonalNote.value
              : this.lastPersonalNote,
      lastStudyNote:
          data.lastStudyNote.present
              ? data.lastStudyNote.value
              : this.lastStudyNote,
      lastSearch:
          data.lastSearch.present ? data.lastSearch.value : this.lastSearch,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntry(')
          ..write('id: $id, ')
          ..write('theme: $theme, ')
          ..write('lastSelectedBook: $lastSelectedBook, ')
          ..write('lastSelectedChapter: $lastSelectedChapter, ')
          ..write('lastSelectedStudyBook: $lastSelectedStudyBook, ')
          ..write('lastSelectedStudyChapter: $lastSelectedStudyChapter, ')
          ..write('lastSelectedMapName: $lastSelectedMapName, ')
          ..write('selectedStudyFont: $selectedStudyFont, ')
          ..write('selectedStudyFontSize: $selectedStudyFontSize, ')
          ..write('selectedFont: $selectedFont, ')
          ..write('selectedFontSize: $selectedFontSize, ')
          ..write('isAutoScrollingEnabled: $isAutoScrollingEnabled, ')
          ..write('autoScrollMode: $autoScrollMode, ')
          ..write('lastBibleNote: $lastBibleNote, ')
          ..write('lastPersonalNote: $lastPersonalNote, ')
          ..write('lastStudyNote: $lastStudyNote, ')
          ..write('lastSearch: $lastSearch')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    theme,
    lastSelectedBook,
    lastSelectedChapter,
    lastSelectedStudyBook,
    lastSelectedStudyChapter,
    lastSelectedMapName,
    selectedStudyFont,
    selectedStudyFontSize,
    selectedFont,
    selectedFontSize,
    isAutoScrollingEnabled,
    autoScrollMode,
    lastBibleNote,
    lastPersonalNote,
    lastStudyNote,
    lastSearch,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsEntry &&
          other.id == this.id &&
          other.theme == this.theme &&
          other.lastSelectedBook == this.lastSelectedBook &&
          other.lastSelectedChapter == this.lastSelectedChapter &&
          other.lastSelectedStudyBook == this.lastSelectedStudyBook &&
          other.lastSelectedStudyChapter == this.lastSelectedStudyChapter &&
          other.lastSelectedMapName == this.lastSelectedMapName &&
          other.selectedStudyFont == this.selectedStudyFont &&
          other.selectedStudyFontSize == this.selectedStudyFontSize &&
          other.selectedFont == this.selectedFont &&
          other.selectedFontSize == this.selectedFontSize &&
          other.isAutoScrollingEnabled == this.isAutoScrollingEnabled &&
          other.autoScrollMode == this.autoScrollMode &&
          other.lastBibleNote == this.lastBibleNote &&
          other.lastPersonalNote == this.lastPersonalNote &&
          other.lastStudyNote == this.lastStudyNote &&
          other.lastSearch == this.lastSearch);
}

class SettingsCompanion extends UpdateCompanion<SettingsEntry> {
  final Value<int> id;
  final Value<String?> theme;
  final Value<String?> lastSelectedBook;
  final Value<int?> lastSelectedChapter;
  final Value<String?> lastSelectedStudyBook;
  final Value<int?> lastSelectedStudyChapter;
  final Value<String?> lastSelectedMapName;
  final Value<String?> selectedStudyFont;
  final Value<double?> selectedStudyFontSize;
  final Value<String?> selectedFont;
  final Value<double?> selectedFontSize;
  final Value<bool?> isAutoScrollingEnabled;
  final Value<String?> autoScrollMode;
  final Value<String?> lastBibleNote;
  final Value<String?> lastPersonalNote;
  final Value<String?> lastStudyNote;
  final Value<String?> lastSearch;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.theme = const Value.absent(),
    this.lastSelectedBook = const Value.absent(),
    this.lastSelectedChapter = const Value.absent(),
    this.lastSelectedStudyBook = const Value.absent(),
    this.lastSelectedStudyChapter = const Value.absent(),
    this.lastSelectedMapName = const Value.absent(),
    this.selectedStudyFont = const Value.absent(),
    this.selectedStudyFontSize = const Value.absent(),
    this.selectedFont = const Value.absent(),
    this.selectedFontSize = const Value.absent(),
    this.isAutoScrollingEnabled = const Value.absent(),
    this.autoScrollMode = const Value.absent(),
    this.lastBibleNote = const Value.absent(),
    this.lastPersonalNote = const Value.absent(),
    this.lastStudyNote = const Value.absent(),
    this.lastSearch = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.theme = const Value.absent(),
    this.lastSelectedBook = const Value.absent(),
    this.lastSelectedChapter = const Value.absent(),
    this.lastSelectedStudyBook = const Value.absent(),
    this.lastSelectedStudyChapter = const Value.absent(),
    this.lastSelectedMapName = const Value.absent(),
    this.selectedStudyFont = const Value.absent(),
    this.selectedStudyFontSize = const Value.absent(),
    this.selectedFont = const Value.absent(),
    this.selectedFontSize = const Value.absent(),
    this.isAutoScrollingEnabled = const Value.absent(),
    this.autoScrollMode = const Value.absent(),
    this.lastBibleNote = const Value.absent(),
    this.lastPersonalNote = const Value.absent(),
    this.lastStudyNote = const Value.absent(),
    this.lastSearch = const Value.absent(),
  });
  static Insertable<SettingsEntry> custom({
    Expression<int>? id,
    Expression<String>? theme,
    Expression<String>? lastSelectedBook,
    Expression<int>? lastSelectedChapter,
    Expression<String>? lastSelectedStudyBook,
    Expression<int>? lastSelectedStudyChapter,
    Expression<String>? lastSelectedMapName,
    Expression<String>? selectedStudyFont,
    Expression<double>? selectedStudyFontSize,
    Expression<String>? selectedFont,
    Expression<double>? selectedFontSize,
    Expression<bool>? isAutoScrollingEnabled,
    Expression<String>? autoScrollMode,
    Expression<String>? lastBibleNote,
    Expression<String>? lastPersonalNote,
    Expression<String>? lastStudyNote,
    Expression<String>? lastSearch,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (theme != null) 'theme': theme,
      if (lastSelectedBook != null) 'last_selected_book': lastSelectedBook,
      if (lastSelectedChapter != null)
        'last_selected_chapter': lastSelectedChapter,
      if (lastSelectedStudyBook != null)
        'last_selected_study_book': lastSelectedStudyBook,
      if (lastSelectedStudyChapter != null)
        'last_selected_study_chapter': lastSelectedStudyChapter,
      if (lastSelectedMapName != null)
        'last_selected_map_name': lastSelectedMapName,
      if (selectedStudyFont != null) 'selected_study_font': selectedStudyFont,
      if (selectedStudyFontSize != null)
        'selected_study_font_size': selectedStudyFontSize,
      if (selectedFont != null) 'selected_font': selectedFont,
      if (selectedFontSize != null) 'selected_font_size': selectedFontSize,
      if (isAutoScrollingEnabled != null)
        'is_auto_scrolling_enabled': isAutoScrollingEnabled,
      if (autoScrollMode != null) 'auto_scroll_mode': autoScrollMode,
      if (lastBibleNote != null) 'last_bible_note': lastBibleNote,
      if (lastPersonalNote != null) 'last_personal_note': lastPersonalNote,
      if (lastStudyNote != null) 'last_study_note': lastStudyNote,
      if (lastSearch != null) 'last_search': lastSearch,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<String?>? theme,
    Value<String?>? lastSelectedBook,
    Value<int?>? lastSelectedChapter,
    Value<String?>? lastSelectedStudyBook,
    Value<int?>? lastSelectedStudyChapter,
    Value<String?>? lastSelectedMapName,
    Value<String?>? selectedStudyFont,
    Value<double?>? selectedStudyFontSize,
    Value<String?>? selectedFont,
    Value<double?>? selectedFontSize,
    Value<bool?>? isAutoScrollingEnabled,
    Value<String?>? autoScrollMode,
    Value<String?>? lastBibleNote,
    Value<String?>? lastPersonalNote,
    Value<String?>? lastStudyNote,
    Value<String?>? lastSearch,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      theme: theme ?? this.theme,
      lastSelectedBook: lastSelectedBook ?? this.lastSelectedBook,
      lastSelectedChapter: lastSelectedChapter ?? this.lastSelectedChapter,
      lastSelectedStudyBook:
          lastSelectedStudyBook ?? this.lastSelectedStudyBook,
      lastSelectedStudyChapter:
          lastSelectedStudyChapter ?? this.lastSelectedStudyChapter,
      lastSelectedMapName: lastSelectedMapName ?? this.lastSelectedMapName,
      selectedStudyFont: selectedStudyFont ?? this.selectedStudyFont,
      selectedStudyFontSize:
          selectedStudyFontSize ?? this.selectedStudyFontSize,
      selectedFont: selectedFont ?? this.selectedFont,
      selectedFontSize: selectedFontSize ?? this.selectedFontSize,
      isAutoScrollingEnabled:
          isAutoScrollingEnabled ?? this.isAutoScrollingEnabled,
      autoScrollMode: autoScrollMode ?? this.autoScrollMode,
      lastBibleNote: lastBibleNote ?? this.lastBibleNote,
      lastPersonalNote: lastPersonalNote ?? this.lastPersonalNote,
      lastStudyNote: lastStudyNote ?? this.lastStudyNote,
      lastSearch: lastSearch ?? this.lastSearch,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (lastSelectedBook.present) {
      map['last_selected_book'] = Variable<String>(lastSelectedBook.value);
    }
    if (lastSelectedChapter.present) {
      map['last_selected_chapter'] = Variable<int>(lastSelectedChapter.value);
    }
    if (lastSelectedStudyBook.present) {
      map['last_selected_study_book'] = Variable<String>(
        lastSelectedStudyBook.value,
      );
    }
    if (lastSelectedStudyChapter.present) {
      map['last_selected_study_chapter'] = Variable<int>(
        lastSelectedStudyChapter.value,
      );
    }
    if (lastSelectedMapName.present) {
      map['last_selected_map_name'] = Variable<String>(
        lastSelectedMapName.value,
      );
    }
    if (selectedStudyFont.present) {
      map['selected_study_font'] = Variable<String>(selectedStudyFont.value);
    }
    if (selectedStudyFontSize.present) {
      map['selected_study_font_size'] = Variable<double>(
        selectedStudyFontSize.value,
      );
    }
    if (selectedFont.present) {
      map['selected_font'] = Variable<String>(selectedFont.value);
    }
    if (selectedFontSize.present) {
      map['selected_font_size'] = Variable<double>(selectedFontSize.value);
    }
    if (isAutoScrollingEnabled.present) {
      map['is_auto_scrolling_enabled'] = Variable<bool>(
        isAutoScrollingEnabled.value,
      );
    }
    if (autoScrollMode.present) {
      map['auto_scroll_mode'] = Variable<String>(autoScrollMode.value);
    }
    if (lastBibleNote.present) {
      map['last_bible_note'] = Variable<String>(lastBibleNote.value);
    }
    if (lastPersonalNote.present) {
      map['last_personal_note'] = Variable<String>(lastPersonalNote.value);
    }
    if (lastStudyNote.present) {
      map['last_study_note'] = Variable<String>(lastStudyNote.value);
    }
    if (lastSearch.present) {
      map['last_search'] = Variable<String>(lastSearch.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('theme: $theme, ')
          ..write('lastSelectedBook: $lastSelectedBook, ')
          ..write('lastSelectedChapter: $lastSelectedChapter, ')
          ..write('lastSelectedStudyBook: $lastSelectedStudyBook, ')
          ..write('lastSelectedStudyChapter: $lastSelectedStudyChapter, ')
          ..write('lastSelectedMapName: $lastSelectedMapName, ')
          ..write('selectedStudyFont: $selectedStudyFont, ')
          ..write('selectedStudyFontSize: $selectedStudyFontSize, ')
          ..write('selectedFont: $selectedFont, ')
          ..write('selectedFontSize: $selectedFontSize, ')
          ..write('isAutoScrollingEnabled: $isAutoScrollingEnabled, ')
          ..write('autoScrollMode: $autoScrollMode, ')
          ..write('lastBibleNote: $lastBibleNote, ')
          ..write('lastPersonalNote: $lastPersonalNote, ')
          ..write('lastStudyNote: $lastStudyNote, ')
          ..write('lastSearch: $lastSearch')
          ..write(')'))
        .toString();
  }
}

class $BibleNotesTable extends BibleNotes
    with TableInfo<$BibleNotesTable, BibleNoteEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BibleNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _verseMeta = const VerificationMeta('verse');
  @override
  late final GeneratedColumn<String> verse = GeneratedColumn<String>(
    'verse',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseTextMeta = const VerificationMeta(
    'verseText',
  );
  @override
  late final GeneratedColumn<String> verseText = GeneratedColumn<String>(
    'verse_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [verse, verseText, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bible_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<BibleNoteEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('verse')) {
      context.handle(
        _verseMeta,
        verse.isAcceptableOrUnknown(data['verse']!, _verseMeta),
      );
    } else if (isInserting) {
      context.missing(_verseMeta);
    }
    if (data.containsKey('verse_text')) {
      context.handle(
        _verseTextMeta,
        verseText.isAcceptableOrUnknown(data['verse_text']!, _verseTextMeta),
      );
    } else if (isInserting) {
      context.missing(_verseTextMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {verse};
  @override
  BibleNoteEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BibleNoteEntry(
      verse:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}verse'],
          )!,
      verseText:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}verse_text'],
          )!,
      note:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}note'],
          )!,
    );
  }

  @override
  $BibleNotesTable createAlias(String alias) {
    return $BibleNotesTable(attachedDatabase, alias);
  }
}

class BibleNoteEntry extends DataClass implements Insertable<BibleNoteEntry> {
  final String verse;
  final String verseText;
  final String note;
  const BibleNoteEntry({
    required this.verse,
    required this.verseText,
    required this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['verse'] = Variable<String>(verse);
    map['verse_text'] = Variable<String>(verseText);
    map['note'] = Variable<String>(note);
    return map;
  }

  BibleNotesCompanion toCompanion(bool nullToAbsent) {
    return BibleNotesCompanion(
      verse: Value(verse),
      verseText: Value(verseText),
      note: Value(note),
    );
  }

  factory BibleNoteEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BibleNoteEntry(
      verse: serializer.fromJson<String>(json['verse']),
      verseText: serializer.fromJson<String>(json['verseText']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'verse': serializer.toJson<String>(verse),
      'verseText': serializer.toJson<String>(verseText),
      'note': serializer.toJson<String>(note),
    };
  }

  BibleNoteEntry copyWith({String? verse, String? verseText, String? note}) =>
      BibleNoteEntry(
        verse: verse ?? this.verse,
        verseText: verseText ?? this.verseText,
        note: note ?? this.note,
      );
  BibleNoteEntry copyWithCompanion(BibleNotesCompanion data) {
    return BibleNoteEntry(
      verse: data.verse.present ? data.verse.value : this.verse,
      verseText: data.verseText.present ? data.verseText.value : this.verseText,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BibleNoteEntry(')
          ..write('verse: $verse, ')
          ..write('verseText: $verseText, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(verse, verseText, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BibleNoteEntry &&
          other.verse == this.verse &&
          other.verseText == this.verseText &&
          other.note == this.note);
}

class BibleNotesCompanion extends UpdateCompanion<BibleNoteEntry> {
  final Value<String> verse;
  final Value<String> verseText;
  final Value<String> note;
  final Value<int> rowid;
  const BibleNotesCompanion({
    this.verse = const Value.absent(),
    this.verseText = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BibleNotesCompanion.insert({
    required String verse,
    required String verseText,
    required String note,
    this.rowid = const Value.absent(),
  }) : verse = Value(verse),
       verseText = Value(verseText),
       note = Value(note);
  static Insertable<BibleNoteEntry> custom({
    Expression<String>? verse,
    Expression<String>? verseText,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (verse != null) 'verse': verse,
      if (verseText != null) 'verse_text': verseText,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BibleNotesCompanion copyWith({
    Value<String>? verse,
    Value<String>? verseText,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return BibleNotesCompanion(
      verse: verse ?? this.verse,
      verseText: verseText ?? this.verseText,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (verse.present) {
      map['verse'] = Variable<String>(verse.value);
    }
    if (verseText.present) {
      map['verse_text'] = Variable<String>(verseText.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BibleNotesCompanion(')
          ..write('verse: $verse, ')
          ..write('verseText: $verseText, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalNotesTable extends PersonalNotes
    with TableInfo<$PersonalNotesTable, PersonalNoteEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalNoteEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalNoteEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalNoteEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      note:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}note'],
          )!,
    );
  }

  @override
  $PersonalNotesTable createAlias(String alias) {
    return $PersonalNotesTable(attachedDatabase, alias);
  }
}

class PersonalNoteEntry extends DataClass
    implements Insertable<PersonalNoteEntry> {
  final String id;
  final String note;
  const PersonalNoteEntry({required this.id, required this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['note'] = Variable<String>(note);
    return map;
  }

  PersonalNotesCompanion toCompanion(bool nullToAbsent) {
    return PersonalNotesCompanion(id: Value(id), note: Value(note));
  }

  factory PersonalNoteEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalNoteEntry(
      id: serializer.fromJson<String>(json['id']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'note': serializer.toJson<String>(note),
    };
  }

  PersonalNoteEntry copyWith({String? id, String? note}) =>
      PersonalNoteEntry(id: id ?? this.id, note: note ?? this.note);
  PersonalNoteEntry copyWithCompanion(PersonalNotesCompanion data) {
    return PersonalNoteEntry(
      id: data.id.present ? data.id.value : this.id,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalNoteEntry(')
          ..write('id: $id, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalNoteEntry &&
          other.id == this.id &&
          other.note == this.note);
}

class PersonalNotesCompanion extends UpdateCompanion<PersonalNoteEntry> {
  final Value<String> id;
  final Value<String> note;
  final Value<int> rowid;
  const PersonalNotesCompanion({
    this.id = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalNotesCompanion.insert({
    required String id,
    required String note,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       note = Value(note);
  static Insertable<PersonalNoteEntry> custom({
    Expression<String>? id,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return PersonalNotesCompanion(
      id: id ?? this.id,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalNotesCompanion(')
          ..write('id: $id, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudyNotesTable extends StudyNotes
    with TableInfo<$StudyNotesTable, StudyNoteEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudyNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'study_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudyNoteEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudyNoteEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudyNoteEntry(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      note:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}note'],
          )!,
    );
  }

  @override
  $StudyNotesTable createAlias(String alias) {
    return $StudyNotesTable(attachedDatabase, alias);
  }
}

class StudyNoteEntry extends DataClass implements Insertable<StudyNoteEntry> {
  final String id;
  final String note;
  const StudyNoteEntry({required this.id, required this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['note'] = Variable<String>(note);
    return map;
  }

  StudyNotesCompanion toCompanion(bool nullToAbsent) {
    return StudyNotesCompanion(id: Value(id), note: Value(note));
  }

  factory StudyNoteEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudyNoteEntry(
      id: serializer.fromJson<String>(json['id']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'note': serializer.toJson<String>(note),
    };
  }

  StudyNoteEntry copyWith({String? id, String? note}) =>
      StudyNoteEntry(id: id ?? this.id, note: note ?? this.note);
  StudyNoteEntry copyWithCompanion(StudyNotesCompanion data) {
    return StudyNoteEntry(
      id: data.id.present ? data.id.value : this.id,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudyNoteEntry(')
          ..write('id: $id, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudyNoteEntry &&
          other.id == this.id &&
          other.note == this.note);
}

class StudyNotesCompanion extends UpdateCompanion<StudyNoteEntry> {
  final Value<String> id;
  final Value<String> note;
  final Value<int> rowid;
  const StudyNotesCompanion({
    this.id = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudyNotesCompanion.insert({
    required String id,
    required String note,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       note = Value(note);
  static Insertable<StudyNoteEntry> custom({
    Expression<String>? id,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudyNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? note,
    Value<int>? rowid,
  }) {
    return StudyNotesCompanion(
      id: id ?? this.id,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudyNotesCompanion(')
          ..write('id: $id, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $MapInfoEntriesTable mapInfoEntries = $MapInfoEntriesTable(this);
  late final $GospelProfilesTable gospelProfiles = $GospelProfilesTable(this);
  late final $PrayersTable prayers = $PrayersTable(this);
  late final $VerseDataEntriesTable verseDataEntries = $VerseDataEntriesTable(
    this,
  );
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $BibleNotesTable bibleNotes = $BibleNotesTable(this);
  late final $PersonalNotesTable personalNotes = $PersonalNotesTable(this);
  late final $StudyNotesTable studyNotes = $StudyNotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contacts,
    mapInfoEntries,
    gospelProfiles,
    prayers,
    verseDataEntries,
    bookmarks,
    favorites,
    settings,
    bibleNotes,
    personalNotes,
    studyNotes,
  ];
}

typedef $$ContactsTableCreateCompanionBuilder =
    ContactsCompanion Function({
      required String id,
      required String firstName,
      required String lastName,
      required String address,
      Value<DateTime?> birthday,
      required double latitude,
      required double longitude,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> picturePath,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$ContactsTableUpdateCompanionBuilder =
    ContactsCompanion Function({
      Value<String> id,
      Value<String> firstName,
      Value<String> lastName,
      Value<String> address,
      Value<DateTime?> birthday,
      Value<double> latitude,
      Value<double> longitude,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> picturePath,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get picturePath => $composableBuilder(
    column: $table.picturePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthday => $composableBuilder(
    column: $table.birthday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get picturePath => $composableBuilder(
    column: $table.picturePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<DateTime> get birthday =>
      $composableBuilder(column: $table.birthday, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get picturePath => $composableBuilder(
    column: $table.picturePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$ContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContactsTable,
          ContactEntry,
          $$ContactsTableFilterComposer,
          $$ContactsTableOrderingComposer,
          $$ContactsTableAnnotationComposer,
          $$ContactsTableCreateCompanionBuilder,
          $$ContactsTableUpdateCompanionBuilder,
          (
            ContactEntry,
            BaseReferences<_$AppDatabase, $ContactsTable, ContactEntry>,
          ),
          ContactEntry,
          PrefetchHooks Function()
        > {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<DateTime?> birthday = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> picturePath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion(
                id: id,
                firstName: firstName,
                lastName: lastName,
                address: address,
                birthday: birthday,
                latitude: latitude,
                longitude: longitude,
                phone: phone,
                email: email,
                picturePath: picturePath,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String firstName,
                required String lastName,
                required String address,
                Value<DateTime?> birthday = const Value.absent(),
                required double latitude,
                required double longitude,
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> picturePath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContactsCompanion.insert(
                id: id,
                firstName: firstName,
                lastName: lastName,
                address: address,
                birthday: birthday,
                latitude: latitude,
                longitude: longitude,
                phone: phone,
                email: email,
                picturePath: picturePath,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContactsTable,
      ContactEntry,
      $$ContactsTableFilterComposer,
      $$ContactsTableOrderingComposer,
      $$ContactsTableAnnotationComposer,
      $$ContactsTableCreateCompanionBuilder,
      $$ContactsTableUpdateCompanionBuilder,
      (
        ContactEntry,
        BaseReferences<_$AppDatabase, $ContactsTable, ContactEntry>,
      ),
      ContactEntry,
      PrefetchHooks Function()
    >;
typedef $$MapInfoEntriesTableCreateCompanionBuilder =
    MapInfoEntriesCompanion Function({
      required String name,
      required String filePath,
      required String downloadUrl,
      required bool isTemporary,
      required double latitude,
      required double longitude,
      required int zoomLevel,
      Value<int> rowid,
    });
typedef $$MapInfoEntriesTableUpdateCompanionBuilder =
    MapInfoEntriesCompanion Function({
      Value<String> name,
      Value<String> filePath,
      Value<String> downloadUrl,
      Value<bool> isTemporary,
      Value<double> latitude,
      Value<double> longitude,
      Value<int> zoomLevel,
      Value<int> rowid,
    });

class $$MapInfoEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MapInfoEntriesTable> {
  $$MapInfoEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTemporary => $composableBuilder(
    column: $table.isTemporary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zoomLevel => $composableBuilder(
    column: $table.zoomLevel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MapInfoEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MapInfoEntriesTable> {
  $$MapInfoEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTemporary => $composableBuilder(
    column: $table.isTemporary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zoomLevel => $composableBuilder(
    column: $table.zoomLevel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MapInfoEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MapInfoEntriesTable> {
  $$MapInfoEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get downloadUrl => $composableBuilder(
    column: $table.downloadUrl,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTemporary => $composableBuilder(
    column: $table.isTemporary,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get zoomLevel =>
      $composableBuilder(column: $table.zoomLevel, builder: (column) => column);
}

class $$MapInfoEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MapInfoEntriesTable,
          MapInfoEntry,
          $$MapInfoEntriesTableFilterComposer,
          $$MapInfoEntriesTableOrderingComposer,
          $$MapInfoEntriesTableAnnotationComposer,
          $$MapInfoEntriesTableCreateCompanionBuilder,
          $$MapInfoEntriesTableUpdateCompanionBuilder,
          (
            MapInfoEntry,
            BaseReferences<_$AppDatabase, $MapInfoEntriesTable, MapInfoEntry>,
          ),
          MapInfoEntry,
          PrefetchHooks Function()
        > {
  $$MapInfoEntriesTableTableManager(
    _$AppDatabase db,
    $MapInfoEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MapInfoEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$MapInfoEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MapInfoEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> downloadUrl = const Value.absent(),
                Value<bool> isTemporary = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<int> zoomLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MapInfoEntriesCompanion(
                name: name,
                filePath: filePath,
                downloadUrl: downloadUrl,
                isTemporary: isTemporary,
                latitude: latitude,
                longitude: longitude,
                zoomLevel: zoomLevel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String name,
                required String filePath,
                required String downloadUrl,
                required bool isTemporary,
                required double latitude,
                required double longitude,
                required int zoomLevel,
                Value<int> rowid = const Value.absent(),
              }) => MapInfoEntriesCompanion.insert(
                name: name,
                filePath: filePath,
                downloadUrl: downloadUrl,
                isTemporary: isTemporary,
                latitude: latitude,
                longitude: longitude,
                zoomLevel: zoomLevel,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MapInfoEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MapInfoEntriesTable,
      MapInfoEntry,
      $$MapInfoEntriesTableFilterComposer,
      $$MapInfoEntriesTableOrderingComposer,
      $$MapInfoEntriesTableAnnotationComposer,
      $$MapInfoEntriesTableCreateCompanionBuilder,
      $$MapInfoEntriesTableUpdateCompanionBuilder,
      (
        MapInfoEntry,
        BaseReferences<_$AppDatabase, $MapInfoEntriesTable, MapInfoEntry>,
      ),
      MapInfoEntry,
      PrefetchHooks Function()
    >;
typedef $$GospelProfilesTableCreateCompanionBuilder =
    GospelProfilesCompanion Function({
      Value<String?> firstName,
      Value<String?> lastName,
      Value<String?> address,
      Value<DateTime?> naturalBirthday,
      Value<String?> phone,
      Value<String?> email,
      Value<DateTime?> spiritualBirthday,
      Value<int> rowid,
    });
typedef $$GospelProfilesTableUpdateCompanionBuilder =
    GospelProfilesCompanion Function({
      Value<String?> firstName,
      Value<String?> lastName,
      Value<String?> address,
      Value<DateTime?> naturalBirthday,
      Value<String?> phone,
      Value<String?> email,
      Value<DateTime?> spiritualBirthday,
      Value<int> rowid,
    });

class $$GospelProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $GospelProfilesTable> {
  $$GospelProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get naturalBirthday => $composableBuilder(
    column: $table.naturalBirthday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get spiritualBirthday => $composableBuilder(
    column: $table.spiritualBirthday,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GospelProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $GospelProfilesTable> {
  $$GospelProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get naturalBirthday => $composableBuilder(
    column: $table.naturalBirthday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get spiritualBirthday => $composableBuilder(
    column: $table.spiritualBirthday,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GospelProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GospelProfilesTable> {
  $$GospelProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<DateTime> get naturalBirthday => $composableBuilder(
    column: $table.naturalBirthday,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get spiritualBirthday => $composableBuilder(
    column: $table.spiritualBirthday,
    builder: (column) => column,
  );
}

class $$GospelProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GospelProfilesTable,
          GospelProfileEntry,
          $$GospelProfilesTableFilterComposer,
          $$GospelProfilesTableOrderingComposer,
          $$GospelProfilesTableAnnotationComposer,
          $$GospelProfilesTableCreateCompanionBuilder,
          $$GospelProfilesTableUpdateCompanionBuilder,
          (
            GospelProfileEntry,
            BaseReferences<
              _$AppDatabase,
              $GospelProfilesTable,
              GospelProfileEntry
            >,
          ),
          GospelProfileEntry,
          PrefetchHooks Function()
        > {
  $$GospelProfilesTableTableManager(
    _$AppDatabase db,
    $GospelProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$GospelProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$GospelProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$GospelProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String?> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<DateTime?> naturalBirthday = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime?> spiritualBirthday = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GospelProfilesCompanion(
                firstName: firstName,
                lastName: lastName,
                address: address,
                naturalBirthday: naturalBirthday,
                phone: phone,
                email: email,
                spiritualBirthday: spiritualBirthday,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<DateTime?> naturalBirthday = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime?> spiritualBirthday = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GospelProfilesCompanion.insert(
                firstName: firstName,
                lastName: lastName,
                address: address,
                naturalBirthday: naturalBirthday,
                phone: phone,
                email: email,
                spiritualBirthday: spiritualBirthday,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GospelProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GospelProfilesTable,
      GospelProfileEntry,
      $$GospelProfilesTableFilterComposer,
      $$GospelProfilesTableOrderingComposer,
      $$GospelProfilesTableAnnotationComposer,
      $$GospelProfilesTableCreateCompanionBuilder,
      $$GospelProfilesTableUpdateCompanionBuilder,
      (
        GospelProfileEntry,
        BaseReferences<_$AppDatabase, $GospelProfilesTable, GospelProfileEntry>,
      ),
      GospelProfileEntry,
      PrefetchHooks Function()
    >;
typedef $$PrayersTableCreateCompanionBuilder =
    PrayersCompanion Function({
      required String id,
      required String richTextJson,
      required String status,
      required DateTime timestamp,
      Value<int> rowid,
    });
typedef $$PrayersTableUpdateCompanionBuilder =
    PrayersCompanion Function({
      Value<String> id,
      Value<String> richTextJson,
      Value<String> status,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$PrayersTableFilterComposer
    extends Composer<_$AppDatabase, $PrayersTable> {
  $$PrayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get richTextJson => $composableBuilder(
    column: $table.richTextJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayersTable> {
  $$PrayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get richTextJson => $composableBuilder(
    column: $table.richTextJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayersTable> {
  $$PrayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get richTextJson => $composableBuilder(
    column: $table.richTextJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$PrayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayersTable,
          PrayerEntry,
          $$PrayersTableFilterComposer,
          $$PrayersTableOrderingComposer,
          $$PrayersTableAnnotationComposer,
          $$PrayersTableCreateCompanionBuilder,
          $$PrayersTableUpdateCompanionBuilder,
          (
            PrayerEntry,
            BaseReferences<_$AppDatabase, $PrayersTable, PrayerEntry>,
          ),
          PrayerEntry,
          PrefetchHooks Function()
        > {
  $$PrayersTableTableManager(_$AppDatabase db, $PrayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PrayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PrayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PrayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> richTextJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayersCompanion(
                id: id,
                richTextJson: richTextJson,
                status: status,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String richTextJson,
                required String status,
                required DateTime timestamp,
                Value<int> rowid = const Value.absent(),
              }) => PrayersCompanion.insert(
                id: id,
                richTextJson: richTextJson,
                status: status,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayersTable,
      PrayerEntry,
      $$PrayersTableFilterComposer,
      $$PrayersTableOrderingComposer,
      $$PrayersTableAnnotationComposer,
      $$PrayersTableCreateCompanionBuilder,
      $$PrayersTableUpdateCompanionBuilder,
      (PrayerEntry, BaseReferences<_$AppDatabase, $PrayersTable, PrayerEntry>),
      PrayerEntry,
      PrefetchHooks Function()
    >;
typedef $$VerseDataEntriesTableCreateCompanionBuilder =
    VerseDataEntriesCompanion Function({
      required String bookName,
      required int chapter,
      required int verse,
      required String verseTextContent,
      Value<int> rowid,
    });
typedef $$VerseDataEntriesTableUpdateCompanionBuilder =
    VerseDataEntriesCompanion Function({
      Value<String> bookName,
      Value<int> chapter,
      Value<int> verse,
      Value<String> verseTextContent,
      Value<int> rowid,
    });

class $$VerseDataEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $VerseDataEntriesTable> {
  $$VerseDataEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verseTextContent => $composableBuilder(
    column: $table.verseTextContent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VerseDataEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $VerseDataEntriesTable> {
  $$VerseDataEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bookName => $composableBuilder(
    column: $table.bookName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verseTextContent => $composableBuilder(
    column: $table.verseTextContent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VerseDataEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VerseDataEntriesTable> {
  $$VerseDataEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bookName =>
      $composableBuilder(column: $table.bookName, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<String> get verseTextContent => $composableBuilder(
    column: $table.verseTextContent,
    builder: (column) => column,
  );
}

class $$VerseDataEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VerseDataEntriesTable,
          VerseDataEntry,
          $$VerseDataEntriesTableFilterComposer,
          $$VerseDataEntriesTableOrderingComposer,
          $$VerseDataEntriesTableAnnotationComposer,
          $$VerseDataEntriesTableCreateCompanionBuilder,
          $$VerseDataEntriesTableUpdateCompanionBuilder,
          (
            VerseDataEntry,
            BaseReferences<
              _$AppDatabase,
              $VerseDataEntriesTable,
              VerseDataEntry
            >,
          ),
          VerseDataEntry,
          PrefetchHooks Function()
        > {
  $$VerseDataEntriesTableTableManager(
    _$AppDatabase db,
    $VerseDataEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$VerseDataEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$VerseDataEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$VerseDataEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> bookName = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int> verse = const Value.absent(),
                Value<String> verseTextContent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VerseDataEntriesCompanion(
                bookName: bookName,
                chapter: chapter,
                verse: verse,
                verseTextContent: verseTextContent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookName,
                required int chapter,
                required int verse,
                required String verseTextContent,
                Value<int> rowid = const Value.absent(),
              }) => VerseDataEntriesCompanion.insert(
                bookName: bookName,
                chapter: chapter,
                verse: verse,
                verseTextContent: verseTextContent,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VerseDataEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VerseDataEntriesTable,
      VerseDataEntry,
      $$VerseDataEntriesTableFilterComposer,
      $$VerseDataEntriesTableOrderingComposer,
      $$VerseDataEntriesTableAnnotationComposer,
      $$VerseDataEntriesTableCreateCompanionBuilder,
      $$VerseDataEntriesTableUpdateCompanionBuilder,
      (
        VerseDataEntry,
        BaseReferences<_$AppDatabase, $VerseDataEntriesTable, VerseDataEntry>,
      ),
      VerseDataEntry,
      PrefetchHooks Function()
    >;
typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      required String verseBook,
      required int verseChapter,
      required int verseVerse,
      required DateTime timestamp,
      Value<int> rowid,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<String> verseBook,
      Value<int> verseChapter,
      Value<int> verseVerse,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get verseBook => $composableBuilder(
    column: $table.verseBook,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseChapter => $composableBuilder(
    column: $table.verseChapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseVerse => $composableBuilder(
    column: $table.verseVerse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get verseBook => $composableBuilder(
    column: $table.verseBook,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseChapter => $composableBuilder(
    column: $table.verseChapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseVerse => $composableBuilder(
    column: $table.verseVerse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get verseBook =>
      $composableBuilder(column: $table.verseBook, builder: (column) => column);

  GeneratedColumn<int> get verseChapter => $composableBuilder(
    column: $table.verseChapter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get verseVerse => $composableBuilder(
    column: $table.verseVerse,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          BookmarkEntry,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (
            BookmarkEntry,
            BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkEntry>,
          ),
          BookmarkEntry,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> verseBook = const Value.absent(),
                Value<int> verseChapter = const Value.absent(),
                Value<int> verseVerse = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion(
                verseBook: verseBook,
                verseChapter: verseChapter,
                verseVerse: verseVerse,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String verseBook,
                required int verseChapter,
                required int verseVerse,
                required DateTime timestamp,
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion.insert(
                verseBook: verseBook,
                verseChapter: verseChapter,
                verseVerse: verseVerse,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      BookmarkEntry,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (
        BookmarkEntry,
        BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkEntry>,
      ),
      BookmarkEntry,
      PrefetchHooks Function()
    >;
typedef $$FavoritesTableCreateCompanionBuilder =
    FavoritesCompanion Function({
      required String verseBook,
      required int verseChapter,
      required int verseVerse,
      required DateTime timestamp,
      Value<int> rowid,
    });
typedef $$FavoritesTableUpdateCompanionBuilder =
    FavoritesCompanion Function({
      Value<String> verseBook,
      Value<int> verseChapter,
      Value<int> verseVerse,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get verseBook => $composableBuilder(
    column: $table.verseBook,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseChapter => $composableBuilder(
    column: $table.verseChapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseVerse => $composableBuilder(
    column: $table.verseVerse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get verseBook => $composableBuilder(
    column: $table.verseBook,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseChapter => $composableBuilder(
    column: $table.verseChapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseVerse => $composableBuilder(
    column: $table.verseVerse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get verseBook =>
      $composableBuilder(column: $table.verseBook, builder: (column) => column);

  GeneratedColumn<int> get verseChapter => $composableBuilder(
    column: $table.verseChapter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get verseVerse => $composableBuilder(
    column: $table.verseVerse,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$FavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoritesTable,
          FavoriteEntry,
          $$FavoritesTableFilterComposer,
          $$FavoritesTableOrderingComposer,
          $$FavoritesTableAnnotationComposer,
          $$FavoritesTableCreateCompanionBuilder,
          $$FavoritesTableUpdateCompanionBuilder,
          (
            FavoriteEntry,
            BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteEntry>,
          ),
          FavoriteEntry,
          PrefetchHooks Function()
        > {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> verseBook = const Value.absent(),
                Value<int> verseChapter = const Value.absent(),
                Value<int> verseVerse = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion(
                verseBook: verseBook,
                verseChapter: verseChapter,
                verseVerse: verseVerse,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String verseBook,
                required int verseChapter,
                required int verseVerse,
                required DateTime timestamp,
                Value<int> rowid = const Value.absent(),
              }) => FavoritesCompanion.insert(
                verseBook: verseBook,
                verseChapter: verseChapter,
                verseVerse: verseVerse,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoritesTable,
      FavoriteEntry,
      $$FavoritesTableFilterComposer,
      $$FavoritesTableOrderingComposer,
      $$FavoritesTableAnnotationComposer,
      $$FavoritesTableCreateCompanionBuilder,
      $$FavoritesTableUpdateCompanionBuilder,
      (
        FavoriteEntry,
        BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteEntry>,
      ),
      FavoriteEntry,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<String?> theme,
      Value<String?> lastSelectedBook,
      Value<int?> lastSelectedChapter,
      Value<String?> lastSelectedStudyBook,
      Value<int?> lastSelectedStudyChapter,
      Value<String?> lastSelectedMapName,
      Value<String?> selectedStudyFont,
      Value<double?> selectedStudyFontSize,
      Value<String?> selectedFont,
      Value<double?> selectedFontSize,
      Value<bool?> isAutoScrollingEnabled,
      Value<String?> autoScrollMode,
      Value<String?> lastBibleNote,
      Value<String?> lastPersonalNote,
      Value<String?> lastStudyNote,
      Value<String?> lastSearch,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<String?> theme,
      Value<String?> lastSelectedBook,
      Value<int?> lastSelectedChapter,
      Value<String?> lastSelectedStudyBook,
      Value<int?> lastSelectedStudyChapter,
      Value<String?> lastSelectedMapName,
      Value<String?> selectedStudyFont,
      Value<double?> selectedStudyFontSize,
      Value<String?> selectedFont,
      Value<double?> selectedFontSize,
      Value<bool?> isAutoScrollingEnabled,
      Value<String?> autoScrollMode,
      Value<String?> lastBibleNote,
      Value<String?> lastPersonalNote,
      Value<String?> lastStudyNote,
      Value<String?> lastSearch,
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

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSelectedBook => $composableBuilder(
    column: $table.lastSelectedBook,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSelectedChapter => $composableBuilder(
    column: $table.lastSelectedChapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSelectedStudyBook => $composableBuilder(
    column: $table.lastSelectedStudyBook,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSelectedStudyChapter => $composableBuilder(
    column: $table.lastSelectedStudyChapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSelectedMapName => $composableBuilder(
    column: $table.lastSelectedMapName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedStudyFont => $composableBuilder(
    column: $table.selectedStudyFont,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get selectedStudyFontSize => $composableBuilder(
    column: $table.selectedStudyFontSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedFont => $composableBuilder(
    column: $table.selectedFont,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get selectedFontSize => $composableBuilder(
    column: $table.selectedFontSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAutoScrollingEnabled => $composableBuilder(
    column: $table.isAutoScrollingEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autoScrollMode => $composableBuilder(
    column: $table.autoScrollMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastBibleNote => $composableBuilder(
    column: $table.lastBibleNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastPersonalNote => $composableBuilder(
    column: $table.lastPersonalNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastStudyNote => $composableBuilder(
    column: $table.lastStudyNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSearch => $composableBuilder(
    column: $table.lastSearch,
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

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSelectedBook => $composableBuilder(
    column: $table.lastSelectedBook,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSelectedChapter => $composableBuilder(
    column: $table.lastSelectedChapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSelectedStudyBook => $composableBuilder(
    column: $table.lastSelectedStudyBook,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSelectedStudyChapter => $composableBuilder(
    column: $table.lastSelectedStudyChapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSelectedMapName => $composableBuilder(
    column: $table.lastSelectedMapName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedStudyFont => $composableBuilder(
    column: $table.selectedStudyFont,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get selectedStudyFontSize => $composableBuilder(
    column: $table.selectedStudyFontSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedFont => $composableBuilder(
    column: $table.selectedFont,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get selectedFontSize => $composableBuilder(
    column: $table.selectedFontSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAutoScrollingEnabled => $composableBuilder(
    column: $table.isAutoScrollingEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autoScrollMode => $composableBuilder(
    column: $table.autoScrollMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastBibleNote => $composableBuilder(
    column: $table.lastBibleNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastPersonalNote => $composableBuilder(
    column: $table.lastPersonalNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastStudyNote => $composableBuilder(
    column: $table.lastStudyNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSearch => $composableBuilder(
    column: $table.lastSearch,
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

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get lastSelectedBook => $composableBuilder(
    column: $table.lastSelectedBook,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSelectedChapter => $composableBuilder(
    column: $table.lastSelectedChapter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSelectedStudyBook => $composableBuilder(
    column: $table.lastSelectedStudyBook,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSelectedStudyChapter => $composableBuilder(
    column: $table.lastSelectedStudyChapter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSelectedMapName => $composableBuilder(
    column: $table.lastSelectedMapName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedStudyFont => $composableBuilder(
    column: $table.selectedStudyFont,
    builder: (column) => column,
  );

  GeneratedColumn<double> get selectedStudyFontSize => $composableBuilder(
    column: $table.selectedStudyFontSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selectedFont => $composableBuilder(
    column: $table.selectedFont,
    builder: (column) => column,
  );

  GeneratedColumn<double> get selectedFontSize => $composableBuilder(
    column: $table.selectedFontSize,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAutoScrollingEnabled => $composableBuilder(
    column: $table.isAutoScrollingEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get autoScrollMode => $composableBuilder(
    column: $table.autoScrollMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastBibleNote => $composableBuilder(
    column: $table.lastBibleNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastPersonalNote => $composableBuilder(
    column: $table.lastPersonalNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastStudyNote => $composableBuilder(
    column: $table.lastStudyNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSearch => $composableBuilder(
    column: $table.lastSearch,
    builder: (column) => column,
  );
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingsEntry,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingsEntry,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingsEntry>,
          ),
          SettingsEntry,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> theme = const Value.absent(),
                Value<String?> lastSelectedBook = const Value.absent(),
                Value<int?> lastSelectedChapter = const Value.absent(),
                Value<String?> lastSelectedStudyBook = const Value.absent(),
                Value<int?> lastSelectedStudyChapter = const Value.absent(),
                Value<String?> lastSelectedMapName = const Value.absent(),
                Value<String?> selectedStudyFont = const Value.absent(),
                Value<double?> selectedStudyFontSize = const Value.absent(),
                Value<String?> selectedFont = const Value.absent(),
                Value<double?> selectedFontSize = const Value.absent(),
                Value<bool?> isAutoScrollingEnabled = const Value.absent(),
                Value<String?> autoScrollMode = const Value.absent(),
                Value<String?> lastBibleNote = const Value.absent(),
                Value<String?> lastPersonalNote = const Value.absent(),
                Value<String?> lastStudyNote = const Value.absent(),
                Value<String?> lastSearch = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                theme: theme,
                lastSelectedBook: lastSelectedBook,
                lastSelectedChapter: lastSelectedChapter,
                lastSelectedStudyBook: lastSelectedStudyBook,
                lastSelectedStudyChapter: lastSelectedStudyChapter,
                lastSelectedMapName: lastSelectedMapName,
                selectedStudyFont: selectedStudyFont,
                selectedStudyFontSize: selectedStudyFontSize,
                selectedFont: selectedFont,
                selectedFontSize: selectedFontSize,
                isAutoScrollingEnabled: isAutoScrollingEnabled,
                autoScrollMode: autoScrollMode,
                lastBibleNote: lastBibleNote,
                lastPersonalNote: lastPersonalNote,
                lastStudyNote: lastStudyNote,
                lastSearch: lastSearch,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> theme = const Value.absent(),
                Value<String?> lastSelectedBook = const Value.absent(),
                Value<int?> lastSelectedChapter = const Value.absent(),
                Value<String?> lastSelectedStudyBook = const Value.absent(),
                Value<int?> lastSelectedStudyChapter = const Value.absent(),
                Value<String?> lastSelectedMapName = const Value.absent(),
                Value<String?> selectedStudyFont = const Value.absent(),
                Value<double?> selectedStudyFontSize = const Value.absent(),
                Value<String?> selectedFont = const Value.absent(),
                Value<double?> selectedFontSize = const Value.absent(),
                Value<bool?> isAutoScrollingEnabled = const Value.absent(),
                Value<String?> autoScrollMode = const Value.absent(),
                Value<String?> lastBibleNote = const Value.absent(),
                Value<String?> lastPersonalNote = const Value.absent(),
                Value<String?> lastStudyNote = const Value.absent(),
                Value<String?> lastSearch = const Value.absent(),
              }) => SettingsCompanion.insert(
                id: id,
                theme: theme,
                lastSelectedBook: lastSelectedBook,
                lastSelectedChapter: lastSelectedChapter,
                lastSelectedStudyBook: lastSelectedStudyBook,
                lastSelectedStudyChapter: lastSelectedStudyChapter,
                lastSelectedMapName: lastSelectedMapName,
                selectedStudyFont: selectedStudyFont,
                selectedStudyFontSize: selectedStudyFontSize,
                selectedFont: selectedFont,
                selectedFontSize: selectedFontSize,
                isAutoScrollingEnabled: isAutoScrollingEnabled,
                autoScrollMode: autoScrollMode,
                lastBibleNote: lastBibleNote,
                lastPersonalNote: lastPersonalNote,
                lastStudyNote: lastStudyNote,
                lastSearch: lastSearch,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
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
      SettingsEntry,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (
        SettingsEntry,
        BaseReferences<_$AppDatabase, $SettingsTable, SettingsEntry>,
      ),
      SettingsEntry,
      PrefetchHooks Function()
    >;
typedef $$BibleNotesTableCreateCompanionBuilder =
    BibleNotesCompanion Function({
      required String verse,
      required String verseText,
      required String note,
      Value<int> rowid,
    });
typedef $$BibleNotesTableUpdateCompanionBuilder =
    BibleNotesCompanion Function({
      Value<String> verse,
      Value<String> verseText,
      Value<String> note,
      Value<int> rowid,
    });

class $$BibleNotesTableFilterComposer
    extends Composer<_$AppDatabase, $BibleNotesTable> {
  $$BibleNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verseText => $composableBuilder(
    column: $table.verseText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BibleNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $BibleNotesTable> {
  $$BibleNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get verse => $composableBuilder(
    column: $table.verse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verseText => $composableBuilder(
    column: $table.verseText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BibleNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BibleNotesTable> {
  $$BibleNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get verse =>
      $composableBuilder(column: $table.verse, builder: (column) => column);

  GeneratedColumn<String> get verseText =>
      $composableBuilder(column: $table.verseText, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$BibleNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BibleNotesTable,
          BibleNoteEntry,
          $$BibleNotesTableFilterComposer,
          $$BibleNotesTableOrderingComposer,
          $$BibleNotesTableAnnotationComposer,
          $$BibleNotesTableCreateCompanionBuilder,
          $$BibleNotesTableUpdateCompanionBuilder,
          (
            BibleNoteEntry,
            BaseReferences<_$AppDatabase, $BibleNotesTable, BibleNoteEntry>,
          ),
          BibleNoteEntry,
          PrefetchHooks Function()
        > {
  $$BibleNotesTableTableManager(_$AppDatabase db, $BibleNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$BibleNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$BibleNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$BibleNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> verse = const Value.absent(),
                Value<String> verseText = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BibleNotesCompanion(
                verse: verse,
                verseText: verseText,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String verse,
                required String verseText,
                required String note,
                Value<int> rowid = const Value.absent(),
              }) => BibleNotesCompanion.insert(
                verse: verse,
                verseText: verseText,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BibleNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BibleNotesTable,
      BibleNoteEntry,
      $$BibleNotesTableFilterComposer,
      $$BibleNotesTableOrderingComposer,
      $$BibleNotesTableAnnotationComposer,
      $$BibleNotesTableCreateCompanionBuilder,
      $$BibleNotesTableUpdateCompanionBuilder,
      (
        BibleNoteEntry,
        BaseReferences<_$AppDatabase, $BibleNotesTable, BibleNoteEntry>,
      ),
      BibleNoteEntry,
      PrefetchHooks Function()
    >;
typedef $$PersonalNotesTableCreateCompanionBuilder =
    PersonalNotesCompanion Function({
      required String id,
      required String note,
      Value<int> rowid,
    });
typedef $$PersonalNotesTableUpdateCompanionBuilder =
    PersonalNotesCompanion Function({
      Value<String> id,
      Value<String> note,
      Value<int> rowid,
    });

class $$PersonalNotesTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalNotesTable> {
  $$PersonalNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonalNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalNotesTable> {
  $$PersonalNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonalNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalNotesTable> {
  $$PersonalNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$PersonalNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalNotesTable,
          PersonalNoteEntry,
          $$PersonalNotesTableFilterComposer,
          $$PersonalNotesTableOrderingComposer,
          $$PersonalNotesTableAnnotationComposer,
          $$PersonalNotesTableCreateCompanionBuilder,
          $$PersonalNotesTableUpdateCompanionBuilder,
          (
            PersonalNoteEntry,
            BaseReferences<
              _$AppDatabase,
              $PersonalNotesTable,
              PersonalNoteEntry
            >,
          ),
          PersonalNoteEntry,
          PrefetchHooks Function()
        > {
  $$PersonalNotesTableTableManager(_$AppDatabase db, $PersonalNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PersonalNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$PersonalNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$PersonalNotesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalNotesCompanion(id: id, note: note, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String note,
                Value<int> rowid = const Value.absent(),
              }) => PersonalNotesCompanion.insert(
                id: id,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonalNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalNotesTable,
      PersonalNoteEntry,
      $$PersonalNotesTableFilterComposer,
      $$PersonalNotesTableOrderingComposer,
      $$PersonalNotesTableAnnotationComposer,
      $$PersonalNotesTableCreateCompanionBuilder,
      $$PersonalNotesTableUpdateCompanionBuilder,
      (
        PersonalNoteEntry,
        BaseReferences<_$AppDatabase, $PersonalNotesTable, PersonalNoteEntry>,
      ),
      PersonalNoteEntry,
      PrefetchHooks Function()
    >;
typedef $$StudyNotesTableCreateCompanionBuilder =
    StudyNotesCompanion Function({
      required String id,
      required String note,
      Value<int> rowid,
    });
typedef $$StudyNotesTableUpdateCompanionBuilder =
    StudyNotesCompanion Function({
      Value<String> id,
      Value<String> note,
      Value<int> rowid,
    });

class $$StudyNotesTableFilterComposer
    extends Composer<_$AppDatabase, $StudyNotesTable> {
  $$StudyNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudyNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $StudyNotesTable> {
  $$StudyNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudyNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudyNotesTable> {
  $$StudyNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$StudyNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudyNotesTable,
          StudyNoteEntry,
          $$StudyNotesTableFilterComposer,
          $$StudyNotesTableOrderingComposer,
          $$StudyNotesTableAnnotationComposer,
          $$StudyNotesTableCreateCompanionBuilder,
          $$StudyNotesTableUpdateCompanionBuilder,
          (
            StudyNoteEntry,
            BaseReferences<_$AppDatabase, $StudyNotesTable, StudyNoteEntry>,
          ),
          StudyNoteEntry,
          PrefetchHooks Function()
        > {
  $$StudyNotesTableTableManager(_$AppDatabase db, $StudyNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$StudyNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$StudyNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$StudyNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudyNotesCompanion(id: id, note: note, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String note,
                Value<int> rowid = const Value.absent(),
              }) =>
                  StudyNotesCompanion.insert(id: id, note: note, rowid: rowid),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudyNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudyNotesTable,
      StudyNoteEntry,
      $$StudyNotesTableFilterComposer,
      $$StudyNotesTableOrderingComposer,
      $$StudyNotesTableAnnotationComposer,
      $$StudyNotesTableCreateCompanionBuilder,
      $$StudyNotesTableUpdateCompanionBuilder,
      (
        StudyNoteEntry,
        BaseReferences<_$AppDatabase, $StudyNotesTable, StudyNoteEntry>,
      ),
      StudyNoteEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$MapInfoEntriesTableTableManager get mapInfoEntries =>
      $$MapInfoEntriesTableTableManager(_db, _db.mapInfoEntries);
  $$GospelProfilesTableTableManager get gospelProfiles =>
      $$GospelProfilesTableTableManager(_db, _db.gospelProfiles);
  $$PrayersTableTableManager get prayers =>
      $$PrayersTableTableManager(_db, _db.prayers);
  $$VerseDataEntriesTableTableManager get verseDataEntries =>
      $$VerseDataEntriesTableTableManager(_db, _db.verseDataEntries);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$BibleNotesTableTableManager get bibleNotes =>
      $$BibleNotesTableTableManager(_db, _db.bibleNotes);
  $$PersonalNotesTableTableManager get personalNotes =>
      $$PersonalNotesTableTableManager(_db, _db.personalNotes);
  $$StudyNotesTableTableManager get studyNotes =>
      $$StudyNotesTableTableManager(_db, _db.studyNotes);
}
