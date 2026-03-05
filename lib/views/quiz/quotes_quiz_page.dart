import 'package:flutter/material.dart';
import 'package:marvel_cinematic_universe/widgets/quiz_option.dart';
import 'package:marvel_cinematic_universe/widgets/quiz_results_page.dart';

class QuotesQuizPage extends StatefulWidget {
  const QuotesQuizPage({super.key});

  @override
  State<QuotesQuizPage> createState() => _QuotesQuizPageState();
}

class _QuotesQuizPageState extends State<QuotesQuizPage> {
  final List<Map<String, dynamic>> questions = [
    {
      "quote": "I am Iron Man.",
      "options": ["Tony Stark", "Steve Rogers", "Thor", "Loki"],
      "answer": "Tony Stark",
    },
    {
      "quote": "Wakanda Forever!",
      "options": ["T'Challa", "Okoye", "Shuri", "Killmonger"],
      "answer": "T'Challa",
    },
    {
      "quote": "I can do this all day.",
      "options": ["Hulk", "Hawkeye", "Steve Rogers", "Vision"],
      "answer": "Steve Rogers",
    },
  ];

  int current = 0;
  int score = 0;

  void _answer(String choice) {
    if (choice == questions[current]["answer"]) {
      score++;
    }
    if (current < questions.length - 1) {
      setState(() {
        current++;
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
  Widget build(BuildContext context) {
    final question = questions[current];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Quiz des répliques"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "\"${question["quote"]}\"",
              style: const TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ...question["options"].map<Widget>(
              (opt) => QuizOption(text: opt, onTap: () => _answer(opt)),
            ),
          ],
        ),
      ),
    );
  }
}
