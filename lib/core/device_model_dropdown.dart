import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twin_commons/core/twinned_session.dart';

typedef OnDeviceModelSelected = void Function(twin.DeviceModel? deviceModel);

class DeviceModelDropdown extends StatefulWidget {
  final String? selectedItem;
  final OnDeviceModelSelected onDeviceModelSelected;
  final TextStyle style;

  const DeviceModelDropdown({
    super.key,
    required this.selectedItem,
    required this.onDeviceModelSelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<DeviceModelDropdown> createState() => _DeviceModelDropdownState();
}

class _DeviceModelDropdownState extends BaseState<DeviceModelDropdown> {
  twin.DeviceModel? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.DeviceModel>.single(
      value: _selectedItem,
      hint: 'Select Device Model',
      searchHint: 'Select Device Model',
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
        twin.DeviceModel entity = value;
        return Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  width: 32,
                  height: 32,
                  child: (entity.images?.isNotEmpty ?? false)
                      ? TwinImageHelper.getDomainImage(entity.images!.first)
                      : const Icon(Icons.image)),
            ),
            divider(horizontal: true),
            Text(
              '${entity.name}, ${entity.description}',
              style: widget.style,
            ),
          ],
        );
      },
      onChanged: (selected) {
        setState(() {
          _selectedItem = selected;
        });
        widget.onDeviceModelSelected(_selectedItem);
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
          if (entity.id == widget.selectedItem) {
            _selectedItem = entity;
          }
          items.add(DropdownMenuItem<twin.DeviceModel>(
              value: entity,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: 64,
                        height: 48,
                        child: (entity.images?.isNotEmpty ?? false)
                            ? TwinImageHelper.getDomainImage(
                                entity.images!.first)
                            : const Icon(Icons.image)),
                  ),
                  divider(horizontal: true),
                  Text(
                    '${entity.name}, ${entity.description}',
                    style: widget.style,
                  ),
                ],
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
      var eRes = await TwinnedSession.instance.twin.getDeviceModel(
        apikey: TwinnedSession.instance.authToken,
        modelId: widget.selectedItem,
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
