import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twin_commons/core/twinned_session.dart';

typedef OnDashboardScreenSelected = void Function(twin.DashboardScreen? device);

class DashboardScreenDropdown extends StatefulWidget {
  final String? selectedItem;
  final OnDashboardScreenSelected onDashboardScreenSelected;
  final TextStyle style;

  const DashboardScreenDropdown({
    super.key,
    required this.selectedItem,
    required this.onDashboardScreenSelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<DashboardScreenDropdown> createState() =>
      _DashboardScreenDropdownState();
}

class _DashboardScreenDropdownState extends BaseState<DashboardScreenDropdown> {
  twin.DashboardScreen? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.DashboardScreen>.single(
      value: _selectedItem,
      hint: 'Select Screen',
      searchHint: 'Select Screen',
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
      selectedValueWidgetFn: (twin.DashboardScreen? value) {
        return Text(
          value?.name ?? '',
          style: widget.style,
        );
      },
      onChanged: (selected) {
        setState(() {
          _selectedItem = selected;
        });
        widget.onDashboardScreenSelected(_selectedItem);
      },
    );
  }

  Future<Tuple2<List<DropdownMenuItem<twin.DashboardScreen>>, int>> _search(
      {String search = "*", int? page = 0}) async {
    if (loading) return Tuple2([], 0);
    loading = true;
    List<DropdownMenuItem<twin.DashboardScreen>> items = [];
    int total = 0;

    try {
      var pRes = await TwinnedSession.instance.twin.searchDashboardScreens(
          apikey: TwinnedSession.instance.authToken,
          body: twin.SearchReq(search: search, page: page ?? 0, size: 25));
      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.selectedItem) {
            _selectedItem = entity;
          }
          items.add(DropdownMenuItem<twin.DashboardScreen>(
              value: entity,
              child: Text(
                entity.name,
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
      var eRes = await TwinnedSession.instance.twin.getDashboardScreen(
        apikey: TwinnedSession.instance.authToken,
        screenId: widget.selectedItem,
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
