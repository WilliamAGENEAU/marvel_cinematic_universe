import 'package:flutter/material.dart';
import 'package:marvel_cinematic_universe/theme/theme.dart';
import 'package:marvel_cinematic_universe/views/home/home.dart';
import 'package:marvel_cinematic_universe/views/tierlist/tierlist_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.configureSystemUI();

  runApp(const MarvelApp());
}

class MarvelApp extends StatelessWidget {
  const MarvelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,

      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomeScreen());

          case '/tierlist':
            final args =
                settings.arguments as List<Map<String, dynamic>>? ?? [];
            return MaterialPageRoute(
              builder: (_) => TierListPage(seenMovies: args),
            );

          default:
            return MaterialPageRoute(
              builder: (_) =>
                  const Scaffold(body: Center(child: Text('Page non trouvée'))),
            );
        }
      },
    );
  }
}
