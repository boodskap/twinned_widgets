import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerField extends StatefulWidget {
  final Map<String, dynamic> config;
  final String parameter;
  const ColorPickerField(
      {super.key, required this.config, required this.parameter});

  @override
  State<ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ElevatedButton(
        onPressed: _showColorPickerDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: getColor(),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
        child: const Text(
          'Pick Color',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Color getColor() {
    return Color(widget.config[widget.parameter] ?? Colors.transparent);
  }

  void setColor(Color color) {
    widget.config[widget.parameter] = color.value;
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
}
