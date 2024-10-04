import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:search_choices/search_choices.dart';
import 'package:google_fonts/google_fonts.dart';

typedef OnFontFamilySelected = void Function(String? fontFamily);

class GoogleFontsDropdown extends StatefulWidget {
  final String? selectedItem;
  final OnFontFamilySelected onFontFamilySelected;
  final String hint;
  final String searchHint;
  final InputDecoration? searchInputDecoration;
  final Color? menuBackgroundColor;
  final EdgeInsets? dropDownDialogPadding;
  final TextStyle style;
  final bool isExpanded;

  const GoogleFontsDropdown({
    super.key,
    required this.selectedItem,
    required this.onFontFamilySelected,
    this.hint = 'Select a Font',
    this.searchHint = 'Search fonts',
    this.isExpanded = true,
    this.menuBackgroundColor,
    this.searchInputDecoration = const InputDecoration(
      hintStyle: TextStyle(overflow: TextOverflow.ellipsis),
      errorStyle: TextStyle(overflow: TextOverflow.ellipsis),
      labelStyle: TextStyle(overflow: TextOverflow.ellipsis),
    ),
    this.dropDownDialogPadding,
    this.style = const TextStyle(overflow: TextOverflow.ellipsis),
  });

  @override
  State<GoogleFontsDropdown> createState() => GoogleFontsDropdownState();
}

class GoogleFontsDropdownState extends BaseState<GoogleFontsDropdown> {
  static List<String> allFonts = [];

  String? _selectedItem;
  List<DropdownMenuItem<String>> items = [];

  @override
  Widget build(BuildContext context) {
    return SearchChoices<String>.single(
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
        var result = await _search(search: keyword ?? '*', page: pageNb);
        return result;
      },
      selectedValueWidgetFn: (value) {
        String entity = value;
        return Text(
          entity,
          style: GoogleFonts.getFont(entity),
        );
      },
      onChanged: (selected) {
        setState(() {
          _selectedItem = selected;
        });
        widget.onFontFamilySelected(_selectedItem);
      },
    );
  }

  Future<Tuple2<List<DropdownMenuItem<String>>, int>> _search(
      {required String search, int? page = 0}) async {
    if (loading) return Tuple2([], 0);
    loading = true;

    items.clear();

    try {
      bool addedSelectedItem = false;

      for (String fontFamily in allFonts) {
        if (fontFamily.toLowerCase().contains(search.toLowerCase())) {
          items.add(DropdownMenuItem<String>(
            value: fontFamily,
            child: Text(
              fontFamily,
              style: GoogleFonts.getFont(fontFamily),
            ),
          ));
        }

        if (items.length >= 25) break;
      }
      if (null != widget.selectedItem &&
          !addedSelectedItem &&
          allFonts.contains(widget.selectedItem)) {
        items.add(DropdownMenuItem<String>(
          value: widget.selectedItem,
          child: Text(
            widget.selectedItem!,
            style: GoogleFonts.getFont(widget.selectedItem!),
          ),
        ));
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }

    loading = false;

    return Tuple2(items, allFonts.length);
  }

  void applyFont(String fontFamily) {
    debugPrint('applying font');
    for (var f in items) {
      if (f.value == fontFamily) return;
    }
    setState(() {
      debugPrint('refreshing font');
      _selectedItem = fontFamily;
    });
  }

  Future _load() async {
    if (allFonts.isNotEmpty) return;
    try {
      allFonts.addAll(GoogleFonts.asMap().keys.toList());
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  @override
  void setup() {
    _load();
  }
}
