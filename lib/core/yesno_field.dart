import 'package:flutter/material.dart';
import 'package:twinned_widgets/core/definitions.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:google_fonts/google_fonts.dart';

class YesNoField extends StatefulWidget {
  final Map<String, dynamic> parameters;
  final String parameter;
  final TextStyle? style;
  final ValueChangeNotifier? changeNotifier;

  const YesNoField(
      {super.key,
      this.style,
      required this.parameters,
      required this.parameter,
      this.changeNotifier});

  @override
  State<YesNoField> createState() => _YesNoFieldState();
}

class _YesNoFieldState extends State<YesNoField> {
  @override
  Widget build(BuildContext context) {
    final TextStyle style = widget.style ??
        GoogleFonts.lato(
          // fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        );
    int initialIndex = (widget.parameters[widget.parameter] ?? false) ? 0 : 1;
    return ToggleSwitch(
      customTextStyles: [style],
      initialLabelIndex: initialIndex,
      totalSwitches: 2,
      minWidth: 90.0,
      cornerRadius: 20.0,
      activeFgColor: Colors.white,
      inactiveBgColor: Colors.grey,
      inactiveFgColor: Colors.white,
      radiusStyle: true,
      labels: const ['True', 'False'],
      activeBgColors: [
        [Colors.green[800]!],
        [Colors.red[800]!]
      ],
      onToggle: (index) {
        bool value = (index ?? 0) == 1;
        setState(() {
          widget.parameters[widget.parameter] = value;
        });
        if (null != widget.changeNotifier) {
          widget.changeNotifier!();
        }
      },
    );
  }
}
