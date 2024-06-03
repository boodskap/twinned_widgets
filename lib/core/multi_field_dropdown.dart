import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:uuid/uuid.dart';

typedef OnFieldsSelected<Parameter> = void Function(List<Parameter> item);

class MultiFieldDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnFieldsSelected onFieldsSelected;

  const MultiFieldDropdown({
    super.key,
    required this.selectedItems,
    required this.onFieldsSelected,
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
        searchHint: 'Select Fields',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onFieldsSelected(selectedItems);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (item) {
          return Text('${item.name}');
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
          for (var p in _allItems) {
            if (widget.selectedItems.contains(p.name)) {
              _selectedItems.add(p);
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
