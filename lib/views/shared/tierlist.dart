// tierlist.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TierListTable extends StatefulWidget {
  final List<Map<String, dynamic>> seenMovies;

  const TierListTable({super.key, required this.seenMovies});

  @override
  State<TierListTable> createState() => _TierListTableState();
}

class _TierListTableState extends State<TierListTable> {
  final List<String> scores = [
    "10",
    "9.5",
    "9",
    "8.5",
    "8",
    "7.5",
    "7",
    "6.5",
    "6",
    "5.5",
    "5",
    "4.5",
    "4",
    "Non classé",
  ];

  late Map<String, List<Map<String, dynamic>>> tiers;

  @override
  void initState() {
    super.initState();
    tiers = {for (var score in scores) score: []};
    _loadRanks();
  }

  Future<void> _loadRanks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList("tierlist_ranks") ?? [];

    final savedRanks = <int, String>{};
    for (final entry in saved) {
      final parts = entry.split(":");
      if (parts.length == 2) {
        savedRanks[int.parse(parts[0])] = parts[1];
      }
    }

    for (var movie in widget.seenMovies) {
      final id = movie["id"] as int;
      final rank = savedRanks[id] ?? "Non classé";
      if (tiers.containsKey(rank)) {
        tiers[rank]!.add(movie);
      } else {
        tiers["Non classé"]!.add(movie);
      }
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
        children: [
          Expanded(
            child: ListView(
              children: scores
                  .where((s) => s != "Non classé")
                  .map((score) => _buildRankContainer(score))
                  .toList(),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: _buildRankContainer("Non classé"),
          ),
        ],
      ),
    );
  }

  Widget _buildRankContainer(String score) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.18,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _colorForScore(score), width: 3),
      ),
      child: DragTarget<Map<String, dynamic>>(
        onAccept: (movie) {
          setState(() {
            tiers.forEach((key, value) => value.remove(movie));
            tiers[score]!.add(movie);
          });
          _saveRanks();
        },
        builder: (context, candidateData, rejectedData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                score,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _colorForScore(score),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: tiers[score]!
                      .map(
                        (movie) => LongPressDraggable<Map<String, dynamic>>(
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
          );
        },
      ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> movie) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 160,
      child: AspectRatio(
        aspectRatio: 9 / 16,
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

  Color _colorForScore(String score) {
    if (score == "Non classé") return Colors.white;

    final rainbow = [
      Colors.red,
      Colors.deepOrange,
      Colors.orange,
      Colors.amber,
      Colors.yellow,
      Colors.lime,
      Colors.green,
      Colors.teal,
      Colors.cyan,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
    ];

    final index = scores.indexOf(score);
    if (index == -1 || index >= rainbow.length) return Colors.grey;

    return rainbow[index];
  }
}
