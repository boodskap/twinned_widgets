import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twin_commons/core/twinned_session.dart';

typedef OnScrappingTableSelected = void Function(
    twin.ScrappingTable? scrappingTable);

class ScrappingTableDropdown extends StatefulWidget {
  final String? selectedItem;
  final List<String>? filterTags;
  final OnScrappingTableSelected onScrappingTableSelected;
  final TextStyle style;

  const ScrappingTableDropdown({
    super.key,
    required this.selectedItem,
    required this.onScrappingTableSelected,
    this.filterTags,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<ScrappingTableDropdown> createState() => _ScrappingTableDropdownState();
}

class _ScrappingTableDropdownState extends BaseState<ScrappingTableDropdown> {
  twin.ScrappingTable? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.ScrappingTable>.single(
      value: _selectedItem,
      hint: 'Select Scrapping Table',
      searchHint: 'Search Scrapping Tables',
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
        twin.ScrappingTable entity = value;
        return Text(
          '${entity.name} ${entity.description} (${entity.attributes.length} parameters)',
          style: widget.style,
        );
      },
      onChanged: (selected) {
        setState(() {
          _selectedItem = selected;
        });
        widget.onScrappingTableSelected(_selectedItem);
      },
    );
  }

  Future<Tuple2<List<DropdownMenuItem<twin.ScrappingTable>>, int>> _search(
      {String search = "*", int? page = 0}) async {
    if (loading) return Tuple2([], 0);
    loading = true;
    List<DropdownMenuItem<twin.ScrappingTable>> items = [];
    int total = 0;
    try {
      var pRes = await TwinnedSession.instance.twin.queryEqlScrappingTable(
        apikey: TwinnedSession.instance.authToken,
        body: twin.EqlSearch(
          source: [],
          mustConditions: [
            {
              "query_string": {
                "query": '*$search*',
                "fields": ["name", "description"]
              }
            },
            if (null != widget.filterTags && widget.filterTags!.isNotEmpty)
              {
                "terms": {"tags.keyword": widget.filterTags}
              },
          ],
          sort: {"namek": "asc"},
          page: 0,
          size: 25,
        ),
      );

      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.selectedItem) {
            _selectedItem = entity;
          }
          items.add(DropdownMenuItem<twin.ScrappingTable>(
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
    if (widget.selectedItem?.isEmpty ?? true) {
      return;
    }
    try {
      var eRes = await TwinnedSession.instance.twin.getScrappingTable(
        apikey: TwinnedSession.instance.authToken,
        scrappingTableId: widget.selectedItem,
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
