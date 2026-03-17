import 'package:bootstrap/interfaces/store/store.dart';
import 'store_mixins.dart';

/// In-memory implementation of [KVPrimitiveStore].
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

/// Streamable version of [KVInMemoryPrimitiveStore].
class StreamableKVInMemoryPrimitiveStore extends KVInMemoryPrimitiveStore
    with KVPrimitiveStoreStreamMixin
    implements StreamableKVPrimitiveStore {}

/// In-memory implementation of [KVObjectStore].
class KVInMemoryObjectStore<ObjectType> extends KVObjectStore<ObjectType> {
  static final _store = <String, dynamic>{};

  @override
  Future<ObjectType?> get(String key) async {
    return _store[key] as ObjectType?;
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> set(String key, ObjectType value) async {
    _store[key] = value;
  }
}

/// Streamable version of [KVInMemoryObjectStore].
class StreamableKVInMemoryObjectStore<ObjectType>
    extends KVInMemoryObjectStore<ObjectType>
    with KVObjectStoreStreamMixin<ObjectType>
    implements StreamableKVObjectStore<ObjectType> {}

/// In-memory implementation of [ObjectStore].
class InMemoryObjectStore<ObjectType> extends ObjectStore<ObjectType> {
  InMemoryObjectStore({String? key})
    : _key = key ?? ObjectType.toString();

  static final _store = <String, dynamic>{};
  final String _key;

  @override
  Future<ObjectType?> get() async {
    return _store[_key] as ObjectType?;
  }

  @override
  Future<void> delete() async {
    _store.remove(_key);
  }

  @override
  Future<void> set(ObjectType value) async {
    _store[_key] = value;
  }
}

/// Streamable version of [InMemoryObjectStore].
class StreamableInMemoryObjectStore<ObjectType>
    extends InMemoryObjectStore<ObjectType>
    with ObjectStoreStreamMixin<ObjectType>
    implements StreamableObjectStore<ObjectType> {
  StreamableInMemoryObjectStore({super.key});
}
