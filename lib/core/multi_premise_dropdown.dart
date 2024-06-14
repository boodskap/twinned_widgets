import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:uuid/uuid.dart';

typedef OnPremisesSelected = void Function(List<twin.Premise> item);

class MultiPremiseDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnPremisesSelected onPremisesSelected;
  final bool allowDuplicates;

  const MultiPremiseDropdown({
    super.key,
    required this.selectedItems,
    required this.onPremisesSelected,
    required this.allowDuplicates,
  });

  @override
  State<MultiPremiseDropdown> createState() => _MultiPremiseDropdownState();
}

class _MultiPremiseDropdownState extends BaseState<MultiPremiseDropdown> {
  final List<twin.Premise> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.Premise>(
        key: Key(Uuid().v4()),
        allowDuplicates: widget.allowDuplicates,
        searchHint: 'Select Premises',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onPremisesSelected(selectedItems as List<twin.Premise>);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (item) {
          return Text('${item.name}');
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

  Future<void> _load() async {
    debugPrint('SELECTED PREMISES: ${widget.selectedItems}');
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
