import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/twinned_session.dart';

typedef OnAssetSelected = void Function(twin.Asset? asset);

class AssetDropdown extends StatefulWidget {
  final String? selectedAsset;
  final OnAssetSelected onAssetSelected;

  const AssetDropdown(
      {super.key, required this.selectedAsset, required this.onAssetSelected});

  @override
  State<AssetDropdown> createState() => _AssetDropdownState();
}

class _AssetDropdownState extends BaseState<AssetDropdown> {
  twin.Asset? _selectedAsset;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.Asset>.single(
      value: _selectedAsset,
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
        twin.Asset entity = value;
        return Text(
            '${entity.name} ${entity.description} (${entity.devices?.length ?? 0} devices)');
      },
      onChanged: (selected) {
        setState(() {
          _selectedAsset = selected;
        });
        widget.onAssetSelected(_selectedAsset);
      },
    );
  }

  Future<Tuple2<List<DropdownMenuItem<twin.Asset>>, int>> _search(
      {String search = "*", int? page = 0}) async {
    if (loading) return Tuple2([], 0);
    loading = true;
    List<DropdownMenuItem<twin.Asset>> items = [];
    int total = 0;
    try {
      var pRes = await TwinnedSession.instance.twin.searchAssets(
          apikey: TwinnedSession.instance.authToken,
          body: twin.SearchReq(search: search, page: page ?? 0, size: 25));
      if (validateResponse(pRes)) {
        for (var entity in pRes.body!.values!) {
          if (entity.id == widget.selectedAsset) {
            _selectedAsset = entity;
          }
          items.add(DropdownMenuItem<twin.Asset>(
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
    if (null == widget.selectedAsset || widget.selectedAsset!.isEmpty) return;
    await execute(() async {
      var eRes = await TwinnedSession.instance.twin.getAsset(
          apikey: TwinnedSession.instance.authToken,
          assetId: widget.selectedAsset);
      if (validateResponse(eRes, shouldAlert: false)) {
        refresh(sync: () {
          _selectedAsset = eRes.body!.entity;
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
