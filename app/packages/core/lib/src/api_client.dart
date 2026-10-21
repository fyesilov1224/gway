import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'failure.dart';
import 'result.dart';

/// Client for the GrupX C# API.
///
/// Attaches the Supabase access token and maps RFC 9457 ProblemDetails to
/// [Failure]. Problem titles are curated Turkish messages written by the
/// backend, so they are safe to show; anything else becomes a generic failure.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required String? Function() accessToken,
    http.Client? httpClient,
  })  : _accessToken = accessToken,
        _http = httpClient ?? http.Client();

  final Uri baseUrl;
  final String? Function() _accessToken;
  final http.Client _http;

  static const _timeout = Duration(seconds: 20);

  Future<Result<T>> get<T>(
    String path, {
    Map<String, String>? query,
    required T Function(Object? json) decode,
  }) =>
      _send('GET', path, query: query, decode: decode);

  Future<Result<T>> post<T>(
    String path, {
    Object? body,
    required T Function(Object? json) decode,
  }) =>
      _send('POST', path, body: body, decode: decode);

  Future<Result<T>> put<T>(
    String path, {
    Object? body,
    required T Function(Object? json) decode,
  }) =>
      _send('PUT', path, body: body, decode: decode);

  Future<Result<T>> patch<T>(
    String path, {
    Object? body,
    required T Function(Object? json) decode,
  }) =>
      _send('PATCH', path, body: body, decode: decode);

  Future<Result<T>> delete<T>(
    String path, {
    required T Function(Object? json) decode,
  }) =>
      _send('DELETE', path, decode: decode);

  void close() => _http.close();

  Future<Result<T>> _send<T>(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    required T Function(Object? json) decode,
  }) async {
    final uri = baseUrl.replace(
      path: '${baseUrl.path.replaceAll(RegExp(r'/$'), '')}$path',
      queryParameters: query == null || query.isEmpty ? null : query,
    );
    final request = http.Request(method, uri)
      ..headers['Accept'] = 'application/json';
    final token = _accessToken();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _http.send(request).timeout(_timeout),
      );
    } on TimeoutException {
      return const Err(NetworkFailure());
    } on http.ClientException {
      return const Err(NetworkFailure());
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final json = response.body.isEmpty ? null : jsonDecode(response.body);
        return Ok(decode(json));
      } on Object catch (e) {
        return Err(UnexpectedFailure(e));
      }
    }
    return Err(failureFromProblem(response.statusCode, response.body));
  }
}

/// Maps an HTTP error response to a [Failure].
Failure failureFromProblem(int status, String body) {
  switch (status) {
    case 401:
      return const UnauthorizedFailure();
    case 403:
      return const ForbiddenFailure();
    case 404:
      return const NotFoundFailure();
    case 429:
      return const RateLimitedFailure();
  }
  // 503 carries a curated message (e.g. payments temporarily unavailable).
  if (status >= 500 && status != 503) return UnexpectedFailure('HTTP $status');

  try {
    final json = jsonDecode(body);
    if (json is Map<String, Object?>) {
      final code = json['code'];
      final title = json['title'];
      if (code is String && title is String && title.isNotEmpty) {
        return RuleFailure(code, title);
      }
    }
  } on FormatException {
    // Not ProblemDetails; fall through.
  }
  return UnexpectedFailure('HTTP $status');
}
