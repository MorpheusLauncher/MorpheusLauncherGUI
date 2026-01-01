import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:morpheus_launcher_gui/globals.dart';
import 'package:morpheus_launcher_gui/utils/version_utils.dart';
import 'package:morpheus_launcher_gui/utils/widget_utils.dart';
import 'package:morpheus_launcher_gui/views/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_theme/system_theme.dart';

Future<void> main() async {
  if (Platform.isWindows) {
    int? buildNumber = getBuildNumber(Platform.operatingSystemVersion);

    Globals.WindowThemes.add('Clear'); // for any version
    if (buildNumber! >= 7601) {
      if (buildNumber < 22000) Globals.WindowThemes.add('Aero'); // No aero for windows 11 (broke)
      if (buildNumber >= 22523) Globals.WindowThemes.add('Mica'); // Mica only for windows 11
      if (buildNumber >= 17134) Globals.WindowThemes.add('Acrylic'); // Acrylic for windows 10+
    }
    Globals.WindowThemes.add('Material');
  } else if (Platform.isLinux) {
    Globals.WindowThemes.add('Clear'); // Can look like acrylic by playing with Desktop Environment
    Globals.WindowThemes.add('Material');
  } else if (Platform.isMacOS) {
    Globals.WindowThemes.add('Acrylic'); // Acrylic for macos
  }

  WidgetsFlutterBinding.ensureInitialized();
  SystemTheme.fallbackColor = Colors.deepPurpleAccent.withAlpha(160);
  await SystemTheme.accentColor.load();
  if (!Platform.isLinux) await Window.initialize();

  if (Platform.isWindows) {
    await Window.hideWindowControls();
    doWhenWindowReady(() {
      appWindow
        ..minSize = Size(640, 480)
        ..size = Size(640, 480)
        ..alignment = Alignment.center
        ..title = Globals.windowTitle
        ..show();
    });
  } else if (Platform.isMacOS) {
    await Window.hideTitle();
    await Window.makeTitlebarTransparent();
    await Window.enableFullSizeContentView();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        return supportedLocales.firstWhere(
          (supportedLocale) => supportedLocale.languageCode == locale?.languageCode,
          orElse: () => Locale('en'),
        );
      },
      debugShowCheckedModeBanner: false,
      home: MyAppBody(),
    );
  }
}

class MyAppBody extends StatefulWidget {
  @override
  MyAppBodyState createState() => MyAppBodyState();
}

class MyAppBodyState extends State<MyAppBody> {
  late WindowEffect effect;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setWindowEffect();
  }

  Future<void> setWindowEffect() async {
    final prefs = await SharedPreferences.getInstance();

    // legge i setting se esistono, in alternativa usa valori predefiniti
    Globals.showOnlyReleases = prefs.getBool('showOnlyReleases') ?? true;
    Globals.darkModeTheme = prefs.getBool('darkModeTheme') ?? false;
    Globals.accentColor = prefs.getInt('accentColor') ?? 0;
    Globals.javaramcontroller.text = prefs.getString('javaRAM') ?? "1024";
    Globals.javapathcontroller.text = prefs.getString('javaPath') ?? "java";
    Globals.javaAdvSet = prefs.getBool('javaAdvSet') ?? false;
    Globals.javavmcontroller.text = prefs.getString('javaVMArgs') ?? "";
    Globals.javalaunchercontroller.text = prefs.getString('javaLauncherArgs') ?? "";
    Globals.customFolderSet = prefs.getBool('customFolderSet') ?? false;
    Globals.gamefoldercontroller.text = prefs.getString('gameFolderPath') ?? LauncherUtils.getApplicationFolder("minecraft");
    Globals.selectedWindowTheme = prefs.getString('themeSet') ?? getDefaultTheme();
    Globals.showConsole = prefs.getBool('showConsole') ?? true;
    Globals.fullTransparent = prefs.getBool('fullTransparent') ?? false;
    Globals.forceClasspath = prefs.getBool('forceClasspath') ?? false;

    ColorUtils.isMaterial = (Globals.selectedWindowTheme.contains('Material'));
    ColorUtils.reloadColors();

    // scrive i setting con i valori predefiniti se non esistono
    if (!prefs.containsKey('showOnlyReleases')) prefs.setBool('showOnlyReleases', Globals.showOnlyReleases);
    if (!prefs.containsKey('darkModeTheme')) prefs.setBool('darkModeTheme', Globals.darkModeTheme);
    if (!prefs.containsKey('accentColor')) prefs.setInt('accentColor', Globals.accentColor);
    if (!prefs.containsKey('javaRAM')) prefs.setString('javaRAM', Globals.javaramcontroller.text);
    if (!prefs.containsKey('javaPath')) prefs.setString('javaPath', Globals.javapathcontroller.text);
    if (!prefs.containsKey('javaAdvSet')) prefs.setBool('javaAdvSet', Globals.javaAdvSet);
    if (!prefs.containsKey('javaVMArgs')) prefs.setString('javaVMArgs', Globals.javavmcontroller.text);
    if (!prefs.containsKey('javaLauncherArgs')) prefs.setString('javaLauncherArgs', Globals.javalaunchercontroller.text);
    if (!prefs.containsKey('customFolderSet')) prefs.setBool('customFolderSet', Globals.customFolderSet);
    if (!prefs.containsKey('gameFolderPath')) prefs.setString('gameFolderPath', Globals.gamefoldercontroller.text);
    if (!prefs.containsKey('themeSet')) prefs.setString('themeSet', Globals.selectedWindowTheme);
    if (!prefs.containsKey('showConsole')) prefs.setBool('showConsole', Globals.showConsole);
    if (!prefs.containsKey('fullTransparent')) prefs.setBool('fullTransparent', Globals.fullTransparent);
    if (!prefs.containsKey('forceClasspath')) prefs.setBool('forceClasspath', Globals.forceClasspath);

    Window.setEffect(
      effect: effect = getWindowEffect(),
      color: ColorUtils.dynamicBackgroundColor,
      dark: Globals.darkModeTheme,
    );
    if (Platform.isMacOS) {
      Window.overrideMacOSBrightness(dark: Globals.darkModeTheme);
    }

    try {
      Globals.pinnedVersions = await VersionUtils.getPinnedVersions();
    } catch (e) {
      print(e);
    }
    try {
      await getNews();
    } catch (e) {
      print(e);
    }
    try {
      await VersionUtils.fetchMorpheusProducts();
    } catch (e) {
      print(e);
    }
    try {
      await VersionUtils.getVersions();
    } catch (e) {
      print(e);
    }
    try {
      await VersionUtils.getFabric();
    } catch (e) {
      print(e);
    }
    try {
      Globals.forgeVersions = await VersionUtils.getForge();
    } catch (e) {
      print(e);
    }
    try {
      Globals.optiforgeVersions = await VersionUtils.getOptiForge();
    } catch (e) {
      print(e);
    }
    try {
      Globals.optifineVersions = await VersionUtils.getOptifine();
    } catch (e) {
      print(e);
    }
    try {
      await VersionUtils.fetchIncompatibleVersions();
    } catch (e) {
      print(e);
    }

    isLoading = false;

    setState(() => effect = effect);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Column(
            children: [
              drawTitleCustomBar(),
              Expanded(
                child: Center(child: Image.asset('assets/morpheus-animated.gif', width: 96)),
              ),
            ],
          )
        : MainPage();
  }
}

WindowEffect getWindowEffect() {
  int? buildNumber = getBuildNumber(Platform.operatingSystemVersion);
  switch (Globals.selectedWindowTheme) {
    case 'Material':
      return WindowEffect.solid;
    case 'Clear':
      return WindowEffect.transparent;
    case 'Aero':
      if (Platform.isWindows && buildNumber! >= 7601) return WindowEffect.aero;
      break;
    case 'Acrylic':
      if (Platform.isWindows && buildNumber! >= 17134 || Platform.isMacOS) return WindowEffect.acrylic;
      break;
    case 'Mica':
      if (Platform.isWindows && buildNumber! >= 22000) return (!Globals.darkModeTheme && buildNumber >= 22523) ? WindowEffect.tabbed : WindowEffect.mica;
      break;
  }

  return WindowEffect.transparent;
}

String getDefaultTheme() {
  if (Platform.isWindows) {
    int? buildNumber = getBuildNumber(Platform.operatingSystemVersion);

    if (buildNumber != null) {
      if (buildNumber >= 22000) return "Acrylic"; // Acrylic default for windows 11
      if (buildNumber >= 7601) return "Aero"; // Aero default for windows 7, 8, 8.1, 10
    }
  } else if (Platform.isMacOS) {
    return "Acrylic";
  }

  return "Clear";
}

int? getBuildNumber(String version) {
  RegExp regex = RegExp(r'Build (\d+)');
  Match? match = regex.firstMatch(version);

  if (match != null) {
    String? buildNumberString = match.group(1);

    return int.tryParse(buildNumberString ?? '');
  } else {
    return null;
  }
}

Widget drawTitleCustomBar() {
  return WindowTitleBarBox(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!Platform.isMacOS) ...[
          SizedBox(width: 10),
          WidgetUtils.backShadow(
            Image.asset("assets/morpheus.png", width: 18),
            40.0,
            ColorUtils.defaultShadowColor,
          ),
          SizedBox(width: 5),
        ],
        Material(
          color: Colors.transparent,
          child: WidgetUtils.backShadow(
            Text(Globals.windowTitle, style: WidgetUtils.customTextStyle(12, FontWeight.w400, ColorUtils.primaryFontColor)),
            40.0,
            ColorUtils.defaultShadowColor,
          ),
        ),
        if (!Platform.isMacOS) ...[
          Expanded(child: MoveWindow()),
          WidgetUtils.backShadow(
            WindowButtons(),
            40.0,
            ColorUtils.defaultShadowColor,
          ),
        ],
      ],
    ),
  );
}

Future<void> getNews() async {
  final oldResponse = await http.get(
    Uri.parse("${Urls.mojangContentURL}/javaPatchNotes.json"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  final newResponse = await http.get(
    Uri.parse("${Urls.mojangContentURL}/v2/javaPatchNotes.json"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  final oldJson = json.decode(oldResponse.body);
  final newJson = json.decode(newResponse.body);
  final Map<String, dynamic> oldEntriesById = {
    for (var entry in oldJson["entries"]) entry["id"]: entry,
  };
  List<Map<String, dynamic>> mergedEntries = [];
  for (var entry in oldJson["entries"]) {
    mergedEntries.add(entry);
  }
  for (var newEntry in newJson["entries"]) {
    if (!oldEntriesById.containsKey(newEntry["id"])) {
      newEntry["body"] = "${newEntry["shortText"]}";
      mergedEntries.add(newEntry);
    }
  }
  mergedEntries.sort((a, b) => b["version"].compareTo(a["version"]));
  Globals.vanillaNewsResponse = mergedEntries;
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  final buttonColors = WindowButtonColors(
    iconNormal: ColorUtils.primaryFontColor,
    mouseOver: const Color(0x66FFFFFF),
    mouseDown: const Color(0xCCFFFFFF),
    iconMouseOver: Colors.white,
    iconMouseDown: Colors.white,
  );

  final closeButtonColors = WindowButtonColors(
    iconNormal: ColorUtils.primaryFontColor,
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconMouseOver: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors, onPressed: maximizeOrRestore),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
