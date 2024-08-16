import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/multi_dropdown_searchable.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:uuid/uuid.dart';

typedef OnClientsSelected = void Function(List<twin.Client> items);

class MultiClientDropdown extends StatefulWidget {
  final List<String> selectedItems;
  final OnClientsSelected onClientsSelected;
  final bool allowDuplicates;
  final TextStyle style;

  const MultiClientDropdown({
    super.key,
    required this.selectedItems,
    required this.onClientsSelected,
    required this.allowDuplicates,
    this.style = const TextStyle(),
  });

  @override
  State<MultiClientDropdown> createState() => _MultiClientDropdownState();
}

class _MultiClientDropdownState extends BaseState<MultiClientDropdown> {
  final List<twin.Client> _selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return MultiDropdownSearchable<twin.Client>(
        key: Key(Uuid().v4()),
        allowDuplicates: widget.allowDuplicates,
        searchHint: 'Select Clients',
        selectedItems: _selectedItems,
        onItemsSelected: (selectedItems) {
          widget.onClientsSelected(selectedItems as List<twin.Client>);
        },
        itemSearchFunc: _search,
        itemLabelFunc: (value) {
          twin.Client entity = value;
          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    width: 64,
                    height: 48,
                    child: (entity.icon?.isNotEmpty ?? false)
                        ? TwinImageHelper.getDomainImage(entity.icon!)
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

  Future<List<twin.Client>> _search(String keyword, int page) async {
    List<twin.Client> items = [];

    try {
      var pRes = await TwinnedSession.instance.twin.searchClients(
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
    if (widget.selectedItems.isEmpty) {
      return;
    }
    try {
      var eRes = await TwinnedSession.instance.twin.getClients(
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
