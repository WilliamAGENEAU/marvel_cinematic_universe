// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:marvel_cinematic_universe/helpers/niveau.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

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
  Color _niveauColor(String niveau) {
    switch (niveau) {
      case "immanquable":
        return Colors.redAccent;
      case "interessant":
        return Colors.orangeAccent;
      case "optionnel":
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  String selectedSaga = "Saga de l'infini";
  String selectedPhase = "Phase 1";

  final sagas = {
    "Saga de l'infini": ["Phase 1", "Phase 2", "Phase 3"],
    "Saga du multivers": ["Phase 4", "Phase 5", "Phase 6"],
  };
  final MultiSelectController<Niveau> niveauController =
      MultiSelectController<Niveau>();

  late final List<DropdownItem<Niveau>> niveauItems;

  Set<String> selectedNiveaux = {"immanquable"};

  GlobalKey? _activeItemKey; // ✅ une seule clé pour l’item actif

  @override
  void didUpdateWidget(covariant TimelineSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeId != oldWidget.activeId) {
      _scrollToActive(widget.activeId);
    }
  }

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
      _activeItemKey = null; // reset clé
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

    // 🔒 Immanquable forcé MAIS invisible
    niveauController.addItems([
      DropdownItem(label: "Immanquable", value: immanquable),
    ]);
  }

  bool _matchesNiveau(Map<String, dynamic> movie) {
    return selectedNiveaux.contains(movie["niveau"]);
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.universe
        .where((m) => m["Phase"] == selectedPhase)
        .where(_matchesNiveau)
        .toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 64) / 4;
    final itemHeight = itemWidth * 16 / 9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔽 Menus stylés
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Row(
            children: [
              _buildDropdown(
                value: selectedSaga,
                items: sagas.keys.toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedSaga = val;
                      selectedPhase = sagas[val]!.first;
                      _activeItemKey = null;
                    });
                    _onPhaseChanged(selectedPhase);
                  }
                },
              ),
              const SizedBox(width: 6),
              _buildDropdown(
                value: selectedPhase,
                items: sagas[selectedSaga]!,
                onChanged: (val) {
                  if (val != null) _onPhaseChanged(val);
                },
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 190,
                height: 42,
                child: MultiDropdown<Niveau>(
                  items: niveauItems,
                  controller: niveauController,
                  enabled: true,
                  searchEnabled: false,

                  chipDecoration: const ChipDecoration(
                    backgroundColor: Colors.black,
                    labelStyle: TextStyle(color: Colors.white),
                    wrap: false,
                  ),

                  fieldDecoration: FieldDecoration(
                    hintText: 'Filtres',
                    hintStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    showClearIcon: false,
                    backgroundColor: Colors.black,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                  ),

                  dropdownDecoration: const DropdownDecoration(
                    backgroundColor: Colors.black,
                    maxHeight: 180,
                  ),

                  dropdownItemDecoration: DropdownItemDecoration(
                    textColor: Colors.white,
                    selectedIcon: const Icon(
                      Icons.check_circle,
                      color: Colors.redAccent,
                    ),
                  ),

                  // ✅ SIGNATURE CORRECTE
                  onSelectionChange: (selectedItems) {
                    setState(() {
                      selectedNiveaux = {
                        "immanquable", // 🔒 toujours présent
                        ...selectedItems.map((e) => e.key),
                      };
                      _activeItemKey = null;
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // 🔽 Timeline
        SizedBox(
          height: widget.isHorizontal ? itemHeight + 50 : null,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: widget.isHorizontal
                ? Axis.horizontal
                : Axis.vertical,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final movie = list[i];
              final isActive = movie["id"] == widget.activeId;
              final index = list.indexWhere(
                (e) => (e["id"] as int) == widget.activeId,
              );
              final phaseColor = widget.phaseColorFor(movie["Phase"]);
              final seen = widget.seenIds.contains(movie["id"]);

              // ✅ clé unique si actif
              final itemKey = isActive ? GlobalKey() : ValueKey(movie["id"]);
              if (isActive) _activeItemKey = itemKey as GlobalKey;

              // Miniature + bouton vu
              final thumb = Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ColorFiltered(
                      colorFilter: seen
                          ? const ColorFilter.mode(
                              Colors.grey,
                              BlendMode.saturation,
                            )
                          : const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.dst,
                            ),
                      child: Image.asset(
                        'assets/images/thumbnail/${movie["Thumbnail"]}',
                        height: itemHeight,
                        width: itemWidth,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () => widget.onToggleSeen(movie["id"] as int),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          seen
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 20,
                          color: seen ? Colors.greenAccent : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _niveauColor(movie["niveau"]),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black87,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );

              return Container(
                key: ValueKey(movie["id"]),
                child: Padding(
                  padding: EdgeInsets.only(right: widget.isHorizontal ? 10 : 0),
                  child: TimelineTile(
                    axis: widget.isHorizontal
                        ? TimelineAxis.horizontal
                        : TimelineAxis.vertical,
                    alignment: TimelineAlign.manual,
                    lineXY: 1.0,
                    startChild: GestureDetector(
                      onTap: () => widget.onTapMovie(movie),
                      child: Column(
                        children: [
                          Container(
                            key: itemKey,
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 250),
                              scale: isActive ? 1.08 : 1.0,
                              curve: Curves.easeOutBack,
                              child: thumb,
                            ),
                          ),
                        ],
                      ),
                    ),
                    indicatorStyle: IndicatorStyle(
                      width: isActive ? 34 : 28,
                      height: isActive ? 34 : 28,
                      indicator: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i <= index ? phaseColor : Colors.grey,
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
                      color: i <= index ? phaseColor : Colors.grey,
                      thickness: 3,
                    ),
                    afterLineStyle: LineStyle(
                      color: i < index ? phaseColor : Colors.grey,
                      thickness: 3,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 🔽 Dropdown stylisé
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    String Function(String)? labelBuilder,
  }) {
    return Container(
      height: 42, // ✅ plus petit
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true, // ✅ compact
          dropdownColor: Colors.black87,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    labelBuilder != null ? labelBuilder(item) : item,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
