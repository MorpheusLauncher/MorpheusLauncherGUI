library account_file;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:morpheus_launcher_gui/account/account_utils.dart';

void saveAccountListToJson(List<Account> accountList, String filePath) {
  final List<Map<String, dynamic>> jsonList = accountList.map((account) => account.toJson()).toList();
  final jsonString = json.encode(jsonList);
  final file = File(filePath);

  final hash = md5.convert(utf8.encode(getHWID()));
  final key = Key.fromUtf8(hash.toString());
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));

  final encryptedJson = encrypter.encrypt(jsonString, iv: iv);

  if (!file.existsSync()) {
    new File('$filePath').create(recursive: true);
  }

  file.writeAsBytesSync(encryptedJson.bytes);
}

List<Account> readAccountListFromJson(String filePath) {
  final file = File(filePath);

  if (!file.existsSync()) {
    return [];
  }

  final hash = md5.convert(utf8.encode(getHWID()));
  final key = Key.fromUtf8(hash.toString());
  final iv = IV.fromLength(16);
  final encrypter = Encrypter(AES(key));

  final encryptedBytes = file.readAsBytesSync();
  final encryptedJson = Encrypted(encryptedBytes);
  final decryptedJson = encrypter.decrypt(encryptedJson, iv: iv);

  final List<dynamic> jsonList = json.decode(decryptedJson);
  final accountList = jsonList.map((json) => Account.fromJson(json)).toList();

  return accountList.cast<Account>();
}

String getHWID() {
  return '${Platform.environment['USERNAME']}${Platform.environment['SystemRoot']}${Platform.environment['HOMEDRIVE']}${Platform.environment['PROCESSOR_LEVEL']}${Platform.environment['PROCESSOR_REVISION']}${Platform.environment['PROCESSOR_IDENTIFIER']}${Platform.environment['PROCESSOR_ARCHITECTURE']}${Platform.environment['PROCESSOR_ARCHITEW6432']}${Platform.numberOfProcessors}';
}
