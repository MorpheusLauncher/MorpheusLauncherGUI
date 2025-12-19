import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:morpheus_launcher_gui/globals.dart';
import 'package:morpheus_launcher_gui/utils/widget_utils.dart';
import 'package:morpheus_launcher_gui/views/main_page.dart';

class LaunchConfig {
  final String gameVersion;
  final String? productId;
  final bool isModded;
  final String realGameVersion;
  final bool enableClassPath;
  final bool startOnFirstThread;

  final List<String> jvmArgs;
  final List<String> launcherArgs;

  LaunchConfig({
    required this.gameVersion,
    this.productId,
    required this.isModded,
    required this.realGameVersion,
    required this.enableClassPath,
    required this.startOnFirstThread,
    this.jvmArgs = const [],
    this.launcherArgs = const [],
  });
}

class LaunchUtils {
  /// Lancia Minecraft con i parametri di LaunchConfig
  static Future<void> launchMinecraft(
    BuildContext context,
    LaunchConfig config, {
    required VoidCallback onAccountRequired,
  }) async {
    // Verifica account
    final account = Globals.getAccount();
    if (account == null) {
      WidgetUtils.showMessageDialog(
        context,
        AppLocalizations.of(context)!.account_required_title,
        AppLocalizations.of(context)!.account_required_msg,
        () {
          Navigator.pop(context);
          onAccountRequired();
        },
      );

      return;
    }

    WidgetUtils.showLoadingCircle(context);
    Globals.consolecontroller.clear();
    await AccountUtils.refreshPremium(context);

    try {
      // Installa Java automaticamente se necessario
      if (!Globals.javaAdvSet) {
        await LauncherUtils.JavaAutoInstall(
          config.isModded ? config.realGameVersion : config.gameVersion,
        );
      }

      if (context.mounted) Navigator.pop(context);

      // Costruisci args di lancio
      final args = await _buildLaunchArguments(context, config);

      // Avvia il processo
      final process = await Process.start(Globals.javapathcontroller.text, args);

      // Gestione console
      if (Globals.showConsole && context.mounted) {
        WidgetUtils.showConsole(context, process);
      } else {
        // Consuma comunque stdout/stderr
        process.stdout.transform(systemEncoding.decoder).listen((_) {});
        process.stderr.transform(systemEncoding.decoder).listen((_) {});
      }

      // Handle exit code senza bloccare UI
      _handleProcessExit(context, process);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        WidgetUtils.showMessageDialog(
          context,
          AppLocalizations.of(context)!.generic_error_msg,
          "$e",
          () => Navigator.pop(context),
        );
      }
    }
  }

  /// Gestione exit del processo in background
  static Future<void> _handleProcessExit(BuildContext context, Process process) async {
    final exitCode = await process.exitCode;
    Globals.consolecontroller.text += "[LAUNCHER]: exit code $exitCode";

    if (exitCode != 0 && exitCode != 143 && context.mounted) {
      _showCrashDialog(context);
    }
  }

  /// Costruisce args completi
  static Future<List<String>> _buildLaunchArguments(BuildContext context, LaunchConfig config) async {
    final account = Globals.getAccount()!;
    final args = <String>[];

    /* ---------- JVM ARGS (PRIMA DI -jar) ---------- */

    args.addAll(config.jvmArgs);

    // Workaround offline 1.16.4 / 1.16.5
    if ((config.realGameVersion == "1.16.4" || config.realGameVersion == "1.16.5") && !account.isPremium) {
      args.addAll([
        "-Dminecraft.api.auth.host=https://0.0.0.0/",
        "-Dminecraft.api.account.host=https://0.0.0.0/",
        "-Dminecraft.api.session.host=https://0.0.0.0/",
        "-Dminecraft.api.services.host=https://0.0.0.0/",
      ]);
    }

    // macOS: XstartOnFirstThread
    if (config.startOnFirstThread) args.add("-XstartOnFirstThread");

    // JVM args utente
    if (Globals.javavmcontroller.text.isNotEmpty) {
      args.addAll(Globals.javavmcontroller.text.split(" "));
    }

    // Ely.by
    if (account.isElyBy) {
      args.add(
        '-javaagent:${LauncherUtils.getApplicationFolder("morpheus")}/authlib-injector.jar=ely.by',
      );
    }

    // JVM base
    args.addAll([
      "-Duser.dir=${Globals.gamefoldercontroller.text}",
      "-Djava.library.path=${Globals.gamefoldercontroller.text}/versions/${config.gameVersion}/natives/",
      ...LauncherUtils.buildJVMOptimizedArgs(Globals.javaramcontroller.text),
    ]);

    /* ---------- JAR ---------- */

    args.addAll([
      "-jar",
      "${LauncherUtils.getApplicationFolder("morpheus")}/Launcher.jar",
    ]);

    /* ---------- LAUNCHER ARGS (DOPO -jar) ---------- */

    args.addAll([
      "-version",
      config.productId ?? config.gameVersion,
      "-minecraftToken",
      account.accessToken,
      "-minecraftUsername",
      account.username,
      "-minecraftUUID",
      account.uuid,
    ]);

    if (config.enableClassPath) args.add("-c");
    if (config.startOnFirstThread) args.add("-startOnFirstThread");

    if (Globals.customFolderSet) {
      args.addAll(["-gameFolder", Globals.gamefoldercontroller.text]);
    }

    // Launcher args utente
    if (Globals.javalaunchercontroller.text.isNotEmpty) {
      args.addAll(Globals.javalaunchercontroller.text.split(" "));
    }

    // Launcher args del loader
    args.addAll(config.launcherArgs);

    return args;
  }

  /// Mostra crash dialog
  static void _showCrashDialog(BuildContext context) {
    WidgetUtils.showPopup(
      context,
      AppLocalizations.of(context)!.generic_error_msg,
      <Widget>[
        Text(
          AppLocalizations.of(context)!.console_crash_msg,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
      <Widget>[
        TextButton(
          child: const Text(
            "OK",
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w300,
            ),
          ),
          onPressed: () {},
        ),
        TextButton(
          child: Text(
            AppLocalizations.of(context)!.generic_cancel,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w300,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  /// Determina se serve startOnFirstThread per macOS
  static bool shouldUseStartOnFirstThread(String resolvedGameVersion) {
    if (!Platform.isMacOS) return false;

    final verList = VersionUtils.getMinecraftVersions(false);
    final currentVersionIndex = verList.indexWhere(
      (version) => version["id"] == resolvedGameVersion,
    );
    final startingVersionIndex = verList.indexWhere(
      (version) => version["id"] == "17w43a",
    );

    return currentVersionIndex != -1 && startingVersionIndex != -1 && currentVersionIndex <= startingVersionIndex;
  }

  /// Determina se serve enableClassPath per versioni nuove
  static bool shouldEnableClassPath(String resolvedGameVersion, bool forcedClasspath) {
    if (forcedClasspath || Globals.forceClasspath) return true;

    final verList = VersionUtils.getMinecraftVersions(false);
    final classpathStartIndex = verList.indexWhere(
      (version) => version["id"] == "25w18a",
    );

    if (classpathStartIndex == -1) return false;

    final allVersions = VersionUtils.getAllVersions();
    final baseVersion = VersionUtils.resolveBaseVersion(resolvedGameVersion, allVersions);

    if (baseVersion != null) {
      final baseIndex = verList.indexWhere(
        (v) => v["id"] == baseVersion["id"],
      );

      return baseIndex != -1 && baseIndex <= classpathStartIndex;
    }

    return false;
  }
}
