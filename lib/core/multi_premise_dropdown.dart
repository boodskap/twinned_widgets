import 'package:flutter/material.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twinned_widgets/twinned_session.dart';

typedef OnPremisesSelected<Premise> = void Function(List<Premise> item);

class MultiPremiseDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnPremisesSelected onPremisesSelected;

  const MultiPremiseDropdown({
    super.key,
    required this.selectedItems,
    required this.onPremisesSelected,
  });

  @override
  State<MultiPremiseDropdown> createState() => _MultiPremiseDropdownState();
}

class _MultiPremiseDropdownState extends State<MultiPremiseDropdown> {
  final List<twin.Premise> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.Premise>(
        searchHint: 'Select Premises',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onPremisesSelected(selectedItems);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (item) {
          return Text('${item.name} ID:${item.id}');
        },
        itemIdFunc: (item) {
          return item.id;
        });
  }

  Future<List<twin.Premise>> _search(String keyword, int page) async {
    List<twin.Premise> items = [];

    try {
      var pRes = await TwinnedSession.instance.twin.searchPremises(
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
      var eRes = await TwinnedSession.instance.twin.getPremises(
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
