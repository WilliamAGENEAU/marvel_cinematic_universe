import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:marvel_cinematic_universe/widgets/quiz_option.dart';
import 'package:marvel_cinematic_universe/widgets/quiz_results_page';

class OstQuizPage extends StatefulWidget {
  const OstQuizPage({super.key});

  @override
  State<OstQuizPage> createState() => _OstQuizPageState();
}

class _OstQuizPageState extends State<OstQuizPage> {
  final AudioPlayer _player = AudioPlayer();

  final List<Map<String, dynamic>> questions = [
    {
      "file": "assets/musics/avengers.mp3",
      "options": ["Avengers", "Iron Man", "Thor", "Guardians of the Galaxy"],
      "answer": "Avengers",
    },
    {
      "file": "assets/musics/ironman.mp3",
      "options": ["Avengers", "Iron Man", "Black Panther", "Doctor Strange"],
      "answer": "Iron Man",
    },
    {
      "file": "assets/musics/guardians.mp3",
      "options": ["Thor", "Guardians of the Galaxy", "Eternals", "Ant-Man"],
      "answer": "Guardians of the Galaxy",
    },
  ];

  int current = 0;
  int score = 0;

  void _playMusic(String file) async {
    await _player.stop();
    await _player.play(AssetSource(file.replaceFirst("assets/", "")));
  }

  void _answer(String choice) {
    if (choice == questions[current]["answer"]) {
      score++;
    }
    if (current < questions.length - 1) {
      setState(() {
        current++;
        _playMusic(questions[current]["file"]);
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResult(score: score, total: questions.length),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _playMusic(questions[current]["file"]);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[current];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Quiz des OST"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Écoute la musique et trouve le film :",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            ...question["options"].map<Widget>(
              (opt) => QuizOption(text: opt, onTap: () => _answer(opt)),
            ),
          ],
        ),
      ),
    );
  }
}
