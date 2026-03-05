// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:marvel_cinematic_universe/helpers/static-data.dart';
import 'package:marvel_cinematic_universe/helpers/utilities.dart';
import 'package:marvel_cinematic_universe/views/tierlist/tierlist_page.dart';
import 'package:marvel_cinematic_universe/views/quiz/quiz_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ASide maintenant accepte:
/// - [onStopAudio] pour couper la musique quand on va sur la Tierlist
/// - [closeMenu] pour fermer le SideMenu avant navigation
Widget ASide(
  BuildContext context, {
  Future<void> Function()? onStopAudio,
  List<Map<String, dynamic>>? universe,
  VoidCallback? closeMenu,
}) {
  Future<void> openTierlist() async {
    closeMenu?.call();

    if (onStopAudio != null) {
      await onStopAudio();
    }

    final prefs = await SharedPreferences.getInstance();
    final seenIds = (prefs.getStringList('seen_ids') ?? [])
        .map(int.parse)
        .toSet();

    final seenMovies = universe!
        .where((m) => seenIds.contains(m["id"] as int))
        .toList(growable: false);

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TierListPage(seenMovies: seenMovies)),
    );
  }

  Future<void> openQuiz() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuizPage()),
    );
  }

  return Column(
    children: [
      Expanded(
        flex: 1,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                onTap: () {
                  closeMenu?.call();
                  Navigator.pushNamed(context, '/');
                },
                leading: Icon(
                  FontAwesome5.globe_asia,
                  size: 20.0,
                  color: DefaultColors.baby_white,
                ),
                title: const Text("Ordre MCU", style: TextStyle(fontSize: 14)),
                textColor: DefaultColors.baby_white,
                dense: true,
              ),
              ListTile(
                onTap: openTierlist,
                leading: Icon(
                  FontAwesome5.list,
                  size: 20.0,
                  color: DefaultColors.baby_white,
                ),
                title: const Text("Tierlist", style: TextStyle(fontSize: 14)),
                textColor: DefaultColors.baby_white,
                dense: true,
              ),
              ListTile(
                onTap: openQuiz,
                leading: Icon(
                  FontAwesome5.book,
                  size: 20.0,
                  color: DefaultColors.baby_white,
                ),
                title: Row(
                  children: [
                    const Text("Quiz", style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                  ],
                ),
                textColor: DefaultColors.baby_white,
                dense: true,
              ),
              ListTile(
                onTap: () {
                  ShowToast('Characters screen is work in progress.');
                },
                leading: Icon(
                  FontAwesome5.users,
                  size: 20.0,
                  color: DefaultColors.baby_white,
                ),
                title: Row(
                  children: [
                    const Text("Characters", style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: DefaultColors.danger,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(3),
                        ),
                      ),
                      child: const Text("WIP", style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                textColor: DefaultColors.baby_white,
                dense: true,
              ),
              ListTile(
                onTap: () {
                  ShowToast('Stories screen is work in progress.');
                },
                leading: Icon(
                  FontAwesome5.history,
                  size: 20.0,
                  color: DefaultColors.baby_white,
                ),
                title: Row(
                  children: [
                    const Text("Stories", style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: DefaultColors.danger,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(3),
                        ),
                      ),
                      child: const Text("WIP", style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                textColor: DefaultColors.baby_white,
                dense: true,
              ),
            ],
          ),
        ),
      ),
      Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.only(bottom: Pad.sm, left: Pad.sm),
        child: Text(
          'v1.0.0',
          style: TextStyle(color: DefaultColors.baby_white),
        ),
      ),
    ],
  );
}
