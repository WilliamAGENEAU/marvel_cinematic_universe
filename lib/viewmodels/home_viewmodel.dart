import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeViewModel extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Map<String, dynamic>> universe = [];
  Map<String, dynamic>? activeMovie;
  Set<int> seenIds = {};
  bool isPaused = false;
  bool isLoading = true;

  HomeViewModel() {
    _init();
  }

  Future<void> _init() async {
    await fetchUniverse();
    await _loadSeen();
    isLoading = false;
    notifyListeners();
  }

  // --- Chargement Supabase ---
  Future<void> fetchUniverse() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('universe')
          .select()
          .order('id', ascending: true);

      universe = List<Map<String, dynamic>>.from(response);
      if (universe.isNotEmpty) {
        activeMovie = universe.first;
      }
    } catch (e) {
      debugPrint("Erreur Supabase: $e");
    }
  }

  Future<void> playMusic(String? url) async {
    if (url == null || url.isEmpty) {
      await _audioPlayer.stop();
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
    }
    isPaused = false;
    notifyListeners();
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

  void updateActiveMovie(Map<String, dynamic> movie) {
    activeMovie = movie;
    playMusic(movie["music_url"]);
    notifyListeners();
  }

  void togglePlayPause() {
    isPaused ? _audioPlayer.resume() : _audioPlayer.pause();
    isPaused = !isPaused;
    notifyListeners();
  }
}
