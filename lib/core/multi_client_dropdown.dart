import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:uuid/uuid.dart';

typedef OnClientsSelected = void Function(List<twin.Client> items);

class MultiClientDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnClientsSelected onClientsSelected;

  const MultiClientDropdown({
    super.key,
    required this.selectedItems,
    required this.onClientsSelected,
  });

  @override
  State<MultiClientDropdown> createState() => _MultiClientDropdownState();
}

class _MultiClientDropdownState extends BaseState<MultiClientDropdown> {
  final List<twin.Client> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.Client>(
        key: Key(Uuid().v4()),
        searchHint: 'Select Clients',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onClientsSelected(selectedItems as List<twin.Client>);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (item) {
          return Text('${item.name}');
        },
        itemIdFunc: (item) {
          return item.id;
        });
  }

  Future<List<twin.Client>> _search(String keyword, int page) async {
    List<twin.Client> items = [];

    try {
      var pRes = await TwinnedSession.instance.twin.searchClients(
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
    if (widget.selectedItems.isEmpty) {
      return;
    }
    try {
      var eRes = await TwinnedSession.instance.twin.getClients(
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
