import 'package:flutter/material.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twinned_widgets/twinned_session.dart';

typedef OnFloorsSelected<Floor> = void Function(List<Floor> item);

class MultiFloorDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnFloorsSelected onFloorsSelected;

  const MultiFloorDropdown({
    super.key,
    required this.selectedItems,
    required this.onFloorsSelected,
  });

  @override
  State<MultiFloorDropdown> createState() => _MultiFloorDropdownState();
}

class _MultiFloorDropdownState extends State<MultiFloorDropdown> {
  final List<twin.Floor> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.Floor>(
        searchHint: 'Select Floors',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onFloorsSelected(selectedItems);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (item) {
          return Text('${item.name} ID:${item.id}');
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
          _selectedItems.addAll(eRes.body!.values!);
        });
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }
}
