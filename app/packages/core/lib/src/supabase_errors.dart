import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'failure.dart';

/// Generic mapping of Supabase / network errors to [Failure].
///
/// Features handle their own expected cases first (e.g. a taken username)
/// and fall back to this.
Failure failureFromSupabase(Object error) => switch (error) {
      http.ClientException() || TimeoutException() => const NetworkFailure(),
      AuthException(statusCode: '429') => const RateLimitedFailure(),
      AuthException(statusCode: '401' || '403') => const UnauthorizedFailure(),
      PostgrestException(code: '42501') => const ForbiddenFailure(),
      PostgrestException(code: 'PGRST116') => const NotFoundFailure(),
      PostgrestException(code: 'PGRST301' || 'PGRST303') =>
        const UnauthorizedFailure(),
      StorageException(statusCode: '403') => const ForbiddenFailure(),
      StorageException(statusCode: '413') => const RuleFailure(
          'storage.too_large',
          'Dosya çok büyük. En fazla 5 MB yükleyebilirsin.',
        ),
      StorageException(statusCode: '415') => const RuleFailure(
          'storage.unsupported_type',
          'Bu dosya türü desteklenmiyor. JPEG, PNG veya WebP seç.',
        ),
      _ => UnexpectedFailure(error),
    };
