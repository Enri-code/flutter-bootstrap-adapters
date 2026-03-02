import 'package:bootstrap/interfaces/store/primitive_store.dart';

class KVInMemoryPrimitiveStore extends KVPrimitiveStore {
  static final _store = <String, dynamic>{};

  @override
  Future<V?> get<V>(String key) async {
    assertIsPrimitive(V);
    return _store[key] as V?;
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> set<V>(String key, V value) async {
    assertIsPrimitive(V);
    _store[key] = value;
  }
}

class KVInMemoryObjectStore<ObjectType> implements KVObjectStore<ObjectType> {
  static final _store = <String, dynamic>{};

  @override
  Future<ObjectType?> get(String key) async => _store[key] as ObjectType?;

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<void> set(String key, ObjectType value) async => _store[key] = value;
}

class InMemoryObjectStore<ObjectType> extends ObjectStore<ObjectType> {
  InMemoryObjectStore({String? key}) : _key = key ?? ObjectType.toString();

  static final _store = <String, dynamic>{};

  final String _key;

  @override
  Future<ObjectType?> get() async => _store[_key] as ObjectType?;

  @override
  Future<void> delete() async => _store.remove(_key);

  @override
  Future<void> set(ObjectType value) async => _store[_key] = value;
}
