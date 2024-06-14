import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/twinned_session.dart';

typedef OnFieldSelected = void Function(twin.Parameter? field);

class FieldDropdown extends StatefulWidget {
  final String? selectedField;
  final OnFieldSelected onFieldSelected;

  const FieldDropdown(
      {super.key, required this.selectedField, required this.onFieldSelected});

  @override
  State<FieldDropdown> createState() => _FieldDropdownState();
}

class _FieldDropdownState extends BaseState<FieldDropdown> {
  final List<DropdownMenuEntry<twin.Parameter>> _dropdownMenuEntries = [];
  twin.Parameter? _selectedParameter;

  @override
  Widget build(BuildContext context) {
    if (_dropdownMenuEntries.isEmpty) {
      return const Icon(Icons.hourglass_bottom);
    }

    return DropdownMenu<twin.Parameter>(
        onSelected: (param) {
          widget.onFieldSelected(param);
        },
        initialSelection: _selectedParameter,
        dropdownMenuEntries: _dropdownMenuEntries);
  }

  Future load() async {
    if (loading) return;
    loading = true;
    _dropdownMenuEntries.clear();
    await execute(() async {
      var pRes = await TwinnedSession.instance.twin
          .listAllParameters(apikey: TwinnedSession.instance.authToken);
      if (validateResponse(pRes)) {
        List<String> names = [];
        for (var param in pRes.body!.values!) {
          if (names.contains(param.name)) continue;
          _dropdownMenuEntries.add(DropdownMenuEntry<twin.Parameter>(
              label: param.name, value: param));
          if (param.name == widget.selectedField) {
            _selectedParameter = param;
          }
          names.add(param.name);
        }
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {
    load();
  }
}
