// ignore_for_file: depend_on_referenced_packages, prefer_interpolation_to_compose_strings, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marvel_cinematic_universe/controller/universeController.dart';
import 'package:marvel_cinematic_universe/helpers/static-data.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../shared/aside.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late YoutubePlayerController _ytbPlayerController;
  List<Map<String, dynamic>> universe = [];
  Map<String, dynamic>? activeUniverse;
  Color menuIconColor = Colors.white;

  double l = 0, r = 0, t = 0, b = 0;
  var c = CrossAxisAlignment.start;
  var m = MainAxisAlignment.start;

  bool isOpened = false;
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateTitlePlacement();
    _updateMenuIconColor(); // Ajouté ici
  }

  Future<void> _initData() async {
    // Liste locale
    universe = universeMock;

    if (universe.isNotEmpty) {
      setState(() {
        activeUniverse = universe.first;
      });

      _ytbPlayerController = YoutubePlayerController(
        initialVideoId: activeUniverse!['YoutubeId'],
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
  }

  Future<void> _updateMenuIconColor() async {
    if (activeUniverse == null) return;

    final imageProvider = AssetImage(
      "assets/images/poster/" + activeUniverse!["Thumbnail"],
    );

    final paletteGenerator = await PaletteGenerator.fromImageProvider(
      imageProvider,
      size: const Size(200, 100), // taille réduite pour performance
    );

    // Couleur dominante
    final dominantColor = paletteGenerator.dominantColor?.color ?? Colors.black;

    // On calcule la luminosité (0 = sombre, 1 = clair)
    final brightness = dominantColor.computeLuminance();

    setState(() {
      menuIconColor = brightness < 0.5 ? Colors.white : Colors.black;
    });
  }

  void toggleMenu() {
    final state = _sideMenuKey.currentState!;
    if (state.isOpened) {
      state.closeSideMenu();
    } else {
      state.openSideMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (activeUniverse == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return SideMenu(
      key: _sideMenuKey,
      menu: ASide("", context),
      background: DefaultColors.dark,
      type: SideMenuType.shrinkNSlide,
      onChange: (opened) {
        setState(() => isOpened = opened);
      },
      child: IgnorePointer(
        ignoring: isOpened,
        child: Scaffold(
          body: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/images/poster/" + activeUniverse!["Thumbnail"],
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: Icon(MfgLabs.menu, color: menuIconColor),
                      onPressed: () => toggleMenu(),
                    ),
                    title: Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        ImgPaths.logo_marvel_universe,
                        width: 120,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.topRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            activeUniverse!["MoviewName"],
                            style: GoogleFonts.anton(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activeUniverse!["RunTime"],
                            style: GoogleFonts.openSans(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            activeUniverse!["ReleaseDate"], // ⚡️ nouvelle ligne
                            style: GoogleFonts.openSans(
                              fontSize: 15,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(color: Colors.white, width: 45, height: 4),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: const EdgeInsets.only(left: 2),
                                child: IconButton(
                                  onPressed: showVideo,
                                  icon: const Icon(
                                    FontAwesome5.play,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Bande-annonce", // ⚡️ nouveau texte
                                style: GoogleFonts.openSans(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 46),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(
                                    left: Pad.md,
                                    bottom: Pad.sm,
                                  ),
                                  child: Text(
                                    "Marvel Cinematic Universe Ordre",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 130,
                                  child: ListView.builder(
                                    itemCount: universe.length,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (BuildContext context, int i) {
                                      final index = universe.indexWhere(
                                        (element) =>
                                            element["id"] ==
                                            activeUniverse!["id"],
                                      );

                                      return TimelineTile(
                                        axis: TimelineAxis.horizontal,
                                        alignment: TimelineAlign.manual,
                                        lineXY: 0.9,
                                        startChild: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              activeUniverse = universe[i];
                                            });
                                            updateTitlePlacement();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                              bottom: Pad.sm,
                                            ),
                                            child: Image.asset(
                                              'assets/images/thumbnail/' +
                                                  universe[i]["Thumbnail"],
                                            ),
                                          ),
                                        ),
                                        indicatorStyle: IndicatorStyle(
                                          width: 14,
                                          height: 14,
                                          color: DefaultColors.baby_white
                                              .withOpacity(0.9),
                                        ),
                                        beforeLineStyle: LineStyle(
                                          color: index >= i
                                              ? DefaultColors.primary
                                              : DefaultColors.baby_white
                                                    .withOpacity(0.8),
                                          thickness: 1,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }

  void updateTitlePlacement() {
    if (activeUniverse == null) return;

    var size = MediaQuery.of(context).size;

    setState(() {
      switch (activeUniverse!["DataPlacement"]) {
        case 'top-left':
          l = size.width * 0.3;
          r = Pad.md;
          t = 24;
          b = 0;
          c = CrossAxisAlignment.end;
          m = MainAxisAlignment.start;
          break;
        default: // top-right
          l = size.width * 0.3;
          r = Pad.md;
          t = 24;
          b = 0;
          c = CrossAxisAlignment.end;
          m = MainAxisAlignment.start;
          break;
      }
    });
  }

  showVideo() async {
    setState(() {
      _ytbPlayerController = YoutubePlayerController(
        initialVideoId: activeUniverse!['YoutubeId'],
        flags: const YoutubePlayerFlags(autoPlay: true),
      );
    });

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(4),
          content: AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(
              controller: _ytbPlayerController,
              showVideoProgressIndicator: true,
              liveUIColor: DefaultColors.primary,
            ),
          ),
        );
      },
    );
  }
}
