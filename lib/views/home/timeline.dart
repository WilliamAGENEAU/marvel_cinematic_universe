// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
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

  final sagas = {
    "Saga de l'infini": ["Phase 1", "Phase 2", "Phase 3"],
    "Saga du multivers": ["Phase 4", "Phase 5", "Phase 6"],
  };

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
  Widget build(BuildContext context) {
    final list = widget.universe
        .where((m) => m["Phase"] == selectedPhase)
        .toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - 64) / 4;
    final itemHeight = itemWidth * 16 / 9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔽 Menus stylés
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              const SizedBox(width: 16),
              _buildDropdown(
                value: selectedPhase,
                items: sagas[selectedSaga]!,
                onChanged: (val) {
                  if (val != null) _onPhaseChanged(val);
                },
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
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.black87,
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.white),
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
