import 'package:flutter/material.dart';
import 'package:twinned_widgets/core/definitions.dart';

class ParameterMultiTextField extends StatefulWidget {
  final Map<String, dynamic> parameters;
  final String parameter;
  final ValueChangeNotifier? changeNotifier;

  const ParameterMultiTextField(
      {super.key,
      required this.parameters,
      required this.parameter,
      this.changeNotifier});

  @override
  State<ParameterMultiTextField> createState() =>
      _ParameterMultiTextFieldState();
}

class _ParameterMultiTextFieldState extends State<ParameterMultiTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    try {
      List<dynamic> value = widget.parameters[widget.parameter] ?? [];
      _controller.text = value.join(',');
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
    debugPrint('Building Multi Text Field');
    return TextField(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      controller: _controller,
      //maxLines: 2,
      onSubmitted: (value) {
        List<String> list = value.split(',');
        debugPrint('OnSubmitted: $list');
        widget.parameters[widget.parameter] = list;
        if (null != widget.changeNotifier) {
          widget.changeNotifier!();
        }
      },
    );
  }
}
