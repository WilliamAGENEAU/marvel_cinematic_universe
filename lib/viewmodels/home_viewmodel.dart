import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:marvel_cinematic_universe/controller/universeController.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Map<String, dynamic>> universe = universeMock;
  Map<String, dynamic>? activeMovie;
  Set<int> seenIds = {};
  bool isPaused = false;

  HomeViewModel() {
    activeMovie = universe.isNotEmpty ? universe.first : null;
    _loadSeen();
  }

  // --- Gestion du "Vu" ---
  Future<void> _loadSeen() async {
    final prefs = await SharedPreferences.getInstance();
    seenIds = (prefs.getStringList('seen_ids') ?? []).map(int.parse).toSet();
    notifyListeners();
  }

  void toggleSeen(int id) async {
    seenIds.contains(id) ? seenIds.remove(id) : seenIds.add(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'seen_ids',
      seenIds.map((e) => e.toString()).toList(),
    );
    notifyListeners();
  }

  double get watchProgress =>
      universe.isEmpty ? 0 : (seenIds.length / universe.length) * 100;

  // --- Gestion Audio ---
  Future<void> playMusic(String? fileName) async {
    if (fileName == null || fileName.isEmpty) {
      await _audioPlayer.stop();
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource("musics/$fileName"));
    }
    isPaused = false;
    notifyListeners();
  }

  void togglePlayPause() {
    isPaused ? _audioPlayer.resume() : _audioPlayer.pause();
    isPaused = !isPaused;
    notifyListeners();
  }

  void updateActiveMovie(Map<String, dynamic> movie) {
    activeMovie = movie;
    playMusic(movie["music"]);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
