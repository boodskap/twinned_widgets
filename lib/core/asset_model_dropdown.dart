import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/twinned_session.dart';

typedef OnAssetModelSelected = void Function(twin.AssetModel? assetModel);

class AssetModelDropdown extends StatefulWidget {
  final String? selectedAssetModel;
  final OnAssetModelSelected onAssetModelSelected;

  const AssetModelDropdown(
      {super.key,
      required this.selectedAssetModel,
      required this.onAssetModelSelected});

  @override
  State<AssetModelDropdown> createState() => _AssetModelDropdownState();
}

class _AssetModelDropdownState extends BaseState<AssetModelDropdown> {
  twin.AssetModel? _selectedAssetModel;

  @override
  Widget build(BuildContext context) {
    return SearchChoices<twin.AssetModel>.single(
      value: _selectedAssetModel,
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
        twin.AssetModel entity = value;
        return Text(
            '${entity.name} ${entity.description} (${entity.allowedDeviceModels?.length ?? 0} device models)');
      },
      onChanged: (selected) {
        setState(() {
          _selectedAssetModel = selected;
        });
        widget.onAssetModelSelected(_selectedAssetModel);
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
          if (entity.id == widget.selectedAssetModel) {
            _selectedAssetModel = entity;
          }
          items.add(DropdownMenuItem<twin.AssetModel>(
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
    if (null == widget.selectedAssetModel || widget.selectedAssetModel!.isEmpty)
      return;
    await execute(() async {
      var eRes = await TwinnedSession.instance.twin.getAssetModel(
          apikey: TwinnedSession.instance.authToken,
          assetModelId: widget.selectedAssetModel);
      if (validateResponse(eRes, shouldAlert: false)) {
        refresh(sync: () {
          _selectedAssetModel = eRes.body!.entity;
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
