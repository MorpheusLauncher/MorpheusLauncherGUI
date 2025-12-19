import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:morpheus_launcher_gui/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomSettingSwitchStyle {
  final IconData icon;
  final Color bgColor;
  final Color shadowColor;
  final Color fontColor;
  final Color toggleColor;
  final Color activeColor;
  final Color inactiveColor;

  CustomSettingSwitchStyle({
    required this.icon,
    required this.bgColor,
    required this.shadowColor,
    required this.fontColor,
    required this.toggleColor,
    required this.activeColor,
    required this.inactiveColor,
  });
}

class WidgetUtils {
  /** Switch impostazioni */
  static Widget buildSettingSwitchItem(
    String name,
    String name2,
    CustomSettingSwitchStyle style,
    var set,
    Function(dynamic value) callback,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
      child: Container(
        height: 55,
        child: Material(
          elevation: 15,
          color: style.bgColor,
          shadowColor: style.shadowColor,
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          child: Stack(
            children: [
              Row(
                children: [
                  Container(
                    height: 55,
                    width: 45,
                    child: Center(
                      child: Material(
                        elevation: 10,
                        color: Colors.transparent,
                        shadowColor: ColorUtils.defaultShadowColor,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Icon(
                          style.icon,
                          color: style.fontColor,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  /** Nome del setting */
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 18, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: customTextStyle(
                            16,
                            FontWeight.w500,
                            style.fontColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /** Interruttore */
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Material(
                      elevation: 15,
                      color: Colors.transparent,
                      shadowColor: Colors.transparent,
                      // Globals.defaultShadowColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: MouseRegion(
                        onEnter: (e) => {},
                        onExit: (e) => {},
                        child: FlutterSwitch(
                          width: 50,
                          height: 25,
                          toggleSize: 18.0,
                          toggleColor: style.toggleColor,
                          activeColor: style.activeColor,
                          inactiveColor: style.inactiveColor,
                          value: set,
                          onToggle: (value) async {
                            callback(value);
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setBool(name2, value);
                            set = value;
                            ;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /** Textfield */
  static Widget buildSettingTextItem(
    dynamic child,
    Color background,
    Color foreground,
    String hint,
    TextEditingController controller,
    Function(dynamic value) callback,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
      child: Container(
        child: Material(
          elevation: 15,
          color: background,
          shadowColor: ColorUtils.defaultShadowColor,
          borderRadius: BorderRadius.circular(Globals.borderRadius - 2),
          child: Stack(
            children: [
              Focus(
                onFocusChange: (hasFocus) async {
                  callback(hasFocus);
                },
                child: TextField(
                  style: TextStyle(
                    color: foreground,
                    fontFamily: 'Comfortaa',
                    shadows: [
                      Shadow(
                        color: ColorUtils.defaultShadowColor,
                        // Choose the color of the shadow
                        blurRadius: 2.0,
                        // Adjust the blur radius for the shadow effect
                        offset: Offset(
                          2.0,
                          2.0,
                        ), // Set the horizontal and vertical offset for the shadow
                      ),
                    ],
                  ),
                  controller: controller,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(Globals.borderRadius - 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(Globals.borderRadius - 2),
                    ),
                    hintText: hint,
                    hintStyle: customTextStyle(16, FontWeight.w300, foreground),
                    filled: false,
                  ),
                ),
              ),
              if (child != null) child,
            ],
          ),
        ),
      ),
    );
  }

  /** Container riempibile impostazioni */
  static Widget buildSettingContainerItem(dynamic widgets) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
      child: Container(
        child: Material(
          elevation: 15,
          color: ColorUtils.dynamicPrimaryForegroundColor,
          shadowColor: ColorUtils.defaultShadowColor,
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          child: widgets,
        ),
      ),
    );
  }

  /////////////////////////////////
  //// ALTRI ELEMENTI GRAFICI /////
  /////////////////////////////////

  static Widget buildButton(
    IconData icon,
    Color color,
    Color iconColor,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 6, 5),
      child: GestureDetector(
        onTap: onPressed,
        child: backShadow(
          MouseRegion(
            onEnter: (e) => {},
            child: Material(
              elevation: 15,
              color: color,
              shadowColor: Colors.transparent,
              borderRadius: BorderRadius.circular(Globals.borderRadius - 4),
              child: Container(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          20.0,
          ColorUtils.defaultShadowColor,
        ),
      ),
    );
  }

  static Widget buildTextButton(
    Color color,
    Color textColor,
    VoidCallback onPressed,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(7, 7, 0, 7),
      child: GestureDetector(
        onTap: onPressed,
        child: backShadow(
          MouseRegion(
            onEnter: (e) => {},
            child: Material(
              elevation: 15,
              color: color,
              shadowColor: Colors.transparent,
              borderRadius: BorderRadius.circular(Globals.borderRadius - 4),
              child: Container(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    text,
                    style: customTextStyle(16, FontWeight.w500, textColor),
                  ),
                ),
              ),
            ),
          ),
          20.0,
          ColorUtils.defaultShadowColor,
        ),
      ),
    );
  }

  static void showPopup(
    dynamic context,
    String title,
    List<Widget> content,
    List<Widget> actions,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(80),
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          backgroundColor: Colors.white.withAlpha(230) /* colore dello sfondo del popup */,
          shadowColor: Colors.transparent,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: content,
            ),
          ),
          actions: actions,
        );
      },
    );
  }

  static void showMessageDialog(
    dynamic context,
    String title,
    String content,
    VoidCallback callback,
  ) {
    WidgetUtils.showPopup(
      context,
      title,
      <Widget>[
        Text(
          content,
          style: TextStyle(
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
          onPressed: callback,
        ),
      ],
    );
  }

  static Future<void> showConsole(dynamic context, dynamic process) async {
    WidgetUtils.showPopup(
      context,
      "Console",
      <Widget>[
        await Container(
          color: Colors.white.withAlpha(128),
          padding: new EdgeInsets.all(2.0),
          child: await new ConstrainedBox(
            constraints: new BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              maxWidth: MediaQuery.of(context).size.width,
              minHeight: 75,
              maxHeight: MediaQuery.of(context).size.height,
            ),
            child: await SingleChildScrollView(
              scrollDirection: Axis.vertical,
              reverse: true,

              // here's the actual text box
              child: await TextField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                controller: Globals.consolecontroller,
                readOnly: true,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  fontFamily: "JetbrainsMono",
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
      <Widget>[
        await IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.help,
            color: Colors.blueAccent,
          ),
          onPressed: () {
            WidgetUtils.showDiagnostic(context);
          },
        ),
        await IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.cleaning_services,
            color: Colors.blueAccent,
          ),
          onPressed: () async {
            Globals.consolecontroller.clear();
            Globals.consolecontroller.text += "[LAUNCHER]: ${AppLocalizations.of(context)!.console_clear_msg}\n";
          },
        ),
        await IconButton(
          iconSize: 30,
          icon: const Icon(
            Icons.folder,
            color: Colors.orange,
          ),
          onPressed: () async {
            final Uri _url;
            if (Platform.isWindows) {
              _url = Uri.parse('file:///${Globals.gamefoldercontroller.text}');
            } else {
              _url = Uri.parse('file://${Globals.gamefoldercontroller.text}');
            }
            if (!await launchUrl(_url)) {
              throw Exception('Could not launch $_url');
            }
          },
        ),
        await IconButton(
          iconSize: 30,
          icon: Icon(
            Icons.logout,
            color: ColorUtils.dynamicAccentColor.withAlpha(255),
          ),
          onPressed: () {
            showPopup(
              context,
              AppLocalizations.of(context)!.console_exit_title,
              <Widget>[
                Text(
                  "${AppLocalizations.of(context)!.console_exit_msg1}\n${AppLocalizations.of(context)!.console_exit_msg2}",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Comfortaa',
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
              <Widget>[
                TextButton(
                  child: Text(
                    AppLocalizations.of(context)!.generic_cancel,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    AppLocalizations.of(context)!.console_exit_kill,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w700,
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    process.kill();
                    Globals.consolecontroller.text += "[LAUNCHER]: ${AppLocalizations.of(context)!.console_game_kill_msg}\n";
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    AppLocalizations.of(context)!.console_exit_only,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w700,
                      color: ColorUtils.dynamicAccentColor.withAlpha(255),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
    process.stdout.transform(systemEncoding.decoder).forEach((line) {
      Globals.consolecontroller.text += line.toString();
    });
    process.stderr.transform(systemEncoding.decoder).forEach((line) {
      Globals.consolecontroller.text += line.toString();
    });
  }

  static void showDiagnostic(dynamic context) {
    Globals.diagnosticcontroller.clear();
    Globals.diagnosticcontroller.text += "------- System info -------\n";
    Globals.diagnosticcontroller.text += "Build: ${Globals.buildVersion}\n";
    Globals.diagnosticcontroller.text += "Platform: ${Platform.version}\n";
    Globals.diagnosticcontroller.text += "Operating system: ${Platform.operatingSystemVersion}\n";
    Globals.diagnosticcontroller.text += "Locale: ${Platform.localeName}\n";
    Globals.diagnosticcontroller.text += "Machine name: ${Platform.localHostname}\n";
    Globals.diagnosticcontroller.text += "CPU cores: ${Platform.numberOfProcessors}\n";
    Globals.diagnosticcontroller.text += "Java executable: ${Globals.javapathcontroller.text}\n";
    Globals.diagnosticcontroller.text += "Java Ram: ${Globals.javaramcontroller.text}\n";
    Globals.diagnosticcontroller.text += "Java advanced settings: ${Globals.javaAdvSet}\n";
    Globals.diagnosticcontroller.text += "Java args: ${Globals.javavmcontroller.text}\n";
    Globals.diagnosticcontroller.text += "Launcher args: ${Globals.javalaunchercontroller.text}\n";
    Globals.diagnosticcontroller.text += "------- Installed versions -------\n";
    for (var version in VersionUtils.getMinecraftOfflineVersions(false)) {
      Globals.diagnosticcontroller.text += "Type: ${version["type"]}, Version: ${version["id"]}\n";
    }
    for (var version in VersionUtils.getMinecraftOfflineVersions(true)) {
      Globals.diagnosticcontroller.text += "Type: ${version["type"]}, Version: ${version["id"]}\n";
    }
    if (Globals.accounts.isNotEmpty) {
      Globals.diagnosticcontroller.text += "------- Accounts -------\n";
      for (var account in Globals.accounts) {
        Globals.diagnosticcontroller.text += "Username: ${account.username}, UUID: ${account.uuid}, Premium: ${account.isPremium}, Slim skin: ${account.isSlimSkin}\n";
      }
    }
    Globals.diagnosticcontroller.text += "------- Game crashlog -------\n";
    List<String> lines = Globals.consolecontroller.text.split('\n');
    for (String line in lines) {
      Globals.diagnosticcontroller.text += line + "\n";
    }

    WidgetUtils.showPopup(
      context,
      AppLocalizations.of(context)!.settings_diagnostic_title,
      <Widget>[
        Container(
          color: Colors.white.withAlpha(128),
          padding: new EdgeInsets.all(2.0),
          child: TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: Globals.diagnosticcontroller,
            readOnly: true,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              fontFamily: "JetbrainsMono",
              color: Colors.black,
            ),
          ),
        ),
      ],
      [
        TextButton(
          child: Text(
            AppLocalizations.of(context)!.settings_diagnostic_copy,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w700,
              color: ColorUtils.dynamicAccentColor.withAlpha(255),
            ),
          ),
          onPressed: () async {
            await Clipboard.setData(
              ClipboardData(text: Globals.diagnosticcontroller.text),
            );
          },
        ),
        TextButton(
          child: Text(
            AppLocalizations.of(context)!.console_exit_only,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Comfortaa',
              fontWeight: FontWeight.w700,
              color: ColorUtils.dynamicAccentColor.withAlpha(255),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  static void showLoadingCircle(dynamic context) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Image.asset(
            'assets/morpheus-animated.gif',
            width: 64,
          ),
        );
      },
    );
  }

  static TextStyle customTextStyle(
    double size,
    FontWeight weight,
    Color textColor,
  ) {
    return TextStyle(
      fontSize: size,
      fontFamily: 'Comfortaa',
      fontWeight: weight,
      color: textColor,
      shadows: [
        Shadow(
          color: ColorUtils.defaultShadowColor,
          // Choose the color of the shadow
          blurRadius: 15.0,
          // Adjust the blur radius for the shadow effect
          offset: Offset(
            2.0,
            2.0,
          ), // Set the horizontal and vertical offset for the shadow
        ),
      ],
    );
  }

  static Widget backShadow(Widget child, dynamic radius, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color,
            blurRadius: radius,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}
