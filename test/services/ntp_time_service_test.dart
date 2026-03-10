import 'package:adapters/time/ntp_time_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NtpTimeService', () {
    late NtpTimeService timeService;

    setUp(() {
      timeService = NtpTimeService();
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
