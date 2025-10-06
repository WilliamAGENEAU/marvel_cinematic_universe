import 'package:flutter/material.dart';
import 'quotes_quiz_page.dart';
import 'ost_quiz_page.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Quiz Marvel", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQuizButton(
              context,
              "Quiz des répliques",
              const QuotesQuizPage(),
              Colors.purpleAccent,
            ),
            const SizedBox(height: 30),
            _buildQuizButton(
              context,
              "Quiz des OST",
              const OstQuizPage(),
              Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizButton(
    BuildContext context,
    String title,
    Widget page,
    Color color,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
