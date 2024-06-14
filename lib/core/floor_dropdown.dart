import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/twinned_session.dart';

typedef OnFloorSelected = void Function(twin.Floor? floor);

class FloorDropdown extends StatefulWidget {
  final String? selectedItem;
  final String? selectedPremise;
  final String? selectedFacility;
  final OnFloorSelected onFloorSelected;

  const FloorDropdown(
      {super.key,
      required this.selectedItem,
      required this.selectedPremise,
      required this.selectedFacility,
      required this.onFloorSelected});

  @override
  State<FloorDropdown> createState() => _FloorDropdownState();
}

class _FloorDropdownState extends BaseState<FloorDropdown> {
  twin.Floor? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.Floor>.single(
      value: _selectedItem,
      hint: 'Select Floor',
      searchHint: 'Select Floor',
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
        twin.Floor entity = value;
        return Text('${entity.name} ${entity.description}');
      },
      onChanged: (selected) {
        setState(() {
          _selectedItem = selected;
        });
        widget.onFloorSelected(_selectedItem);
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
          premiseId: widget.selectedPremise,
          facilityId: widget.selectedFacility,
          body: twin.SearchReq(search: search, page: page ?? 0, size: 25));
      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.selectedItem) {
            _selectedItem = entity;
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
    if (widget.selectedItem?.isEmpty ?? true) {
      return;
    }
    try {
      var eRes = await TwinnedSession.instance.twin.getFloor(
        apikey: TwinnedSession.instance.authToken,
        floorId: widget.selectedItem,
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
