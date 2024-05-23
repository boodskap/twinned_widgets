import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/twinned_session.dart';

typedef OnPremiseSelected = void Function(twin.Premise? premise);

class PremiseDropdown extends StatefulWidget {
  final String? selectedPremise;
  final OnPremiseSelected onPremiseSelected;

  const PremiseDropdown(
      {super.key,
      required this.selectedPremise,
      required this.onPremiseSelected});

  @override
  State<PremiseDropdown> createState() => _PremiseDropdownState();
}

class _PremiseDropdownState extends BaseState<PremiseDropdown> {
  twin.Premise? _selectedPremise;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.Premise>.single(
      value: _selectedPremise,
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
          _selectedPremise = selected;
        });
        widget.onPremiseSelected(_selectedPremise);
      },
    );
  }

  Future<Tuple2<List<DropdownMenuItem<twin.Premise>>, int>> _search(
      {String search = "*", int? page = 0}) async {
    if (loading) return Tuple2([], 0);
    loading = true;
    List<DropdownMenuItem<twin.Premise>> items = [];
    int total = 0;
    try {
      var pRes = await TwinnedSession.instance.twin.searchPremises(
          apikey: TwinnedSession.instance.authToken,
          body: twin.SearchReq(search: search, page: page ?? 0, size: 25));
      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.selectedPremise) {
            _selectedPremise = entity;
          }
          items.add(DropdownMenuItem<twin.Premise>(
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
    if (null == widget.selectedPremise || widget.selectedPremise!.isEmpty)
      return;
    await execute(() async {
      var eRes = await TwinnedSession.instance.twin.getPremise(
          apikey: TwinnedSession.instance.authToken,
          premiseId: widget.selectedPremise);
      if (validateResponse(eRes, shouldAlert: false)) {
        refresh(sync: () {
          _selectedPremise = eRes.body!.entity;
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
