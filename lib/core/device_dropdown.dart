import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twin_commons/core/twinned_session.dart';

typedef OnDeviceSelected = void Function(twin.Device? device);

class DeviceDropdown extends StatefulWidget {
  final String? selectedItem;
  final OnDeviceSelected onDeviceSelected;
  final String hint;
  final String searchHint;
  final InputDecoration? searchInputDecoration;
  final Color? menuBackgroundColor;
  final EdgeInsets? dropDownDialogPadding;
  final TextStyle style;
  final bool isExpanded;
  final bool isCollapse;

  const DeviceDropdown({
    super.key,
    required this.selectedItem,
    required this.onDeviceSelected,
    this.hint = 'Select a Device',
    this.searchHint = 'Search devices',
    this.isExpanded = true,
    this.isCollapse = false,
    this.menuBackgroundColor,
    this.searchInputDecoration = const InputDecoration(
      hintStyle: TextStyle(overflow: TextOverflow.ellipsis),
      errorStyle: TextStyle(overflow: TextOverflow.ellipsis),
      labelStyle: TextStyle(overflow: TextOverflow.ellipsis),
    ),
    this.dropDownDialogPadding,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<DeviceDropdown> createState() => _DeviceDropdownState();
}

class _DeviceDropdownState extends BaseState<DeviceDropdown> {
  twin.Device? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.Device>.single(
      value: _selectedItem,
      hint: widget.isCollapse ? '' : widget.hint,
      searchHint: widget.isCollapse ? '' : widget.searchHint,
      style: widget.style,
      dropDownDialogPadding: widget.dropDownDialogPadding,
      searchInputDecoration: widget.searchInputDecoration,
      menuBackgroundColor: widget.menuBackgroundColor,
      isExpanded: widget.isExpanded,
      underline: widget.isCollapse
          ? Container(
              height: 0,
            )
          : Container(
              height: 1,
              color: const Color(0xFFBDBDBD),
            ),
      futureSearchFn: (String? keyword, String? orderBy, bool? orderAsc,
          List<Tuple2<String, String>>? filters, int? pageNb) async {
        pageNb = pageNb ?? 1;
        --pageNb;
        var result = await _search(search: keyword ?? '*', page: pageNb);
        return result;
      },
      selectedValueWidgetFn: (value) {
        twin.Device entity = value;
        return widget.isCollapse
            ? Container()
            : Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: 32,
                        height: 32,
                        child: (entity.images?.isNotEmpty ?? false)
                            ? TwinImageHelper.getDomainImage(
                                entity.images!.first)
                            : const Icon(Icons.image)),
                  ),
                  divider(horizontal: true),
                  Text(
                    entity.name,
                    style: widget.style,
                  ),
                ],
              );
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
