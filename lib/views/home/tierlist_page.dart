import 'package:flutter/material.dart';
import 'package:marvel_cinematic_universe/helpers/static-data.dart';
import 'package:marvel_cinematic_universe/views/shared/aside.dart';
import 'package:marvel_cinematic_universe/views/shared/tierlist.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

class TierListPage extends StatefulWidget {
  final List<Map<String, dynamic>> seenMovies;
  const TierListPage({super.key, required this.seenMovies});

  @override
  State<TierListPage> createState() => _TierListPageState();
}

class _TierListPageState extends State<TierListPage> {
  final GlobalKey<SideMenuState> _sideMenuKey = GlobalKey<SideMenuState>();

  void _toggleMenu() {
    final state = _sideMenuKey.currentState;
    if (state?.isOpened ?? false) {
      state?.closeSideMenu();
    } else {
      state?.openSideMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SideMenu(
      key: _sideMenuKey,
      background: DefaultColors.dark,
      type: SideMenuType.shrinkNSlide,
      menu: ASide(
        "",
        context,
        closeMenu: () => _sideMenuKey.currentState?.closeSideMenu(),
      ),
      child: Scaffold(
        backgroundColor: DefaultColors.dark,
        appBar: AppBar(
          backgroundColor: DefaultColors.dark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: _toggleMenu,
          ),
          title: const Text(
            "Tierlist MCU",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: TierListTable(seenMovies: widget.seenMovies),
      ),
    );
  }
}
