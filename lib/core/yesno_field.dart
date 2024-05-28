import 'package:flutter/material.dart';
import 'package:twinned_widgets/core/definitions.dart';

class YesNoField extends StatefulWidget {
  final Map<String, dynamic> parameters;
  final String parameter;
  final ValueChangeNotifier? changeNotifier;

  const YesNoField(
      {super.key,
      required this.parameters,
      required this.parameter,
      this.changeNotifier});

  @override
  State<YesNoField> createState() => _YesNoFieldState();
}

class _YesNoFieldState extends State<YesNoField> {
  @override
  Widget build(BuildContext context) {
    return Checkbox(
        value: widget.parameters[widget.parameter] ?? false,
        onChanged: (value) {
          setState(() {
            widget.parameters[widget.parameter] = value ?? false;
          });
          if (null != widget.changeNotifier) {
            widget.changeNotifier!();
          }
        });
  }
}
