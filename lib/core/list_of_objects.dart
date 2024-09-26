import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_commons/core//busy_indicator.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_widgets/core/google_fonts_dropdown.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_widgets/core/twinned_utils.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/core/definitions.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:twinned_models/twinned_models.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:google_fonts/google_fonts.dart';

enum ObjectType { text, number, decimal, color, font, image }

class ListOfObjectsWidget extends StatefulWidget {
  final Map<String, dynamic> config;
  final String parameter;
  final ObjectType objectType;
  final ValueChangeNotifier? changeNotifier;
  final bool allowDuplicates;
  final int maxTextLines;
  final TextStyle? style;
  const ListOfObjectsWidget(
      {super.key,
      this.style,
      required this.config,
      required this.parameter,
      required this.objectType,
      this.allowDuplicates = true,
      this.maxTextLines = 1,
      this.changeNotifier});

  @override
  State<ListOfObjectsWidget> createState() => _ListOfObjectsWidgetState();
}

class _ListOfObjectsWidgetState extends BaseState<ListOfObjectsWidget> {
  TextEditingController controller = TextEditingController();
  TextEditingController intController = TextEditingController();
  TextEditingController doubleController = TextEditingController();
  GlobalKey<GoogleFontsDropdownState> googleFonts =
      GlobalKey<GoogleFontsDropdownState>();

  String value = '';
  int? intValue;
  double? doubleValue;
  String? fontFamily = 'Open Sans';
  double? fontSize = 12;
  int? fontColor = Colors.black.value;
  bool? fontBold = false;
  bool _editing = false;
  int _editingIndex = -1;
  final List<String> stringValues = [];
  final List<int> intValues = [];
  final List<double> doubleValues = [];
  final List<Map<String, dynamic>> fontValues = [];
  late final TextStyle _defaultStyle;
  @override
  void initState() {
    _defaultStyle = widget.style ??
        GoogleFonts.lato(
          color: Colors.black,
        );

    switch (widget.objectType) {
      case ObjectType.text:
      case ObjectType.image:
        debugPrint(
            '** PARAMETER: ${widget.parameter}, TYPE ${widget.objectType}**');
        List<String> sValues = _toStringList(widget.config[widget.parameter]);
        stringValues.addAll(sValues);
        break;
      case ObjectType.decimal:
        debugPrint(
            '**PARAMETER: ${widget.parameter}, TYPE ${widget.objectType} **');
        List<double> dValues = _toDoubleList(widget.config[widget.parameter]);
        doubleValues.addAll(dValues);
        break;
      case ObjectType.color:
      case ObjectType.number:
        debugPrint(
            '**PARAMETER: ${widget.parameter}, TYPE ${widget.objectType} **');
        List<int> iValues = _toIntList(widget.config[widget.parameter]);
        intValues.addAll(iValues);
        break;
      case ObjectType.font:
        debugPrint(
            '**PARAMETER: ${widget.parameter}, TYPE ${widget.objectType} **');
        List<Map<String, dynamic>> fValues =
            _toMapList(widget.config[widget.parameter]);
        fontValues.addAll(fValues);

        break;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.objectType) {
      case ObjectType.text:
        return _buildTextObject();
      case ObjectType.number:
        return _buildNumberObject();
      case ObjectType.decimal:
        return _buildDoubleObject();
      case ObjectType.color:
        return _buildColorObject();
      case ObjectType.font:
        return _buildFontObject();
      case ObjectType.image:
        return _buildImageObject();
      default:
        return const Placeholder();
    }
  }

  Widget _buildImageObject() {
    List<Widget> children = [];

    for (int i = 0; i < stringValues.length; i++) {
      String imageId = stringValues[i];
      children.add(Chip(
        label: SizedBox(
            width: 48,
            height: 48,
            child: InkWell(
                onDoubleTap: () {
                  _doImageUpload(index: i);
                },
                child: TwinImageHelper.getDomainImage(imageId))),
        onDeleted: () {
          _removeImageValue(i);
        },
      ));
    }

    return SizedBox(
      width: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BusyIndicator(),
          divider(),
          IconButton(
              onPressed: () {
                _doImageUpload();
              },
              icon: const Icon(Icons.upload)),
          divider(),
          if (children.isNotEmpty)
            SizedBox(
              height: 100,
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 5.0,
                  children: children,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addImageValue(String value, {int index = -1}) {
    if (!widget.allowDuplicates && stringValues.contains(value)) {
      return;
    }

    setState(() {
      if (index == -1) {
        stringValues.add(value);
      } else {
        stringValues[index] = value;
      }
    });

    widget.config[widget.parameter] = stringValues;

    if (null != widget.changeNotifier) {
      widget.changeNotifier!();
    }
  }

  void _removeImageValue(int index) {
    setState(() {
      stringValues.removeAt(index);
    });

    widget.config[widget.parameter] = stringValues;

    if (null != widget.changeNotifier) {
      widget.changeNotifier!();
    }
  }

  Widget _buildFontObject() {
    List<Widget> children = [];

    for (int i = 0; i < fontValues.length; i++) {
      FontConfig font = FontConfig.fromJson(fontValues[i]);

      children.add(Chip(
        labelStyle: _defaultStyle,
        label: InkWell(
          onDoubleTap: () {
            setState(() {
              if (_editing) {
                _setEditing();
                fontFamily = 'Open Sans';
                fontSize = 12;
                fontColor = Colors.black.value;
                fontBold = false;
              } else {
                _setEditing(editing: true, editingIndex: i);
                fontFamily = font.fontFamily;
                fontSize = font.fontSize;
                fontColor = font.fontColor;
                fontBold = font.fontBold;
              }
            });
            if (null != googleFonts.currentState) {
              googleFonts.currentState?.applyFont(fontFamily!);
            }
          },
          child: Tooltip(
            message: _editing
                ? 'Double click to cancel edit'
                : 'Double click to edit',
            child: Text(
              font.fontFamily,
              style: TwinUtils.getTextStyle(font, googleFonts: true),
            ),
          ),
        ),
        onDeleted: () {
          _removeFontValue(i);
        },
      ));
    }

    return SizedBox(
      width: 600,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(
                width: 200,
                child: Tooltip(
                  message: 'Choose a font',
                  child: GoogleFontsDropdown(
                      key: googleFonts,
                      selectedItem: fontFamily,
                      onFontFamilySelected: (value) {
                        setState(() {
                          fontFamily = value ?? 'Open Sans';
                        });
                      }),
                ),
              ),
              divider(horizontal: true),
              SizedBox(
                width: 150,
                child: Tooltip(
                  message: 'Select font size',
                  child: SpinBox(
                    textStyle: _defaultStyle,
                    min: 4,
                    max: 100,
                    value: fontSize ?? 12.0,
                    onChanged: (value) {
                      fontSize = value;
                    },
                  ),
                ),
              ),
              divider(horizontal: true),
              Tooltip(
                message: (fontBold ?? false)
                    ? 'Click to make normal'
                    : 'Click to make bold',
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        fontBold = !fontBold!;
                      });
                    },
                    icon: Icon(
                      Icons.format_bold,
                      color: fontBold! ? Colors.black : Colors.black38,
                    )),
              ),
              Tooltip(
                message: 'Choose font color',
                child: IconButton(
                    onPressed: () async {
                      _showColorPickerDialog(Colors.black, font: true);
                    },
                    icon: Icon(
                      Icons.palette,
                      color: Color(fontColor!),
                    )),
              ),
              Tooltip(
                message:
                    _editing ? 'Update this font' : 'Add this font to list',
                child: IconButton(
                    onPressed: !_canAddFont()
                        ? null
                        : () {
                            _addFontValue(index: _editingIndex);
                          },
                    icon: Icon(_editing ? Icons.save : Icons.add)),
              ),
              if (_editing)
                Tooltip(
                  message: 'Clone this font',
                  child: IconButton(
                      onPressed: !_canAddFont()
                          ? null
                          : () {
                              _addFontValue(index: -1);
                            },
                      icon: const Icon(Icons.copy)),
                ),
            ],
          ),
          SizedBox(
            height: 120,
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 5.0,
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setEditing({int editingIndex = -1, bool editing = false}) {
    _editingIndex = editingIndex;
    _editing = editing;
  }

  bool _canAddFont() {
    FontConfig fc = FontConfig(
        fontColor: fontColor!,
        fontSize: fontSize!,
        fontBold: fontBold!,
        fontFamily: fontFamily!);
    Map<String, dynamic> map = fc.toJson();
    return !fontValues.contains(map);
  }

  void _addFontValue({int index = -1}) {
    FontConfig value = FontConfig(
        fontColor: fontColor!,
        fontSize: fontSize!,
        fontBold: fontBold!,
        fontFamily: fontFamily!);

    Map<String, dynamic> map = value.toJson();

    if (!widget.allowDuplicates && fontValues.contains(map)) {
      return;
    }

    setState(() {
      if (index == -1) {
        fontValues.add(map);
      } else {
        fontValues[index] = map;
        _setEditing();
        fontFamily = 'Open Sans';
        fontSize = 12;
        fontColor = Colors.black.value;
        fontBold = false;
      }
    });

    widget.config[widget.parameter] = fontValues;

    if (null != widget.changeNotifier) {
      widget.changeNotifier!();
    }
  }

  void _removeFontValue(int index) {
    setState(() {
      fontValues.removeAt(index);
    });

    widget.config[widget.parameter] = fontValues;

    if (null != widget.changeNotifier) {
      widget.changeNotifier!();
    }
  }

  Widget _buildColorObject() {
    List<Widget> children = [];

    for (int i = 0; i < intValues.length; i++) {
      Color color = Color(intValues[i]);
      children.add(Chip(
        labelStyle: _defaultStyle,
        label: SizedBox(
            width: 70,
            height: 18,
            child: Container(
              color: color,
              child: Text(
                color.toHexString(),
                style:
                    _defaultStyle.copyWith(color: TwinUtils.darken(color, 0.5)),
              ),
            )),
        onDeleted: () {
          _removeColorValue(i);
        },
      ));
    }

    return SizedBox(
      width: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                _showColorPickerDialog(Colors.black);
              },
              icon: const Icon(Icons.palette)),
          divider(),
          if (children.isNotEmpty)
            SizedBox(
              height: 100,
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 5.0,
                  children: children,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addColorValue(Color value, {int index = -1}) {
    if (!widget.allowDuplicates && intValues.contains(value.value)) {
      return;
    }

    setState(() {
      if (index == -1) {
        intValues.add(value.value);
      } else {
        intValues[index] = value.value;
        _setEditing();
      }
    });

    widget.config[widget.parameter] = intValues;

    if (null != widget.changeNotifier) {
      widget.changeNotifier!();
    }
  }

  void _removeColorValue(int index) {
    setState(() {
      intValues.removeAt(index);
    });

    widget.config[widget.parameter] = intValues;

    if (null != widget.changeNotifier) {
      widget.changeNotifier!();
    }
  }

  Widget _buildDoubleObject() {
    List<Widget> children = [];

    for (int i = 0; i < doubleValues.length; i++) {
      children.add(Chip(
        label: InkWell(
            onDoubleTap: () {
              setState(() {
                if (_editing) {
                  _setEditing();
                  doubleController.text = '';
                } else {
                  _setEditing(editing: true, editingIndex: i);
                  doubleController.text = '${doubleValues[i]}';
                }
              });
            },
            child: Text('${doubleValues[i]}')),
        onDeleted: _editing
            ? null
            : () {
                _removeDoubleValue(i);
              },
      ));
    }

    return SizedBox(
      width: 400,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: TextField(
                controller: doubleController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: false, signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
                ],
                onChanged: (value) {
                  if (value == '-') return;
                  setState(() {
                    if (value.isEmpty) {
                      doubleValue = null;
                    } else {
                      doubleValue = double.parse(value);
                    }
                  });
                },
              )),
              divider(horizontal: true),
              IconButton(
                  onPressed: (null == doubleValue ||
                          (!_editing &&
                              !widget.allowDuplicates &&
                              doubleValues.contains(doubleValue!)))
                      ? null
                      : () {
                          _addDoubleValue(doubleValue!, index: _editingIndex);
                        },
                  icon: Icon(_editing ? Icons.save : Icons.add)),
            ],
          ),
          divider(),
          if (children.isNotEmpty)
            SizedBox(
              height: 80,
              child: Wrap(
                spacing: 5.0,
                children: children,
              ),
            )
        ],
      ),
    );
  }

  void _addDoubleValue(double value, {int index = -1}) {
    setState(() {
      if (index == -1) {
        doubleValues.add(value);
      } else {
        doubleValues[index] = value;
        _setEditing();
      }
      doubleController.text = '';
    });

    widget.config[widget.parameter] = doubleValues;

    if (null != widget.changeNotifier) {
      widget.changeNotifier!();
    }
  }

  void _removeDoubleValue(int index) {
    setState(() {
      doubleValues.removeAt(index);
    });

    widget.config[widget.parameter] = doubleValues;

    if (null != widget.changeNotifier) {
      widget.changeNotifier!();
    }
  }

  Future _doImageUpload({int index = -1}) async {
    if (loading) return;
    loading = true;
    await execute(() async {
      twin.ImageFileEntityRes? res = await TwinImageHelper.uploadDomainImage();
      if (null == res) {
        return null;
      }
      if (res?.ok ?? false) {
        if (index == -1) {
          _addImageValue(res!.entity!.id);
        } else {
          _addImageValue(res!.entity!.id, index: index);
        }
      } else {
        alert('Upload Failed', 'Unknown failure');
      }
    });
    loading = false;
  }

  void _showColorPickerDialog(Color? pickerColor, {bool font = false}) {
    Color? pickedColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle:
              _defaultStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
          contentTextStyle: _defaultStyle,
          title: Text('Pick a color',
              style: _defaultStyle.copyWith(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor ?? Colors.transparent,
              onColorChanged: (color) {
                pickedColor = color;
              },
              enableAlpha: true,
              displayThumbColor: true,
              pickerAreaHeightPercent: 0.8,
              hexInputBar: true,
              labelTypes: [],
              labelTextStyle: _defaultStyle,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Done',
                style: _defaultStyle,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (null != pickedColor) {
                  if (font) {
                    setState(() {
                      fontColor = pickedColor!.value;
                    });
                  } else {
                    _addColorValue(pickedColor!, index: _editingIndex);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNumberObject() {
    List<Widget> children = [];

    for (int i = 0; i < intValues.length; i++) {
      children.add(Chip(
        labelStyle: _defaultStyle,
        label: InkWell(
            onDoubleTap: () {
              setState(() {
                if (_editing) {
                  _setEditing();
                  intController.text = '';
                } else {
                  _setEditing(editing: true, editingIndex: i);
                  intController.text = '${intValues[i]}';
                }
              });
            },
            child: Text(
              '${intValues[i]}',
              style: _defaultStyle,
            )),
        onDeleted: () {
          _removeIntValue(i);
        },
      ));
    }

    return SizedBox(
      width: 400,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: TextField(
                style: _defaultStyle,
                controller: intController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintStyle: _defaultStyle,
                    labelStyle: _defaultStyle,
                    errorStyle: _defaultStyle),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: false, signed: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^-?\s*-?[0-9]{1,10}\s*$')),
                ],
                onChanged: (value) {
                  if (value == '-') return;
                  setState(() {
                    if (value.isEmpty) {
                      intValue = null;
                    } else {
                      intValue = int.parse(value);
                    }
                  });
                },
              )),
              divider(horizontal: true),
              IconButton(
                  onPressed: (null == intValue ||
                          (!_editing &&
                              !widget.allowDuplicates &&
                              intValues.contains(intValue!)))
                      ? null
                      : () {
                          _addIntValue(intValue!, index: _editingIndex);
                        },
                  icon: Icon(_editing ? Icons.save : Icons.add)),
            ],
          ),
          divider(),
          if (children.isNotEmpty)
            SizedBox(
              height: 80,
              child: Wrap(
                spacing: 5.0,
                children: children,
              ),
            )
        ],
      ),
    );
  }

  void _addIntValue(int value, {int index = -1}) {
    setState(() {
      if (index == -1) {
        intValues.add(value);
      } else {
        intValues[index] = value;
        _setEditing();
      }
      intController.text = '';
    });

    widget.config[widget.parameter] = intValues;

    if (null != widget.changeNotifier) {
      widget.changeNotifier!();
    }
  }

  void _removeIntValue(int index) {
    setState(() {
      intValues.removeAt(index);
    });

    widget.config[widget.parameter] = intValues;

    if (null != widget.changeNotifier) {
      widget.changeNotifier!();
    }
  }

  Widget _buildTextObject() {
    List<Widget> children = [];

    for (int i = 0; i < stringValues.length; i++) {
      children.add(Chip(
        labelStyle: _defaultStyle,
        label: InkWell(
            onDoubleTap: () {
              setState(() {
                if (_editing) {
                  _setEditing();
                  controller.text = '';
                } else {
                  _setEditing(editing: true, editingIndex: i);
                  controller.text = stringValues[i];
                }
              });
            },
            child: Text(stringValues[i])),
        onDeleted: () {
          _removeStringValue(i);
        },
      ));
    }

    return SizedBox(
      width: 400,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: TextField(
                style: _defaultStyle,
                controller: controller,
                decoration: InputDecoration(
                  hintStyle: _defaultStyle,
                  labelStyle: _defaultStyle,
                  errorStyle: _defaultStyle,
                ),
                maxLines: widget.maxTextLines,
                onChanged: (content) {
                  setState(() {
                    value = controller.text.trim();
                  });
                },
              )),
              divider(horizontal: true),
              IconButton(
                  onPressed: (value.isEmpty ||
                          (!_editing &&
                              !widget.allowDuplicates &&
                              stringValues.contains(value)))
                      ? null
                      : () {
                          _addStringValue(value);
                        },
                  icon: Icon(_editing ? Icons.save : Icons.add)),
            ],
          ),
          divider(),
          if (children.isNotEmpty)
            SizedBox(
              height: 80,
              child: Wrap(
                spacing: 5.0,
                children: children,
              ),
            )
        ],
      ),
    );
  }

  void _addStringValue(String value, {int index = -1}) {
    setState(() {
      if (index == -1) {
        stringValues.add(controller.text);
      } else {
        stringValues[index] = controller.text;
        _setEditing();
      }
      controller.text = '';
    });

    widget.config[widget.parameter] = stringValues;

    if (null != widget.changeNotifier) {
      widget.changeNotifier!();
    }
  }

  void _removeStringValue(int index) {
    setState(() {
      stringValues.removeAt(index);
    });

    widget.config[widget.parameter] = stringValues;

    if (null != widget.changeNotifier) {
      widget.changeNotifier!();
    }
  }

  List<String> _toStringList(dynamic value) {
    if (null != value) {
      List<dynamic> dValues = value as List<dynamic>;
      List<String> values = [];
      for (dynamic value in dValues) {
        values.add('$value');
      }
      return values;
    }
    return [];
  }

  List<int> _toIntList(dynamic value) {
    if (null != value) {
      List<dynamic> dValues = value as List<dynamic>;
      List<int> values = [];
      for (dynamic value in dValues) {
        values.add(value);
      }
      return values;
    }
    return [];
  }

  List<double> _toDoubleList(dynamic value) {
    if (null != value) {
      List<dynamic> dValues = value as List<dynamic>;
      List<double> values = [];
      for (dynamic value in dValues) {
        values.add(value);
      }
      return values;
    }
    return [];
  }

  List<Map<String, dynamic>> _toMapList(dynamic value) {
    if (null != value) {
      List<dynamic> dList = value as List<dynamic>;
      List<Map<String, dynamic>> values = [];
      for (dynamic dValue in dList) {
        values.add(dValue as Map<String, dynamic>);
      }
      return values;
    }
    return [<String, dynamic>{}];
  }

  @override
  void setup() {}
}
