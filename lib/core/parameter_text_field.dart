import 'package:flutter/material.dart';
import 'package:twinned_widgets/core/definitions.dart';

class ParameterTextField extends StatefulWidget {
  final Map<String, dynamic> parameters;
  final String parameter;
  final ValueChangeNotifier? changeNotifier;

  const ParameterTextField(
      {super.key,
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
    return TextField(
      decoration: const InputDecoration(border: OutlineInputBorder()),
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
