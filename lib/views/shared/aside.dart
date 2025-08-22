// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:marvel_cinematic_universe/controller/universeController.dart';
import 'package:marvel_cinematic_universe/helpers/static-data.dart';
import 'package:marvel_cinematic_universe/helpers/utilities.dart';
import 'package:marvel_cinematic_universe/views/home/tierlist_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ASide maintenant accepte:
/// - [onStopAudio] pour couper la musique quand on va sur la Tierlist
/// - [closeMenu] pour fermer le SideMenu avant navigation
Widget ASide(
  String email,
  BuildContext context, {
  Future<void> Function()? onStopAudio,
  VoidCallback? closeMenu,
}) {
  Future<void> openTierlist() async {
    // 1) fermer le menu s'il y a une callback
    closeMenu?.call();

    // 2) couper l'audio s'il y a une callback
    if (onStopAudio != null) {
      await onStopAudio();
    }

    // 3) récupérer les IDs vus depuis SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final seenIds = (prefs.getStringList('seen_ids') ?? [])
        .map(int.parse)
        .toSet();

    // 4) construire la liste des films vus à partir de universeMock
    final seenMovies = universeMock
        .where((m) => seenIds.contains(m["id"] as int))
        .toList(growable: false);

    // 5) naviguer vers la TierListPage en lui passant les films vus
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TierListPage(seenMovies: seenMovies)),
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
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    Text(
                      email,
                      style: TextStyle(
                        color: DefaultColors.baby_white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
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
                onTap: openTierlist, // ✅ ouvre la tierlist correctement
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
                onTap: () {
                  ShowToast('Comics screen is work in progress.');
                },
                leading: Icon(
                  FontAwesome5.book,
                  size: 20.0,
                  color: DefaultColors.baby_white,
                ),
                title: Row(
                  children: [
                    const Text("Comics", style: TextStyle(fontSize: 14)),
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
