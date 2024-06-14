import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/twinned_session.dart';

typedef OnDeviceSelected = void Function(twin.Device? device);

class DeviceDropdown extends StatefulWidget {
  final String? selectedItem;
  final OnDeviceSelected onDeviceSelected;

  const DeviceDropdown(
      {super.key, required this.selectedItem, required this.onDeviceSelected});

  @override
  State<DeviceDropdown> createState() => _DeviceDropdownState();
}

class _DeviceDropdownState extends BaseState<DeviceDropdown> {
  twin.Device? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.Device>.single(
      value: _selectedItem,
      hint: 'Select Device',
      searchHint: 'Select Device',
      isExpanded: true,
      futureSearchFn: (String? keyword, String? orderBy, bool? orderAsc,
          List<Tuple2<String, String>>? filters, int? pageNb) async {
        pageNb = pageNb ?? 1;
        --pageNb;
        var result = await _search(search: keyword ?? '*', page: pageNb);
        return result;
      },
      dialogBox: true,
      dropDownDialogPadding: const EdgeInsets.fromLTRB(250, 50, 250, 50),
      selectedValueWidgetFn: (value) {
        twin.Device device = value;
        return Text('${device.name}, SN:${device.deviceId}');
      },
      onChanged: (selected) {
        setState(() {
          _selectedItem = selected;
        });
        widget.onDeviceSelected(_selectedItem);
      },
    );
  }

  Future<Tuple2<List<DropdownMenuItem<twin.Device>>, int>> _search(
      {String search = "*", int? page = 0}) async {
    if (loading) return Tuple2([], 0);
    loading = true;
    List<DropdownMenuItem<twin.Device>> items = [];
    int total = 0;

    try {
      var pRes = await TwinnedSession.instance.twin.searchDevices(
          apikey: TwinnedSession.instance.authToken,
          body: twin.SearchReq(search: search, page: page ?? 0, size: 25));
      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.selectedItem) {
            _selectedItem = entity;
          }
          items.add(DropdownMenuItem<twin.Device>(
              value: entity,
              child: Text(
                '${entity.name}, SN:${entity.deviceId} ${entity.description}',
                style: const TextStyle(overflow: TextOverflow.ellipsis),
              )));
        }

        total = pRes.body!.total;
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
    loading = false;
    return Tuple2(items, total);
  }

  Future _load() async {
    if (widget.selectedItem?.isEmpty ?? true) {
      return;
    }
    try {
      var eRes = await TwinnedSession.instance.twin.getDevice(
        apikey: TwinnedSession.instance.authToken,
        deviceId: widget.selectedItem,
      );
      if (eRes != null && eRes.body != null) {
        setState(() {
          _selectedItem = eRes.body!.entity;
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
