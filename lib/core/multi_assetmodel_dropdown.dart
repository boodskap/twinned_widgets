import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:uuid/uuid.dart';

typedef OnAssetModelsSelected = void Function(List<twin.AssetModel> item);

class MultiAssetModelDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnAssetModelsSelected onAssetModelsSelected;
  final bool allowDuplicates;
  final TextStyle style;

  const MultiAssetModelDropdown({
    super.key,
    required this.selectedItems,
    required this.onAssetModelsSelected,
    required this.allowDuplicates,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<MultiAssetModelDropdown> createState() =>
      _MultiAssetModelDropdownState();
}

class _MultiAssetModelDropdownState extends BaseState<MultiAssetModelDropdown> {
  final List<twin.AssetModel> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.AssetModel>(
        key: Key(Uuid().v4()),
        allowDuplicates: widget.allowDuplicates,
        hint: 'Select Asset Models',
        searchHint: 'Search asset models',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onAssetModelsSelected(selectedItems as List<twin.AssetModel>);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (value) {
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
        itemIdFunc: (item) {
          return item.id;
        });
  }

  Future<List<twin.AssetModel>> _search(String keyword, int page) async {
    List<twin.AssetModel> items = [];

    try {
      var pRes = await TwinnedSession.instance.twin.searchAssetModels(
        apikey: TwinnedSession.instance.authToken,
        body: twin.SearchReq(search: keyword, page: page, size: 25),
      );
      if (pRes.body != null) {
        items.addAll(pRes.body!.values!);
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
    return items;
  }

  Future<void> _load() async {
    debugPrint('SELECTED ASSET MODELS: ${widget.selectedItems}');
    if (widget.selectedItems.isEmpty) {
      return;
    }
    try {
      var eRes = await TwinnedSession.instance.twin.getAssetModels(
        apikey: TwinnedSession.instance.authToken,
        body: twin.GetReq(ids: widget.selectedItems),
      );
      if (eRes != null && eRes.body != null) {
        setState(() {
          if (!mounted) return;
          _selectedItems.addAll(eRes.body!.values!);
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
