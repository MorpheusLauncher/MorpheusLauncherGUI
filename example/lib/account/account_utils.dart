library account_utils;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:morpheus_launcher_gui/account/encryption.dart';
import 'package:morpheus_launcher_gui/account/uuid_utils.dart';
import 'package:morpheus_launcher_gui/globals.dart';

// Modello degli account
class Account {
  String username;
  String uuid;
  String accessToken;
  String refreshToken;
  bool isPremium;
  bool isSlimSkin;
  bool isElyBy;

  Account({
    required this.username,
    required this.uuid,
    required this.accessToken,
    required this.refreshToken,
    required this.isPremium,
    required this.isSlimSkin,
    required this.isElyBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'uuid': uuid,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'isPremium': isPremium,
      'isSlimSkin': isSlimSkin,
      'isElyBy': isElyBy,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      username: json['username'],
      uuid: json['uuid'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      isPremium: json['isPremium'],
      isSlimSkin: json['isSlimSkin'] != null ? json['isSlimSkin'] : false,
      isElyBy: json['isElyBy'] != null ? json['isElyBy'] : false,
    );
  }
}

// Genera un uuid offline per gli SP
Uuid getOfflinePlayerUuid(String username) {
  Int8List bytes = Int8List.fromList(utf8.encode("OfflinePlayer:$username"));
  List<int> unsignedBytes = md5.convert(bytes).bytes; // array di byte unsigned
  Int8List signedBytes = Int8List.fromList(
    unsignedBytes.map((b) => b > 127 ? b - 256 : b).toList(),
  );

  return Uuid.nameUUIDFromBytes(signedBytes);
}

// Discrimina se la skin SP è steve/alex in base all'uuid
bool isOfflineSlimSkin(String username) {
  return (getOfflinePlayerUuid(username).hashCode & 1) == 1;
}

// Salva gli account su disco
void saveAccounts() {
  final filePath = "${LauncherUtils.getApplicationFolder("morpheus")}/accounts.json";
  saveAccountListToJson(Globals.accounts, filePath);
}

List<Account> importAccountListFromJsonPlain(String filePath) {
  final file = File(filePath);

  if (!file.existsSync()) {
    return [];
  }

  final jsonString = file.readAsStringSync();
  final List<dynamic> jsonList = json.decode(jsonString);
  final accountList = jsonList.map((json) => Account.fromJson(json)).toList();

  return accountList.cast<Account>();
}

void exportAccountListToJsonPlain(List<Account> accountList, String filePath) {
  final List<Map<String, dynamic>> jsonList = accountList.map((account) => account.toJson()).toList();
  final jsonString = json.encode(jsonList);
  final file = File(filePath);

  if (!file.existsSync()) {
    file.createSync(recursive: true);
  }

  file.writeAsStringSync(jsonString);
}
