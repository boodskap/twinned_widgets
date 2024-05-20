import 'package:configs/models.dart';
import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';

typedef OnConfigSaved = void Function(Map<String, dynamic> parameters);

class TwinnedConfigBuilder extends StatefulWidget {
  final BaseConfig config;
  final Map<String, dynamic> parameters;
  final OnConfigSaved onConfigSaved;
  const TwinnedConfigBuilder(
      {super.key,
      required this.config,
      required this.parameters,
      required this.onConfigSaved});

  @override
  State<TwinnedConfigBuilder> createState() => _TwinnedConfigBuilderState();
}

class _TwinnedConfigBuilderState extends BaseState<TwinnedConfigBuilder> {
  final Map<String, dynamic> _parameters = {};

  @override
  void initState() {
    _parameters.addAll(widget.parameters);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Widget> _fields = {};
    final List<Widget> _children = [];

    for (var parameter in widget.parameters.keys) {
      switch (widget.config.getDataType(parameter)) {
        case DataType.numeric:
          _fields[parameter] = _buildNumberField(parameter);
          break;
        case DataType.decimal:
          _fields[parameter] = _buildDecimalField(parameter);
          break;
        case DataType.text:
          _fields[parameter] = _buildTextField(parameter);
          break;
        case DataType.yesno:
          _fields[parameter] = _buildYesNoField(parameter);
          break;
        case DataType.enumerated:
          _fields[parameter] = _buildEnumeratedField(parameter);
          break;
        case DataType.font:
          _fields[parameter] = _buildFontField(parameter);
          break;
        case DataType.listOfTexts:
          _fields[parameter] = _buildListOfTextsField(parameter);
          break;
        case DataType.listOfNumbers:
          _fields[parameter] = _buildListOfNumbersField(parameter);
          break;
        case DataType.listOfDecimals:
          _fields[parameter] = _buildListOfDecimalsField(parameter);
          break;
        case DataType.listOfObjects:
          _fields[parameter] = _buildListOfObjectsField(parameter);
          break;
      }
    }

    _fields.forEach((key, value) {
      _children.add(Row(
        children: [
          Expanded(flex: 1, child: Text(key)),
          divider(horizontal: true),
          Expanded(flex: 4, child: value),
        ],
      ));

      _children.add(divider());
    });

    _children.add(Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.cancel)),
        divider(horizontal: true),
        IconButton(
            onPressed: () {
              widget.onConfigSaved(_parameters);
            },
            icon: const Icon(Icons.save)),
      ],
    ));

    return SingleChildScrollView(
        child: Column(
      children: _children,
    ));
  }

  Widget _buildNumberField(String parameter) {
    return const SizedBox.shrink(); //TODO implement this
  }

  Widget _buildDecimalField(String parameter) {
    return const SizedBox.shrink(); //TODO implement this
  }

  Widget _buildTextField(String parameter) {
    return const SizedBox.shrink(); //TODO implement this
  }

  Widget _buildYesNoField(String parameter) {
    return const SizedBox.shrink(); //TODO implement this
  }

  Widget _buildEnumeratedField(String parameter) {
    return const SizedBox.shrink(); //TODO implement this
  }

  Widget _buildFontField(String parameter) {
    return const SizedBox.shrink(); //TODO implement this
  }

  Widget _buildListOfTextsField(String parameter) {
    return const SizedBox.shrink(); //TODO implement this
  }

  Widget _buildListOfNumbersField(String parameter) {
    return const SizedBox.shrink(); //TODO implement this
  }

  Widget _buildListOfDecimalsField(String parameter) {
    return const SizedBox.shrink(); //TODO implement this
  }

  Widget _buildListOfObjectsField(String parameter) {
    return const SizedBox.shrink(); //TODO implement this
  }

  @override
  void setup() {}
}
