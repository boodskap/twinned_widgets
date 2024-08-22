import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:uuid/uuid.dart';

typedef OnRolesSelected = void Function(List<twin.Role> items);

class MultiRoleDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnRolesSelected onRolesSelected;
  final TextStyle style;

  const MultiRoleDropdown({
    super.key,
    required this.selectedItems,
    required this.onRolesSelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<MultiRoleDropdown> createState() => _MultiRoleDropdownState();
}

class _MultiRoleDropdownState extends BaseState<MultiRoleDropdown> {
  final List<twin.Role> _allItems = [];
  final List<twin.Role> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.Role>(
        key: Key(Uuid().v4()),
        allowDuplicates: false,
        searchHint: 'Select Roles',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onRolesSelected(selectedItems as List<twin.Role>);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (item) {
          return Text(
            '${item.name}',
            style: widget.style,
          );
        },
        itemIdFunc: (item) {
          return item.name;
        });
  }

  Future<List<twin.Role>> _search(String keyword, int page) async {
    List<twin.Role> items = [];

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
      var eRes = await TwinnedSession.instance.twin.listRoles(
          apikey: TwinnedSession.instance.authToken,
          body: const twin.ListReq(page: 0, size: 10000));
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
