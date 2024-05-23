import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_widgets/core/color_picker_field.dart';
import 'package:twinned_widgets/core/decimal_field.dart';
import 'package:twinned_widgets/core/device_field_dropdown.dart';
import 'package:twinned_widgets/core/enumerated_field.dart';
import 'package:twinned_widgets/core/font_field.dart';
import 'package:twinned_widgets/core/model_field_dropdown.dart';
import 'package:twinned_models/twinned_models.dart';

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
  final List<TextEditingController> _controllers = [];

  @override
  void initState() {
    _parameters.addAll(widget.parameters);
    super.initState();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
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
          Expanded(
            flex: 1,
            child: Text(
              key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          divider(horizontal: true),
          Expanded(flex: 4, child: value),
        ],
      ));

      _children.add(divider());
    });

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: _children,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Tooltip(
              message: 'Cancel',
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.cancel),
              ),
            ),
            divider(horizontal: true),
            Tooltip(
              message: 'Save',
              child: IconButton(
                onPressed: () async {
                  await _save();
                },
                icon: const Icon(Icons.save),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberField(String parameter) {
    switch (widget.config.getHintType(parameter)) {
      case HintType.field:
      case HintType.modelId:
      case HintType.assetModelId:
      case HintType.color:
        return const ColorPickerField();
      default:
        TextEditingController controller = TextEditingController();
        _controllers.add(controller);
        controller.addListener(() {
          _parameters[parameter] = controller.text;
        });
        return TextField(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          controller: controller,
        );
    }
  }

  Widget _buildDecimalField(String parameter) {
    switch (widget.config.getDataType(parameter)) {
      case DataType.decimal:
        return const DecimalField();
      case DataType.numeric:
      case DataType.font:
      case DataType.yesno:
      case DataType.enumerated:
      case DataType.listOfTexts:
      case DataType.listOfNumbers:
      case DataType.listOfDecimals:
      case DataType.listOfObjects:
      default:
        TextEditingController controller = TextEditingController();
        _controllers.add(controller);
        controller.addListener(() {
          _parameters[parameter] = controller.text;
        });
        return TextField(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          controller: controller,
        );
    }
  }

  Widget _buildTextField(String parameter) {
    switch (widget.config.getHintType(parameter)) {
      case HintType.field:
      case HintType.modelId:
      case HintType.assetModelId:
        return ModelFieldDropdown(
          selectedField: _parameters[parameter],
          onModelFieldSelected: (param) {
            _parameters[parameter] = param?.name ?? '';
          },
        );
      default:
        TextEditingController controller = TextEditingController();
        _controllers.add(controller);
        controller.addListener(() {
          _parameters[parameter] = controller.text;
        });
        return TextField(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          controller: controller,
        );
    }
  }

  Widget _buildYesNoField(String parameter) {
    return const SizedBox.shrink(); //TODO implement this
  }

  Widget _buildEnumeratedField(String parameter) {
    switch (widget.config.getDataType(parameter)) {
      case DataType.enumerated:
        List<String> enumeratedValues =
            widget.config.getEnumeratedValues(parameter);
        return EnumeratedDropdown(
          enumeratedValues: enumeratedValues,
          selectedValue: _parameters[parameter] ?? enumeratedValues.first,
          onChanged: (String? value) {
            setState(() {
              _parameters[parameter] = value!;
            });
          },
        );
      case DataType.numeric:
      case DataType.decimal:
      case DataType.yesno:
      case DataType.font:
      case DataType.listOfTexts:
      case DataType.listOfNumbers:
      case DataType.listOfDecimals:
      case DataType.listOfObjects:
      default:
        TextEditingController controller = TextEditingController();
        _controllers.add(controller);
        controller.addListener(() {
          _parameters[parameter] = controller.text;
        });
        return TextField(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          controller: controller,
        );
    }
  }

  // Widget _buildEnumeratedField(String parameter) {
  //   List<String> enumeratedValues =
  //       widget.config.getEnumeratedValues(parameter);
  //   String selectedValue = _parameters[parameter] ?? enumeratedValues.first;

  //   return DropdownButton<String>(
  //     value: selectedValue,
  //     onChanged: (String? newValue) {
  //       setState(() {
  //         _parameters[parameter] = newValue;
  //       });
  //     },
  //     items: enumeratedValues.map<DropdownMenuItem<String>>((String value) {
  //       return DropdownMenuItem<String>(
  //         value: value,
  //         child: Text(value),
  //       );
  //     }).toList(),
  //   );
  // }

  Widget _buildFontField(String parameter) {
    switch (widget.config.getDataType(parameter)) {
      case DataType.font:
        return const FontField();
      case DataType.numeric:
      case DataType.decimal:
      case DataType.yesno:
      case DataType.enumerated:
      case DataType.listOfTexts:
      case DataType.listOfNumbers:
      case DataType.listOfDecimals:
      case DataType.listOfObjects:
      default:
        TextEditingController controller = TextEditingController();
        _controllers.add(controller);
        controller.addListener(() {
          _parameters[parameter] = controller.text;
        });
        return TextField(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          controller: controller,
        );
    }
  }

  Widget _buildListOfTextsField(String parameter) {
    var paramValue = _parameters[parameter];
    List<String> selectedDevices = [];

    if (paramValue is List<String>) {
      selectedDevices = paramValue;
    } else if (paramValue is String) {
      selectedDevices = [paramValue];
    }

    switch (widget.config.getHintType(parameter)) {
      case HintType.field:
      case HintType.modelId:
        return DeviceFieldDropdown(
          selectedDevices: selectedDevices,
          onDevicesSelected: (devices) {
            setState(() {
              _parameters[parameter] =
                  devices.map((device) => device.name).toList();
            });
          },
        );
      case HintType.assetModelId:
      default:
        TextEditingController controller = TextEditingController();
        _controllers.add(controller);
        controller.addListener(() {
          _parameters[parameter] = controller.text;
        });
        return TextField(
          decoration: const InputDecoration(border: OutlineInputBorder()),
          controller: controller,
        );
    }
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

  Future _save() async {
    bool valid = true;

    _parameters.forEach((parameter, value) {
      bool required = widget.config.isRequired(parameter);
      if (required) {
        switch (widget.config.getDataType(parameter)) {
          case DataType.text:
            String sValue = value;
            if (null == sValue || sValue.isEmpty) {
              valid = false;
              alert('Missing', '$parameter is required');
            }
            break;
          case DataType.numeric:
            break;
          case DataType.decimal:
            break;
          case DataType.yesno:
            break;
          case DataType.enumerated:
            break;
          case DataType.font:
            break;
          case DataType.listOfTexts:
            break;
          case DataType.listOfNumbers:
            break;
          case DataType.listOfDecimals:
            break;
          case DataType.listOfObjects:
            break;
        }
      }
    });

    if (valid) {
      widget.onConfigSaved(_parameters);
      Navigator.pop(context);
    }
  }
}
