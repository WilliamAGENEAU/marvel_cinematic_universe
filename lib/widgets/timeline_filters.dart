import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import '../../../helpers/niveau.dart';

class TimelineFilters extends StatelessWidget {
  final String selectedSaga;
  final String selectedPhase;
  final Map<String, List<String>> sagas;
  final List<DropdownItem<Niveau>> niveauItems;
  final MultiSelectController<Niveau> niveauController;
  final Function(String) onSagaChanged;
  final Function(String) onPhaseChanged;
  final void Function(List<Niveau>) onNiveauChanged;
  const TimelineFilters({
    super.key,
    required this.selectedSaga,
    required this.selectedPhase,
    required this.sagas,
    required this.niveauItems,
    required this.niveauController,
    required this.onSagaChanged,
    required this.onPhaseChanged,
    required this.onNiveauChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _customDropdown(
              selectedSaga,
              sagas.keys.toList(),
              onSagaChanged,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: _customDropdown(
              selectedPhase,
              sagas[selectedSaga]!,
              onPhaseChanged,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(flex: 3, child: _buildMultiSelect()),
        ],
      ),
    );
  }

  Widget _customDropdown(
    String value,
    List<String> items,
    Function(String) onChanged,
  ) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.black,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }

  Widget _buildMultiSelect() {
    return SizedBox(
      height: 42,
      child: MultiDropdown<Niveau>(
        items: niveauItems,
        controller: niveauController,
        fieldDecoration: FieldDecoration(
          hintText: 'Filtres',
          hintStyle: const TextStyle(color: Colors.white, fontSize: 13),
          backgroundColor: Colors.black,
          borderRadius: 10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white24),
          ),
        ),
        chipDecoration: const ChipDecoration(
          backgroundColor: Colors.black,
          labelStyle: TextStyle(color: Colors.white),
          wrap: false,
        ),
        dropdownDecoration: const DropdownDecoration(
          backgroundColor: Colors.black,
        ),
        dropdownItemDecoration: DropdownItemDecoration(
          textColor: Colors.white,
          selectedIcon: const Icon(Icons.check_circle, color: Colors.redAccent),
        ),
        onSelectionChange: onNiveauChanged,
      ),
    );
  }
}
