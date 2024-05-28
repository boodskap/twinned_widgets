import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_widgets/core/asset_dropdown.dart';
import 'package:twinned_widgets/core/asset_model_dropdown.dart';
import 'package:twinned_widgets/core/color_picker_field.dart';
import 'package:twinned_widgets/core/decimal_field.dart';
import 'package:twinned_widgets/core/device_dropdown.dart';
import 'package:twinned_widgets/core/device_model_dropdown.dart';
import 'package:twinned_widgets/core/facility_dropdown.dart';
import 'package:twinned_widgets/core/floor_dropdown.dart';
import 'package:twinned_widgets/core/image_upload_field.dart';
import 'package:twinned_widgets/core/multi_asset_dropdown.dart';
import 'package:twinned_widgets/core/multi_assetmodel_dropdown.dart';
import 'package:twinned_widgets/core/multi_device_dropdown.dart';
import 'package:twinned_widgets/core/enumerated_field.dart';
import 'package:twinned_widgets/core/font_field.dart';
import 'package:twinned_widgets/core/field_dropdown.dart';
import 'package:twinned_models/twinned_models.dart';
import 'package:twinned_widgets/core/multi_devicemodel_dropdown.dart';
import 'package:twinned_widgets/core/multi_facility_dropdown.dart';
import 'package:twinned_widgets/core/multi_field_dropdown.dart';
import 'package:twinned_widgets/core/multi_floor_dropdown.dart';
import 'package:twinned_widgets/core/multi_premise_dropdown.dart';
import 'package:twinned_widgets/core/number_field.dart';
import 'package:twinned_widgets/core/parameter_text_field.dart';
import 'package:twinned_widgets/core/premise_dropdown.dart';
import 'package:twinned_widgets/core/range_list.dart';
import 'package:twinned_widgets/core/yesno_field.dart';

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
      DataType dataType = widget.config.getDataType(parameter);
      HintType hintType = widget.config.getHintType(parameter);

      debugPrint('Building type:$dataType hint:$hintType');

      switch (dataType) {
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
        case DataType.listOfRanges:
          _fields[parameter] = _buildListOfRangesField(parameter);
          break;
        case DataType.image:
          _fields[parameter] = _buildImageUploadField(parameter);
          break;
        case DataType.none:
          // We ignore unknown data types (may be a hidden parameter)
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
      case HintType.color:
        return ColorPickerField(
          config: _parameters,
          parameter: parameter,
        );
      default:
        return NumberField(
          parameters: _parameters,
          parameter: parameter,
        );
    }
  }

  Widget _buildDecimalField(String parameter) {
    return DecimalField(
      parameters: _parameters,
      parameter: parameter,
    );
  }

  Widget _buildTextField(String parameter) {
    switch (widget.config.getHintType(parameter)) {
      case HintType.field:
        return FieldDropdown(
          selectedField: _parameters[parameter],
          onFieldSelected: (param) {
            _parameters[parameter] = param?.name ?? '';
          },
        );
      case HintType.deviceId:
        return DeviceDropdown(
            selectedItem: _parameters[parameter],
            onDeviceSelected: (device) {
              _parameters[parameter] = device?.id ?? '';
            });
      case HintType.deviceModelId:
        return DeviceModelDropdown(
            selectedItem: _parameters[parameter],
            onDeviceModelSelected: (deviceModel) {
              _parameters[parameter] = deviceModel?.id ?? '';
            });
      case HintType.assetModelId:
        return AssetModelDropdown(
            selectedItem: _parameters[parameter],
            onAssetModelSelected: (assetModel) {
              _parameters[parameter] = assetModel?.id ?? '';
            });
      case HintType.assetId:
        return AssetDropdown(
            selectedItem: _parameters[parameter],
            onAssetSelected: (asset) {
              _parameters[parameter] = asset?.id ?? '';
            });
      case HintType.premiseId:
        return PremiseDropdown(
            selectedItem: _parameters[parameter],
            onPremiseSelected: (premise) {
              _parameters[parameter] = premise?.id ?? '';
            });
      case HintType.facilityId:
        return FacilityDropdown(
            selectedItem: _parameters[parameter],
            onFacilitySelected: (facility) {
              _parameters[parameter] = facility?.id ?? '';
            });
      case HintType.floorId:
        return FloorDropdown(
            selectedItem: _parameters[parameter],
            onFloorSelected: (floor) {
              _parameters[parameter] = floor?.id ?? '';
            });
      default:
        return ParameterTextField(
            parameters: _parameters, parameter: parameter);
    }
  }

  Widget _buildYesNoField(String parameter) {
    return YesNoField(parameters: _parameters, parameter: parameter);
  }

  Widget _buildEnumeratedField(String parameter) {
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
  }

  Widget _buildImageUploadField(String parameter) {
    return ImageUploadField(
      config: _parameters,
      parameter: parameter,
    );
  }

  Widget _buildFontField(String parameter) {
    return FontField(
      config: _parameters,
      parameter: parameter,
    );
  }

  List<String> toList(List<dynamic> list) {
    List<String> values = [];
    for (dynamic item in list) {
      values.add(item);
    }
    return values;
  }

  Widget _buildListOfTextsField(String parameter) {
    var paramValue = _parameters[parameter];

    if (null == paramValue) {
    } else if (paramValue is List<String>) {
    } else if (paramValue is String) {}

    switch (widget.config.getHintType(parameter)) {
      case HintType.deviceId:
        return MultiDeviceDropdown(
            selectedItems: toList(_parameters[parameter]),
            onDevicesSelected: (items) {
              _parameters[parameter] = items.map((i) => i.id).toList();
            });
      case HintType.field:
        return MultiFieldDropdown(
            selectedItems: toList(_parameters[parameter]),
            onFieldsSelected: (fields) {
              _parameters[parameter] = fields.map((i) => i.name).toList();
            });
      case HintType.deviceModelId:
        return MultiDeviceModelDropdown(
            selectedItems: toList(_parameters[parameter]),
            onDeviceModelsSelected: (models) {
              _parameters[parameter] = models.map((i) => i.id).toList();
            });
      case HintType.assetId:
        return MultiAssetDropdown(
            selectedItems: toList(_parameters[parameter]),
            onAssetsSelected: (models) {
              _parameters[parameter] = models.map((i) => i.id).toList();
            });
      case HintType.assetModelId:
        return MultiAssetModelDropdown(
            selectedItems: toList(_parameters[parameter]),
            onAssetModelsSelected: (models) {
              _parameters[parameter] = models.map((i) => i.id).toList();
            });
      case HintType.premiseId:
        return MultiPremiseDropdown(
            selectedItems: toList(_parameters[parameter]),
            onPremisesSelected: (models) {
              _parameters[parameter] = models.map((i) => i.id).toList();
            });
      case HintType.facilityId:
        return MultiFacilityDropdown(
            selectedItems: toList(_parameters[parameter]),
            onFacilitiesSelected: (models) {
              _parameters[parameter] = models.map((i) => i.id).toList();
            });
      case HintType.floorId:
        return MultiFloorDropdown(
            selectedItems: toList(_parameters[parameter]),
            onFloorsSelected: (models) {
              _parameters[parameter] = models.map((i) => i.id).toList();
            });
      default:
        return const SizedBox(
            height: 48,
            child: Placeholder(
              color: Colors.red,
              child: Text('String List'),
            ));
    }
  }

  Widget _buildListOfNumbersField(String parameter) {
    return const SizedBox(
        height: 48,
        child: Placeholder(
          color: Colors.red,
          child: Text('Number List'),
        ));
  }

  Widget _buildListOfDecimalsField(String parameter) {
    return const SizedBox(
        height: 48,
        child: Placeholder(
          color: Colors.red,
          child: Text('Decimal List'),
        ));
  }

  Widget _buildListOfRangesField(String parameter) {
    List<dynamic> list = _parameters[parameter];
    List<Map<String, dynamic>> values = [];
    for (Map<String, dynamic> map in list) {
      values.add(map);
    }
    return RangeList(
      parameters: values,
      onRangeListSaved: (params) {
        _parameters[parameter] = params;
      },
    );
  }

  @override
  void setup() {}

  Future _save() async {
    bool valid = true;

    _parameters.forEach((parameter, value) {
      bool required = widget.config.isRequired(parameter);
      dynamic value = _parameters[parameter];

      if (required && null == value) {
        alert('Missing', '$parameter is required');
        return;
      }

      if (required) {
        switch (widget.config.getDataType(parameter)) {
          case DataType.text:
          case DataType.image:
            String sValue = value;
            if (sValue.isEmpty) {
              valid = false;
              alert('Invalid', '$parameter can not be empty');
            }
            break;
          case DataType.numeric:
          case DataType.decimal:
          case DataType.yesno:
          case DataType.font:
            break;
          case DataType.enumerated:
          case DataType.listOfTexts:
          case DataType.listOfNumbers:
          case DataType.listOfDecimals:
          case DataType.listOfRanges:
            List<dynamic> values = value;
            if (values.isEmpty) {
              alert('Invalid', '$parameter can not be an empty array');
            }
            break;
          case DataType.none:
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
