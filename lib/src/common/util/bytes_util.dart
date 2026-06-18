// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:meta/meta.dart';

@internal
abstract final class BytesUtil {
  /// Extract hash from a [Uint8List] and convert it to a hex string.
  static String sha256(Uint8List bytes) {
    if (bytes.isEmpty) return 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
    var digest = crypto.sha256.convert(bytes);
    return digest.toString();
  }
}
