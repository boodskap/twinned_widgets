import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:nocode_commons/core/base_state.dart';

class FontField extends StatefulWidget {
  final Map<String, dynamic> config;
  final String parameter;
  const FontField({
    super.key,
    required this.config,
    required this.parameter,
  });

  @override
  State<FontField> createState() => _FontFieldState();
}

class _FontFieldState extends BaseState<FontField> {
  final Map<String, dynamic> _values = <String, dynamic>{};

  @override
  void initState() {
    _values.addAll(widget.config[widget.parameter]);
    super.initState();
  }

  Color getColor() {
    return Color(_values['fontColor'] ?? Colors.black.value);
  }

  void setColor(Color color) {
    _values['fontColor'] = color.value;
    widget.config[widget.parameter] = _values;
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: getColor(),
              onColorChanged: (color) {
                setState(() {
                  setColor(color);
                });
              },
              enableAlpha: true,
              displayThumbColor: true,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool isBold() {
    return _values['fontBold'] ?? false;
  }

  void _toggleBold() {
    setState(() {
      bool isBold = _values['fontBold'] ?? false;
      _values['fontBold'] = !isBold;
      widget.config[widget.parameter] = _values;
    });
  }

  double getFontSize() {
    return _values['fontSize'] ?? 12;
  }

  void _updateFontSize(double value) {
    setState(() {
      _values['fontSize'] = value;
      widget.config[widget.parameter] = _values;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            IntrinsicWidth(
              child: ElevatedButton(
                onPressed: _showColorPickerDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: getColor(),
                ),
                child: const Text(
                  'Pick Color',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 35,
              child: IntrinsicWidth(
                child: SpinBox(
                  min: 4,
                  max: 50,
                  value: getFontSize(),
                  showCursor: true,
                  autofocus: true,
                  onChanged: _updateFontSize,
                ),
              ),
            ),
            const SizedBox(width: 10),
            IntrinsicWidth(
              child: IconButton(
                icon: Icon(isBold()
                    ? Icons.font_download_sharp
                    : Icons.font_download_outlined),
                onPressed: _toggleBold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void setup() {
    // Implement setup if needed
  }
}
