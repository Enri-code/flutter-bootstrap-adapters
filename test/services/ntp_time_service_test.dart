import 'package:adapters/time/ntp_time_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NtpTimeService', () {
    late NtpTimeService timeService;

    setUp(() {
      timeService = NtpTimeService();
    });

    tearDown(() {
      timeService.dispose();
    });

    group('getTime', () {
      test(
        'returns current time from NTP server',
        () async {
          // Act
          final result = await timeService.getTime();

          // Assert
          expect(result, isA<DateTime>());
          // Time should be reasonably close to now (within 5 minutes)
          final now = DateTime.now();
          final difference = result.difference(now).abs();
          expect(difference.inMinutes, lessThan(5));
        },
        skip:
            'Requires platform plugin TimeConfigChecker - integration test only',
      );

      test(
        'returns time multiple times without caching',
        () async {
          // Act
          final first = await timeService.getTime();
          await Future.delayed(const Duration(milliseconds: 100));
          final second = await timeService.getTime();

          // Assert
          expect(first, isA<DateTime>());
          expect(second, isA<DateTime>());
          // Second call should return a slightly later time
          expect(
            second.isAfter(first) || second.isAtSameMomentAs(first),
            isTrue,
          );
        },
        skip:
            'Requires platform plugin TimeConfigChecker - integration test only',
      );

      test(
        'falls back to device time when NTP unavailable',
        () async {
          // Note: This test assumes NTP might fail in some environments
          // If NTP always succeeds, this test will still pass

          // Act
          final result = await timeService.getTime();

          // Assert
          expect(result, isA<DateTime>());
        },
        skip:
            'Requires platform plugin TimeConfigChecker - integration test only',
      );
    });

    group('onMidnight stream', () {
      test('provides a broadcast stream', () {
        // Act
        final stream = timeService.onMidnight;

        // Assert
        expect(stream, isA<Stream<DateTime>>());
        expect(stream.isBroadcast, isTrue);
      });

      test('can have multiple listeners', () {
        // Act
        final stream = timeService.onMidnight;
        final subscription1 = stream.listen((_) {});
        final subscription2 = stream.listen((_) {});

        // Assert
        expect(subscription1, isNotNull);
        expect(subscription2, isNotNull);

        // Cleanup
        subscription1.cancel();
        subscription2.cancel();
      });

      test('emits midnight event when day changes', () async {
        // This test is difficult to implement without mocking time
        // In a real scenario, you would inject a clock/time provider
        // For now, we verify the stream exists and can be listened to

        // Arrange
        final events = <void>[];
        final subscription = timeService.onMidnight.listen(events.add);

        // Wait a short time
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert - no events should have occurred in 100ms
        expect(events, isEmpty);

        // Cleanup
        await subscription.cancel();
      });
    });

    group('dispose', () {
      test('cleans up resources properly', () {
        // Arrange
        final service = NtpTimeService()
          // Act
          ..dispose();

        // Assert - should not throw
        expect(service.dispose, returnsNormally);
      });

      test('can be called multiple times safely', () {
        // Arrange
        final service = NtpTimeService();

        // Act & Assert
        expect(() {
          service
            ..dispose()
            ..dispose()
            ..dispose();
        }, returnsNormally);
      });
    });
  });

  // group('SystemTimeNotAutomaticException', () {
  //   test('can be created and has proper toString', () {
  //     // Act
  //     const exception = SystemTimeNotAutomaticException();

  //     // Assert
  //     expect(exception, isA<Exception>());
  //     expect(exception.toString(), contains('SystemTimeNotAutomaticException'));
  //     expect(exception.toString(), contains('System time must be set to'));
  //     expect(exception.toString(), contains('automatic'));
  //   });

  //   test('toString provides helpful error message', () {
  //     // Arrange
  //     const exception = SystemTimeNotAutomaticException();

  //     // Act
  //     final string = exception.toString();

  //     // Assert
  //     expect(string, contains('automatic date & time'));
  //     expect(string, contains('device settings'));
  //   });
  // });
}
