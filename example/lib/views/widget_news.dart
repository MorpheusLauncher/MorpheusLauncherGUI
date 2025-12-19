import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:morpheus_launcher_gui/globals.dart';
import 'package:morpheus_launcher_gui/main.dart';

class NewsScreen extends StatelessWidget {
  final String title;
  final String body;
  final String url;

  NewsScreen({required this.title, required this.body, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width / 5) - 5,
      child: Material(
        elevation: 15,
        color: ColorUtils.dynamicWindowBackgroundColor,
        shadowColor: Colors.black.withAlpha(60),
        child: Column(
          children: [
            drawTitleCustomBar(),

            /** Roba della miniatura e titolo */
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
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
                    colorOpacity: 0.3,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 20,
                      fontFamily: 'Comfortaa',
                      color: Colors.white.withAlpha(160),
                    ),
                  ),
                ],
              ),
            ),

            /** Mostra il contenuto */
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: true,
                ),
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Html(
                        style: {
                          "*": Style(
                            color: Globals.darkModeTheme ? Colors.white.withAlpha(160) : Colors.black.withAlpha(200),
                            fontFamily: 'Comfortaa',
                          ),
                          "h1": Style(
                            color: Globals.darkModeTheme ? Colors.white.withAlpha(200) : Colors.black,
                          ),
                          "h2": Style(
                            color: Globals.darkModeTheme ? Colors.white.withAlpha(200) : Colors.black,
                          ),
                          "h3": Style(
                            color: Globals.darkModeTheme ? Colors.white.withAlpha(200) : Colors.black,
                          ),
                          "code": Style(
                            color: ColorUtils.dynamicAccentColor.withAlpha(255),
                          ),
                          "a": Style(
                            color: ColorUtils.dynamicAccentColor.withAlpha(255),
                          ),
                        },
                        data: body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
