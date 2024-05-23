import 'package:flutter/material.dart';

class ParameterTextField extends StatefulWidget {
  final Map<String, dynamic> parameters;
  final String parameter;

  const ParameterTextField(
      {super.key, required this.parameters, required this.parameter});

  @override
  State<ParameterTextField> createState() => _ParameterTextFieldState();
}

class _ParameterTextFieldState extends State<ParameterTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    dynamic value = widget.parameters[widget.parameter] ?? '';
    debugPrint('Parameter: ${widget.parameter}, Value: $value');
    try {
      _controller.text = widget.parameters[widget.parameter] ?? '';
    } catch (e, s) {
      //debugPrint('$e\n$s');
      debugPrint('ERROR');
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
    return TextField(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      controller: _controller,
      onChanged: (value) {
        widget.parameters[widget.parameter] = value;
      },
    );
  }
}
