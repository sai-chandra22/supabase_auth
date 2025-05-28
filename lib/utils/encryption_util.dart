import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';

class UrlCompressor {
  /// Your existing method, which compresses & Base64URL-encodes a JSON string.
  static String encode(String query) {
    final compressed = zlib.encode(utf8.encode(query));
    final encoded =
        base64Url.encode(Uint8List.fromList(compressed)).replaceAll('=', '');
    return encoded;
  }

  /// Your existing method, which decodes, decompresses, then JSON-decodes.
  static String decode(String encoded) {
    try {
      final padded = encoded.padRight((encoded.length + 3) ~/ 4 * 4, '=');
      final compressed = base64Url.decode(padded);
      final decompressed = utf8.decode(zlib.decode(compressed));
      final link = jsonDecode(decompressed);
      return link;
    } catch (e) {
      debugPrint('Error decoding: $e');
      return '';
    }
  }

  static String encodeNews(String input) {
    // 1) UTF-8 encode
    final data = utf8.encode(input);
    // 2) Compress via zlib
    final compressed = zlib.encode(data);
    // 3) Base64URL encode
    return base64Url.encode(Uint8List.fromList(compressed));
  }

  /// Decodes a string produced by [encode]. Throws if input is invalid.
  static String decodeNews(String encoded) {
    try {
      // 1) Normalize padding (adds `=` if missing)
      final normalized = base64Url.normalize(encoded);
      // 2) Base64URL decode to compressed bytes
      final compressed = base64Url.decode(normalized);
      // 3) zlib decompress
      final decompressed = zlib.decode(compressed);
      // 4) UTF-8 decode to original string
      return utf8.decode(decompressed);
    } catch (e) {
      debugPrint('UrlCompressor.decode error: $e');
      return '';
    }
  }

  /// ─── NEW ───
  /// Compress & Base64URL-encode *any* string (e.g. your AES ciphertext).
  static String encodeRaw(String input) {
    final compressed = zlib.encode(utf8.encode(input));
    return base64Url.encode(Uint8List.fromList(compressed)).replaceAll('=', '');
  }

  /// ─── NEW ───
  /// Reverse of encodeRaw: returns the original UTF-8 string (no JSON parsing).
  static String decodeRaw(String encoded) {
    try {
      final padded = encoded.padRight((encoded.length + 3) ~/ 4 * 4, '=');
      final compressed = base64Url.decode(padded);
      return utf8.decode(zlib.decode(compressed));
    } catch (e) {
      debugPrint('Error in decodeRaw: $e');
      return '';
    }
  }
}

/// Holds your AES-256 key (32 bytes) and IV (16 bytes), Base64-encoded.
/// Replace these Base64 strings with ones you generate securely.
class EncryptionUtil {
  // 32-byte key
  static const _base64Key = 'MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmRlZmY=';

  // 16-byte IV
  static const _base64Iv = 'YWJjZGVmMDEyMzQ1Njc4OQ==';

  /// The raw 32 bytes for AES-256
  static final List<int> sharedKeyBytes = base64.decode(_base64Key);

  /// The raw 16 bytes for AES-CBC IV
  static final List<int> sharedIvBytes = base64.decode(_base64Iv);
}
