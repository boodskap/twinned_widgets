import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:twinned_widgets/core/definitions.dart';
import 'package:google_fonts/google_fonts.dart';

class ColorPickerField extends StatefulWidget {
  final Map<String, dynamic> config;
  final String parameter;
  final TextStyle? style;
  final ValueChangeNotifier? changeNotifier;
  const ColorPickerField(
      {super.key,
      this.style,
      required this.config,
      required this.parameter,
      this.changeNotifier});

  @override
  State<ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {
  @override
  Widget build(BuildContext context) {
    final TextStyle style = widget.style ??
        GoogleFonts.lato(
          color: Colors.black,
        );
    return Align(
      alignment: Alignment.topLeft,
      child: ElevatedButton(
        onPressed: _showColorPickerDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: getColor(),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
        child: Text(
          'Pick Color',
          style: style.copyWith(color: Colors.white),
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
    final TextStyle style = widget.style ??
        GoogleFonts.lato(
          color: Colors.black,
        );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titleTextStyle: style.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: style,
          title: Text(
            'Pick a color',
            style: style.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              hexInputBar: true,
              labelTypes: const [],
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
              child: Text(
                'Done',
                style: style,
              ),
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
