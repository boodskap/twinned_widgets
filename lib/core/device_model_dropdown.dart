import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/twinned_session.dart';

typedef OnDeviceModelSelected = void Function(twin.DeviceModel? deviceModel);

class DeviceModelDropdown extends StatefulWidget {
  final String? selectedDeviceModel;
  final OnDeviceModelSelected onDeviceModelSelected;

  const DeviceModelDropdown(
      {super.key,
      required this.selectedDeviceModel,
      required this.onDeviceModelSelected});

  @override
  State<DeviceModelDropdown> createState() => _DeviceModelDropdownState();
}

class _DeviceModelDropdownState extends BaseState<DeviceModelDropdown> {
  twin.DeviceModel? _selectedDeviceModel;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.DeviceModel>.single(
      value: _selectedDeviceModel,
      hint: 'Select One',
      searchHint: 'Select One',
      isExpanded: true,
      futureSearchFn: (String? keyword, String? orderBy, bool? orderAsc,
          List<Tuple2<String, String>>? filters, int? pageNb) async {
        var result = await _search(search: keyword ?? '*', page: pageNb);
        return result;
      },
      dialogBox: true,
      dropDownDialogPadding: const EdgeInsets.fromLTRB(250, 50, 250, 50),
      selectedValueWidgetFn: (value) {
        twin.DeviceModel entity = value;
        return Text(
            '${entity.name} ${entity.description} (${entity.parameters.length} parameters)');
      },
      onChanged: (selected) {
        setState(() {
          _selectedDeviceModel = selected;
        });
        widget.onDeviceModelSelected(_selectedDeviceModel);
      },
    );
  }

  Future<Tuple2<List<DropdownMenuItem<twin.DeviceModel>>, int>> _search(
      {String search = "*", int? page = 0}) async {
    if (loading) return Tuple2([], 0);
    loading = true;
    List<DropdownMenuItem<twin.DeviceModel>> items = [];
    int total = 0;
    try {
      var pRes = await TwinnedSession.instance.twin.searchDeviceModels(
          apikey: TwinnedSession.instance.authToken,
          body: twin.SearchReq(search: search, page: page ?? 0, size: 25));
      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.selectedDeviceModel) {
            _selectedDeviceModel = entity;
          }
          items.add(DropdownMenuItem<twin.DeviceModel>(
              value: entity, child: Text(entity.name)));
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
    if (loading) return;
    loading = true;
    if (null == widget.selectedDeviceModel ||
        widget.selectedDeviceModel!.isEmpty) return;
    await execute(() async {
      var eRes = await TwinnedSession.instance.twin.getDeviceModel(
          apikey: TwinnedSession.instance.authToken,
          modelId: widget.selectedDeviceModel);
      if (validateResponse(eRes, shouldAlert: false)) {
        refresh(sync: () {
          _selectedDeviceModel = eRes.body!.entity;
        });
      }
    });
    loading = false;
  }

  @override
  void setup() {
    _load();
  }
}
