// ignore_for_file: depend_on_referenced_packages, prefer_interpolation_to_compose_strings, deprecated_member_use

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marvel_cinematic_universe/controller/universeController.dart';
import 'package:marvel_cinematic_universe/helpers/static-data.dart';
import 'package:marvel_cinematic_universe/views/home/timeline.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../shared/aside.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Video & Audio
  late YoutubePlayerController _ytbPlayerController;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isPaused = false;

  // Data
  List<Map<String, dynamic>> universe = [];
  Map<String, dynamic>? activeUniverse;

  // UI states
  Color menuIconColor = Colors.white;
  bool isOpened = false;
  final bool _isHorizontal = true; // Toggle direction
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();

  // Persist "seen"
  Set<int> _seenIds = {};

  ImageProvider? _posterProvider; // current
  ImageProvider? _nextPosterProvider; // preloaded

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✅ on s'abonne aux événements
    _audioPlayer = AudioPlayer();
    _initData();
    _loadSeen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Après que le context est prêt, on peut précacher l’image actuelle
    if (activeUniverse != null) {
      _precachePoster(activeUniverse!["Thumbnail"]);
      _updateMenuIconColor();
    }
  }

  Future<void> _initData() async {
    universe = universeMock;

    if (universe.isNotEmpty) {
      activeUniverse = universe.first;
      _posterProvider = AssetImage(
        "assets/images/poster/${activeUniverse!["Thumbnail"]}",
      );
      _playMusic(activeUniverse!["music"]); // joue la musique du 1er film

      _ytbPlayerController = YoutubePlayerController(
        initialVideoId: activeUniverse!['YoutubeId'],
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
      setState(() {});
    }
  }

  Future<void> _loadSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('seen_ids') ?? [];
    setState(() {
      _seenIds = list.map(int.parse).toSet();
    });
  }

  Future<void> _saveSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'seen_ids',
      _seenIds.map((e) => e.toString()).toList(),
    );
  }

  void _toggleSeen(int id) {
    setState(() {
      if (_seenIds.contains(id)) {
        _seenIds.remove(id);
      } else {
        _seenIds.add(id);
      }
    });
    _saveSeen();
  }

  // ========= Audio =========
  Future<void> _playMusic(String fileName) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource("musics/$fileName"));
    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying && !_isPaused) {
      await _audioPlayer.pause();
      setState(() => _isPaused = true);
    } else if (_isPlaying && _isPaused) {
      await _audioPlayer.resume();
      setState(() => _isPaused = false);
    }
  }

  // ========= Menu Contrast =========
  Future<void> _updateMenuIconColor() async {
    if (activeUniverse == null) return;

    final imageProvider = AssetImage(
      "assets/images/poster/${activeUniverse!["Thumbnail"]}",
    );
    final palette = await PaletteGenerator.fromImageProvider(
      imageProvider,
      size: const Size(200, 100),
    );
    final dominantColor = palette.dominantColor?.color ?? Colors.black;
    final brightness = dominantColor.computeLuminance();
    if (mounted) {
      setState(() {
        menuIconColor = brightness < 0.5 ? Colors.white : Colors.black;
      });
    }
  }

  // ========= Poster Precache & Swap =========
  Future<void> _precachePoster(String thumbnail) async {
    final provider = AssetImage("assets/images/poster/$thumbnail");
    await precacheImage(provider, context);
    _nextPosterProvider = provider;

    // swap sans flash via AnimatedSwitcher + FadeIn/Gapless
    if (mounted) {
      setState(() {
        _posterProvider = _nextPosterProvider;
        _nextPosterProvider = null;
      });
    }
  }

  // ========= Timeline helpers =========
  Color _phaseColor(String? phase) {
    switch (phase) {
      case "Phase 1":
        return Colors.red;
      case "Phase 2":
        return Colors.blue;
      case "Phase 3":
        return Colors.green;
      case "Phase 4":
        return Colors.yellow;
      case "Phase 5":
        return Colors.orange;
      case "Phase 6":
        return Colors.purple;
      default:
        return DefaultColors.primary;
    }
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ✅ on se désabonne
    _ytbPlayerController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ✅ écoute les changements de cycle de vie
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // quand on verrouille ou quitte l’app → stop musique
      _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
        _isPaused = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (activeUniverse == null || _posterProvider == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bg = _posterProvider!;

    return SideMenu(
      key: _sideMenuKey,
      background: DefaultColors.dark,
      type: SideMenuType.shrinkNSlide,
      menu: ASide(
        "",
        context,
        onStopAudio: () async => _audioPlayer.stop(), // ✅ stoppe la musique
        closeMenu: () =>
            _sideMenuKey.currentState?.closeSideMenu(), // ✅ ferme le menu
      ),
      child: IgnorePointer(
        ignoring: isOpened,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                // Background poster + subtle gradient overlay
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: Container(
                      key: ValueKey(bg),
                      decoration: BoxDecoration(
                        image: DecorationImage(image: bg, fit: BoxFit.cover),
                      ),
                      foregroundDecoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black54,
                            Colors.black54,
                            Colors.black87,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                Column(
                  children: [
                    // Top AppBar
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: Icon(MfgLabs.menu, color: menuIconColor),
                        onPressed: () => toggleMenu(),
                      ),
                      title: Container(
                        padding: const EdgeInsets.only(left: 4),
                        alignment: Alignment.center,
                        child: Image.asset(
                          ImgPaths.logo_marvel_universe,
                          width: 120,
                        ),
                      ),
                    ),

                    // Info top-right
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.topRight,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              Text(
                                activeUniverse!["MoviewName"],
                                textAlign: TextAlign.right,
                                style: GoogleFonts.anton(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Release date & runtime (plus grands)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    activeUniverse!["ReleaseDate"],
                                    style: GoogleFonts.openSans(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "•",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    activeUniverse!["RunTime"],
                                    style: GoogleFonts.openSans(
                                      fontSize: 17,
                                      color: Colors.white70,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Divider deco
                              Container(
                                color: Colors.white,
                                width: 48,
                                height: 4,
                              ),
                              const SizedBox(height: 14),

                              // Actions : Play trailer + Bande-annonce + Audio toggle
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Trailer button (rounded)
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white70),
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.white.withOpacity(0.08),
                                    ),
                                    child: IconButton(
                                      onPressed: showVideo,
                                      icon: const Icon(
                                        FontAwesome5.play,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Bande-annonce",
                                    style: GoogleFonts.openSans(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Pause/Resume Audio
                                  IconButton(
                                    tooltip: _isPaused
                                        ? 'Reprendre le son'
                                        : 'Mettre en pause',
                                    onPressed: _togglePlayPause,
                                    icon: Icon(
                                      _isPaused
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Timeline area
                    TimelineSection(
                      universe: universe,
                      activeId: activeUniverse!["id"] as int,
                      isHorizontal: _isHorizontal,
                      seenIds: _seenIds,
                      phaseColorFor: _phaseColor,
                      onTapMovie: (movie) async {
                        // Preload, then swap & play music
                        await _precachePoster(movie["Thumbnail"]);
                        setState(() => activeUniverse = movie);
                        _updateMenuIconColor();
                        _playMusic(activeUniverse!["music"]);
                      },
                      onToggleSeen: _toggleSeen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // (L’ancienne updateTitlePlacement n’est plus nécessaire car l’UI est fixe en haut-droite)

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
          backgroundColor: Colors.black,
          contentPadding: const EdgeInsets.all(4),
          content: AspectRatio(
            aspectRatio: 16 / 9,
            child: YoutubePlayer(
              controller: _ytbPlayerController,
              showVideoProgressIndicator: true,
              liveUIColor: DefaultColors.primary,
              progressIndicatorColor: DefaultColors.primary,
            ),
          ),
        );
      },
    );
  }
}
