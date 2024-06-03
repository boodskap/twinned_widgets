import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:uuid/uuid.dart';

typedef OnDevicesSelected<Device> = void Function(List<Device> device);

class MultiDeviceDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnDevicesSelected onDevicesSelected;

  const MultiDeviceDropdown({
    super.key,
    required this.selectedItems,
    required this.onDevicesSelected,
  });

  @override
  State<MultiDeviceDropdown> createState() => _MultiDeviceDropdownState();
}

class _MultiDeviceDropdownState extends BaseState<MultiDeviceDropdown> {
  final List<twin.Device> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.Device>(
        key: Key(Uuid().v4()),
        searchHint: 'Select Devices',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onDevicesSelected(selectedItems);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (item) {
          return Text('${item.name}');
        },
        itemIdFunc: (item) {
          return item.id;
        });
  }

  Future<List<twin.Device>> _search(String keyword, int page) async {
    List<twin.Device> items = [];

    try {
      var pRes = await TwinnedSession.instance.twin.searchDevices(
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
      return;
    }
    try {
      var eRes = await TwinnedSession.instance.twin.getDevices(
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
