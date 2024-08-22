import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twin_commons/core/twinned_session.dart';

typedef OnFacilitySelected = void Function(twin.Facility? facility);

class FacilityDropdown extends StatefulWidget {
  final String? selectedItem;
  final String? selectedPremise;
  final OnFacilitySelected onFacilitySelected;
  final TextStyle style;

  const FacilityDropdown({
    super.key,
    required this.selectedItem,
    required this.selectedPremise,
    required this.onFacilitySelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<FacilityDropdown> createState() => _FacilityDropdownState();
}

class _FacilityDropdownState extends BaseState<FacilityDropdown> {
  twin.Facility? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.Facility>.single(
      value: _selectedItem,
      hint: 'Select Facility',
      searchHint: 'Select Facility',
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
        twin.Facility entity = value;
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
        widget.onFacilitySelected(_selectedItem);
      },
    );
  }

  Future<Tuple2<List<DropdownMenuItem<twin.Facility>>, int>> _search(
      {String search = "*", int? page = 0}) async {
    if (loading) return Tuple2([], 0);
    loading = true;
    List<DropdownMenuItem<twin.Facility>> items = [];
    int total = 0;
    try {
      var pRes = await TwinnedSession.instance.twin.searchFacilities(
          apikey: TwinnedSession.instance.authToken,
          premiseId: widget.selectedPremise,
          body: twin.SearchReq(search: search, page: page ?? 0, size: 25));
      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.selectedItem) {
            _selectedItem = entity;
          }
          items.add(DropdownMenuItem<twin.Facility>(
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
      var eRes = await TwinnedSession.instance.twin.getFacility(
        apikey: TwinnedSession.instance.authToken,
        facilityId: widget.selectedItem,
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
