import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:uuid/uuid.dart';

typedef OnFloorsSelected = void Function(List<twin.Floor> item);

class MultiFloorDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnFloorsSelected onFloorsSelected;
  final bool allowDuplicates;

  const MultiFloorDropdown({
    super.key,
    required this.selectedItems,
    required this.onFloorsSelected,
    required this.allowDuplicates,
  });

  @override
  State<MultiFloorDropdown> createState() => _MultiFloorDropdownState();
}

class _MultiFloorDropdownState extends BaseState<MultiFloorDropdown> {
  final List<twin.Floor> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.Floor>(
        key: Key(Uuid().v4()),
        allowDuplicates: widget.allowDuplicates,
        searchHint: 'Select Floors',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onFloorsSelected(selectedItems as List<twin.Floor>);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (item) {
          return Text('${item.name}');
        },
        itemIdFunc: (item) {
          return item.id;
        });
  }

  Future<List<twin.Floor>> _search(String keyword, int page) async {
    List<twin.Floor> items = [];

    try {
      var pRes = await TwinnedSession.instance.twin.searchFloors(
        apikey: TwinnedSession.instance.authToken,
        body: twin.SearchReq(search: keyword, page: page, size: 25),
      );
      if (pRes.body != null) {
        items.addAll(pRes.body!.values!);
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
    return items;
  }

  Future<void> _load() async {
    debugPrint('SELECTED FLOORS: ${widget.selectedItems}');
    if (widget.selectedItems.isEmpty) {
      return;
    }
    try {
      var eRes = await TwinnedSession.instance.twin.getFloors(
        apikey: TwinnedSession.instance.authToken,
        body: twin.GetReq(ids: widget.selectedItems),
      );
      if (eRes != null && eRes.body != null) {
        setState(() {
          if (!mounted) return;
          _selectedItems.addAll(eRes.body!.values!);
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
