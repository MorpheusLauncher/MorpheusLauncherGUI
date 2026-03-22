import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:morpheus_launcher_gui/globals.dart';
import 'package:morpheus_launcher_gui/utils/widget_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:morpheus_launcher_gui/views/modpack_detail_view.dart';

class ModrinthView extends StatefulWidget {
  const ModrinthView({Key? key}) : super(key: key);

  @override
  State<ModrinthView> createState() => _ModrinthViewState();
}

class _ModrinthViewState extends State<ModrinthView> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _modpacks = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
    _searchModpacks("");
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchModpacks(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("${Urls.modrinthApiURL}/search?query=$query&facets=[[\"project_type:modpack\"]]&limit=200"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _modpacks = data["hits"];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchModpacks(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtils.dynamicWindowBackgroundColor,
      body: Column(
        children: [
          drawTitleCustomBar(),
          _buildTopBar(context),
          _buildSearchBar(context),
          Expanded(
            child: _isLoading ? Center(child: Image.asset('assets/morpheus-animated.gif', width: 64)) : _buildModpackList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: ColorUtils.primaryFontColor),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.modded_modrinth_title,
            style: WidgetUtils.customTextStyle(24, FontWeight.w600, ColorUtils.primaryFontColor),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        elevation: 0,
        color: ColorUtils.dynamicPrimaryForegroundColor,
        borderRadius: BorderRadius.circular(Globals.borderRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            style: WidgetUtils.customTextStyle(16, FontWeight.w400, ColorUtils.primaryFontColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: AppLocalizations.of(context)!.modded_modrinth_search,
              hintStyle: WidgetUtils.customTextStyle(16, FontWeight.w300, ColorUtils.secondaryFontColor),
              icon: Icon(Icons.search, color: ColorUtils.secondaryFontColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _searchModpacks("");
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModpackList() {
    if (_modpacks.isEmpty && !_isLoading) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.modded_modrinth_empty,
          style: WidgetUtils.customTextStyle(16, FontWeight.w300, ColorUtils.secondaryFontColor),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _modpacks.length,
      itemBuilder: (context, index) {
        final modpack = _modpacks[index];
        return _buildModpackItem(modpack);
      },
    );
  }

  Widget _buildModpackItem(dynamic modpack) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        elevation: 0,
        color: ColorUtils.dynamicPrimaryForegroundColor,
        shadowColor: ColorUtils.defaultShadowColor,
        borderRadius: BorderRadius.circular(Globals.borderRadius),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ModpackDetailView(modpack: modpack)),
            );
          },
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Globals.borderRadius - 4),
                  child: CachedNetworkImage(
                    imageUrl: modpack["icon_url"] ?? "",
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.white.withOpacity(0.05)),
                    errorWidget: (context, url, error) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.white.withOpacity(0.05),
                      child: Icon(Icons.apps, color: ColorUtils.secondaryFontColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Replace the Expanded Column in _buildModpackItem with this:
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        modpack["title"] ?? "",
                        style: WidgetUtils.customTextStyle(17, FontWeight.w600, ColorUtils.primaryFontColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2), // was 4
                      Flexible(
                        // <-- wrap description in Flexible
                        child: Text(
                          modpack["description"] ?? "",
                          style: WidgetUtils.customTextStyle(13, FontWeight.w300, ColorUtils.secondaryFontColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4), // was 10
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildMetaData(Icons.download, _formatNumber(modpack["downloads"]), Colors.grey),
                              const SizedBox(width: 12),
                              _buildMetaData(Icons.code, modpack["latest_version"] ?? "N/A", ColorUtils.dynamicAccentColor),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaData(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: WidgetUtils.customTextStyle(12, FontWeight.w400, color),
        ),
      ],
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return "0";
    if (number is int) {
      if (number >= 1000000) return "${(number / 1000000).toStringAsFixed(1)}M";
      if (number >= 1000) return "${(number / 1000).toStringAsFixed(1)}K";
      return number.toString();
    }
    return number.toString();
  }
}
