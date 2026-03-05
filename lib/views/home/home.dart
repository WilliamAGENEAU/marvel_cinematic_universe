import 'package:flutter/material.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:marvel_cinematic_universe/helpers/static-data.dart';
import 'package:marvel_cinematic_universe/viewmodels/home_viewmodel.dart';
import 'package:marvel_cinematic_universe/views/aside.dart';
import 'package:marvel_cinematic_universe/views/home/timeline.dart';
import 'package:marvel_cinematic_universe/widgets/movie_details.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeViewModel vm = HomeViewModel();
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();
  Color menuIconColor = Colors.white;
  late YoutubePlayerController _ytbPlayerController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        if (vm.isLoading) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.red)),
          );
        }

        final movie = vm.activeMovie;
        if (movie == null) return const SizedBox.shrink();

        return SideMenu(
          key: _sideMenuKey,
          background: DefaultColors.dark,
          type: SideMenuType.shrinkNSlide,
          menu: ASide(
            context,
            onStopAudio: () => vm.playMusic(null),
            universe: vm.universe,
          ),
          child: Scaffold(
            body: Stack(
              children: [
                _buildBackground(movie["thumbnail_url"]),
                SafeArea(
                  child: Column(
                    children: [
                      _buildAppBar(vm.watchProgress),
                      MovieDetails(
                        movie: movie,
                        isAudioPaused: vm.isPaused,
                        onPlayVideo: () =>
                            _showVideoDialog(movie['youtube_id']),
                        onToggleAudio: vm.togglePlayPause,
                        onShowSpoil: () => _showSpoilDialog(movie['spoil']),
                      ),
                      const Spacer(),
                      TimelineSection(
                        universe: vm.universe,
                        activeId: movie["id"],
                        seenIds: vm.seenIds,
                        onTapMovie: (m) => vm.updateActiveMovie(m),
                        onToggleSeen: vm.toggleSeen,
                        isHorizontal: true,
                        phaseColorFor: _phaseColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackground(String? imageUrl) {
    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Container(
          key: ValueKey(imageUrl),
          decoration: BoxDecoration(
            image: (imageUrl != null && imageUrl.isNotEmpty)
                ? DecorationImage(
                    image: CachedNetworkImageProvider(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            color: Colors.black,
          ),
          foregroundDecoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black45, Colors.black45, Colors.black87],
            ),
          ),
        ),
      ),
    );
  }

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

  void _showSpoilDialog(String? spoilText) {
    if (spoilText == null || spoilText.toString().isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
              SizedBox(width: 8),
              Text("Spoiler", style: TextStyle(color: Colors.white)),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              spoilText,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Fermer",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showVideoDialog(String? youtubeId) async {
    if (youtubeId == null || youtubeId.isEmpty) return;
    setState(() {
      _ytbPlayerController = YoutubePlayerController(
        initialVideoId: youtubeId,
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

  Widget _buildAppBar(double watchProgress) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(MfgLabs.menu, color: menuIconColor),
        onPressed: () => toggleMenu(),
      ),
      title: Container(
        padding: const EdgeInsets.only(left: 4),
        alignment: Alignment.center,
        child: Image.asset(ImgPaths.logo_marvel_universe, width: 120),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              "${watchProgress.toStringAsFixed(0)}% vues",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void toggleMenu() {
    final state = _sideMenuKey.currentState!;
    if (state.isOpened) {
      state.closeSideMenu();
    } else {
      state.openSideMenu();
    }
  }
}
