import 'package:flutter/material.dart';
import 'package:twinned_widgets/core/definitions.dart';
import 'package:google_fonts/google_fonts.dart';

class ParameterTextField extends StatefulWidget {
  final Map<String, dynamic> parameters;
  final String parameter;
  final ValueChangeNotifier? changeNotifier;
  final TextStyle? style;
  const ParameterTextField(
      {super.key,
      this.style,
      required this.parameters,
      required this.parameter,
      this.changeNotifier});

  @override
  State<ParameterTextField> createState() => _ParameterTextFieldState();
}

class _ParameterTextFieldState extends State<ParameterTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    dynamic value = widget.parameters[widget.parameter] ?? '';
    try {
      _controller.text = widget.parameters[widget.parameter] ?? '';
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = widget.style ??
        GoogleFonts.lato(
          // fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        );
    return TextField(
      style: style,
      decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintStyle: style,
          labelStyle: style,
          errorStyle: style),
      controller: _controller,
      onSubmitted: (value) {
        widget.parameters[widget.parameter] = value;
        if (null != widget.changeNotifier) {
          widget.changeNotifier!();
        }
      },
    );
  }
}
