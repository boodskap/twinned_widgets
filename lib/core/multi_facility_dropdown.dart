import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:uuid/uuid.dart';

typedef OnFacilitiesSelected = void Function(List<twin.Facility> item);

class MultiFacilityDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnFacilitiesSelected onFacilitiesSelected;
  final bool allowDuplicates;
  final TextStyle style;

  const MultiFacilityDropdown({
    super.key,
    required this.selectedItems,
    required this.onFacilitiesSelected,
    required this.allowDuplicates,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<MultiFacilityDropdown> createState() => _MultiFacilityDropdownState();
}

class _MultiFacilityDropdownState extends BaseState<MultiFacilityDropdown> {
  final List<twin.Facility> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.Facility>(
        key: Key(Uuid().v4()),
        allowDuplicates: widget.allowDuplicates,
        searchHint: 'Select Facilities',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onFacilitiesSelected(selectedItems as List<twin.Facility>);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (value) {
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
        itemIdFunc: (item) {
          return item.id;
        });
  }

  Future<List<twin.Facility>> _search(String keyword, int page) async {
    List<twin.Facility> items = [];

    try {
      var pRes = await TwinnedSession.instance.twin.searchFacilities(
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
    debugPrint('SELECTED FACILITIES: ${widget.selectedItems}');
    if (widget.selectedItems.isEmpty) {
      return;
    }
    try {
      var eRes = await TwinnedSession.instance.twin.getFacilities(
        apikey: TwinnedSession.instance.authToken,
        body: twin.GetReq(ids: widget.selectedItems),
      );
      if (eRes != null && eRes.body != null) {
        setState(() {
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
