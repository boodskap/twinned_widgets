import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twin_commons/core/base_state.dart';

class NumberField extends StatefulWidget {
  final Map<String, dynamic> parameters;
  final String parameter;
  const NumberField({
    super.key,
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
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        height: 45,
        width: 100,
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
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
