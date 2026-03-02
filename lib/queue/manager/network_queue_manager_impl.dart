import 'dart:async';
import 'package:bootstrap/interfaces/connectivity/connectivity.dart';
import 'package:bootstrap/interfaces/queue/manager/network_queue_manager.dart';
import 'package:bootstrap/interfaces/queue/queue_task_registry.dart';
import '../runner/queue_runner.dart';

class NetworkQueueManagerImpl implements NetworkQueueManager {
  NetworkQueueManagerImpl({
    required this.connectivity,
    required this.runner,
    required QueueTaskRegistry registry,
  }) {
    registry.register(NetworkQueueTaskHandler());
    _setupQueueListener();
  }

  final IConnectivityService connectivity;
  final QueueRunner runner;

  StreamSubscription<bool>? _connectivitySub;
  StreamSubscription<void>? _queueSubscription;

  bool _isRunning = false;

  /// Sets up listener to auto-start when queue has items
  void _setupQueueListener() {
    _queueSubscription ??= runner.tasksStream.listen((tasks) {
      final networkTasks = tasks.whereType<NetworkQueueTask>();
      if (networkTasks.isNotEmpty && !_isRunning) {
        start();
      } else if (networkTasks.isEmpty && _isRunning) {
        close();
      }
    });
  }

  @override
  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;

    _connectivitySub ??= connectivity.onConnectivityChanged.listen((connected) {
      if (connected) runner.run();
    });
    if (connectivity.isConnected) await runner.run();
  }

  @override
  void close() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
    _isRunning = false;
  }

  void dispose() {
    _queueSubscription?.cancel();
    close();
  }
}
