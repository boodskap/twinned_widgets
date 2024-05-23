import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/twinned_session.dart';

typedef OnFloorSelected = void Function(twin.Floor? floor);

class FloorDropdown extends StatefulWidget {
  final String? selectedFloor;
  final OnFloorSelected onFloorSelected;

  const FloorDropdown(
      {super.key, this.selectedFloor, required this.onFloorSelected});

  @override
  State<FloorDropdown> createState() => _FloorDropdownState();
}

class _FloorDropdownState extends BaseState<FloorDropdown> {
  twin.Floor? _selectedFloor;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.Floor>.single(
      value: _selectedFloor,
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
        twin.Premise entity = value;
        return Text('${entity.name} ${entity.description}');
      },
      onChanged: (selected) {
        setState(() {
          _selectedFloor = selected;
        });
        widget.onFloorSelected(_selectedFloor);
      },
    );
  }

  Future<Tuple2<List<DropdownMenuItem<twin.Floor>>, int>> _search(
      {String search = "*", int? page = 0}) async {
    if (loading) return Tuple2([], 0);
    loading = true;
    List<DropdownMenuItem<twin.Floor>> items = [];
    int total = 0;
    try {
      var pRes = await TwinnedSession.instance.twin.searchFloors(
          apikey: TwinnedSession.instance.authToken,
          body: twin.SearchReq(search: search, page: page ?? 0, size: 25));
      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.selectedFloor) {
            _selectedFloor = entity;
          }
          items.add(DropdownMenuItem<twin.Floor>(
              value: entity,
              child: Text(
                '${entity.name} ${entity.description}',
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
    if (loading) return;
    loading = true;
    if (null == widget.selectedFloor || widget.selectedFloor!.isEmpty) return;
    await execute(() async {
      var eRes = await TwinnedSession.instance.twin.getFloor(
          apikey: TwinnedSession.instance.authToken,
          floorId: widget.selectedFloor);
      if (validateResponse(eRes, shouldAlert: false)) {
        refresh(sync: () {
          _selectedFloor = eRes.body!.entity;
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