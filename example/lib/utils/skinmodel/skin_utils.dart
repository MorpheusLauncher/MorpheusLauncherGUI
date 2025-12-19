import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:morpheus_launcher_gui/globals.dart';
import 'package:morpheus_launcher_gui/utils/skinmodel/skin_viewer.dart';

class SkinUtils {

  static Future<Uint8List> loadCroppedSkin() async {
    final rawSkin = await ThreeDimensionalViewer.getImageBytes(
      buildSkinModelImageProvider(),
    );
    final img.Image? original = img.decodeImage(rawSkin);
    if (original == null) return rawSkin;
    final cropped = img.copyCrop(original, x: 8, y: 8, width: 8, height: 8);

    return Uint8List.fromList(img.encodePng(cropped));
  }

  static ImageProvider buildSkinModelImageProvider() {
    final account = Globals.getAccount();
    if (account == null) {
      return const AssetImage("assets/alex-raw.png");
    }

    final offlineSkin = AssetImage(
      account.isSlimSkin ? "assets/alex-raw.png" : "assets/steve-raw.png",
    );

    String? imageUrl;

    if (account.isPremium) {
      imageUrl = "${Urls.skinURL}/raw/${account.uuid}";
    } else if (account.isElyBy) {
      imageUrl = "${Urls.elybySkinsURL}/skins/${account.username}";
    }

    if (imageUrl != null) {
      try {
        return CachedNetworkImageProvider(imageUrl);
      } catch (_) {
        return offlineSkin;
      }
    }

    return offlineSkin;
  }
}
