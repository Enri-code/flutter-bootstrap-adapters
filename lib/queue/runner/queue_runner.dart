import 'dart:async';
import 'dart:collection';

import 'package:bootstrap/interfaces/queue/base_queue_runner.dart';
import 'package:bootstrap/interfaces/queue/queue_task.dart';

class QueueRunner extends BaseQueueRunner {
  QueueRunner(super.registry);

  final List<QueueTask> _tasks = [];
  final _controller = StreamController<List<QueueTask>>.broadcast();

  /// Stream that emits the current queue size whenever it changes
  Stream<List<QueueTask>> get tasksStream => _controller.stream;

  void enqueue(QueueTask task) {
    _tasks.add(task);
    _controller.add(_tasks);
  }

  @override
  Future<List<QueueTask>> getTasks() async => UnmodifiableListView(_tasks);

  @override
  Future<void> onSuccess(QueueTask task) async {
    _tasks.remove(task);
    _controller.add(_tasks);
  }

  @override
  Future<void> onRetry(QueueTask task) async {
    _tasks
      ..remove(task)
      ..add(task);
  }

  @override
  Future<void> onFail(QueueTask task) async {
    _tasks.remove(task);
    _controller.add(_tasks);
  }

  void dispose() {
    _controller.close();
  }
}
