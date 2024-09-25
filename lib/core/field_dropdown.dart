import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twin_commons/core/twinned_session.dart';

typedef OnFieldSelected = void Function(twin.Parameter? field);

class FieldDropdown extends StatefulWidget {
  final String? selectedField;
  final OnFieldSelected onFieldSelected;
  final TextStyle style;

  const FieldDropdown({
    super.key,
    required this.selectedField,
    required this.onFieldSelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

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
        textStyle: widget.style,
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
        for (var entity in pRes.body!.values!) {
          if (names.contains(entity.name)) continue;
          _dropdownMenuEntries.add(DropdownMenuEntry<twin.Parameter>(
              label: entity.name,
              value: entity,
              labelWidget: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: 32,
                        height: 32,
                        child: (entity.icon?.isNotEmpty ?? false)
                            ? TwinImageHelper.getDomainImage(entity.icon!)
                            : const Icon(Icons.image)),
                  ),
                  divider(horizontal: true),
                  Text(
                    entity.name,
                    style: widget.style,
                  ),
                ],
              )));
          if (entity.name == widget.selectedField) {
            _selectedParameter = entity;
          }
          names.add(entity.name);
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
