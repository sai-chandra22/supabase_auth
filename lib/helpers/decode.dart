import 'dart:convert';

import 'package:flutter/material.dart';

String? decodeJWTAndGetEmail(String jwt) {
  try {
    // Split the JWT into parts: header, payload, signature
    final parts = jwt.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT');
    }

    // The payload is the second part of the token
    final payload = parts[1];

    // Decode the Base64Url-encoded payload
    final normalizedPayload = base64Url.normalize(payload);
    final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));

    // Parse the JSON from the payload
    final payloadMap = json.decode(decodedPayload) as Map<String, dynamic>;

    // Extract the email from the payload
    final email = payloadMap['email'] as String?;
    debugPrint('Email: $email');

    return email; // Return the email if it exists, or null if not found
  } catch (e) {
    debugPrint('Error decoding JWT: $e');
    return null; // Return null if there is an error or no email
  }
}
