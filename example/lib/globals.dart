library globals;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:morpheus_launcher_gui/account/account_utils.dart';
import 'package:morpheus_launcher_gui/account/encryption.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';

class Globals {
  static final buildVersion = "Ver 2.4.1";
  static final windowTitle = "Morpheus Launcher";
  static final borderRadius = 14.0;

  // Impostazioni del launcher: anche se sono settate su false il loro valore viene sempre sovrascritto dalla config
  static var showOnlyReleases = false;
  static var darkModeTheme = false;
  static var showConsole = false;
  static var javaAdvSet = false;
  static var customFolderSet = false;
  static var selectedWindowTheme = '';
  static var accentColor = 0;
  static var fullTransparent = false;
  static var forceClasspath = false;

  //////////////////////////////
  ///// Sezione Variabili //////
  //////////////////////////////
  static late List<Account> accounts = readAccountListFromJson("${LauncherUtils.getApplicationFolder("morpheus")}/accounts.json");
  static late List<String> pinnedVersions = [];
  static late List<String> WindowThemes = [];

  static int NavSelected = 0, AccountSelected = 0;

  /** Sezione textfield */
  static final javapathcontroller = TextEditingController();
  static final javaramcontroller = TextEditingController();
  static final javavmcontroller = TextEditingController();
  static final javalaunchercontroller = TextEditingController();
  static final gamefoldercontroller = TextEditingController();
  static final usernamecontroller = TextEditingController();
  static final consolecontroller = TextEditingController();
  static final diagnosticcontroller = TextEditingController();

  /** Fabric */
  static late var fabricGameVersionsResponse = null;
  static late var fabricLoaderVersionsResponse = null;

  /** Forge */
  static late var forgeVersions = null;

  /** OptiForge */
  static late var optiforgeVersions = null;

  /** Optifine */
  static late var optifineVersions = null;

  /** Vanilla */
  static late var vanillaVersionsResponse = null;
  static late var vanillaNewsResponse = null;

  /** Incompatible versions blacklist */
  static late var incompatibleVersions = null;
}

class Urls {
  // Vari
  static final skinURL = "https://minepic.org";
  static final morpheusBaseURL = "https://morpheuslauncher.it";
  static final fabricApiURL = "https://meta.fabricmc.net/";
  static final forgeVersionsURL = "https://files.minecraftforge.net/net/minecraftforge/forge/maven-metadata.json";
  static final optifineVersionsURL = "${morpheusBaseURL}/downloads/optifine.json";

  // Roba inerente a ElyBy
  static final elybyBaseURL = "https://account.ely.by";
  static final elybySkinsURL = "http://skinsystem.ely.by";

  // Roba inerente al changelog mojang e alle vanilla
  static final mojangContentURL = "https://launchercontent.mojang.com";
  static final mojangVersionsURL = "https://launchermeta.mojang.com/mc/game/version_manifest.json";

  // Authenticazione Premium
  static final msAuthURL = "https://login.microsoftonline.com/consumers/oauth2/v2.0";
  static final xboxAuthURL = "https://user.auth.xboxlive.com/user/authenticate";
  static final xstsAuthURL = "https://xsts.auth.xboxlive.com/xsts/authorize";
  static final mcAuthURL = "https://api.minecraftservices.com/authentication/login_with_xbox";
  static final mcSkinURL = "https://api.minecraftservices.com/minecraft/profile/skins";
}

class ColorUtils {
  static var isMaterial = false;

  /** Base accent color */
  static late Color dynamicAccentColor = getColorFromAccent(Globals.accentColor);

  static Color getColorFromAccent(int accent) {
    List<Color> accentColors = [
      SystemTheme.accentColor.light.withAlpha(200), // System default color
      Colors.red.withAlpha(160),
      Colors.orange.withAlpha(160),
      Colors.yellow.withAlpha(160),
      Colors.green.withAlpha(160),
      Colors.teal.withAlpha(160),
      Colors.blue.withAlpha(160),
      Colors.deepPurpleAccent.withAlpha(160),
    ];

    return accent < accentColors.length ? accentColors[accent] : SystemTheme.accentColor.light.withAlpha(200);
  }

  /** Sfumature */
  static Color get defaultShadowColor => Colors.black.withAlpha(30);

  /** Background */
  static late Hct dynamicBackgroundMaterialHct;

  static Color get dynamicMaterialColor => Globals.darkModeTheme ? Color(dynamicBackgroundMaterialHct.toInt()) : Color(0xFFF0F0F5);

  static Color get dynamicAcrylicColor {
    if (Platform.isMacOS) {
      return Globals.darkModeTheme ? Colors.black.withAlpha(40) : Colors.white.withAlpha(60);
    }

    return Globals.darkModeTheme ? Colors.black.withAlpha(60) : Colors.white.withAlpha(80);
  }

  static Color get dynamicBackgroundColor => isMaterial ? dynamicMaterialColor : dynamicAcrylicColor;

  static Color get dynamicWindowBackgroundColor {
    if (Platform.isMacOS || (Platform.isLinux && Globals.fullTransparent)) {
      return Colors.transparent;
    }

    if (ColorUtils.isMaterial) {
      return ColorUtils.dynamicBackgroundColor;
    } else {
      if (Globals.darkModeTheme) {
        return Colors.black.withAlpha(80);
      } else {
        return Colors.white.withAlpha(10);
      }
    }
  }

  /** Foreground */
  static late Hct dynamicPrimaryMaterialHct; // Colore foreground primario (container)
  static Color get dynamicPrimaryMaterialColor => Globals.darkModeTheme ? Color(dynamicPrimaryMaterialHct.toInt()) : Color(dynamicPrimaryMaterialHct.toInt());

  static Color get dynamicPrimaryForegroundColor => isMaterial ? dynamicPrimaryMaterialColor : dynamicAcrylicColor;
  static late Hct dynamicSecondaryMaterialHct; // Colore foreground secondario (pulsanti, etc.)
  static Color get dynamicSecondaryMaterialColor => Globals.darkModeTheme ? Color(dynamicSecondaryMaterialHct.toInt()) : Color(dynamicSecondaryMaterialHct.toInt());

  static Color get dynamicSecondaryForegroundColor => isMaterial ? dynamicSecondaryMaterialColor : dynamicAcrylicColor;
  static late Hct dynamicTertiaryMaterialHct; // Colore foreground terziario (Font)

  /** Font, Icone e Separatori */
  static Color get primaryFontColor => isMaterial ? (Globals.darkModeTheme ? Colors.white : Color(dynamicTertiaryMaterialHct.toInt()).withAlpha(160)) : Colors.white;

  static Color get secondaryFontColor => primaryFontColor.withAlpha(160);

  static reloadColors() {
    // Background material you
    dynamicBackgroundMaterialHct = Hct.fromInt(dynamicAccentColor.value);
    dynamicBackgroundMaterialHct.tone = 15;
    dynamicBackgroundMaterialHct.chroma = 18;
    // Foreground material you
    dynamicPrimaryMaterialHct = Hct.fromInt(dynamicAccentColor.value);
    dynamicSecondaryMaterialHct = Hct.fromInt(dynamicAccentColor.value);
    dynamicTertiaryMaterialHct = Hct.fromInt(dynamicAccentColor.value);

    if (Globals.darkModeTheme) {
      // Primario (contenitori)
      dynamicPrimaryMaterialHct.tone = 25;
      dynamicPrimaryMaterialHct.chroma = 18;
      // Secondario (bottoni, etc.)
      dynamicSecondaryMaterialHct.tone = 40;
      dynamicSecondaryMaterialHct.chroma = 25;
    } else {
      // Primario (contenitori)
      dynamicPrimaryMaterialHct.tone = 100;
      // Secondario (bottoni, etc.)
      dynamicSecondaryMaterialHct.tone = 90;
      dynamicSecondaryMaterialHct.chroma = 15;
    }
    // Terziario (font)
    dynamicTertiaryMaterialHct.tone = 10;
  }
}

class LauncherUtils {
  static dynamic getApplicationFolder(String targetProgram) {
    if (Platform.isWindows) {
      return ('${Platform.environment['APPDATA']}/.${targetProgram}').replaceAll("\\", "/");
    } else if (Platform.isLinux) {
      return '${Platform.environment['HOME']}/.${targetProgram}';
    } else if (Platform.isMacOS) {
      return '${Platform.environment['HOME']}/Library/Application Support/${targetProgram}';
    } else {
      throw UnsupportedError('Unsupported operating system');
    }
  }

  static dynamic buildJVMOptimizedArgs(String maximumRam) {
    return [
      "-XX:+UnlockExperimentalVMOptions",
      "-XX:+UseG1GC",
      "-XX:G1NewSizePercent=20",
      "-XX:G1ReservePercent=20",
      "-XX:MaxGCPauseMillis=50",
      "-XX:G1HeapRegionSize=32M",
      "-XX:+DisableExplicitGC",
      "-XX:+AlwaysPreTouch",
      "-XX:+ParallelRefProcEnabled",
      "-Xms512M",
      "-Xmx${maximumRam}M",
      "-Dfile.encoding=UTF-8",
      "-XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump",
      "-Xss1M",
    ];
  }

  static Future<Map<String, String>?> checkJava() async {
    try {
      Process process = await Process.start(
        Globals.javapathcontroller.text,
        ['-version'],
      );

      String? firstLine;
      await for (String line in process.stderr.transform(systemEncoding.decoder)) {
        firstLine = line.trim();
        break; // Solo la prima riga
      }

      await process.exitCode;

      if (firstLine != null) {
        // Esempio: openjdk version "21.0.5" 2024-10-15 LTS
        final regex = RegExp(r'^(?<type>\S+)\s+version\s+"(?<version>[^"]+)"(?:\s+(?<date>\d{4}-\d{2}-\d{2}))?(?:\s+(?<lts>LTS))?');
        final match = regex.firstMatch(firstLine);

        if (match != null) {
          return {
            'type': match.namedGroup('type') ?? 'unknown',
            'version': match.namedGroup('version') ?? 'unknown',
            'releaseDate': match.namedGroup('date') ?? '',
            'lts': match.namedGroup('lts') == 'LTS' ? 'true' : 'false',
          };
        }
      }
    } catch (error) {
      print("Errore nel checkJava: $error");
    }

    return null;
  }

  /** Installa java automaticamente */
  static Future<dynamic> JavaAutoInstall(String gameVersion) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var requiredJavaVersion;

    File versionJsonFile = File('${Globals.gamefoldercontroller.text}/versions/$gameVersion/$gameVersion.json');
    if (versionJsonFile.existsSync()) {
      requiredJavaVersion = json.decode(versionJsonFile.readAsStringSync())["javaVersion"]["majorVersion"];
    } else {
      var realgameversion = gameVersion;
      if (gameVersion == "latest") realgameversion = Globals.vanillaVersionsResponse["latest"]["release"];
      if (gameVersion == "snapshot") realgameversion = Globals.vanillaVersionsResponse["latest"]["snapshot"];

      for (var ver in Globals.vanillaVersionsResponse["versions"]) {
        if (realgameversion == ver["id"]) {
          final response = await http.get(
            Uri.parse(ver["url"]),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
          );
          requiredJavaVersion = json.decode(response.body)["javaVersion"]["majorVersion"];
        }
      }
    }

    var javaBasePath = "${LauncherUtils.getApplicationFolder("morpheus")}/runtime/jre-$requiredJavaVersion";
    var javaBinPath = "$javaBasePath/bin";

    if (requiredJavaVersion != null) {
      try {
        if (isOnline() && !Directory(javaBinPath).existsSync()) {
          final queryParameters = {
            'java_version': "$requiredJavaVersion",
            'os': Platform.operatingSystem,
            'arch': Platform.version.contains("arm64") ? "aarch64" : "x86_64",
            'archive_type': 'zip',
            'java_package_type': 'jre',
            'latest': 'true',
            'javafx_bundled': 'false',
          };
          final uri = Uri.https('api.azul.com', '/metadata/v1/zulu/packages', queryParameters);
          final azulResponse = await http.get(uri, headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          });

          dynamic javaResponse = json.decode(azulResponse.body);
          String fileName = javaResponse[0]["name"];
          String downloadURL = javaResponse[0]["download_url"];
          Directory(javaBasePath).createSync(recursive: true); // Crea la cartella

          final zipResponse = await http.get(Uri.parse(downloadURL));
          if (zipResponse.statusCode == 200) {
            // Il nome dello zip che verrà scaricato
            String zipPath = "$javaBasePath/jre-$requiredJavaVersion.zip";

            // Scarica lo zip
            File(zipPath).writeAsBytesSync(zipResponse.bodyBytes);

            if (Platform.isMacOS) {
              // Unzippa da terminale, perchè in dart fa schifo
              Process unzipProcess = await Process.start("unzip", ["-o", zipPath, "-d", "$javaBasePath/"]);

              // Senza non funziona
              unzipProcess.stdout.transform(systemEncoding.decoder).forEach((line) {});

              // Quando finisce di estrarre tutto sposta i file nella directory precedente
              if (await unzipProcess.exitCode == 0) {
                Directory currentDir = Directory("$javaBasePath/${fileName.replaceAll(".zip", "/")}");
                List<FileSystemEntity> files = currentDir.listSync();
                for (FileSystemEntity file in files) {
                  Process moveProcess = await Process.start("mv", [file.path, javaBasePath]);

                  // Quando finisce di spostare un file alla volta cancella la cartella alla fine
                  if (await moveProcess.exitCode == 0) {
                    await Process.start("rmdir", [currentDir.path]);
                  }
                }
              }
            } else if (Platform.isWindows) {
              final archive = ZipDecoder().decodeBytes(zipResponse.bodyBytes);
              for (final file in archive) {
                final filePath = "$javaBasePath/${file.name}".replaceAll(fileName.replaceAll(".zip", "/"), "");
                if (file.isFile) {
                  File(filePath)
                    ..createSync(recursive: true)
                    ..writeAsBytesSync(file.content);
                } else {
                  Directory(filePath).create(recursive: true);
                }
              }
            } else if (Platform.isLinux) {
              // Unzippa da terminale, perchè in dart fa schifo
              Process unzipProcess = await Process.start("unzip", [zipPath, "-d", "$javaBasePath/"]);

              // Senza non funziona
              unzipProcess.stdout.transform(systemEncoding.decoder).forEach((line) {});

              // Quando finisce di estrarre tutto sposta i file nella directory precedente
              if (await unzipProcess.exitCode == 0) {
                Directory currentDir = Directory("$javaBasePath/${fileName.replaceAll(".zip", "/")}");
                List<FileSystemEntity> files = currentDir.listSync();
                for (FileSystemEntity file in files) {
                  Process moveProcess = await Process.start("mv", [file.path, javaBasePath]);

                  // Quando finisce di spostare un file alla volta cancella la cartella alla fine
                  if (await moveProcess.exitCode == 0) {
                    await Process.start("rmdir", [currentDir.path]);
                  }
                }
              }
            }

            // Cancella lo zip
            File(zipPath).deleteSync();
          }
        }
      } catch (error) {
        print(error);
      }

      if (Directory(javaBinPath).existsSync()) {
        Globals.javapathcontroller.text = "$javaBinPath/java".replaceAll("//", "/");
      } else {
        Globals.javapathcontroller.text = "java";
      }
    } else {
      Globals.javapathcontroller.text = "java";
    }

    await prefs.setString("javaPath", Globals.javapathcontroller.text);

    return true;
  }

  static bool isOnline() {
    if (Globals.vanillaNewsResponse != null) return true;
    if (Globals.vanillaVersionsResponse != null) return true;

    return false;
  }
}

class VersionUtils {
  static Future<List<String>> getPinnedVersions() async {
    String filePath = '${Globals.gamefoldercontroller.text}/launcher_profiles.json';
    File file = File(filePath);

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('{"profiles":{}}');
    }

    String content = await file.readAsString();
    Map<String, dynamic> jsonMap = json.decode(content);
    Map<String, dynamic> profiles = jsonMap['profiles'];
    List<String> versionIds = [];

    // Iterate through each profile to get the version ID
    profiles.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        String? versionId = value['lastVersionId'];
        if (versionId != null) {
          versionIds.add(versionId);
        }
      }
    });

    return versionIds;
  }

  static Future<void> updateLauncherProfiles(List<String> versionIds) async {
    String filePath = '${Globals.gamefoldercontroller.text}/launcher_profiles.json';
    File file = File(filePath);

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString('{"profiles":{}}');
    }

    String content = await file.readAsString();
    Map<String, dynamic> jsonMap = json.decode(content);
    Map<String, dynamic>? profiles = jsonMap['profiles'] as Map<String, dynamic>?;
    profiles ??= {};
    List<String> keysToRemove = [];

    // Aggiungere o aggiornare le voci dei profili
    versionIds.forEach((versionId) {
      if (!profiles!.containsKey(versionId)) {
        profiles[versionId] = {
          "name": versionId,
          "lastVersionId": versionId,
        };
      }
    });

    // Rimuovere le chiavi non più presenti in versionIds
    profiles.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        if (!versionIds.contains(key)) {
          keysToRemove.add(key);
        }
      }
    });

    keysToRemove.forEach((key) {
      profiles!.remove(key);
    });

    jsonMap['profiles'] = profiles;

    await file.writeAsString(json.encode(jsonMap));
  }

  // Versioni Vanilla di MC da Mojang
  static Future<void> getVersions() async {
    final response = await http.get(
      Uri.parse(Urls.mojangVersionsURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    Globals.vanillaVersionsResponse = jsonDecode(response.body);
  }

  // Versioni Vanilla di MC da Fabric
  static Future<void> getFabric() async {
    /** Versioni compatibili con fabric */
    final fabricGameResponse = await http.get(
      Uri.parse("${Urls.fabricApiURL}/v2/versions/game"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    Globals.fabricGameVersionsResponse = jsonDecode(fabricGameResponse.body);

    /** Versioni del loader fabric */
    final fabricLoaderResponse = await http.get(
      Uri.parse("${Urls.fabricApiURL}/v2/versions/loader"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    Globals.fabricLoaderVersionsResponse = jsonDecode(fabricLoaderResponse.body);
  }

  static Future<List<String>> getForge() async {
    final forgeGameResponse = await http.get(
      Uri.parse(Urls.forgeVersionsURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var parsedData = jsonDecode(forgeGameResponse.body);
    var keys = parsedData.keys.toList();
    List<String> resultList = [];
    parsedData.forEach((key, value) {
      if (value.isNotEmpty) {
        var parts = value.last.split('-');
        if (parts.length >= 2) {
          if (keys.indexOf(key) >= keys.indexOf("1.6.4") && keys.indexOf(key) <= keys.indexOf("1.12.2")) resultList.add("${parts[0]}-forge-${parts[1]}");
        }
      }
    });

    return resultList.reversed.toList();
  }

  static Future<List<String>> getOptiForge() async {
    final forgeGameResponse = await http.get(
      Uri.parse(Urls.forgeVersionsURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var parsedData = jsonDecode(forgeGameResponse.body);
    var keys = parsedData.keys.toList();
    List<String> resultList = [];
    parsedData.forEach((key, value) {
      if (value.isNotEmpty) {
        var parts = value.last.split('-');
        if (parts.length >= 2) {
          if (keys.indexOf(key) >= keys.indexOf("1.8.9") && keys.indexOf(key) <= keys.indexOf("1.12.2")) resultList.add("${parts[0]}-forge-${parts[1]}");
        }
      }
    });

    return resultList.reversed.toList();
  }

  static Future<List<String>> getOptifine() async {
    final optifineGameResponse = await http.get(
      Uri.parse(Urls.optifineVersionsURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var parsedData = jsonDecode(optifineGameResponse.body);
    List<String> resultList = [];
    parsedData.forEach((key, value) {
      resultList.add(value["launchname"]);
    });

    return resultList.toList();
  }

  // tutte le versioni possibili immaginabili
  static List<Map<String, dynamic>> getAllVersions() {
    List<Map<String, dynamic>> versions = [];
    Set<String> addedVersions = Set<String>();

    // Moddate
    versions.addAll(getMinecraftVersions(true));
    // Vanilla
    versions.addAll(getMinecraftVersions(false));
    addedVersions.addAll(versions.map((version) => version["id"]));

    versions.sort((a, b) {
      if (a["inheritsFrom"] != null && b["inheritsFrom"] != null) {
        return a["inheritsFrom"].compareTo(b["inheritsFrom"]);
      } else if (a["releaseTime"] != null && b["releaseTime"] != null) {
        return b["releaseTime"].compareTo(a["releaseTime"]);
      }

      return 0;
    });

    return versions;
  }

  // prende il json da mojang, se fallisce lista quelle già scaricate
  static List<Map<String, dynamic>> getMinecraftVersions(bool onlyModded) {
    List<Map<String, dynamic>> versions = [];
    Set<String> addedVersions = Set<String>();

    /* Aggiungi le versioni moddate/offline */
    versions.addAll(getMinecraftOfflineVersions(onlyModded));
    addedVersions.addAll(versions.map((version) => version["id"]));

    /* Aggiungi le versioni vanilla se internet c'è */
    if (!onlyModded && Globals.vanillaVersionsResponse != null && Globals.vanillaVersionsResponse["versions"] != null) {
      for (var version in Globals.vanillaVersionsResponse["versions"]) {
        if (!addedVersions.contains(version["id"])) {
          versions.add(version);
          addedVersions.add(version["id"]);
        }
      }
    }

    versions.sort((a, b) {
      if (a["inheritsFrom"] != null && b["inheritsFrom"] != null) {
        return a["inheritsFrom"].compareTo(b["inheritsFrom"]);
      } else {
        return b["releaseTime"].compareTo(a["releaseTime"]);
      }
    });

    return versions;
  }

  static List<Map<String, dynamic>> getMinecraftOfflineVersions(var onlyModded) {
    String versionsFolder = '${Globals.gamefoldercontroller.text}/versions';

    Directory directory = Directory(versionsFolder);
    if (!directory.existsSync()) {
      return [];
    }

    List<Map<String, dynamic>> versions = [];
    directory.listSync().forEach((entity) {
      if (entity is Directory) {
        String version = entity.path.replaceAll("\\", "/").split('/').last;
        String jsonPath = '${versionsFolder}/$version/$version.json';
        File jsonFile = File(jsonPath);

        if (jsonFile.existsSync()) {
          String jsonContent = jsonFile.readAsStringSync();
          Map<String, dynamic> jsonData = json.decode(jsonContent);

          if (onlyModded) {
            if (jsonData["inheritsFrom"] != null) {
              versions.add(jsonData);
            }
          } else {
            if (jsonData["inheritsFrom"] == null) {
              versions.add(jsonData);
            }
          }
        }
      }
    });

    return versions;
  }

  static Future<List<VersionCompatibility>> fetchIncompatibleVersions() async {
    final url = '${Urls.morpheusBaseURL}/downloads/known-incompatible.json';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      List<VersionCompatibility> incompatibleVersions = [];

      jsonData.forEach((version, data) {
        if (data['forge'] != null) {
          final forgeArch = data['forge']['arch'];
          if (forgeArch['x64'] != null) {
            incompatibleVersions.add(VersionCompatibility(version, "forge", 'x64'));
          }
          if (forgeArch['arm64'] != null) {
            incompatibleVersions.add(VersionCompatibility(version, "forge", 'arm64'));
          }
        }
        if (data['optiforge'] != null) {
          final forgeArch = data['optiforge']['arch'];
          if (forgeArch['x64'] != null) {
            incompatibleVersions.add(VersionCompatibility(version, "optiforge", 'x64'));
          }
          if (forgeArch['arm64'] != null) {
            incompatibleVersions.add(VersionCompatibility(version, "optiforge", 'arm64'));
          }
        }
        if (data['vanilla'] != null) {
          final vanillaArch = data['vanilla']['arch'];
          if (vanillaArch['x64'] != null) {
            incompatibleVersions.add(VersionCompatibility(version, "release", 'x64'));
          }
          if (vanillaArch['arm64'] != null) {
            incompatibleVersions.add(VersionCompatibility(version, "release", 'arm64'));
          }
        }
      });

      return incompatibleVersions;
    } else {
      throw Exception('Errore nel download del JSON: ${response.statusCode}');
    }
  }

  static bool isCompatible(String type, String id) {
    bool isCompatible = true;

    RegExp regex = RegExp(r'on "[a-zA-Z]+_([a-zA-Z0-9]+)"');
    RegExpMatch? match = regex.firstMatch(Platform.version);
    String os_arch = match != null ? match.group(1)! : '';

    if (Globals.incompatibleVersions != null) {
      Globals.incompatibleVersions.forEach((result) {
        if (result.version == id && result.type == type.toLowerCase() && result.arch == os_arch) isCompatible = false;
      });
    }

    return isCompatible;
  }
}

class VersionCompatibility {
  final String version;
  final String type;
  final String arch;

  VersionCompatibility(this.version, this.type, this.arch);

  @override
  String toString() => 'Version: $version, Type: $type, Arch: $arch';
}

class News {
  String title;
  String type;
  String version;
  String imageUrl;
  String imageTitle;
  String body;
  String id;
  String contentPath;

  News({
    required this.title,
    required this.type,
    required this.version,
    required this.imageUrl,
    required this.imageTitle,
    required this.body,
    required this.id,
    required this.contentPath,
  });

  factory News.fromJSON(Map<String, dynamic> json) {
    return News(
      title: json["title"],
      type: json["type"],
      version: json["version"],
      imageUrl: json["image"]["url"],
      imageTitle: json["image"]["title"],
      body: json["body"],
      id: json["id"],
      contentPath: json["contentPath"],
    );
  }
}
