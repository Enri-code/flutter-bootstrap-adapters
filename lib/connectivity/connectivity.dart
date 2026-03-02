import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bootstrap/interfaces/connectivity/connectivity.dart';

class ConnectivityAdapter implements IConnectivityService {
  ConnectivityAdapter(this._connectivity) {
    // Initialize the status immediately so [isConnected] is accurate from start
    unawaited(_getStatus());
  }

  final Connectivity _connectivity;

  // Internal state to track the last known status
  bool? _lastStatus;

  @override
  bool get isConnected => _lastStatus ?? false;

  Future<bool> _getStatus() async {
    return _lastStatus ??= _calculateIsConnected(
      await _connectivity.checkConnectivity(),
    );
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged
        .map(_calculateIsConnected)
        .handleError((_) => false) // Fail-safe for platform errors
        .asBroadcastStream(); // Essential: allows multiple NetworkTasks to listen
  }

  /// Logic to determine if we are "online" based on connection type
  bool _calculateIsConnected(List<ConnectivityResult> results) {
    // Note: In newer versions of connectivity_plus, it returns a List
    final connected = results.any((result) {
      return result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet;
    });

    _lastStatus = connected;
    return connected;
  }
}
