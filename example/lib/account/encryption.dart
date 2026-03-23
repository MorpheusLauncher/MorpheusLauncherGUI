library account_file;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart';
import 'package:morpheus_launcher_gui/account/account_utils.dart';

// ---------------------------------------------------------------------------
// Helpers cifratura token
// ---------------------------------------------------------------------------

enc.Encrypter _buildEncrypter() {
  final hash = md5.convert(utf8.encode(getHWID()));
  // md5 produce 32 caratteri hex → chiave AES-256 valida
  final key = enc.Key.fromUtf8(hash.toString());

  return enc.Encrypter(enc.AES(key));
}

// IV fisso e derivato dall'HWID (primi 16 byte dell'hash)
enc.IV _buildIV() {
  final hash = md5.convert(utf8.encode(getHWID()));

  return enc.IV(Uint8List.fromList(hash.bytes));
}

String encryptToken(String token) {
  if (token.isEmpty) return '';

  return _buildEncrypter().encrypt(token, iv: _buildIV()).base64;
}

String decryptToken(String encryptedBase64) {
  if (encryptedBase64.isEmpty) return '';

  return _buildEncrypter().decrypt64(encryptedBase64, iv: _buildIV());
}

// ---------------------------------------------------------------------------
// Serializzazione con token cifrati
// ---------------------------------------------------------------------------

Map<String, dynamic> _toJsonWithEncryptedTokens(Account account) {
  final plain = account.toJson();
  plain['accessToken'] = encryptToken(plain['accessToken'] as String);
  plain['refreshToken'] = encryptToken(plain['refreshToken'] as String);

  return plain;
}

Account _fromJsonWithEncryptedTokens(Map<String, dynamic> json) {
  final copy = Map<String, dynamic>.from(json);
  try {
    copy['accessToken'] = decryptToken(copy['accessToken'] as String);
    copy['refreshToken'] = decryptToken(copy['refreshToken'] as String);
  } catch (e) {
    debugPrint("Token decryption failed for '${copy['username']}': $e");
    copy['accessToken'] = '';
    copy['refreshToken'] = '';
  }

  return Account.fromJson(copy);
}

// ---------------------------------------------------------------------------
// I/O su disco
// ---------------------------------------------------------------------------

void saveAccountListToJson(List<Account> accountList, String filePath) {
  final jsonString = const JsonEncoder.withIndent('  ').convert(
    accountList.map(_toJsonWithEncryptedTokens).toList(),
  );

  final file = File(filePath);
  if (!file.existsSync()) file.createSync(recursive: true);
  file.writeAsStringSync(jsonString);
}

/// Restituisce null se la lettura/decifratura fallisce, [] se il file non esiste.
List<Account>? readAccountListFromJson(String filePath) {
  final file = File(filePath);
  if (!file.existsSync()) return [];

  try {
    final bytes = file.readAsBytesSync();

    // Prova a decodificare come UTF-8 — se fallisce è il vecchio formato binario
    final String jsonString;
    try {
      jsonString = utf8.decode(bytes);
    } catch (_) {
      debugPrint("Account file is in old binary format, resetting.");
      saveAccountListToJson([], filePath);

      return null;
    }

    return (json.decode(jsonString) as List).map((j) => _fromJsonWithEncryptedTokens(j as Map<String, dynamic>)).toList();
  } catch (e) {
    debugPrint("Account file read failed: $e");
    saveAccountListToJson([], filePath);

    return null;
  }
}

// ---------------------------------------------------------------------------

String getHWID() {
  return '${Platform.environment['USERNAME']}'
      '${Platform.environment['SystemRoot']}'
      '${Platform.environment['HOMEDRIVE']}'
      '${Platform.environment['PROCESSOR_LEVEL']}'
      '${Platform.environment['PROCESSOR_REVISION']}'
      '${Platform.environment['PROCESSOR_IDENTIFIER']}'
      '${Platform.environment['PROCESSOR_ARCHITECTURE']}'
      '${Platform.environment['PROCESSOR_ARCHITEW6432']}'
      '${Platform.numberOfProcessors}';
}
