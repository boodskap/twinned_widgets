import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:nocode_commons/core/base_state.dart';

class FontField extends StatefulWidget {
  const FontField({
    super.key,
  });

  @override
  State<FontField> createState() => _FontFieldState();
}

class _FontFieldState extends BaseState<FontField> {
  Color selectedColor = Colors.black;
  bool isBold = false;
  double fontSize = 12;

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                });
              },
              enableAlpha: false,
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

  void _toggleBold() {
    setState(() {
      isBold = !isBold;
    });
  }

  void _updateFontSize(double value) {
    setState(() {
      fontSize = value;
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
                  backgroundColor: selectedColor,
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
                  value: fontSize,
                  showCursor: true,
                  autofocus: true,
                  onChanged: _updateFontSize,
                ),
              ),
            ),
            const SizedBox(width: 10),
            IntrinsicWidth(
              child: IconButton(
                icon: const Icon(Icons.font_download),
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
