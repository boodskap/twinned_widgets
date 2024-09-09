import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:google_fonts/google_fonts.dart';

class NumberField extends StatefulWidget {
  final Map<String, dynamic> parameters;
  final String parameter;
  final TextStyle? style;
  const NumberField({
    super.key,
    this.style,
    required this.parameters,
    required this.parameter,
  });

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends BaseState<NumberField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    String value;

    if (null == widget.parameters[widget.parameter]) {
      value = '0';
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
              border: OutlineInputBorder(),
              hintStyle: style,
              errorStyle: style,
              labelStyle: style),
          keyboardType: const TextInputType.numberWithOptions(
              decimal: false, signed: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'^-?\s*-?[0-9]{1,10}\s*$')),
          ],
          onChanged: (value) {
            if (value == '-') return;
            if (value.isEmpty) {
              widget.parameters[widget.parameter] = null;
            } else {
              widget.parameters[widget.parameter] = int.parse(value);
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
