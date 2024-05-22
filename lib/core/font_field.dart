import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:nocode_commons/core/base_state.dart';

class FontField extends StatefulWidget {
  const FontField({
    Key? key,
  }) : super(key: key);

  @override
  State<FontField> createState() => _FontFieldState();
}

class _FontFieldState extends BaseState<FontField> {
  Color selectedColor = Colors.black;

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a color'),
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
              child: Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                child: Text('Pick Color'),
              ),
            ),
            SizedBox(width: 10),
            IntrinsicWidth(
              child: SpinBox(
                min: 4,
                max: 50,
                value: 12,
                showCursor: true,
                autofocus: true,
                onChanged: (value) {},
              ),
            ),
            SizedBox(width: 10),
            IntrinsicWidth(
              child: IconButton(
                icon: Icon(Icons.font_download),
                onPressed: () {},
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