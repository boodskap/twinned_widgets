import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/core/definitions.dart';
import 'package:google_fonts/google_fonts.dart';

class DecimalField extends StatefulWidget {
  final Map<String, dynamic> parameters;
  final String parameter;
  final TextStyle? style;
  final ValueChangeNotifier? changeNotifier;
  const DecimalField({
    super.key,
    this.style,
    required this.parameters,
    required this.parameter,
    this.changeNotifier,
  });

  @override
  State<DecimalField> createState() => _DecimalFieldState();
}

class _DecimalFieldState extends BaseState<DecimalField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    String value;

    if (null == widget.parameters[widget.parameter]) {
      value = '0.0';
    } else {
      value = '${widget.parameters[widget.parameter]}';
    }

    _controller.text = value;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = widget.style ??
        GoogleFonts.lato(
          // fontSize: 18,
          // fontWeight: FontWeight.bold,
          color: Colors.black,
        );
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        height: 45,
        width: 100,
        child: TextField(
          style: style,
          controller: _controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelStyle: style,
            errorStyle: style,
            hintStyle: style,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$')),
          ],
          onSubmitted: (value) {
            if (value == '-') return;
            if (value.isEmpty) {
              widget.parameters[widget.parameter] = null;
            } else {
              widget.parameters[widget.parameter] = double.parse(value);
            }
            if (null != widget.changeNotifier) {
              widget.changeNotifier!();
            }
          },
        ),
      ),
    );
  }

  @override
  void setup() {
    // Implement setup if needed
  }
}
