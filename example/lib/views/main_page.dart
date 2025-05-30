import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:blur/blur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image/image.dart' as img;
import 'package:morpheus_launcher_gui/account/account_utils.dart';
import 'package:morpheus_launcher_gui/account/microsoft_auth.dart';
import 'package:morpheus_launcher_gui/globals.dart';
import 'package:morpheus_launcher_gui/main.dart';
import 'package:morpheus_launcher_gui/utils/morpheus_icons_icons.dart';
import 'package:morpheus_launcher_gui/views/widget_news.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_3d/simple_3d.dart';
import 'package:simple_3d_renderer/simple_3d_renderer.dart';
import 'package:system_theme/system_theme.dart';
import 'package:text_divider/text_divider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:util_simple_3d/util_simple_3d.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    rebuild();
  }

  Future<void> rebuild() async {
    if (AccountUtils.getAccount() != null) {
      ThreeDimensionalViewer.objs.clear();
      ThreeDimensionalViewer.setupUV(AccountUtils.getAccount()!.isSlimSkin);
      ThreeDimensionalViewer.texturizePlayerModel();
      Timer.periodic(Duration(milliseconds: 100), (timer) async {
        setState(() {
          ThreeDimensionalViewer.isLoaded = ThreeDimensionalViewer.isLoaded;
        });
        timer.cancel();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /** Padding per non far casino con i tasti della titlebar */
    /** e anche Padding laterale per la navbar e per la lista */
    return Material(
      color: ColorUtils.dynamicWindowBackgroundColor,
      child: Column(
        children: [
          drawTitleCustomBar(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Stack(
                children: [
                  if (Globals.NavSelected == 0) ...[
                    /** Home */
                    Row(children: [
                      buildNavbar(),
                      SizedBox(width: 8),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: buildHomeWidgetList(),
                        ),
                      ),
                    ]),
                  ] else if (Globals.NavSelected == 1) ...[
                    /** Vanilla */
                    Row(children: [
                      buildNavbar(),
                      SizedBox(width: 8),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: buildVanillaList(),
                        ),
                      ),
                    ]),
                  ] else if (Globals.NavSelected == 2) ...[
                    /** Versioni moddate */
                    Row(children: [
                      buildNavbar(),
                      SizedBox(width: 8),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: buildModdedList(),
                        ),
                      ),
                    ]),
                  ] else if (Globals.NavSelected == 3) ...[
                    /** Impostazioni */
                    Row(children: [
                      buildNavbar(),
                      SizedBox(width: 8),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: buildSettingsList(),
                        ),
                      ),
                    ]),
                  ] else if (Globals.NavSelected == 4) ...[
                    /** Alt Manager */
                    Row(children: [
                      buildNavbar(),
                      SizedBox(width: 8),
                      /** Lista account */
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: buildAccountList(),
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /** Mostra la skin del player a destra */
                          if (AccountUtils.getAccount() != null && ThreeDimensionalViewer.objs.isNotEmpty) ...[
                            Sp3dRenderer(
                              const Size(150, 280),
                              Sp3dV2D(75, 125),
                              ThreeDimensionalViewer.world,
                              Sp3dCamera(Sp3dV3D(0, 0, 3000), 1500),
                              Sp3dLight(Sp3dV3D(0, 0, 0), syncCam: true),
                              allowUserWorldZoom: false,
                              allowUserWorldRotation: true,
                              useClipping: true,
                            ),
                          ],
                          SizedBox(height: 5),

                          /** Pulsante Cambia Skin */
                          WidgetUtils.buildButton(
                            Icons.brush,
                            ColorUtils.dynamicPrimaryForegroundColor,
                            ColorUtils.primaryFontColor,
                            () async {
                              if (AccountUtils.getAccount()!.isPremium) {
                                WidgetUtils.showPopup(
                                  context,
                                  AppLocalizations.of(context)!.account_skin_uploader_type_title,
                                  <Widget>[
                                    Text(
                                      AppLocalizations.of(context)!.account_skin_uploader_msg,
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
                                        "Slim",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Comfortaa',
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        FilePickerResult? result = await FilePicker.platform.pickFiles();
                                        if (result != null) {
                                          File file = File(result.files.single.path!);
                                          WidgetUtils.showMessageDialog(
                                            context,
                                            AppLocalizations.of(context)!.account_skin_uploader_title,
                                            "${await uploadSkin(context, "slim", AccountUtils.getAccount()!, file.path.replaceAll("\\", "/"))}",
                                            () => Navigator.pop(context),
                                          );
                                        }
                                      },
                                    ),
                                    TextButton(
                                      child: const Text(
                                        "Classic",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Comfortaa',
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        FilePickerResult? result = await FilePicker.platform.pickFiles();
                                        if (result != null) {
                                          File file = File(result.files.single.path!);
                                          WidgetUtils.showMessageDialog(
                                            context,
                                            AppLocalizations.of(context)!.account_skin_uploader_title,
                                            "${await uploadSkin(context, "classic", AccountUtils.getAccount()!, file.path.replaceAll("\\", "/"))}",
                                            () => Navigator.pop(context),
                                          );
                                        }
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        AppLocalizations.of(context)!.generic_cancel,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Comfortaa',
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red,
                                        ),
                                      ),
                                      onPressed: () async => Navigator.pop(context),
                                    ),
                                  ],
                                );
                              } else {
                                WidgetUtils.showPopup(
                                  context,
                                  AppLocalizations.of(context)!.generic_error_msg,
                                  [
                                    Text(
                                      AppLocalizations.of(context)!.account_skin_error_msg,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Comfortaa',
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                  [
                                    TextButton(
                                      onPressed: () async {
                                        await launchUrl(Uri.parse("https://www.minecraft.net/it-it/store/minecraft-java-bedrock-edition-pc"));
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.account_skin_buy_game,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Comfortaa',
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        "OK",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Comfortaa',
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),

                          /** Pulsanti add remove */
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              /** Aggiungi Account */
                              WidgetUtils.buildButton(
                                Icons.add,
                                ColorUtils.dynamicPrimaryForegroundColor,
                                ColorUtils.primaryFontColor,
                                () {
                                  /** Selezione tipo di account */
                                  WidgetUtils.showPopup(
                                    context,
                                    AppLocalizations.of(context)!.account_add_button,
                                    <Widget>[
                                      Text(
                                        AppLocalizations.of(context)!.account_add_type,
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
                                          "SP",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Comfortaa',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        onPressed: () {
                                          AccountUtils.addSP(
                                            context,
                                            () => {
                                              setState(() {
                                                if (Globals.usernamecontroller.text.isNotEmpty)
                                                  Globals.accounts.add(
                                                    new Account(
                                                      username: Globals.usernamecontroller.text,
                                                      uuid: getOfflinePlayerUuid(Globals.usernamecontroller.text).toString(),
                                                      accessToken: "0",
                                                      refreshToken: "",
                                                      isPremium: false,
                                                      isSlimSkin: isSkinSlim(Globals.usernamecontroller.text),
                                                    ),
                                                  );
                                                saveAccounts();
                                                Globals.usernamecontroller.text = "";
                                              }),
                                              rebuild(),
                                            },
                                          );
                                        },
                                      ),
                                      TextButton(
                                        child: const Text(
                                          "Premium",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Comfortaa',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        onPressed: () {
                                          AccountUtils.addPremium(
                                            context,
                                            (username, uuid, accesstoken, refreshtoken, isPremium, isSlimSkin) => {
                                              setState(
                                                () {
                                                  Globals.accounts.add(
                                                    new Account(
                                                      username: username,
                                                      uuid: uuid,
                                                      accessToken: accesstoken,
                                                      refreshToken: refreshtoken,
                                                      isPremium: isPremium,
                                                      isSlimSkin: isSlimSkin,
                                                    ),
                                                  );
                                                },
                                              ),
                                              rebuild(),
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                              /** Remove Account */
                              WidgetUtils.buildButton(
                                Icons.remove,
                                ColorUtils.dynamicPrimaryForegroundColor,
                                ColorUtils.primaryFontColor,
                                () {
                                  setState(() {
                                    if (Globals.accounts.isNotEmpty) {
                                      Globals.accounts.removeAt(Globals.AccountSelected);
                                      saveAccounts();
                                    } else {
                                      WidgetUtils.showMessageDialog(
                                        context,
                                        AppLocalizations.of(context)!.generic_error_msg,
                                        AppLocalizations.of(context)!.account_remove_error,
                                        () => Navigator.pop(context),
                                      );
                                    }
                                    Globals.AccountSelected = 0;
                                  });
                                  rebuild();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(width: 10),
                    ]),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////
  //////////// NAVBAR //////////////
  //////////////////////////////////

  /** Renderizza la Navbar */
  Widget buildNavbar() {
    return Material(
      elevation: 15,
      color: ColorUtils.dynamicPrimaryForegroundColor,
      shadowColor: ColorUtils.defaultShadowColor,
      borderRadius: BorderRadius.circular(Globals.borderRadius),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildNavItem(Icons.home, 0),
          buildNavItem(MorpheusIcons.vanilla, 1),
          buildNavItem(MorpheusIcons.modded, 2),
          buildNavItem(Icons.settings, 3),
          buildNavAccountItem(4),
        ],
      ),
    );
  }

  /** Renderizza le icone della Navbar */
  Widget buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          Globals.NavSelected = index;
        });
        try {
          Globals.pinnedVersions = await VersionUtils.getPinnedVersions();
        } catch (e) {
          print(e);
        }
      },
      child: MouseRegion(
        onEnter: (e) => {},
        child: Container(
          height: 70,
          width: 60,
          child: Center(
            child: Material(
              elevation: 10,
              color: Colors.transparent,
              shadowColor: ColorUtils.defaultShadowColor,
              borderRadius: BorderRadius.circular(10),
              child: Icon(
                icon,
                color: Globals.NavSelected == index ? ColorUtils.primaryFontColor.withAlpha(255) : ColorUtils.primaryFontColor.withAlpha(128),
                size: 30,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /** Renderizza la faccia del player */
  Widget buildNavAccountItem(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          Globals.NavSelected = index;
        });
      },
      child: MouseRegion(
        onEnter: (e) => {},
        child: Container(
          height: 80,
          width: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              opacity: Globals.NavSelected == index ? 1 : 0.5,
              image: AccountUtils._buildAvatarImageProvider(),
            ),
          ),
          child: Center(
            child: Material(
              elevation: 10,
              color: Colors.transparent,
              shadowColor: ColorUtils.defaultShadowColor,
              borderRadius: BorderRadius.circular(10),
              child: ImageIcon(
                AccountUtils._buildAvatarImageProvider(),
                color: Colors.transparent,
                size: 35,
              ),
            ),
          ),
        ),
      ),
    );
  }

  ////////// HOME PAGE /////////////

  ListView buildHomeWidgetList() {
    return ListView(
      children: [
        /** Versioni pinnate */
        if (Globals.pinnedVersions.isNotEmpty) ...[
          /** Divider Versioni Preferite */
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: TextDivider(
              color: ColorUtils.secondaryFontColor.withAlpha(80),
              thickness: 2,
              text: Text(
                AppLocalizations.of(context)!.home_favourite_title,
                textAlign: TextAlign.center,
                style: WidgetUtils.customTextStyle(20, FontWeight.w300, ColorUtils.primaryFontColor),
              ),
            ),
          ),
          for (var version in VersionUtils.getAllVersions())
            if (Globals.pinnedVersions.contains(version["id"])) ...[
              buildVanillaItem(
                version["type"],
                version["id"],
                "",
                VersionUtils.isCompatible(version["type"], version["id"]),
              ),
            ],
          /** Divider News/Changelog mojang */
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: TextDivider(
              color: ColorUtils.secondaryFontColor.withAlpha(80),
              thickness: 2,
              text: Text(
                AppLocalizations.of(context)!.home_news_title,
                textAlign: TextAlign.center,
                style: WidgetUtils.customTextStyle(20, FontWeight.w300, ColorUtils.primaryFontColor),
              ),
            ),
          ),
        ],

        /** Changelog */
        if (LauncherUtils.isOnline()) ...[
          for (var version in Globals.vanillaNewsResponse) ...[
            if ((version["type"] == "release" && Globals.showOnlyReleases) || !Globals.showOnlyReleases) ...[
              buildNewsItem(
                version["title"].toString().replaceAll(": Java Edition", "").replaceAll(" Aquatic", ""),
                version["body"],
                version["image"]["url"],
              ),
            ],
          ],
        ] else ...[
          /** quando non può mostrare le news */
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Text(
              AppLocalizations.of(context)!.home_news_empty_msg,
              textAlign: TextAlign.center,
              style: WidgetUtils.customTextStyle(14, FontWeight.w300, ColorUtils.primaryFontColor),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Divider(
              color: ColorUtils.secondaryFontColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget buildNewsItem(String title, String body, String url) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
      child: Container(
        width: (MediaQuery.of(context).size.width / 5) - 5,
        child: Material(
          elevation: 15,
          color: ColorUtils.dynamicPrimaryForegroundColor,
          shadowColor: ColorUtils.defaultShadowColor,
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsScreen(
                        title: title,
                        body: body,
                        url: url,
                      ),
                    ),
                  );
                },
                /** Roba della miniatura e titolo */
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        "${Urls.mojangContentURL}${url}",
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 4,
                        fit: BoxFit.cover,
                      ).blurred(
                        blur: 4,
                        blurColor: Colors.black,
                        colorOpacity: 0.1,
                        borderRadius: BorderRadius.circular(Globals.borderRadius - 2),
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width / 25,
                          fontFamily: 'Comfortaa',
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withAlpha(160),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /////////// VANILLA //////////////

  ListView buildVanillaList() {
    return ListView(
      children: [
        /** Avvisa l'utente che non ha versioni vanilla */
        if (VersionUtils.getMinecraftVersions(false).isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              AppLocalizations.of(context)!.vanilla_empty_title,
              textAlign: TextAlign.center,
              style: WidgetUtils.customTextStyle(22, FontWeight.w300, ColorUtils.primaryFontColor),
            ),
          ),

        /** Ultime versioni (ONLINE) */
        if (Globals.vanillaVersionsResponse != null) ...[
          buildVanillaItem(AppLocalizations.of(context)!.vanilla_release_title, Globals.vanillaVersionsResponse["latest"]["release"], "", true),
          buildVanillaItem(AppLocalizations.of(context)!.vanilla_snapshot_title, Globals.vanillaVersionsResponse["latest"]["snapshot"], "", true),
          /** Separatore */
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              color: ColorUtils.secondaryFontColor,
            ),
          ),
        ],

        /** Lista completa delle versioni solo vanilla (misto) */
        for (var version in VersionUtils.getMinecraftVersions(false))
          if ((version["type"] == "release" && Globals.showOnlyReleases) || !Globals.showOnlyReleases)
            buildVanillaItem(version["type"], version["id"], version["releaseTime"], VersionUtils.isCompatible(version["type"], version["id"])),
      ],
    );
  }

  Widget buildVanillaItem(String gameType, String gameVersion, String releaseDate, bool compatible) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
      child: Container(
        height: 55,
        width: (MediaQuery.of(context).size.width / 5) - 5,
        child: Material(
          elevation: 15,
          color: ColorUtils.dynamicPrimaryForegroundColor,
          shadowColor: ColorUtils.defaultShadowColor,
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                child: Icon(
                  compatible ? Icons.check_circle_rounded : Icons.not_interested_rounded,
                  color: compatible ? Colors.lightGreenAccent : Colors.redAccent,
                ),
              ),

              /** Info delle Versione */
              Padding(
                padding: EdgeInsets.fromLTRB(42, releaseDate != "" ? 5 : 14, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${gameType.substring(0, 1).toUpperCase() + gameType.substring(1)} ${gameVersion}",
                      style: WidgetUtils.customTextStyle(releaseDate.isNotEmpty ? 18 : 20, FontWeight.w500, ColorUtils.primaryFontColor),
                    ),
                    if (releaseDate.isNotEmpty)
                      Text(
                        "${DateTime.parse(releaseDate).toLocal().day}/${DateTime.parse(releaseDate).toLocal().month}/${DateTime.parse(releaseDate).toLocal().year}",
                        style: WidgetUtils.customTextStyle(14, FontWeight.w500, ColorUtils.secondaryFontColor),
                      ),
                  ],
                ),
              ),

              /** Sezione pulsanti */
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  /** Pulsante Preferiti */
                  if (!gameType.contains(AppLocalizations.of(context)!.vanilla_release_title) && !gameType.contains(AppLocalizations.of(context)!.vanilla_snapshot_title)) ...[
                    WidgetUtils.buildButton(
                      Globals.pinnedVersions.contains(gameVersion) ? Icons.favorite : Icons.favorite_border,
                      ColorUtils.dynamicSecondaryForegroundColor,
                      ColorUtils.primaryFontColor,
                      () async {
                        setState(() {
                          if (!Globals.pinnedVersions.contains(gameVersion)) {
                            Globals.pinnedVersions.add(gameVersion);
                          } else {
                            Globals.pinnedVersions.remove(gameVersion);
                          }
                        });
                        await VersionUtils.updateLauncherProfiles(Globals.pinnedVersions);
                      },
                    ),
                  ],

                  /** Pulsante Play */
                  WidgetUtils.buildButton(
                    Icons.rocket_launch,
                    ColorUtils.dynamicAccentColor,
                    Colors.white,
                    () async {
                      if (AccountUtils.getAccount() != null) {
                        if (!Globals.javaAdvSet) WidgetUtils.showLoadingCircle(context);
                        Globals.consolecontroller.clear();
                        AccountUtils.refreshPremium(context); // refresha il token di minecraft

                        var realGameVersion = gameVersion;
                        var isModded = false;
                        List<String> args = [];

                        if (gameType.contains(AppLocalizations.of(context)!.vanilla_release_title)) {
                          /* When game type is flagged as latest, the launcher will understand to download the latest release */
                          gameVersion = "latest";
                        } else if (gameType.contains(AppLocalizations.of(context)!.vanilla_snapshot_title)) {
                          /* Same as latest but even with snapshot */
                          gameVersion = "snapshot";
                        } else if (gameType.toLowerCase().contains("fabric") || gameVersion.toLowerCase().contains("fabric")) {
                          /* check if fabric is already installed, if not tells to launcher to install fabric */
                          if (gameVersion.toLowerCase().startsWith("fabric")) {
                            /* Recognize what minecraft version it is, by parsing version name */
                            realGameVersion = gameVersion.split("-")[3];
                          } else {
                            var fabricVersion = Globals.fabricLoaderVersionsResponse[0]["version"];
                            gameVersion = "fabric-loader-$fabricVersion-$realGameVersion";
                          }
                          isModded = true;
                        } else if (gameType.toLowerCase().contains("optifine") || gameVersion.toLowerCase().contains("optifine")) {
                          /* check if the user is trying to install optifine, if yes tell the launcher to install optifine */
                          if (gameType.toLowerCase().contains("optifine")) {
                            realGameVersion = gameVersion.toLowerCase(); /* Recognize easily the minecraft version */
                            for (var version in Globals.optifineVersions) {
                              if (version.split("-")[0] == realGameVersion) {
                                /* Find what optifines are available to download */
                                gameVersion = version;
                              }
                            }
                          } else {
                            realGameVersion = gameVersion.toLowerCase().split("-")[0]; /* Java installer need always to know what minecraft you are launching */
                          }
                          isModded = true;
                        } else if (gameType.toLowerCase().contains("optiforge") || gameVersion.toLowerCase().contains("optiforge")) {
                          if (gameType.toLowerCase().contains("optiforge")) {
                            realGameVersion = gameVersion.toLowerCase();
                            for (var version in Globals.forgeVersions) {
                              if (version.split("-")[0] == realGameVersion) {
                                gameVersion = version.toString().replaceAll("forge", "optiforge");
                              }
                            }
                          } else {
                            realGameVersion = gameVersion.toLowerCase().split("-")[0];
                          }
                          isModded = true;
                          args.add("-Dfml.ignoreInvalidMinecraftCertificates=true");
                        } else if (gameType.toLowerCase().contains("forge") || gameVersion.toLowerCase().contains("forge")) {
                          if (gameType.toLowerCase().contains("forge")) {
                            realGameVersion = gameVersion.toLowerCase();
                            for (var version in Globals.forgeVersions) {
                              if (version.split("-")[0] == realGameVersion) {
                                gameVersion = version;
                              }
                            }
                          } else {
                            realGameVersion = gameVersion.toLowerCase().split("-")[0];
                          }
                          isModded = true;
                          args.add("-Dfml.ignoreInvalidMinecraftCertificates=true"); // Workaround for 1.6.4
                        }

                        // Installa java automaticamente
                        if (!Globals.javaAdvSet) {
                          try {
                            await LauncherUtils.JavaAutoInstall(isModded ? realGameVersion : gameVersion);
                            Navigator.pop(context); // Chiudi il cerchiolino
                          } catch (e) {
                            Navigator.pop(context);
                            WidgetUtils.showMessageDialog(context, AppLocalizations.of(context)!.generic_error_msg, "$e", () {
                              Navigator.pop(context);
                            });
                          }
                        }

                        // Workaround per colpa di mojang di merda
                        var isPremium = AccountUtils.getAccount()?.isPremium;
                        if ((gameVersion == "1.16.4" || gameVersion == "1.16.5") && isPremium == false) {
                          args.addAll([
                            "-Dminecraft.api.auth.host=https://0.0.0.0/",
                            "-Dminecraft.api.account.host=https://0.0.0.0/",
                            "-Dminecraft.api.session.host=https://0.0.0.0/",
                            "-Dminecraft.api.services.host=https://0.0.0.0/",
                          ]);
                        }
                        // Workaround sovra-ingegnerizzato per colpa di apple
                        var startOnFirstThread = false;
                        if (Platform.isMacOS) {
                          var verList = VersionUtils.getMinecraftVersions(false);
                          // A partire da questa versione è necessario su mac usare XstartOnFirstThread
                          var startingVersionIndex = verList.indexWhere((version) => version["id"] == "17w43a");
                          var currentVersionIndex = verList.indexWhere((version) => version["id"] == gameVersion);

                          if (currentVersionIndex <= startingVersionIndex) {
                            args.addAll(["-XstartOnFirstThread"]);
                            startOnFirstThread = true;
                          }
                        }

                        // Args VM aggiuntivi
                        var vmSplit = Globals.javavmcontroller.text.split(" ");
                        if (Globals.javavmcontroller.text.isNotEmpty) args.addAll(vmSplit);

                        // Args normali
                        args.addAll([
                          "-Duser.dir=${Globals.gamefoldercontroller.text}",
                          "-Djava.library.path=${Globals.gamefoldercontroller.text}/versions/${gameVersion}/natives/",
                          ...LauncherUtils.buildJVMOptimizedArgs(Globals.javaramcontroller.text),
                          "-jar",
                          "${LauncherUtils.getApplicationFolder("morpheus")}/Launcher.jar",
                          "-version",
                          gameVersion,
                          "-minecraftToken",
                          "${AccountUtils.getAccount()?.accessToken}",
                          "-minecraftUsername",
                          "${AccountUtils.getAccount()?.username}",
                          "-minecraftUUID",
                          "${AccountUtils.getAccount()?.uuid}",
                        ]);

                        if (Globals.forceClasspath) {
                          args.addAll(['-c']);
                        }

                        if (startOnFirstThread) {
                          args.addAll(["-startOnFirstThread"]);
                        }

                        if (Globals.customFolderSet) {
                          args.addAll([
                            "-gameFolder",
                            "${Globals.gamefoldercontroller.text}",
                          ]);
                        }

                        var launcherSplit = Globals.javalaunchercontroller.text.split(" ");
                        if (Globals.javalaunchercontroller.text.isNotEmpty) args.addAll(launcherSplit);

                        try {
                          Process process = await Process.start(Globals.javapathcontroller.text, args);
                          if (Globals.showConsole) {
                            WidgetUtils.showConsole(context, process);
                          } else {
                            process.stdout.transform(systemEncoding.decoder).forEach((line) {});
                            process.stderr.transform(systemEncoding.decoder).forEach((line) {});
                          }
                          int exitCode = await process.exitCode;
                          Globals.consolecontroller.text += "[LAUNCHER]: exit code $exitCode";
                          // check if minecraft crashed and isn't crashed manually
                          if (exitCode != 0 && exitCode != 143) {
                            WidgetUtils.showPopup(
                              context,
                              AppLocalizations.of(context)!.generic_error_msg,
                              <Widget>[
                                Text(
                                  AppLocalizations.of(context)!.console_crash_msg,
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
                                  onPressed: () async {
                                    // final lines = Globals.consolecontroller.text.split('\n');
                                    // final crashlog = lines.skip(lines.length > 40 ? lines.length - 40 : 0).join('\n');
                                    // print(crashlog);
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    AppLocalizations.of(context)!.generic_cancel,
                                    style: TextStyle(
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
                        } catch (error) {
                          WidgetUtils.showMessageDialog(
                            context,
                            AppLocalizations.of(context)!.generic_error_msg,
                            "$error",
                            () => Navigator.pop(context),
                          );
                        }
                      } else {
                        WidgetUtils.showMessageDialog(
                          context,
                          AppLocalizations.of(context)!.account_required_title,
                          AppLocalizations.of(context)!.account_required_msg,
                          () {
                            Navigator.pop(context);
                            setState(() => Globals.NavSelected = 4);
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /////////// MODDING //////////////

  ListView buildModdedList() {
    return ListView(
      children: [
        /** Separatore versioni moddate istallate */
        if (VersionUtils.getMinecraftVersions(true).isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: TextDivider(
              color: ColorUtils.secondaryFontColor.withAlpha(80),
              thickness: 2,
              text: Text(
                AppLocalizations.of(context)!.modded_installed_title,
                textAlign: TextAlign.center,
                style: WidgetUtils.customTextStyle(20, FontWeight.w300, ColorUtils.primaryFontColor),
              ),
            ),
          ),

        /** Avvisa l'utente che non ha versioni moddate */
        if (VersionUtils.getMinecraftVersions(true).isEmpty && !LauncherUtils.isOnline())
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              AppLocalizations.of(context)!.modded_empty_title,
              textAlign: TextAlign.center,
              style: WidgetUtils.customTextStyle(22, FontWeight.w300, ColorUtils.primaryFontColor),
            ),
          ),

        /** Lista completa delle versioni moddate istallate */
        for (var version in VersionUtils.getMinecraftVersions(true))
          buildVanillaItem(version["type"], version["id"], "", VersionUtils.isCompatible(version["type"], version["id"])),

        /** Lista delle optifine installabili */
        if (Globals.optifineVersions != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: TextDivider(
              color: ColorUtils.secondaryFontColor.withAlpha(80),
              thickness: 2,
              text: Text(
                AppLocalizations.of(context)!.modded_optifine_download_available,
                textAlign: TextAlign.center,
                style: WidgetUtils.customTextStyle(20, FontWeight.w300, ColorUtils.primaryFontColor),
              ),
            ),
          ),
          for (var version in Globals.optifineVersions) buildVanillaItem("Optifine", version.split("-")[0], "", VersionUtils.isCompatible("Optifine", version.split("-")[0])),
        ],

        /** Lista dei forge optifine installabili */
        if (Globals.forgeVersions != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: TextDivider(
              color: ColorUtils.secondaryFontColor.withAlpha(80),
              thickness: 2,
              text: Text(
                AppLocalizations.of(context)!.modded_forge_download_available,
                textAlign: TextAlign.center,
                style: WidgetUtils.customTextStyle(20, FontWeight.w300, ColorUtils.primaryFontColor),
              ),
            ),
          ),
          for (var version in Globals.optiforgeVersions) buildVanillaItem("OptiForge", version.split("-")[0], "", VersionUtils.isCompatible("OptiForge", version.split("-")[0])),
        ],

        /** Lista dei forge installabili */
        if (Globals.forgeVersions != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: TextDivider(
              color: ColorUtils.secondaryFontColor.withAlpha(80),
              thickness: 2,
              text: Text(
                AppLocalizations.of(context)!.modded_forge_download_available,
                textAlign: TextAlign.center,
                style: WidgetUtils.customTextStyle(20, FontWeight.w300, ColorUtils.primaryFontColor),
              ),
            ),
          ),
          for (var version in Globals.forgeVersions) buildVanillaItem("Forge", version.split("-")[0], "", VersionUtils.isCompatible("Forge", version.split("-")[0])),
        ],

        /** Lista dei fabric installabili */
        if (Globals.fabricGameVersionsResponse != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: TextDivider(
              color: ColorUtils.secondaryFontColor.withAlpha(80),
              thickness: 2,
              text: Text(
                AppLocalizations.of(context)!.modded_fabric_download_available,
                textAlign: TextAlign.center,
                style: WidgetUtils.customTextStyle(20, FontWeight.w300, ColorUtils.primaryFontColor),
              ),
            ),
          ),
          for (var version in Globals.fabricGameVersionsResponse) buildVanillaItem("Fabric", version["version"], "", true),
        ],
      ],
    );
  }

  /////////// SETTING //////////////

  ListView buildSettingsList() {
    return ListView(
      children: [
        /** Separatore */
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: TextDivider(
            color: ColorUtils.secondaryFontColor.withAlpha(80),
            thickness: 2,
            text: Text(
              AppLocalizations.of(context)!.settings_appearance_label,
              textAlign: TextAlign.center,
              style: WidgetUtils.customTextStyle(20, FontWeight.w300, ColorUtils.primaryFontColor),
            ),
          ),
        ),

        /** Setting per la darkmode */
        WidgetUtils.buildSettingSwitchItem(
          AppLocalizations.of(context)!.settings_dark_mode_switch,
          "darkModeTheme",
          CustomSettingSwitchStyle(
            icon: Icons.invert_colors_rounded,
            bgColor: ColorUtils.dynamicPrimaryForegroundColor,
            shadowColor: ColorUtils.defaultShadowColor,
            fontColor: ColorUtils.primaryFontColor,
            toggleColor: ColorUtils.isMaterial ? ColorUtils.dynamicPrimaryForegroundColor : Colors.white,
            activeColor: ColorUtils.dynamicAccentColor,
            inactiveColor: ColorUtils.dynamicSecondaryForegroundColor,
          ),
          Globals.darkModeTheme,
          (value) {
            setState(() => Globals.darkModeTheme = value);
            ColorUtils.reloadColors();

            Window.setEffect(
              effect: getWindowEffect(),
              color: ColorUtils.dynamicBackgroundColor,
              dark: Globals.darkModeTheme,
            );
            if (Platform.isMacOS) {
              Window.overrideMacOSBrightness(
                dark: Globals.darkModeTheme,
              );
            }
          },
        ),

        /** Setting per il colore */
        WidgetUtils.buildSettingContainerItem(
          Stack(
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
                        borderRadius: BorderRadius.circular(10),
                        child: Icon(
                          Icons.color_lens,
                          color: ColorUtils.primaryFontColor,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  /** Nome del setting */
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.settings_follow_system_color,
                          style: WidgetUtils.customTextStyle(16, FontWeight.w500, ColorUtils.primaryFontColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 18, 10, 0),
                    child: Material(
                      elevation: 15,
                      color: Colors.transparent,
                      shadowColor: Colors.transparent,
                      // Globals.defaultShadowColor,
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: [
                          MouseRegion(
                            onEnter: (e) => {},
                            child: GestureDetector(
                              onTap: () async => {
                                Globals.accentColor = 0,
                                (await SharedPreferences.getInstance()).setInt('accentColor', Globals.accentColor),
                                setState(() => ColorUtils.dynamicAccentColor = ColorUtils.getColorFromAccent(Globals.accentColor)),
                                ColorUtils.reloadColors(),
                                Window.setEffect(
                                  effect: getWindowEffect(),
                                  color: ColorUtils.dynamicBackgroundColor,
                                  dark: Globals.darkModeTheme,
                                ),
                                if (Platform.isMacOS) ...[
                                  Window.overrideMacOSBrightness(
                                    dark: Globals.darkModeTheme,
                                  ),
                                ],
                              },
                              child: Stack(
                                children: [
                                  ColoredCircle(
                                    size: 20,
                                    color: SystemTheme.accentColor.light.withAlpha(200),
                                    outlineColor: Globals.accentColor == 0 ? Colors.white : Colors.transparent,
                                    outlineWidth: 2,
                                    distance: 3,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(2, 4, 0, 0),
                                    child: Text(
                                      "OS",
                                      style: WidgetUtils.customTextStyle(10, FontWeight.w100, Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          for (int i = 1; i <= 7; i++) ...[
                            SizedBox(
                              width: 2,
                            ),
                            MouseRegion(
                              onEnter: (e) => {},
                              child: GestureDetector(
                                onTap: () async => {
                                  Globals.accentColor = i,
                                  (await SharedPreferences.getInstance()).setInt('accentColor', Globals.accentColor),
                                  setState(() => ColorUtils.dynamicAccentColor = ColorUtils.getColorFromAccent(Globals.accentColor)),
                                  ColorUtils.reloadColors(),
                                  Window.setEffect(
                                    effect: getWindowEffect(),
                                    color: ColorUtils.dynamicBackgroundColor,
                                    dark: Globals.darkModeTheme,
                                  ),
                                  if (Platform.isMacOS) ...[
                                    Window.overrideMacOSBrightness(
                                      dark: Globals.darkModeTheme,
                                    ),
                                  ],
                                },
                                child: ColoredCircle(
                                  size: 20,
                                  color: ColorUtils.getColorFromAccent(i),
                                  outlineColor: Globals.accentColor == i ? Colors.white : Colors.transparent,
                                  outlineWidth: 2,
                                  distance: 3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        /** Setting Tema */
        WidgetUtils.buildSettingContainerItem(
          Stack(
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
                        borderRadius: BorderRadius.circular(10),
                        child: Icon(
                          Icons.brush,
                          color: ColorUtils.primaryFontColor,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                  /** Nome del setting */
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.settings_theme,
                          style: WidgetUtils.customTextStyle(16, FontWeight.w500, ColorUtils.primaryFontColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                    child: Material(
                      elevation: 15,
                      color: Colors.transparent,
                      shadowColor: ColorUtils.defaultShadowColor,
                      borderRadius: BorderRadius.circular(Globals.borderRadius),
                      child: MouseRegion(
                        onEnter: (e) => {},
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              'Theme',
                              style: WidgetUtils.customTextStyle(16, FontWeight.w500, ColorUtils.primaryFontColor),
                            ),
                            items: Globals.WindowThemes.map((String item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: WidgetUtils.customTextStyle(16, FontWeight.w500, ColorUtils.primaryFontColor),
                                  ),
                                )).toList(),
                            value: Globals.selectedWindowTheme,
                            onChanged: (String? value) async {
                              Globals.selectedWindowTheme = value!;
                              ColorUtils.isMaterial = (Globals.selectedWindowTheme.contains('Material'));

                              if (ColorUtils.isMaterial) Globals.fullTransparent = false;

                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setString("themeSet", Globals.selectedWindowTheme);
                              ColorUtils.reloadColors();

                              dynamic effect = getWindowEffect();
                              Window.setEffect(
                                effect: effect,
                                color: ColorUtils.dynamicBackgroundColor,
                                dark: Globals.darkModeTheme,
                              );
                              if (Platform.isMacOS) {
                                Window.overrideMacOSBrightness(
                                  dark: Globals.darkModeTheme,
                                );
                              }
                              setState(() => effect = effect);
                              ;
                            },
                            buttonStyleData: ButtonStyleData(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              height: 40,
                              width: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Globals.borderRadius - 4),
                                color: ColorUtils.dynamicSecondaryForegroundColor,
                              ),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              height: 40,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Globals.borderRadius - 4),
                                color: ColorUtils.dynamicPrimaryForegroundColor,
                              ),
                              offset: Offset(0, -4),
                              elevation: ColorUtils.isMaterial ? 9 : 0,
                            ),
                            iconStyleData: IconStyleData(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                              ),
                              iconSize: 14,
                              iconEnabledColor: ColorUtils.primaryFontColor,
                              iconDisabledColor: Colors.white30,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        /** Setting trasparenza per linux */
        if (Platform.isLinux && Globals.selectedWindowTheme == 'Clear') ...[
          WidgetUtils.buildSettingSwitchItem(
            "Disable background tinting",
            "fullTransparent",
            CustomSettingSwitchStyle(
              icon: Icons.format_paint_rounded,
              bgColor: ColorUtils.dynamicPrimaryForegroundColor,
              shadowColor: ColorUtils.defaultShadowColor,
              fontColor: ColorUtils.primaryFontColor,
              toggleColor: ColorUtils.isMaterial ? ColorUtils.dynamicPrimaryForegroundColor : Colors.white,
              activeColor: ColorUtils.dynamicAccentColor,
              inactiveColor: ColorUtils.dynamicSecondaryForegroundColor,
            ),
            Globals.fullTransparent,
            (value) {
              setState(() => Globals.fullTransparent = value);
            },
          ),
        ],

        /** Separatore */
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: TextDivider(
            color: ColorUtils.secondaryFontColor.withAlpha(80),
            thickness: 2,
            text: Text(
              AppLocalizations.of(context)!.settings_misc_label,
              textAlign: TextAlign.center,
              style: WidgetUtils.customTextStyle(20, FontWeight.w300, ColorUtils.primaryFontColor),
            ),
          ),
        ),

        /** Setting per nascondere tutto tranne le release */
        WidgetUtils.buildSettingSwitchItem(
          AppLocalizations.of(context)!.settings_only_release_switch,
          "showOnlyReleases",
          CustomSettingSwitchStyle(
            icon: Icons.widgets_rounded,
            bgColor: ColorUtils.dynamicPrimaryForegroundColor,
            shadowColor: ColorUtils.defaultShadowColor,
            fontColor: ColorUtils.primaryFontColor,
            toggleColor: ColorUtils.isMaterial ? ColorUtils.dynamicPrimaryForegroundColor : Colors.white,
            activeColor: ColorUtils.dynamicAccentColor,
            inactiveColor: ColorUtils.dynamicSecondaryForegroundColor,
          ),
          Globals.showOnlyReleases,
          (value) => setState(() => Globals.showOnlyReleases = value),
        ),

        /** Setting per mostrare la console */
        WidgetUtils.buildSettingSwitchItem(
          AppLocalizations.of(context)!.settings_console_switch,
          "showConsole",
          CustomSettingSwitchStyle(
            icon: Icons.terminal_rounded,
            bgColor: ColorUtils.dynamicPrimaryForegroundColor,
            shadowColor: ColorUtils.defaultShadowColor,
            fontColor: ColorUtils.primaryFontColor,
            toggleColor: ColorUtils.isMaterial ? ColorUtils.dynamicPrimaryForegroundColor : Colors.white,
            activeColor: ColorUtils.dynamicAccentColor,
            inactiveColor: ColorUtils.dynamicSecondaryForegroundColor,
          ),
          Globals.showConsole,
          (value) => setState(() => Globals.showConsole = value),
        ),

        /** Setting Java */
        WidgetUtils.buildSettingContainerItem(
          Column(
            children: [
              WidgetUtils.buildSettingSwitchItem(
                AppLocalizations.of(context)!.settings_java_advanced_settings,
                "javaAdvSet",
                CustomSettingSwitchStyle(
                  icon: MorpheusIcons.java,
                  bgColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  fontColor: ColorUtils.primaryFontColor,
                  toggleColor: ColorUtils.isMaterial ? ColorUtils.dynamicPrimaryForegroundColor : Colors.white,
                  activeColor: ColorUtils.dynamicAccentColor,
                  inactiveColor: ColorUtils.dynamicSecondaryForegroundColor,
                ),
                Globals.javaAdvSet,
                (value) => setState(() => Globals.javaAdvSet = value),
              ),
              if (Globals.javaAdvSet) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(6, 0, 6, 4),
                  child: Column(
                    children: [
                      /** Java selection */
                      WidgetUtils.buildSettingTextItem(
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 3, 3, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              WidgetUtils.buildButton(
                                Icons.folder,
                                ColorUtils.dynamicAccentColor,
                                Colors.white,
                                () async {
                                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                                  if (result != null) {
                                    File file = File(result.files.single.path!);
                                    Globals.javapathcontroller.text = file.path.replaceAll("\\", "/");
                                    SharedPreferences prefs = await SharedPreferences.getInstance();
                                    await prefs.setString("javaPath", Globals.javapathcontroller.text);
                                  }
                                },
                              ),
                              WidgetUtils.buildButton(
                                Icons.checklist,
                                ColorUtils.dynamicAccentColor,
                                Colors.white,
                                () async {
                                  final result = await LauncherUtils.checkJava();

                                  // Titolo fisso localizzato
                                  final title = AppLocalizations.of(context)!.settings_check_java_title;

                                  // Corpo del messaggio
                                  String message;
                                  if (result != null) {
                                    final type = result['type'];
                                    final version = result['version'];
                                    final date = result['releaseDate'];
                                    final lts = result['lts'] == 'true' ? 'LTS' : '';

                                    // Messaggio positivo + info JVM
                                    message = AppLocalizations.of(context)!.settings_check_java_yes +
                                        '\n\n→ JVM: $type\n→ Versione: $version' +
                                        (date != null && date.isNotEmpty ? '\n→ Data rilascio: $date' : '') +
                                        (lts.isNotEmpty ? '\n→ Tipo: $lts' : '');
                                  } else {
                                    // Messaggio negativo
                                    message = AppLocalizations.of(context)!.settings_check_java_no;
                                  }

                                  // Mostra dialog
                                  WidgetUtils.showMessageDialog(
                                    context,
                                    title,
                                    message,
                                    () => Navigator.pop(context),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        ColorUtils.dynamicSecondaryForegroundColor,
                        ColorUtils.primaryFontColor,
                        AppLocalizations.of(context)!.settings_java_path_msg,
                        Globals.javapathcontroller,
                        (value) async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString("javaPath", Globals.javapathcontroller.text);
                        },
                      ),
                      /** Java ram */
                      WidgetUtils.buildSettingTextItem(
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 3, 3, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              WidgetUtils.buildButton(
                                Icons.memory,
                                ColorUtils.dynamicAccentColor,
                                Colors.white,
                                () => {},
                              ),
                            ],
                          ),
                        ),
                        ColorUtils.dynamicSecondaryForegroundColor,
                        ColorUtils.primaryFontColor,
                        AppLocalizations.of(context)!.settings_java_ram_msg,
                        Globals.javaramcontroller,
                        (value) async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString("javaRAM", Globals.javaramcontroller.text);
                        },
                      ),
                      /** Java VM args */
                      WidgetUtils.buildSettingTextItem(
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 3, 3, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              WidgetUtils.buildButton(
                                MorpheusIcons.java,
                                ColorUtils.dynamicAccentColor,
                                Colors.white,
                                () => {},
                              ),
                            ],
                          ),
                        ),
                        ColorUtils.dynamicSecondaryForegroundColor,
                        ColorUtils.primaryFontColor,
                        "VM Args",
                        Globals.javavmcontroller,
                        (value) async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString("javaVMArgs", Globals.javavmcontroller.text);
                        },
                      ),
                      /** Launcher args */
                      WidgetUtils.buildSettingTextItem(
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 3, 3, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              WidgetUtils.buildButton(
                                Icons.terminal,
                                ColorUtils.dynamicAccentColor,
                                Colors.white,
                                () => {},
                              ),
                            ],
                          ),
                        ),
                        ColorUtils.dynamicSecondaryForegroundColor,
                        ColorUtils.primaryFontColor,
                        "Launcher args",
                        Globals.javalaunchercontroller,
                        (value) async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString("javaLauncherArgs", Globals.javalaunchercontroller.text);
                        },
                      ),
                      /** Modalità classpath */
                      WidgetUtils.buildSettingSwitchItem(
                        AppLocalizations.of(context)!.settings_force_classpath,
                        "forceClasspath",
                        CustomSettingSwitchStyle(
                          icon: Icons.fork_left_rounded,
                          bgColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          fontColor: ColorUtils.primaryFontColor,
                          toggleColor: ColorUtils.isMaterial ? ColorUtils.dynamicPrimaryForegroundColor : Colors.white,
                          activeColor: ColorUtils.dynamicAccentColor,
                          inactiveColor: ColorUtils.dynamicSecondaryForegroundColor,
                        ),
                        Globals.forceClasspath,
                        (value) => setState(() => Globals.forceClasspath = value),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        /** Cartella di installazione */
        WidgetUtils.buildSettingContainerItem(
          Column(
            children: [
              WidgetUtils.buildSettingSwitchItem(
                AppLocalizations.of(context)!.settings_custom_folder_title,
                "customFolderSet",
                CustomSettingSwitchStyle(
                  icon: Icons.folder_rounded,
                  bgColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  fontColor: ColorUtils.primaryFontColor,
                  toggleColor: ColorUtils.isMaterial ? ColorUtils.dynamicPrimaryForegroundColor : Colors.white,
                  activeColor: ColorUtils.dynamicAccentColor,
                  inactiveColor: ColorUtils.dynamicSecondaryForegroundColor,
                ),
                Globals.customFolderSet,
                (value) async => {
                  setState(() => Globals.customFolderSet = value),
                  if (!Globals.customFolderSet) ...[
                    Globals.gamefoldercontroller.text = LauncherUtils.getApplicationFolder("minecraft"),
                    await (await SharedPreferences.getInstance()).setString("gameFolderPath", Globals.gamefoldercontroller.text),
                  ],
                },
              ),
              if (Globals.customFolderSet) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(6, 0, 6, 4),
                  child: WidgetUtils.buildSettingTextItem(
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 3, 3, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          WidgetUtils.buildButton(
                            Icons.folder,
                            ColorUtils.dynamicAccentColor,
                            Colors.white,
                            () async {
                              final String? selectedDirectory = await getDirectoryPath();
                              if (selectedDirectory != null) {
                                Globals.gamefoldercontroller.text = selectedDirectory.replaceAll("\\", "/");
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setString("gameFolderPath", Globals.gamefoldercontroller.text);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    ColorUtils.dynamicSecondaryForegroundColor,
                    ColorUtils.primaryFontColor,
                    AppLocalizations.of(context)!.settings_custom_folder,
                    Globals.gamefoldercontroller,
                    (value) async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString("gameFolderPath", Globals.gamefoldercontroller.text);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),

        /* Tasti vari*/
        WidgetUtils.buildSettingContainerItem(
          Row(
            children: [
              /** Dati di diagnostica */
              WidgetUtils.buildTextButton(
                ColorUtils.dynamicSecondaryForegroundColor,
                ColorUtils.primaryFontColor,
                () {
                  WidgetUtils.showDiagnostic(context);
                },
                AppLocalizations.of(context)!.settings_diagnostic_title,
              ),
            ],
          ),
        ),

        /** Separatore */
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: TextDivider(
            color: ColorUtils.secondaryFontColor.withAlpha(80),
            thickness: 2,
            text: Text(
              AppLocalizations.of(context)!.settings_account_label,
              textAlign: TextAlign.center,
              style: WidgetUtils.customTextStyle(20, FontWeight.w300, ColorUtils.primaryFontColor),
            ),
          ),
        ),

        /**/
        WidgetUtils.buildSettingContainerItem(
          Row(children: [
            /** Bottone per pulire la cache */
            WidgetUtils.buildTextButton(
              Colors.red.withAlpha(160),
              Colors.white,
              () async {
                await DefaultCacheManager().emptyCache();
              },
              AppLocalizations.of(context)!.settings_clear_cache,
            ),

            /** Bottone per importare gli account */
            WidgetUtils.buildTextButton(
              ColorUtils.dynamicSecondaryForegroundColor,
              Colors.white,
              () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );
                if (result != null && result.files.single.path != null) {
                  final path = result.files.single.path!;
                  final importedAccounts = importAccountListFromJsonPlain(path);
                  Globals.accounts = importedAccounts;
                  saveAccounts();
                }
              },
              AppLocalizations.of(context)!.settings_account_import,
            ),

            /** Bottone per esportare gli account */
            WidgetUtils.buildTextButton(
              ColorUtils.dynamicSecondaryForegroundColor,
              Colors.white,
              () async {
                final result = await FilePicker.platform.saveFile(
                  dialogTitle: 'Save accounts as JSON',
                  fileName: 'accounts_plain.json',
                  type: FileType.custom,
                  allowedExtensions: ['json'],
                );
                if (result != null) {
                  exportAccountListToJsonPlain(Globals.accounts, result);
                }
              },
              AppLocalizations.of(context)!.settings_account_export,
            ),
          ]),
        ),

        /** Separatore */
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Divider(
              color: ColorUtils.secondaryFontColor,
            ),
          ),
        ),

        /** Info */
        Center(
          child: GestureDetector(
            child: Text(
              "build: ${Globals.buildVersion} on ${extractPlatformInfo(Platform.version)} - morpheuslauncher.it (cc by-nc-sa) 2023-2025",
              style: WidgetUtils.customTextStyle(12, FontWeight.w500, ColorUtils.secondaryFontColor),
            ),
            onTap: () {
              WidgetUtils.showMessageDialog(
                context,
                AppLocalizations.of(context)!.settings_credits_title,
                AppLocalizations.of(context)!.settings_credits_content,
                () => Navigator.pop(context),
              );
            },
          ),
        ),

        /** Links vari */
        Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              linkIcon(MorpheusIcons.globe, 'https://morpheuslauncher.it'),
              linkIcon(MorpheusIcons.discord, 'https://discord.gg/aerXnBe'),
              linkIcon(MorpheusIcons.github_mark, 'https://github.com/MorpheusLauncher'),
              linkIcon(MorpheusIcons.patreon, 'https://www.patreon.com/c/Lampadina_17'),
              linkIcon(MorpheusIcons.kofi, 'https://ko-fi.com/lampadina_17'),
            ],
          ),
        ),
      ],
    );
  }

  Widget linkIcon(IconData icon, String url) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: HoverIcon(icon: icon, url: url),
    );
  }

  String extractPlatformInfo(String versionString) {
    RegExp regex = RegExp(r'([a-zA-Z0-9]+_[a-zA-Z0-9]+)');
    RegExpMatch? match = regex.firstMatch(versionString);

    return match != null ? match.group(0)! : 'N/A';
  }

  /////////// ACCOUNT //////////////

  ListView buildAccountList() {
    return ListView(
      children: [
        if (Globals.accounts.isNotEmpty) ...[
          /** Lista degli account */
          for (var account in Globals.accounts)
            buildAccountEntry(
              account.username,
              account.isPremium,
              Globals.accounts.indexOf(account),
            ),
        ] else ...[
          /** mostra il messaggio quando non ci sono account */
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              AppLocalizations.of(context)!.account_empty_msg,
              textAlign: TextAlign.center,
              style: WidgetUtils.customTextStyle(14, FontWeight.w300, ColorUtils.primaryFontColor),
            ),
          ),
        ],
      ],
    );
  }

  Widget buildAccountEntry(String username, bool premium, int index) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
      child: Container(
        height: 55,
        width: (MediaQuery.of(context).size.width / 5) - 5,
        child: Material(
          elevation: 15,
          color: ColorUtils.dynamicPrimaryForegroundColor,
          shadowColor: ColorUtils.defaultShadowColor,
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          child: Stack(
            children: [
              /** Skin, nomi e altro */
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          opacity: 0.8,
                          image: CachedNetworkImageProvider("${Urls.skinURL}/head/${username}"),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: WidgetUtils.customTextStyle(18, FontWeight.w500, ColorUtils.primaryFontColor),
                        ),
                        Text(
                          premium ? "Premium" : "Offline",
                          style: WidgetUtils.customTextStyle(14, FontWeight.w300, ColorUtils.secondaryFontColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  /** Pulsante selezione */
                  WidgetUtils.buildButton(
                    Icons.check,
                    Globals.AccountSelected == index ? ColorUtils.dynamicAccentColor : (ColorUtils.dynamicSecondaryForegroundColor),
                    Globals.AccountSelected == index ? Colors.white : (Globals.darkModeTheme ? Colors.white.withAlpha(80) : Colors.black.withAlpha(80)),
                    () {
                      setState(() => Globals.AccountSelected = index);
                      rebuild();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HoverIcon extends StatefulWidget {
  final IconData icon;
  final String url;

  const HoverIcon({Key? key, required this.icon, required this.url}) : super(key: key);

  @override
  _HoverIconState createState() => _HoverIconState();
}

class _HoverIconState extends State<HoverIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () async {
          if (!await launchUrl(Uri.parse(widget.url))) {
            throw 'Unable to open the link: ${widget.url}';
          }
        },
        child: TweenAnimationBuilder<Color?>(
          duration: Duration(milliseconds: 100),
          tween: ColorTween(
            begin: _hovering ? ColorUtils.secondaryFontColor.withAlpha(128) : ColorUtils.secondaryFontColor.withAlpha(255),
            end: _hovering ? ColorUtils.secondaryFontColor.withAlpha(255) : ColorUtils.secondaryFontColor.withAlpha(128),
          ),
          builder: (context, color, child) => Icon(
            widget.icon,
            color: color,
          ),
        ),
      ),
    );
  }
}

class AccountUtils {
  //////////////////////////////////
  /////// ACCOUNT MANAGER //////////
  //////////////////////////////////

  static ImageProvider _buildSkinModelImageProvider() {
    if (getAccount() == null) {
      return AssetImage("assets/alex-raw.png");
    }

    final isPremium = getAccount()!.isPremium;
    final isSlimSkin = isSkinSlim(getAccount()!.username);

    if (isPremium) {
      try {
        return CachedNetworkImageProvider("${Urls.skinURL}/raw/${AccountUtils.getAccount()?.uuid}");
      } catch (e) {
        return AssetImage(isSlimSkin ? "assets/alex-raw.png" : "assets/steve-raw.png");
      }
    } else {
      return AssetImage(isSlimSkin ? "assets/alex-raw.png" : "assets/steve-raw.png");
    }
  }

  static ImageProvider _buildAvatarImageProvider() {
    if (getAccount() == null) {
      return AssetImage("assets/alex.png");
    }

    final isPremium = getAccount()!.isPremium;
    final isSlimSkin = isSkinSlim(getAccount()!.username);

    if (isPremium) {
      try {
        return CachedNetworkImageProvider("${Urls.skinURL}/avatar/${getAccount()?.username}");
      } catch (e) {
        return AssetImage(isSlimSkin ? "assets/alex.png" : "assets/steve.png");
      }
    } else {
      return AssetImage(isSlimSkin ? "assets/alex.png" : "assets/steve.png");
    }
  }

  static void addSP(dynamic context, Function callback) {
    Navigator.pop(context);
    WidgetUtils.showPopup(
      context,
      AppLocalizations.of(context)!.account_add_offline,
      <Widget>[
        Material(
          elevation: 10,
          color: Colors.transparent,
          shadowColor: ColorUtils.defaultShadowColor,
          borderRadius: BorderRadius.circular(8),
          child: WidgetUtils.buildSettingTextItem(
            null,
            Colors.white /* Sfondo della textbox */,
            Colors.black /* Colore del font della textbox */,
            "Username",
            Globals.usernamecontroller,
            (value) => null,
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
              fontWeight: FontWeight.w700,
            ),
          ),
          onPressed: () {
            callback();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  static Future<void> refreshPremium(dynamic context) async {
    if (getAccount()?.isPremium == true) {
      Globals.consolecontroller.text += "[LAUNCHER]: ${AppLocalizations.of(context)!.account_token_refresh}\n";

      try {
        var minecraftAuth = await doMicrosoftRefresh(context, getAccount()!.refreshToken);
        if (!minecraftAuth.toString().startsWith("[MC]:")) {
          var minecraftToken = minecraftAuth['access_token'];
          var minecraft = await fetchMinecraftProfile(context, minecraftToken);

          if (!minecraft.toString().startsWith("[MC]:")) {
            getAccount()?.accessToken = minecraftToken;
            saveAccounts();
          } else {
            WidgetUtils.showMessageDialog(
              context,
              AppLocalizations.of(context)!.generic_error_msg,
              "${minecraft}",
              () => Navigator.pop(context),
            );
          }
        }
      } catch (e) {
        Globals.consolecontroller.text += "[LAUNCHER]: ${AppLocalizations.of(context)!.account_token_fail}\n";
      }
    }
  }

  static Future<void> addPremium(
    dynamic context,
    Function(dynamic username, dynamic uuid, dynamic accesstoken, dynamic refreshtoken, bool isPremium, bool isSlimSkin) callback,
  ) async {
    String str = await doMicrosoftConsent(context);

    if (!str.startsWith("[MS]:")) {
      Map<String, dynamic> data = json.decode(str);
      final String userCode = data['user_code'];
      final String deviceCode = data['device_code'];
      final String verificationUri = data['verification_uri'];

      print(verificationUri);
      print(userCode);

      Navigator.pop(context);

      WidgetUtils.showPopup(
        context,
        AppLocalizations.of(context)!.account_add_premium,
        <Widget>[
          Text(
            "${AppLocalizations.of(context)!.account_add_link1}: $verificationUri\n\n${AppLocalizations.of(context)!.account_add_link2} $userCode",
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
              AppLocalizations.of(context)!.account_add_copy,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Comfortaa',
                fontWeight: FontWeight.w300,
              ),
            ),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: userCode));
              if (!await launchUrl(Uri.parse(verificationUri))) {
                throw Exception("${AppLocalizations.of(context)!.account_add_fail}: ${verificationUri}");
              }
            },
          ),
          TextButton(
            child: const Text(
              "OK",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Comfortaa',
                fontWeight: FontWeight.w300,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );

      Timer.periodic(Duration(seconds: 3), (timer) async {
        var data = await getToken(context, 'urn:ietf:params:oauth:grant-type:device_code', null, deviceCode);
        if (data != null) {
          if (!data.toString().startsWith("[MS]:")) {
            var microsoftAccess = data['access_token'];
            var microsoftRefresh = data['refresh_token'];
            var minecraftAuth = await doXboxLiveAuth(context, microsoftAccess);
            if (!minecraftAuth.toString().startsWith("[MC]:")) {
              var minecraftToken = minecraftAuth['access_token'];
              var minecraft = await fetchMinecraftProfile(context, minecraftToken);

              if (!minecraft.toString().startsWith("[MC]:")) {
                // print('ID: ${minecraft['id']}');
                // print('Name: ${minecraft['name']}');
                // print('Skins: ${minecraft['skins']}');
                // print('Capes: ${minecraft['capes']}');
                // print('Profile actions: ${minecraft['profileActions']}');
                bool slim = minecraft['skins'][0]["variant"].toString().toUpperCase().contains("SLIM");
                callback(
                  minecraft['name'], // username
                  minecraft['id'], // uuid
                  minecraftToken, // token (gioco)
                  microsoftRefresh, // token (ms refresh)
                  true, // premium
                  slim, // skin type
                );
                saveAccounts();
                Navigator.pop(context);
              } else {
                WidgetUtils.showMessageDialog(
                  context,
                  AppLocalizations.of(context)!.generic_error_msg,
                  "${minecraft}",
                  () => Navigator.pop(context),
                );
              }
            } else {
              WidgetUtils.showMessageDialog(
                context,
                AppLocalizations.of(context)!.generic_error_msg,
                "${minecraftAuth}",
                () => Navigator.pop(context),
              );
            }
            timer.cancel();
          }
        }
      });
    } else {
      WidgetUtils.showMessageDialog(
        context,
        AppLocalizations.of(context)!.generic_error_msg,
        "$str",
        () => Navigator.pop(context),
      );
    }
  }

  static Account? getAccount() {
    if (Globals.accounts.isEmpty) return null;

    return Globals.accounts.elementAt(Globals.AccountSelected);
  }
}

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
  //////////////////////////////////
  /////////// SETTINGS /////////////
  //////////////////////////////////

  /** Switch impostazioni */
  static Widget buildSettingSwitchItem(String name, String name2, CustomSettingSwitchStyle style, var set, Function(dynamic value) callback) {
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
                        borderRadius: BorderRadius.circular(10),
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
                          style: customTextStyle(16, FontWeight.w500, style.fontColor),
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
                      borderRadius: BorderRadius.circular(10),
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
  static Widget buildSettingTextItem(dynamic child, Color background, Color foreground, String hint, TextEditingController controller, Function(dynamic value) callback) {
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
                        color: ColorUtils.defaultShadowColor, // Choose the color of the shadow
                        blurRadius: 2.0, // Adjust the blur radius for the shadow effect
                        offset: Offset(2.0, 2.0), // Set the horizontal and vertical offset for the shadow
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

  static Widget buildButton(IconData icon, Color color, Color iconColor, VoidCallback onPressed) {
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

  static Widget buildTextButton(Color color, Color textColor, VoidCallback onPressed, String text) {
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

  static void showPopup(dynamic context, String title, List<Widget> content, List<Widget> actions) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(80),
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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

  static void showMessageDialog(dynamic context, String title, String content, VoidCallback callback) {
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
            await Clipboard.setData(ClipboardData(text: Globals.diagnosticcontroller.text));
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

  static TextStyle customTextStyle(double size, FontWeight weight, Color textColor) {
    return TextStyle(
      fontSize: size,
      fontFamily: 'Comfortaa',
      fontWeight: weight,
      color: textColor,
      shadows: [
        Shadow(
          color: ColorUtils.defaultShadowColor, // Choose the color of the shadow
          blurRadius: 15.0, // Adjust the blur radius for the shadow effect
          offset: Offset(2.0, 2.0), // Set the horizontal and vertical offset for the shadow
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

class ThreeDimensionalViewer {
  static late List<Sp3dObj> objs = [];
  static late Sp3dWorld world = Sp3dWorld(objs);
  static late bool isLoaded = false;

  static void setupUV(bool isSlimSkin) {
    int yaw = 0;
    int pitch = 0;

    loadPlayerHead(yaw, pitch);
    loadPlayerChest(yaw, pitch);
    loadPlayerLegs(yaw, pitch);
    loadPlayerArms(yaw, pitch, AccountUtils.getAccount()!.isSlimSkin);
  }

  static void texturizePlayerModel() async {
    final rawSkin = await getImageBytes(AccountUtils._buildSkinModelImageProvider());
    final img.Image? originalSkin = img.decodeImage(rawSkin);

    texturizePlayerHead(originalSkin);
    texturizePlayerChest(originalSkin);
    texturizePlayerLegs(originalSkin);
    texturizePlayerArms(originalSkin, AccountUtils.getAccount()!.isSlimSkin);
    world = Sp3dWorld(objs);
    world.initImages();
  }

  /** Crea la testa */
  static void loadPlayerHead(dynamic yaw, dynamic pitch) {
    Sp3dObj testa = UtilSp3dGeometry.cube(128, 128, 128, 1, 1, 1);
    updateCube(testa, Sp3dV3D(0, 160, -64), yaw, pitch);
    testa.materials.add(Sp3dMaterial(Colors.green, true, 0.0, Colors.green)); // Testa avanti
    testa.materials.add(Sp3dMaterial(Colors.red, true, 0.0, Colors.red)); // Testa dietro
    testa.materials.add(Sp3dMaterial(Colors.blue, true, 0.0, Colors.blue)); // Testa sopra
    testa.materials.add(Sp3dMaterial(Colors.yellow, true, 0.0, Colors.yellow)); // Testa sinistra
    testa.materials.add(Sp3dMaterial(Colors.purple, true, 0.0, Colors.purple)); // Testa sotto
    testa.materials.add(Sp3dMaterial(Colors.teal, true, 0.0, Colors.teal)); // Testa destra
    for (int i = 0; i < 6; i++) testa.fragments[0].faces[i].materialIndex = i + 1;
    testa.materials[0] = FSp3dMaterial.white;
    objs.add(testa);
  }

  static void loadPlayerChest(dynamic yaw, dynamic pitch) {
    Sp3dObj busto = UtilSp3dGeometry.cube(128, 192, 64, 1, 1, 1);
    updateCube(busto, Sp3dV3D(0, 0, -32), yaw, pitch);
    busto.materials.add(Sp3dMaterial(Colors.lightGreen, true, 0.0, Colors.lightGreen)); // Busto avanti
    busto.materials.add(Sp3dMaterial(Colors.redAccent, true, 0.0, Colors.redAccent)); // Busto dietro
    busto.materials.add(Sp3dMaterial(Colors.lightBlue, true, 0.0, Colors.lightBlue)); // Busto sopra
    busto.materials.add(Sp3dMaterial(Colors.yellowAccent, true, 0.0, Colors.yellowAccent)); // Busto sinistra
    busto.materials.add(Sp3dMaterial(Colors.purpleAccent, true, 0.0, Colors.purpleAccent)); // Busto sotto
    busto.materials.add(Sp3dMaterial(Colors.tealAccent, true, 0.0, Colors.tealAccent)); // Busto destra
    for (int i = 0; i < 6; i++) busto.fragments[0].faces[i].materialIndex = i + 1;
    busto.materials[0] = FSp3dMaterial.white;
    objs.add(busto);
  }

  static void loadPlayerLegs(dynamic yaw, dynamic pitch) {
    Sp3dObj leftleg = UtilSp3dGeometry.cube(64, 192, 64, 1, 1, 1);
    updateCube(leftleg, Sp3dV3D(-32, -192, -32), yaw, pitch);
    leftleg.materials.add(Sp3dMaterial(Colors.lightGreenAccent, true, 0.0, Colors.lightGreenAccent)); // leftleg avanti
    leftleg.materials.add(Sp3dMaterial(Color(0xffbe0000), true, 0.0, Color(0xffbe0000))); // leftleg dietro
    leftleg.materials.add(Sp3dMaterial(Color(0xff2f2fff), true, 0.0, Color(0xff2f2fff))); // leftleg sopra
    leftleg.materials.add(Sp3dMaterial(Color(0xffffd300), true, 0.0, Color(0xffffd300))); // leftleg sinistra
    leftleg.materials.add(Sp3dMaterial(Color(0xff931089), true, 0.0, Color(0xff931089))); // leftleg sotto
    leftleg.materials.add(Sp3dMaterial(Color(0xff00ffb2), true, 0.0, Color(0xff00ffb2))); // leftleg destra
    for (int i = 0; i < 6; i++) leftleg.fragments[0].faces[i].materialIndex = i + 1;
    leftleg.materials[0] = FSp3dMaterial.white;
    objs.add(leftleg);

    Sp3dObj rightleg = UtilSp3dGeometry.cube(64, 192, 64, 1, 1, 1);
    updateCube(rightleg, Sp3dV3D(32, -192, -32), yaw, pitch);
    rightleg.materials.add(Sp3dMaterial(Color(0xff06dc4b), true, 0.0, Color(0xff06dc4b))); // rightleg avanti
    rightleg.materials.add(Sp3dMaterial(Color(0xffbd0606), true, 0.0, Color(0xffbd0606))); // rightleg dietro
    rightleg.materials.add(Sp3dMaterial(Color(0xff2929ee), true, 0.0, Color(0xff2929ee))); // rightleg sopra
    rightleg.materials.add(Sp3dMaterial(Color(0xffe8c51c), true, 0.0, Color(0xffe8c51c))); // rightleg sinistra
    rightleg.materials.add(Sp3dMaterial(Color(0xff9b1191), true, 0.0, Color(0xff9b1191))); // rightleg sotto
    rightleg.materials.add(Sp3dMaterial(Color(0xff12d99c), true, 0.0, Color(0xff12d99c))); // rightleg destra
    for (int i = 0; i < 6; i++) rightleg.fragments[0].faces[i].materialIndex = i + 1;
    rightleg.materials[0] = FSp3dMaterial.white;
    objs.add(rightleg);
  }

  static void loadPlayerArms(dynamic yaw, dynamic pitch, bool isSlimSkin) {
    Sp3dObj leftarm = UtilSp3dGeometry.cube(isSlimSkin ? 48 : 64, 192, 64, 1, 1, 1);
    updateCube(leftarm, Sp3dV3D(isSlimSkin ? -88 : -96, 0, -32), yaw, pitch);
    leftarm.materials.add(Sp3dMaterial(Color(0xff36ce14), true, 0.0, Color(0xff36ce14))); // leftarm avanti
    leftarm.materials.add(Sp3dMaterial(Color(0xffd73232), true, 0.0, Color(0xffd73232))); // leftarm dietro
    leftarm.materials.add(Sp3dMaterial(Color(0xff324dd7), true, 0.0, Color(0xff324dd7))); // leftarm sopra
    leftarm.materials.add(Sp3dMaterial(Color(0xffd7c932), true, 0.0, Color(0xffd7c932))); // leftarm sinistra
    leftarm.materials.add(Sp3dMaterial(Color(0xffb332d7), true, 0.0, Color(0xffb332d7))); // leftarm sotto
    leftarm.materials.add(Sp3dMaterial(Color(0xff1fbb7f), true, 0.0, Color(0xff1fbb7f))); // leftarm destra
    for (int i = 0; i < 6; i++) leftarm.fragments[0].faces[i].materialIndex = i + 1;
    leftarm.materials[0] = FSp3dMaterial.white;
    objs.add(leftarm);

    Sp3dObj rightarm = UtilSp3dGeometry.cube(isSlimSkin ? 48 : 64, 192, 64, 1, 1, 1);
    updateCube(rightarm, Sp3dV3D(isSlimSkin ? 88 : 96, 0, -32), yaw, pitch);
    rightarm.materials.add(Sp3dMaterial(Color(0xff35c416), true, 0.0, Color(0xff35c416))); // rightarm avanti
    rightarm.materials.add(Sp3dMaterial(Color(0xffbb2323), true, 0.0, Color(0xffbb2323))); // rightarm dietro
    rightarm.materials.add(Sp3dMaterial(Color(0xff2e47c7), true, 0.0, Color(0xff2e47c7))); // rightarm sopra
    rightarm.materials.add(Sp3dMaterial(Color(0xffc5b82a), true, 0.0, Color(0xffc5b82a))); // rightarm sinistra
    rightarm.materials.add(Sp3dMaterial(Color(0xffa131c0), true, 0.0, Color(0xffa131c0))); // rightarm sotto
    rightarm.materials.add(Sp3dMaterial(Color(0xff159865), true, 0.0, Color(0xff159865))); // leftarm destra
    for (int i = 0; i < 6; i++) rightarm.fragments[0].faces[i].materialIndex = i + 1;
    rightarm.materials[0] = FSp3dMaterial.white;
    objs.add(rightarm);
  }

  /** Texturizza la testa */
  static void texturizePlayerHead(dynamic originalSkin) async {
    objs[0].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin!, x: 8, y: 8, width: 8, height: 8)))); // Testa avanti (faccia)
    objs[0].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 24, y: 8, width: 8, height: 8)))); // Testa dietro (nuca)
    objs[0].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 8, y: 0, width: 8, height: 8)))); // Testa sopra
    objs[0].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 0, y: 8, width: 8, height: 8)))); // Testa sinistra
    objs[0].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 16, y: 0, width: 8, height: 8)))); // Testa sotto
    objs[0].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 16, y: 8, width: 8, height: 8)))); // Testa destra

    for (int i = 0; i < 6; i++) objs[0].materials[i + 1].imageIndex = i;
  }

  /** Texturizza il busto */
  static void texturizePlayerChest(dynamic originalSkin) async {
    objs[1].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 20, y: 20, width: 8, height: 12)))); // Busto avanti
    objs[1].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 32, y: 20, width: 8, height: 12)))); // Busto dietro
    objs[1].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 20, y: 16, width: 8, height: 4)))); // Busto sopra
    objs[1].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 16, y: 20, width: 4, height: 12)))); // Busto sinistra
    objs[1].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 28, y: 16, width: 8, height: 4)))); // Busto sotto
    objs[1].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 28, y: 20, width: 4, height: 12)))); // Busto destra

    for (int i = 0; i < 6; i++) objs[1].materials[i + 1].imageIndex = i;
  }

  /** Texturizza le gambe */
  static void texturizePlayerLegs(dynamic originalSkin) async {
    /** Prepara le texture per la gamba destra (flippato) */
    img.Image RightLegAvanti = img.copyCrop(originalSkin, x: 4, y: 20, width: 4, height: 12);
    img.flipHorizontal(RightLegAvanti);
    img.Image RightLegDietro = img.copyCrop(originalSkin, x: 12, y: 20, width: 4, height: 12);
    img.flipHorizontal(RightLegDietro);
    img.Image RightLegSopra = img.copyCrop(originalSkin, x: 4, y: 16, width: 4, height: 4);
    img.flipHorizontal(RightLegSopra);
    img.Image RightLegSinistra = img.copyCrop(originalSkin, x: 8, y: 20, width: 4, height: 12);
    img.flipHorizontal(RightLegSinistra);
    img.Image RightLegSotto = img.copyCrop(originalSkin, x: 8, y: 16, width: 4, height: 4);
    img.flipHorizontal(RightLegSotto);
    img.Image RightLegDestra = img.copyCrop(originalSkin, x: 0, y: 20, width: 4, height: 12);
    img.flipHorizontal(RightLegDestra);

    /** Texturizza la gamba sinistra (terza persona) */
    objs[2].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 4, y: 20, width: 4, height: 12)))); // LeftLeg avanti
    objs[2].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 12, y: 20, width: 4, height: 12)))); // LeftLeg dietro
    objs[2].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 4, y: 16, width: 4, height: 4)))); // LeftLeg sopra
    objs[2].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 0, y: 20, width: 4, height: 12)))); // LeftLeg sinistra
    objs[2].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 8, y: 16, width: 4, height: 4)))); // LeftLeg sotto
    objs[2].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 8, y: 20, width: 4, height: 12)))); // LeftLeg destra
    /** Texturizza la gamba destra (terza persona) */
    objs[3].images.add(Uint8List.fromList(img.encodePng(RightLegAvanti))); // RightLeg avanti
    objs[3].images.add(Uint8List.fromList(img.encodePng(RightLegDietro))); // RightLeg dietro
    objs[3].images.add(Uint8List.fromList(img.encodePng(RightLegSopra))); // RightLeg sopra
    objs[3].images.add(Uint8List.fromList(img.encodePng(RightLegSinistra))); // RightLeg sinistra
    objs[3].images.add(Uint8List.fromList(img.encodePng(RightLegSotto))); // RightLeg sotto
    objs[3].images.add(Uint8List.fromList(img.encodePng(RightLegDestra))); // RightLeg destra

    for (int i = 0; i < 6; i++) objs[2].materials[i + 1].imageIndex = i;
    for (int i = 0; i < 6; i++) objs[3].materials[i + 1].imageIndex = i;
  }

  /** Texturizza le braccia */
  static void texturizePlayerArms(dynamic originalSkin, bool isSlimSkin) async {
    /** Prepara le texture per il braccio destro (flippato) */
    img.Image RightArmAvanti = img.copyCrop(originalSkin, x: 44, y: 20, width: isSlimSkin ? 3 : 4, height: 12);
    img.flipHorizontal(RightArmAvanti);
    img.Image RightArmDietro = img.copyCrop(originalSkin, x: 52, y: 20, width: isSlimSkin ? 3 : 4, height: 12);
    img.flipHorizontal(RightArmDietro);
    img.Image RightArmSopra = img.copyCrop(originalSkin, x: 44, y: 16, width: isSlimSkin ? 3 : 4, height: 4);
    img.flipHorizontal(RightArmSopra);
    img.Image RightArmSinistra = img.copyCrop(originalSkin, x: 48, y: 20, width: 4, height: 12);
    img.flipHorizontal(RightArmSinistra);
    img.Image RightArmSotto = img.copyCrop(originalSkin, x: 48, y: 16, width: isSlimSkin ? 3 : 4, height: 4);
    img.flipHorizontal(RightArmSotto);
    img.Image RightArmDestra = img.copyCrop(originalSkin, x: 40, y: 20, width: 4, height: 12);
    img.flipHorizontal(RightArmDestra);

    /** Texturizza il braccio sinistro (terza persona) */
    objs[4].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 44, y: 20, width: isSlimSkin ? 3 : 4, height: 12)))); // LeftArm avanti
    objs[4].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 52, y: 20, width: isSlimSkin ? 3 : 4, height: 12)))); // LeftArm dietro
    objs[4].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 44, y: 16, width: isSlimSkin ? 3 : 4, height: 4)))); // LeftArm sopra
    objs[4].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 40, y: 20, width: 4, height: 12)))); // LeftArm sinistra
    objs[4].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 48, y: 16, width: isSlimSkin ? 3 : 4, height: 4)))); // LeftArm sotto
    objs[4].images.add(Uint8List.fromList(img.encodePng(img.copyCrop(originalSkin, x: 48, y: 20, width: 4, height: 12)))); // LeftArm destra
    /** Texturizza il braccio destro (terza persona) */
    objs[5].images.add(Uint8List.fromList(img.encodePng(RightArmAvanti))); // RightArm avanti
    objs[5].images.add(Uint8List.fromList(img.encodePng(RightArmDietro))); // RightArm dietro
    objs[5].images.add(Uint8List.fromList(img.encodePng(RightArmSopra))); // RightArm sopra
    objs[5].images.add(Uint8List.fromList(img.encodePng(RightArmSinistra))); // RightArm sinistra
    objs[5].images.add(Uint8List.fromList(img.encodePng(RightArmSotto))); // RightArm sotto
    objs[5].images.add(Uint8List.fromList(img.encodePng(RightArmDestra))); // RightArm destra

    for (int i = 0; i < 6; i++) objs[4].materials[i + 1].imageIndex = i;
    for (int i = 0; i < 6; i++) objs[5].materials[i + 1].imageIndex = i;
  }

  static void updateCube(Sp3dObj obj, Sp3dV3D position, int yaw, int pitch) {
    obj.move(position);
    obj.rotateBy(Sp3dV3D(0, 0, 0), Sp3dV3D(0, 1, 0).nor(), yaw * Sp3dConstantValues.toRadian);
    obj.rotateBy(Sp3dV3D(0, 0, 0), Sp3dV3D(1, 0, 0).nor(), pitch * Sp3dConstantValues.toRadian);
  }

  static Future<Uint8List> getImageBytes(ImageProvider imageProvider) async {
    final completer = Completer<Uint8List>();
    final imageStream = imageProvider.resolve(ImageConfiguration.empty);

    imageStream.addListener(ImageStreamListener((info, _) async {
      final byteData = await info.image.toByteData(format: ImageByteFormat.png);
      if (byteData != null) {
        final uint8List = byteData.buffer.asUint8List();
        completer.complete(uint8List);
      }
    }));

    return completer.future;
  }
}

class CirclePainter extends CustomPainter {
  final Color color;
  final double radius;
  final Color outlineColor;
  final double outlineWidth;
  final double distance;

  CirclePainter({
    required this.color,
    required this.radius,
    this.outlineColor = Colors.transparent,
    this.outlineWidth = 0,
    this.distance = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    size = Size(radius, radius);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Disegna il cerchio interno
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);

    if (outlineWidth > 0) {
      final outlinePaint = Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth;

      // Calcola il raggio del cerchio esterno tenendo conto della distanza
      double outerRadius = size.width / 2 + distance + outlineWidth / 2;

      // Disegna il cerchio esterno
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), outerRadius, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ColoredCircle extends StatelessWidget {
  final double size;
  final Color color;
  final Color outlineColor;
  final double outlineWidth;
  final double distance;

  ColoredCircle({
    required this.size,
    required this.color,
    this.outlineColor = Colors.transparent,
    this.outlineWidth = 0,
    this.distance = 0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size + 2 * (distance + outlineWidth), size + 2 * (distance + outlineWidth)),
      painter: CirclePainter(
        color: color,
        radius: size,
        outlineColor: outlineColor,
        outlineWidth: outlineWidth,
        distance: distance,
      ),
    );
  }
}
