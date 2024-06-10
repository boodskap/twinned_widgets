import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:twinned_widgets/core/definitions.dart';

class ColorPickerField extends StatefulWidget {
  final Map<String, dynamic> config;
  final String parameter;
  final ValueChangeNotifier? changeNotifier;
  const ColorPickerField(
      {super.key,
      required this.config,
      required this.parameter,
      this.changeNotifier});

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
    if (null != widget.changeNotifier) {
      widget.changeNotifier!();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              hexInputBar: true,
              labelTypes: [],
              pickerColor: getColor(),
              onColorChanged: (color) {
                setColor(color);
              },
              enableAlpha: true,
              displayThumbColor: true,
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
