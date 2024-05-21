import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/twinned_session.dart';

typedef OnModelFieldSelected = void Function(twin.Parameter? field);

class ModelFieldDropdown extends StatefulWidget {
  final String? selectedField;
  final OnModelFieldSelected onModelFieldSelected;

  ModelFieldDropdown(
      {super.key,
      required this.selectedField,
      required this.onModelFieldSelected});

  @override
  State<ModelFieldDropdown> createState() => _ModelFieldDropdownState();
}

class _ModelFieldDropdownState extends BaseState<ModelFieldDropdown> {
  final List<DropdownMenuEntry<twin.Parameter>> _dropdownMenuEntries = [];
  twin.Parameter? _selectedParameter;

  @override
  Widget build(BuildContext context) {
    if (_dropdownMenuEntries.isEmpty) {
      return const Icon(Icons.hourglass_bottom);
    }

    return DropdownMenu<twin.Parameter>(
        onSelected: (param) {
          widget.onModelFieldSelected(param);
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
        for (var param in pRes.body!.values!) {
          if (param.name == widget.selectedField) {
            _selectedParameter = param;
          }
          _dropdownMenuEntries.add(DropdownMenuEntry<twin.Parameter>(
              label: param.name, value: param));
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
