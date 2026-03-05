import 'package:flutter/material.dart';
import 'package:marvel_cinematic_universe/helpers/niveau.dart';
import 'package:marvel_cinematic_universe/widgets/timeline_card.dart';
import 'package:marvel_cinematic_universe/widgets/timeline_filters.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelineSection extends StatefulWidget {
  const TimelineSection({
    super.key,
    required this.universe,
    required this.activeId,
    required this.isHorizontal,
    required this.seenIds,
    required this.phaseColorFor,
    required this.onTapMovie,
    required this.onToggleSeen,
  });

  final List<Map<String, dynamic>> universe;
  final int activeId;
  final bool isHorizontal;
  final Set<int> seenIds;
  final Color Function(String?) phaseColorFor;
  final void Function(Map<String, dynamic> movie) onTapMovie;
  final void Function(int id) onToggleSeen;

  @override
  State<TimelineSection> createState() => _TimelineSectionState();
}

class _TimelineSectionState extends State<TimelineSection> {
  final ScrollController _scrollController = ScrollController();
  String selectedSaga = "Saga de l'infini";
  String selectedPhase = "Phase 1";
  Set<String> selectedNiveaux = {"immanquable"};
  GlobalKey? _activeItemKey;
  late final List<DropdownItem<Niveau>> niveauItems;
  final MultiSelectController<Niveau> niveauController =
      MultiSelectController<Niveau>();

  final sagas = {
    "Saga de l'infini": ["Phase 1", "Phase 2", "Phase 3"],
    "Saga du multivers": ["Phase 4", "Phase 5", "Phase 6"],
  };

  void _scrollToActive(int activeId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _activeItemKey?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          alignment: 0.5,
        );
      }
    });
  }

  void _onPhaseChanged(String phase) {
    setState(() {
      selectedPhase = phase;
      _activeItemKey = null;
    });

    final movie = widget.universe.firstWhere(
      (m) => m["Phase"] == phase,
      orElse: () => {},
    );

    if (movie.isNotEmpty) {
      widget.onTapMovie(movie);
      _scrollToActive(movie["id"]);
    }
  }

  @override
  void initState() {
    super.initState();
    final immanquable = Niveau(
      "immanquable 🔴",
      "Immanquable",
      Colors.redAccent,
    );
    niveauItems = [
      DropdownItem(
        label: "Intéressant 🟠",
        value: Niveau("interessant", "Intéressant", Colors.orangeAccent),
      ),
      DropdownItem(
        label: "Optionnel 🟢",
        value: Niveau("optionnel", "Optionnel", Colors.blueAccent),
      ),
    ];
    niveauController.addItems([
      DropdownItem(label: "Immanquable", value: immanquable),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = widget.universe
        .where(
          (m) =>
              m["Phase"] == selectedPhase &&
              selectedNiveaux.contains(m["niveau"]),
        )
        .toList();

    return Column(
      children: [
        TimelineFilters(
          selectedSaga: selectedSaga,
          selectedPhase: selectedPhase,
          sagas: sagas,
          niveauItems: niveauItems,
          niveauController: niveauController,
          onSagaChanged: (val) => setState(() {
            selectedSaga = val;
            selectedPhase = sagas[val]!.first;
            _onPhaseChanged(selectedPhase);
          }),
          onPhaseChanged: _onPhaseChanged,
          onNiveauChanged: (selectedNiveauxList) {
            setState(() {
              selectedNiveaux = {
                "immanquable",
                ...selectedNiveauxList.map((n) => n.key),
              };
              _activeItemKey = null;
            });
          },
        ),
        _buildTimelineList(filteredList),
      ],
    );
  }

  Widget _buildTimelineList(List<Map<String, dynamic>> list) {
    final itemWidth = (MediaQuery.of(context).size.width - 64) / 4;
    final itemHeight = itemWidth * 16 / 9;

    return SizedBox(
      height: itemHeight + 60,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, i) {
          final movie = list[i];
          final isActive = movie["id"] == widget.activeId;

          final activeIndexInFiltered = list.indexWhere(
            (e) => e["id"] == widget.activeId,
          );
          final phaseColor = widget.phaseColorFor(movie["Phase"]);

          final itemKey = isActive ? GlobalKey() : ValueKey(movie["id"]);
          if (isActive) _activeItemKey = itemKey as GlobalKey;

          return TimelineTile(
            axis: TimelineAxis.horizontal,
            alignment: TimelineAlign.manual,
            lineXY: 0.9,
            isFirst: i == 0,
            isLast: i == list.length - 1,

            startChild: GestureDetector(
              onTap: () => widget.onTapMovie(movie),
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  key: itemKey,
                  child: TimelineCard(
                    movie: movie,
                    isActive: isActive,
                    isSeen: widget.seenIds.contains(movie["id"]),
                    width: itemWidth,
                    height: itemHeight,
                    onToggleSeen: () => widget.onToggleSeen(movie["id"]),
                  ),
                ),
              ),
            ),

            indicatorStyle: IndicatorStyle(
              width: isActive ? 34 : 28,
              height: isActive ? 34 : 28,
              indicator: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= activeIndexInFiltered ? phaseColor : Colors.grey,
                  border: Border.all(
                    color: Colors.white,
                    width: isActive ? 2.5 : 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    movie["id"].toString(),
                    style: TextStyle(
                      fontSize: isActive ? 13 : 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            beforeLineStyle: LineStyle(
              color: i <= activeIndexInFiltered ? phaseColor : Colors.grey,
              thickness: 3,
            ),
            afterLineStyle: LineStyle(
              color: i < activeIndexInFiltered ? phaseColor : Colors.grey,
              thickness: 3,
            ),
          );
        },
      ),
    );
  }
}
