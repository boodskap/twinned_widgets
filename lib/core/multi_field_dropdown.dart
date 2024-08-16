import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:uuid/uuid.dart';

typedef OnFieldsSelected = void Function(List<twin.Parameter> item);

class MultiFieldDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnFieldsSelected onFieldsSelected;
  final bool allowDuplicates;
  final TextStyle style;

  const MultiFieldDropdown({
    super.key,
    required this.selectedItems,
    required this.onFieldsSelected,
    required this.allowDuplicates,
    this.style = const TextStyle(),
  });

  @override
  State<MultiFieldDropdown> createState() => _MultiFieldDropdownState();
}

class _MultiFieldDropdownState extends BaseState<MultiFieldDropdown> {
  final List<twin.Parameter> _allItems = [];
  final List<twin.Parameter> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.Parameter>(
        key: Key(Uuid().v4()),
        allowDuplicates: widget.allowDuplicates,
        searchHint: 'Select Fields',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          List<twin.Parameter> parameters =
              selectedItems as List<twin.Parameter>;
          debugPrint('PARAMETERS: $parameters');
          widget.onFieldsSelected(parameters);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (value) {
          twin.Parameter entity = value;
          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: 64,
                    height: 48,
                    child: (entity.icon?.isNotEmpty ?? false)
                        ? TwinImageHelper.getDomainImage(entity.icon!)
                        : const Icon(Icons.image)),
              ),
              divider(horizontal: true),
              Text(
                '${entity.name}, ${entity.description}',
                style: widget.style,
              ),
            ],
          );
        },
        itemIdFunc: (item) {
          return item.name;
        });
  }

  Future<List<twin.Parameter>> _search(String keyword, int page) async {
    List<twin.Parameter> items = [];

    try {
      for (var p in _allItems) {
        if (p.name.contains(keyword)) {
          items.add(p);
        }
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
    return items;
  }

  Future<void> _load() async {
    _selectedItems.clear();
    try {
      var eRes = await TwinnedSession.instance.twin.listAllParameters(
        apikey: TwinnedSession.instance.authToken,
      );
      if (eRes != null && eRes.body != null) {
        setState(() {
          if (!mounted) return;
          _allItems.addAll(eRes.body!.values!);
          for (String selected in widget.selectedItems) {
            for (var p in _allItems) {
              if (p.name == selected) {
                _selectedItems.add(p);
              }
            }
          }
        });
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  @override
  void setup() {
    _load();
  }
}
