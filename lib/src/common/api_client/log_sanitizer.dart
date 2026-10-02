/// Replacement for sensitive transport metadata in logs and telemetry.
const String kRedactedTransportLogValue = '[REDACTED]';

const _sensitiveHeaders = <String>{
  'authorization',
  'proxyauthorization',
  'cookie',
  'setcookie',
  'apikey',
  'xapikey',
  'xauthtoken',
};

const _sensitiveQueryParameters = <String>{
  'password',
  'repeatpassword',
  'newpassword',
  'oldpassword',
  'accesstoken',
  'refreshtoken',
  'idtoken',
  'token',
  'phone',
  'code',
  'secret',
  'signature',
  'credential',
  'awsaccesskeyid',
};

bool _isSensitive(String name, Set<String> names) {
  final normalized = name.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
  return names.contains(normalized) || normalized.startsWith('xamz') || normalized.startsWith('xgoog');
}

/// Returns a sanitized URI without changing the outgoing request.
String sanitizeUriForLogging(Uri uri) {
  try {
    return _sanitizeUriForLogging(uri);
  } on FormatException {
    return kRedactedTransportLogValue;
  }
}

String _sanitizeUriForLogging(Uri uri) {
  final query = uri.query
      .split('&')
      .map((part) {
        final separator = part.indexOf('=');
        final name = separator < 0 ? part : part.substring(0, separator);
        if (!_isSensitive(Uri.decodeQueryComponent(name), _sensitiveQueryParameters)) return part;
        return '$name=${Uri.encodeQueryComponent(kRedactedTransportLogValue)}';
      })
      .join('&');
  return uri
      .replace(
        query: uri.hasQuery ? query : null,
        userInfo: uri.userInfo.isEmpty ? null : Uri.encodeComponent(kRedactedTransportLogValue),
        fragment: uri.hasFragment ? kRedactedTransportLogValue : null,
      )
      .toString();
}

/// Redacts URL credentials embedded in diagnostic text without changing the
/// original exception or request. Uses the same policy as transport metadata.
String sanitizeTransportMessageForLogging(String message) =>
    message.replaceAllMapped(RegExp(r'''https?://[^\s<>"']+''', caseSensitive: false), (match) {
      final uri = Uri.tryParse(match.group(0)!);
      return uri == null ? kRedactedTransportLogValue : sanitizeUriForLogging(uri);
    });

/// Returns an immutable copy with sensitive header values removed.
Map<String, Object?> sanitizeHeadersForLogging(Map<String, Object?> headers) => Map<String, Object?>.unmodifiable({
  for (final entry in headers.entries)
    entry.key: _isSensitive(entry.key, _sensitiveHeaders) ? kRedactedTransportLogValue : entry.value,
});

/// Returns an immutable copy with sensitive query values removed.
Map<String, Object?> sanitizeQueryParametersForLogging(Map<String, Object?> parameters) =>
    Map<String, Object?>.unmodifiable({
      for (final entry in parameters.entries)
        entry.key: _isSensitive(entry.key, _sensitiveQueryParameters) ? kRedactedTransportLogValue : entry.value,
    });
