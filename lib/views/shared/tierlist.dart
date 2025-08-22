// tierlist.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TierListTable extends StatefulWidget {
  final List<Map<String, dynamic>> seenMovies; // films cochés

  const TierListTable({super.key, required this.seenMovies});

  @override
  State<TierListTable> createState() => _TierListTableState();
}

class _TierListTableState extends State<TierListTable> {
  final Map<String, List<Map<String, dynamic>>> tiers = {
    "S": [],
    "A": [],
    "B": [],
    "C": [],
    "D": [],
    "Non classé": [], // ✅ nouveau rang
  };

  @override
  void initState() {
    super.initState();
    _loadRanks();
  }

  Future<void> _loadRanks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList("tierlist_ranks") ?? [];

    // mapping id -> rank
    final savedRanks = <int, String>{};
    for (final entry in saved) {
      final parts = entry.split(":");
      if (parts.length == 2) {
        savedRanks[int.parse(parts[0])] = parts[1];
      }
    }

    // Placer les films selon sauvegarde
    for (var movie in widget.seenMovies) {
      final id = movie["id"] as int;
      final rank = savedRanks[id] ?? "Non classé";
      tiers[rank]!.add(movie);
    }

    setState(() {});
  }

  Future<void> _saveRanks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = <String>[];
    for (final entry in tiers.entries) {
      for (final movie in entry.value) {
        list.add("${movie["id"]}:${entry.key}");
      }
    }
    await prefs.setStringList("tierlist_ranks", list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: tiers.keys.map((rank) {
          return Expanded(
            child: DragTarget<Map<String, dynamic>>(
              onAccept: (movie) {
                setState(() {
                  // supprimer d'où il était avant
                  tiers.forEach((key, value) => value.remove(movie));
                  // ajouter dans le bon rang
                  tiers[rank]!.add(movie);
                });
                _saveRanks(); // ✅ sauvegarde
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _colorForRank(rank), width: 3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rang $rank",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _colorForRank(rank),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: tiers[rank]!
                              .map(
                                (movie) =>
                                    LongPressDraggable<Map<String, dynamic>>(
                                      data: movie,
                                      feedback: Opacity(
                                        opacity: 0.8,
                                        child: _buildMovieCard(movie),
                                      ),
                                      childWhenDragging: Opacity(
                                        opacity: 0.3,
                                        child: _buildMovieCard(movie),
                                      ),
                                      child: _buildMovieCard(movie),
                                    ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 160, // hauteur fixe (ou variable selon besoin)
      child: AspectRatio(
        aspectRatio: 9 / 16, // portrait
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/thumbnail/${movie["Thumbnail"]}',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Color _colorForRank(String rank) {
    switch (rank) {
      case "S":
        return Colors.purpleAccent;
      case "A":
        return Colors.greenAccent;
      case "B":
        return Colors.blueAccent;
      case "C":
        return Colors.orangeAccent;
      case "D":
        return Colors.redAccent;
      case "Non classé":
        return Colors.white;
      default:
        return Colors.grey;
    }
  }
}
