import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twin_commons/core/twinned_session.dart';

typedef OnAssetModelSelected = void Function(twin.AssetModel? assetModel);

class AssetModelDropdown extends StatefulWidget {
  final String? selectedItem;
  final OnAssetModelSelected onAssetModelSelected;
  final TextStyle style;

  const AssetModelDropdown({
    super.key,
    required this.selectedItem,
    required this.onAssetModelSelected,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<AssetModelDropdown> createState() => _AssetModelDropdownState();
}

class _AssetModelDropdownState extends BaseState<AssetModelDropdown> {
  twin.AssetModel? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.AssetModel>.single(
      value: _selectedItem,
      hint: 'Select Asset Model',
      searchHint: 'Select Asset Model',
      style: widget.style,
      searchInputDecoration: InputDecoration(
        hintStyle: widget.style,
        errorStyle: widget.style,
        labelStyle: widget.style,
      ),
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
        twin.AssetModel entity = value;
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
        widget.onAssetModelSelected(_selectedItem);
      },
    );
  }

  Future<Tuple2<List<DropdownMenuItem<twin.AssetModel>>, int>> _search(
      {String search = "*", int? page = 0}) async {
    if (loading) return Tuple2([], 0);
    loading = true;
    List<DropdownMenuItem<twin.AssetModel>> items = [];
    int total = 0;
    try {
      var pRes = await TwinnedSession.instance.twin.searchAssetModels(
          apikey: TwinnedSession.instance.authToken,
          body: twin.SearchReq(search: search, page: page ?? 0, size: 25));
      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.selectedItem) {
            _selectedItem = entity;
          }
          items.add(DropdownMenuItem<twin.AssetModel>(
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
      var eRes = await TwinnedSession.instance.twin.getAssetModel(
        apikey: TwinnedSession.instance.authToken,
        assetModelId: widget.selectedItem,
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
