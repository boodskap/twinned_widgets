import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/twinned_session.dart';

typedef OnItemsSelected<T> = void Function(List<T> items);
typedef ItemSearchFunc<T> = Future<List<T>> Function(String search, int page);
typedef ItemLabelFunc<T> = Widget Function(T item);
typedef ItemIdFunc<T> = String Function(T item);

class MultiDropdownSearchable<T> extends StatefulWidget {
  final List<T> selectedItems;
  final OnItemsSelected onItemsSelected;
  final ItemSearchFunc itemSearchFunc;
  final ItemLabelFunc itemLabelFunc;
  final ItemIdFunc itemIdFunc;

  const MultiDropdownSearchable(
      {super.key,
      required this.selectedItems,
      required this.onItemsSelected,
      required this.itemSearchFunc,
      required this.itemLabelFunc,
      required this.itemIdFunc});

  @override
  State<MultiDropdownSearchable> createState() =>
      _MultiDropdownSearchableState<T>();
}

class _MultiDropdownSearchableState<T>
    extends BaseState<MultiDropdownSearchable> {
  final Map<String, T> _selectedItems = <String, T>{};
  final Map<String, DropdownMenuItem<T>> _items =
      <String, DropdownMenuItem<T>>{};
  T? _selectedItem;

  @override
  void initState() {
    for (var item in widget.selectedItems) {
      String id = widget.itemIdFunc(item);
      _selectedItems[id] = item;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Chip> chips = [];

    _selectedItems.forEach((k, v) {
      chips.add(Chip(
        label: widget.itemLabelFunc(v),
        onDeleted: () {
          setState(() {
            _selectedItems.remove(k);
          });
          List<dynamic> items = [];
          _selectedItems.forEach((k, v) {
            items.add(v);
          });
          widget.onItemsSelected(items);
        },
      ));
    });

    return Column(
      children: [
        SearchChoices<T>.single(
          value: _selectedItem,
          hint: 'Select One',
          searchHint: 'Select One',
          isExpanded: true,
          futureSearchFn: (String? keyword, String? orderBy, bool? orderAsc,
              List<Tuple2<String, String>>? filters, int? pageNb) async {
            _items.clear();
            var result =
                await widget.itemSearchFunc(keyword ?? '*', pageNb ?? 0);

            for (var item in result) {
              String id = widget.itemIdFunc(item);
              _items[id] = DropdownMenuItem<T>(
                  value: item, child: widget.itemLabelFunc(item));
            }

            List<DropdownMenuItem<T>> list = [];

            for (var value in _items.values) {
              list.add(value);
            }

            return Tuple2(list, _items.length);
            ;
          },
          dialogBox: true,
          dropDownDialogPadding: const EdgeInsets.fromLTRB(250, 50, 250, 50),
          selectedValueWidgetFn: (value) {
            return widget.itemLabelFunc(value);
          },
          onChanged: (selected) {
            setState(() {
              _selectedItem = selected;
            });
            String id = widget.itemIdFunc(selected);

            if (!_selectedItems.containsKey(id)) {
              _selectedItems[id] = selected;
            }
            List<dynamic> items = [];
            _selectedItems.forEach((k, v) {
              items.add(v);
            });
            widget.onItemsSelected(items);
          },
        ),
        Wrap(
          spacing: 5.0,
          children: chips,
        ),
      ],
    );
  }

  @override
  void setup() {}
}
