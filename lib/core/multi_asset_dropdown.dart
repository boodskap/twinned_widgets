import 'package:flutter/material.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twinned_widgets/twinned_session.dart';

typedef OnAssetsSelected<Asset> = void Function(List<Asset> item);

class MultiAssetDropdown extends StatefulWidget {
  final List<twin.Asset> selectedItems;
  final OnAssetsSelected onAssetsSelected;

  const MultiAssetDropdown({
    super.key,
    required this.selectedItems,
    required this.onAssetsSelected,
  });

  @override
  State<MultiAssetDropdown> createState() => _MultiAssetDropdownState();
}

class _MultiAssetDropdownState extends State<MultiAssetDropdown> {
  final List<twin.Asset> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.Asset>(
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onAssetsSelected(selectedItems);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (item) {
          return Text('${item.name} ID:${item.id}');
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (null == widget.selectedItems || widget.selectedItems!.isEmpty) {
      return;
    }
    try {
      List<String> ids = [];
      for (var dm in widget.selectedItems) {
        ids.add(dm.id);
      }
      var eRes = await TwinnedSession.instance.twin.getAssets(
        apikey: TwinnedSession.instance.authToken,
        body: twin.GetReq(ids: ids),
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
