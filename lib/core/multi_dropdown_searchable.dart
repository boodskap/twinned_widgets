import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:uuid/uuid.dart';

typedef OnItemsSelected<T> = void Function(List<T> items);
typedef ItemSearchFunc<T> = Future<List<T>> Function(String search, int page);
typedef ItemLabelFunc<T> = Widget Function(T item);
typedef ItemIdFunc<T> = String Function(T item);

class MultiDropdownSearchable<T> extends StatefulWidget {
  final bool allowDuplicates;
  final String hint;
  final String searchHint;
  final List<T> selectedItems;
  final OnItemsSelected onItemsSelected;
  final ItemSearchFunc itemSearchFunc;
  final ItemLabelFunc itemLabelFunc;
  final ItemIdFunc itemIdFunc;
  final InputDecoration? searchInputDecoration;
  final Color? menuBackgroundColor;
  final EdgeInsets? dropDownDialogPadding;
  final TextStyle style;
  final bool isExpanded;

  const MultiDropdownSearchable({
    super.key,
    required this.allowDuplicates,
    required this.hint,
    required this.searchHint,
    required this.selectedItems,
    required this.onItemsSelected,
    required this.itemSearchFunc,
    required this.itemLabelFunc,
    required this.itemIdFunc,
    this.isExpanded = true,
    this.searchInputDecoration,
    this.menuBackgroundColor,
    this.dropDownDialogPadding = const EdgeInsets.fromLTRB(250, 50, 250, 50),
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<MultiDropdownSearchable> createState() =>
      _MultiDropdownSearchableState<T>();
}

class _MultiDropdownSearchableState<T>
    extends BaseState<MultiDropdownSearchable> {
  final Map<String, List<T>> _selectedItems = <String, List<T>>{};
  final Map<String, DropdownMenuItem<T>> _items =
      <String, DropdownMenuItem<T>>{};
  T? _selectedItem;

  @override
  void initState() {
    for (T item in widget.selectedItems) {
      String id = widget.itemIdFunc(item);
      if (_selectedItems.containsKey(id)) {
        _selectedItems[id]!.add(item);
      } else {
        _selectedItems[id] = [item];
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Chip> chips = [];

    _selectedItems.forEach((k, values) {
      for (int i = 0; i < values.length; i++) {
        T v = values[i];
        chips.add(Chip(
          label: widget.itemLabelFunc(v),
          onDeleted: () {
            setState(() {
              values.removeAt(i);
              if (values.isEmpty) {
                _selectedItems.remove(k);
              }
            });
            widget.onItemsSelected(values);
          },
        ));
      }
    });

    return Column(
      children: [
        SearchChoices<T>.single(
          value: _selectedItem,
          hint: widget.hint,
          searchHint: widget.searchHint,
          style: widget.style,
          dropDownDialogPadding: widget.dropDownDialogPadding,
          searchInputDecoration: widget.searchInputDecoration,
          menuBackgroundColor: widget.menuBackgroundColor,
          isExpanded: widget.isExpanded,
          futureSearchFn: (String? keyword, String? orderBy, bool? orderAsc,
              List<Tuple2<String, String>>? filters, int? pageNb) async {
            pageNb = pageNb ?? 1;
            --pageNb;
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
          selectedValueWidgetFn: (value) {
            return widget.itemLabelFunc(value);
          },
          onChanged: (selected) {
            setState(() {
              _selectedItem = selected;
            });
            String id = widget.itemIdFunc(selected);

            if (!_selectedItems.containsKey(id)) {
              _selectedItems[id] = [selected];
            } else if (widget.allowDuplicates) {
              _selectedItems[id]!.add(selected);
            }

            List<T> items = [];
            _selectedItems.forEach((k, v) {
              items.addAll(v);
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
