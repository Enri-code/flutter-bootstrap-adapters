import 'dart:convert';
import 'dart:io';

import 'package:bootstrap/interfaces/store/store.dart';
import 'package:flutter/foundation.dart';
import 'in_memory_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'store_mixins.dart';

typedef FromJson<ObjectType> = ObjectType? Function(Map<String, dynamic> json);
typedef ToJson<ObjectType> = Map<String, dynamic>? Function(ObjectType? object);

/// --- Factories ---

/// Creates a [KVPrimitiveStore].
KVPrimitiveStore createKVPrimitiveStore() {
  if (kDebugMode && Platform.isAndroid) {
    return KVInMemoryPrimitiveStore();
  }
  return KVSharedPrefsPrimitiveStore();
}

/// Creates a [StreamableKVPrimitiveStore].
StreamableKVPrimitiveStore createStreamableKVPrimitiveStore() {
  if (kDebugMode && Platform.isAndroid) {
    return StreamableKVInMemoryPrimitiveStore();
  }
  return StreamableKVSharedPrefsPrimitiveStore();
}

/// Creates a [KVObjectStore].
KVObjectStore<ObjectType> createKVObjectStore<ObjectType>({
  required FromJson<ObjectType> fromJson,
  required ToJson<ObjectType> toJson,
}) {
  if (kDebugMode && Platform.isAndroid) {
    return KVInMemoryObjectStore<ObjectType>();
  }
  return KVSharedPrefsObjectStore<ObjectType>(fromJson, toJson);
}

/// Creates a [StreamableKVObjectStore].
StreamableKVObjectStore<ObjectType> createStreamableKVObjectStore<ObjectType>({
  required FromJson<ObjectType> fromJson,
  required ToJson<ObjectType> toJson,
}) {
  if (kDebugMode && Platform.isAndroid) {
    return StreamableKVInMemoryObjectStore<ObjectType>();
  }
  return StreamableKVSharedPrefsObjectStore<ObjectType>(fromJson, toJson);
}

/// Creates a [PrimitiveStore].
PrimitiveStore<V> createPrimitiveStore<V>({required String key}) {
  return SharedPrefsPrimitiveStore<V>(key, createKVPrimitiveStore());
}

/// Creates a [StreamablePrimitiveStore].
StreamablePrimitiveStore<V> createStreamablePrimitiveStore<V>({
  required String key,
}) {
  return StreamableSharedPrefsPrimitiveStore<V>(
    key,
    createStreamableKVPrimitiveStore(),
  );
}

/// Creates an [ObjectStore].
ObjectStore<ObjectType> createObjectStore<ObjectType>({
  required FromJson<ObjectType> fromJson,
  required ToJson<ObjectType> toJson,
  String? key,
}) {
  if (kDebugMode && Platform.isAndroid) {
    return InMemoryObjectStore<ObjectType>(key: key);
  }
  return SharedPrefsObjectStore<ObjectType>(fromJson, toJson, key: key);
}

/// Creates a [StreamableObjectStore].
StreamableObjectStore<ObjectType> createStreamableObjectStore<ObjectType>({
  required FromJson<ObjectType> fromJson,
  required ToJson<ObjectType> toJson,
  String? key,
}) {
  if (kDebugMode && Platform.isAndroid) {
    return StreamableInMemoryObjectStore<ObjectType>(key: key);
  }
  return StreamableSharedPrefsObjectStore<ObjectType>(fromJson, toJson, key: key);
}

/// --- Implementations ---

/// Shared Preferences implementation of [KVPrimitiveStore].
class KVSharedPrefsPrimitiveStore extends KVPrimitiveStore {
  @override
  Future<V?> get<V>(String key) async {
    assertIsPrimitive(V);
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) as V?;
  }

  @override
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  @override
  Future<void> set<V>(String key, V value) async {
    assertIsPrimitive(V);
    final prefs = await SharedPreferences.getInstance();

    if (V == bool) {
      await prefs.setBool(key, value as bool);
    } else if (V == int) {
      await prefs.setInt(key, value as int);
    } else if (V == double) {
      await prefs.setDouble(key, value as double);
    } else if (V == String) {
      await prefs.setString(key, value as String);
    } else if (V == List<String>) {
      await prefs.setStringList(key, value as List<String>);
    } else {
      throw UnsupportedError('Unsupported type: $V');
    }
  }
}

/// Streamable version of [KVSharedPrefsPrimitiveStore].
class StreamableKVSharedPrefsPrimitiveStore extends KVSharedPrefsPrimitiveStore
    with KVPrimitiveStoreStreamMixin
    implements StreamableKVPrimitiveStore {}

/// Shared Preferences implementation of [PrimitiveStore].
class SharedPrefsPrimitiveStore<V> extends PrimitiveStore<V> {
  SharedPrefsPrimitiveStore(this.key, [KVPrimitiveStore? store])
    : _store = store ?? createKVPrimitiveStore();

  final String key;
  final KVPrimitiveStore _store;

  @override
  Future<void> delete() => _store.delete(key);

  @override
  Future<V?> get() => _store.get<V>(key);

  @override
  Future<void> set(V value) => _store.set<V>(key, value);
}

/// Streamable version of [SharedPrefsPrimitiveStore].
class StreamableSharedPrefsPrimitiveStore<V> extends SharedPrefsPrimitiveStore<V>
    with PrimitiveStoreStreamMixin<V>
    implements StreamablePrimitiveStore<V> {
  StreamableSharedPrefsPrimitiveStore(super.key, [super.store]);
}

/// Shared Preferences implementation of [KVObjectStore].
class KVSharedPrefsObjectStore<ObjectType> extends KVObjectStore<ObjectType> {
  KVSharedPrefsObjectStore(this._fromJson, this._toJson);

  final FromJson<ObjectType> _fromJson;
  final ToJson<ObjectType> _toJson;

  @override
  Future<ObjectType?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data == null) return null;
    return _fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  @override
  Future<void> set(String key, ObjectType value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(_toJson(value)));
  }
}

/// Streamable version of [KVSharedPrefsObjectStore].
class StreamableKVSharedPrefsObjectStore<ObjectType>
    extends KVSharedPrefsObjectStore<ObjectType>
    with KVObjectStoreStreamMixin<ObjectType>
    implements StreamableKVObjectStore<ObjectType> {
  StreamableKVSharedPrefsObjectStore(super.fromJson, super.toJson);
}

/// Shared Preferences implementation of [ObjectStore].
class SharedPrefsObjectStore<ObjectType> extends ObjectStore<ObjectType> {
  SharedPrefsObjectStore(
    FromJson<ObjectType> fromJson,
    ToJson<ObjectType> toJson, {
    String? key,
  }) : _key = key ?? ObjectType.toString(),
       _store = KVSharedPrefsObjectStore<ObjectType>(fromJson, toJson);

  final String _key;
  final KVSharedPrefsObjectStore<ObjectType> _store;

  @override
  Future<ObjectType?> get() => _store.get(_key);

  @override
  Future<void> delete() => _store.delete(_key);

  @override
  Future<void> set(ObjectType value) => _store.set(_key, value);
}

/// Streamable version of [SharedPrefsObjectStore].
class StreamableSharedPrefsObjectStore<ObjectType>
    extends SharedPrefsObjectStore<ObjectType>
    with ObjectStoreStreamMixin<ObjectType>
    implements StreamableObjectStore<ObjectType> {
  StreamableSharedPrefsObjectStore(
    super.fromJson,
    super.toJson, {
    super.key,
  });
}
