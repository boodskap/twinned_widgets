import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:uuid/uuid.dart';

typedef OnAssetsSelected = void Function(List<twin.Asset> item);

class MultiAssetDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnAssetsSelected onAssetsSelected;
  final bool allowDuplicates;

  const MultiAssetDropdown({
    super.key,
    required this.selectedItems,
    required this.onAssetsSelected,
    required this.allowDuplicates,
  });

  @override
  State<MultiAssetDropdown> createState() => _MultiAssetDropdownState();
}

class _MultiAssetDropdownState extends BaseState<MultiAssetDropdown> {
  final List<twin.Asset> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.Asset>(
        key: Key(Uuid().v4()),
        allowDuplicates: widget.allowDuplicates,
        searchHint: 'Select Assets',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onAssetsSelected(selectedItems as List<twin.Asset>);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (item) {
          return Text('${item.name}');
        },
        itemIdFunc: (item) {
          return item.id;
        });
  }

  Future<List<twin.Asset>> _search(String keyword, int page) async {
    List<twin.Asset> items = [];

    try {
      var pRes = await TwinnedSession.instance.twin.searchAssets(
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
    debugPrint('SELECTED ASSETS: ${widget.selectedItems}');
    if (widget.selectedItems.isEmpty) {
      return;
    }
    try {
      var eRes = await TwinnedSession.instance.twin.getAssets(
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
