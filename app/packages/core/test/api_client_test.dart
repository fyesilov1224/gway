import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

ApiClient _client(
  Future<http.Response> Function(http.Request) handler, {
  String? token = 'tok',
}) =>
    ApiClient(
      baseUrl: Uri.parse('http://api.test/'),
      accessToken: () => token,
      httpClient: MockClient(handler),
    );

http.Response _problem(int status, String code, String title) => http.Response(
      jsonEncode({'status': status, 'code': code, 'title': title}),
      status,
      headers: {'content-type': 'application/problem+json; charset=utf-8'},
    );

void main() {
  test('sends bearer token and decodes success', () async {
    late http.Request sent;
    final client = _client((req) async {
      sent = req;
      return http.Response('{"status":"active"}', 200);
    });

    final result = await client.get(
      '/account',
      decode: (json) => (json! as Map)['status'],
    );

    expect(result, const Ok<Object?>('active'));
    expect(sent.url.toString(), 'http://api.test/account');
    expect(sent.headers['Authorization'], 'Bearer tok');
  });

  test('omits Authorization header when signed out', () async {
    late http.Request sent;
    final client = _client(
      (req) async {
        sent = req;
        return http.Response('', 204);
      },
      token: null,
    );

    await client.delete('/x', decode: (_) => null);

    expect(sent.headers.containsKey('Authorization'), isFalse);
  });

  test('rule violations keep the backend code and Turkish title', () async {
    final client = _client(
      (_) async => _problem(422, 'account.suspended', 'Askıdaki hesap.'),
    );

    final result = await client.post('/account/deletion', decode: (_) => 1);

    expect(result, const Err<int>(RuleFailure('account.suspended', 'Askıdaki hesap.')));
  });

  test('status codes map to typed failures', () {
    expect(failureFromProblem(401, ''), const UnauthorizedFailure());
    expect(failureFromProblem(403, ''), const ForbiddenFailure());
    expect(failureFromProblem(404, ''), const NotFoundFailure());
    expect(failureFromProblem(429, ''), const RateLimitedFailure());
    expect(failureFromProblem(500, 'stack trace...'), isA<UnexpectedFailure>());
    // 503 with ProblemDetails is a curated "try later" message (e.g. payments).
    expect(
      failureFromProblem(503, '{"code":"billing.provider_unavailable","title":"Ödeme şu anda alınamıyor."}'),
      const RuleFailure('billing.provider_unavailable', 'Ödeme şu anda alınamıyor.'),
    );
    expect(failureFromProblem(503, 'Service Unavailable'), isA<UnexpectedFailure>());
  });

  test('non-ProblemDetails error bodies never reach the user', () {
    final failure = failureFromProblem(400, '<html>Bad gateway</html>');

    expect(failure, isA<UnexpectedFailure>());
    expect(failure.userMessage, isNot(contains('html')));
  });

  test('network errors become NetworkFailure', () async {
    final client = _client((_) async => throw http.ClientException('down'));

    final result = await client.get('/account', decode: (_) => 1);

    expect(result, const Err<int>(NetworkFailure()));
  });

  test('waits for the token getter, so an expired session is refreshed first', () async {
    late http.Request sent;
    final client = ApiClient(
      baseUrl: Uri.parse('http://api.test/'),
      accessToken: () async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return 'fresh';
      },
      httpClient: MockClient((req) async {
        sent = req;
        return http.Response('{}', 200);
      }),
    );

    await client.get('/account', decode: (json) => json);

    expect(sent.headers['Authorization'], 'Bearer fresh');
  });
}
