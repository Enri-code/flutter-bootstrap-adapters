import 'dart:convert';
import 'dart:io';

import 'package:bootstrap/interfaces/store/primitive_store.dart';
import 'package:flutter/foundation.dart';
import 'in_memory_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef FromJson<ObjectType> = ObjectType? Function(Map<String, dynamic> json);
typedef ToJson<ObjectType> = Map<String, dynamic>? Function(ObjectType? object);

KVPrimitiveStore createKVPrimitiveStore() {
  if (Platform.isAndroid && kDebugMode) {
    return KVInMemoryPrimitiveStore();
  }
  return KVSharedPrefsPrimitiveStore();
}

KVObjectStore<ObjectType> createKVObjectStore<ObjectType>({
  required FromJson<ObjectType> fromJson,
  required ToJson<ObjectType> toJson,
}) {
  if (Platform.isAndroid && kDebugMode) {
    return KVInMemoryObjectStore<ObjectType>();
  }
  return KVSharedPrefsObjectStore<ObjectType>(fromJson, toJson);
}

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

    if (V case const (bool)) {
      await prefs.setBool(key, value as bool);
    } else if (V case const (int)) {
      await prefs.setInt(key, value as int);
    } else if (V case const (double)) {
      await prefs.setDouble(key, value as double);
    } else if (V case const (String)) {
      await prefs.setString(key, value as String);
    } else if (V case const (List<String>)) {
      await prefs.setStringList(key, value as List<String>);
    } else {
      throw UnsupportedError(
        'KVSharedPrefsPrimitiveStore: $V is not supported',
      );
    }
  }
}

class SharedPrefsPrimitiveStore<V> extends PrimitiveStore<V> {
  SharedPrefsPrimitiveStore(this.key, [KVPrimitiveStore? store])
    : store = store ?? createKVPrimitiveStore();

  final String key;

  final KVPrimitiveStore store;

  @override
  Future<void> delete() => store.delete(key);

  @override
  Future<V?> get() => store.get(key);

  @override
  Future<void> set(V value) => store.set(key, value);
}

class KVSharedPrefsObjectStore<ObjectType>
    implements KVObjectStore<ObjectType> {
  KVSharedPrefsObjectStore(this._fromJson, this._toJson);

  final FromJson<ObjectType> _fromJson;
  final ToJson<ObjectType> _toJson;

  @override
  Future<ObjectType?> get(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    return data == null
        ? null
        : _fromJson(jsonDecode(data) as Map<String, dynamic>);
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

ObjectStore<ObjectType> createObjectStore<ObjectType>({
  required KVSharedPrefsObjectStore<ObjectType> store,
  String? key,
}) {
  if (Platform.isAndroid && kDebugMode) {
    return InMemoryObjectStore<ObjectType>(key: key);
  }
  return SharedPrefsObjectStore(store, key: key);
}

class SharedPrefsObjectStore<ObjectType> implements ObjectStore<ObjectType> {
  SharedPrefsObjectStore(this._store, {String? key})
    : _key = key ?? ObjectType.toString();

  final String _key;
  final KVSharedPrefsObjectStore<ObjectType> _store;

  @override
  Future<ObjectType?> get() => _store.get(_key);

  @override
  Future<void> delete() => _store.delete(_key);

  @override
  Future<void> set(ObjectType value) => _store.set(_key, value);
}
