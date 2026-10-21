import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('map transforms Ok value', () {
      const Result<int> result = Ok(2);

      expect(result.map((v) => v * 10), const Ok(20));
    });

    test('map passes Err through without calling transform', () {
      const Result<int> result = Err(NetworkFailure());
      var called = false;

      final mapped = result.map((v) {
        called = true;
        return v.toString();
      });

      expect(mapped, const Err<String>(NetworkFailure()));
      expect(called, isFalse);
    });

    test('exhaustive switch reads value or failure', () {
      String describe(Result<String> r) => switch (r) {
            Ok(:final value) => 'ok:$value',
            Err(:final failure) => 'err:${failure.runtimeType}',
          };

      expect(describe(const Ok('a')), 'ok:a');
      expect(describe(const Err(ForbiddenFailure())), 'err:ForbiddenFailure');
    });
  });

  group('Failure', () {
    test('every failure has a non-empty Turkish user message', () {
      const failures = <Failure>[
        NetworkFailure(),
        UnauthorizedFailure(),
        ForbiddenFailure(),
        NotFoundFailure(),
        RateLimitedFailure(),
        RuleFailure('group.full', 'Grup dolu.'),
        UnexpectedFailure(),
      ];

      for (final f in failures) {
        expect(f.userMessage.trim(), isNotEmpty, reason: '$f');
      }
    });

    test('UnexpectedFailure does not leak its cause to the user', () {
      final failure = UnexpectedFailure(StateError('db password=secret'));

      expect(failure.userMessage, isNot(contains('secret')));
    });
  });
}
