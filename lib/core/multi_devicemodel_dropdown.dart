import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:uuid/uuid.dart';

typedef OnDeviceModelsSelected<DeviceModel> = void Function(
    List<DeviceModel> device);

class MultiDeviceModelDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnDeviceModelsSelected onDeviceModelsSelected;

  const MultiDeviceModelDropdown({
    super.key,
    required this.selectedItems,
    required this.onDeviceModelsSelected,
  });

  @override
  State<MultiDeviceModelDropdown> createState() =>
      _MultiDeviceModelDropdownState();
}

class _MultiDeviceModelDropdownState
    extends BaseState<MultiDeviceModelDropdown> {
  final List<twin.DeviceModel> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.DeviceModel>(
        key: Key(Uuid().v4()),
        searchHint: 'Select Device Models',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onDeviceModelsSelected(selectedItems);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (item) {
          return Text('${item.name} ID:${item.id}');
        },
        itemIdFunc: (item) {
          return item.id;
        });
  }

  Future<List<twin.DeviceModel>> _search(String keyword, int page) async {
    List<twin.DeviceModel> items = [];

    try {
      var pRes = await TwinnedSession.instance.twin.searchDeviceModels(
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
    if (widget.selectedItems!.isEmpty) {
      debugPrint('no device model items');
      return;
    }
    try {
      var eRes = await TwinnedSession.instance.twin.getDeviceModels(
        apikey: TwinnedSession.instance.authToken,
        body: twin.GetReq(ids: widget.selectedItems),
      );
      if (eRes != null && eRes.body != null) {
        setState(() {
          _selectedItems.addAll(eRes.body!.values!);
        });
        debugPrint('Updated with ${_selectedItems.length} items');
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