import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nocode_commons/core/base_state.dart';

class DecimalField extends StatefulWidget {
  const DecimalField({
    super.key,
  });

  @override
  State<DecimalField> createState() => _DecimalFieldState();
}

class _DecimalFieldState extends BaseState<DecimalField> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 45,
        width: 100,
        child: TextField(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
          ],
        ),
      ),
    );
  }

  @override
  void setup() {
    // Implement setup if needed
  }
}
