import 'package:flutter/material.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twinned_widgets/twinned_session.dart';

typedef OnAssetModelsSelected<AssetModel> = void Function(
    List<AssetModel> item);

class MultiAssetModelDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnAssetModelsSelected onAssetModelsSelected;

  const MultiAssetModelDropdown({
    super.key,
    required this.selectedItems,
    required this.onAssetModelsSelected,
  });

  @override
  State<MultiAssetModelDropdown> createState() =>
      _MultiAssetModelDropdownState();
}

class _MultiAssetModelDropdownState extends State<MultiAssetModelDropdown> {
  final List<twin.AssetModel> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.AssetModel>(
        searchHint: 'Select Asset Models',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onAssetModelsSelected(selectedItems);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (item) {
          return Text('${item.name} ID:${item.id}');
        },
        itemIdFunc: (item) {
          return item.id;
        });
  }

  Future<List<twin.AssetModel>> _search(String keyword, int page) async {
    List<twin.AssetModel> items = [];

    try {
      var pRes = await TwinnedSession.instance.twin.searchAssetModels(
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
      var eRes = await TwinnedSession.instance.twin.getAssetModels(
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
