import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/core/asset_dropdown.dart';
import 'package:twinned_widgets/core/asset_model_dropdown.dart';
import 'package:twinned_widgets/core/color_picker_field.dart';
import 'package:twinned_widgets/core/decimal_field.dart';
import 'package:twinned_widgets/core/device_dropdown.dart';
import 'package:twinned_widgets/core/device_model_dropdown.dart';
import 'package:twinned_widgets/core/facility_dropdown.dart';
import 'package:twinned_widgets/core/floor_dropdown.dart';
import 'package:twinned_widgets/core/image_upload_field.dart';
import 'package:twinned_widgets/core/list_of_objects.dart';
import 'package:twinned_widgets/core/multi_asset_dropdown.dart';
import 'package:twinned_widgets/core/multi_assetmodel_dropdown.dart';
import 'package:twinned_widgets/core/multi_client_dropdown.dart';
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
import 'package:google_fonts/google_fonts.dart';

typedef OnConfigSaved = void Function(Map<String, dynamic> parameters);

class TwinnedConfigBuilder extends StatefulWidget {
  final TextStyle? style;
  final bool verbose;
  final BaseConfig config;
  final Map<String, dynamic> parameters;
  final Map<String, dynamic> defaultParameters;
  final OnConfigSaved onConfigSaved;

  const TwinnedConfigBuilder(
      {super.key,
      this.style,
      required this.verbose,
      required this.config,
      required this.parameters,
      required this.defaultParameters,
      required this.onConfigSaved});

  @override
  State<TwinnedConfigBuilder> createState() => _TwinnedConfigBuilderState();
}

class _TwinnedConfigBuilderState extends BaseState<TwinnedConfigBuilder> {
  final Map<String, dynamic> _parameters = {};
  final List<TextEditingController> _controllers = [];
  late final TextStyle _defaultStyle;

  @override
  void initState() {
    _parameters.addAll(widget.parameters);
    _defaultStyle = widget.style ??
        GoogleFonts.lato(
          color: Colors.black,
        );
    widget.defaultParameters.forEach((k, v) {
      if (!_parameters.containsKey(k)) {
        _parameters[k] = v;
      }
    });

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
    final Map<String, Widget> fields = {};
    final List<Widget> children = [];

    for (var parameter in _parameters.keys) {
      DataType dataType = widget.config.getDataType(parameter);
      String label = widget.config.getLabel(parameter);

      switch (dataType) {
        case DataType.numeric:
          fields[label] = _buildNumberField(parameter);
          break;
        case DataType.decimal:
          fields[label] = _buildDecimalField(parameter);
          break;
        case DataType.text:
          fields[label] = _buildTextField(parameter);
          break;
        case DataType.yesno:
          fields[label] = _buildYesNoField(parameter);
          break;
        case DataType.enumerated:
          fields[label] = _buildEnumeratedField(parameter);
          break;
        case DataType.font:
          fields[label] = _buildFontField(parameter);
          break;
        case DataType.listOfTexts:
          fields[label] = _buildListOfTextsField(parameter);
          break;
        case DataType.listOfNumbers:
          fields[label] = _buildListOfNumbersField(parameter);
          break;
        case DataType.listOfDecimals:
          fields[label] = _buildListOfDecimalsField(parameter);
          break;
        case DataType.listOfRanges:
          fields[label] = _buildListOfRangesField(parameter);
          break;
        case DataType.image:
          fields[label] = _buildImageUploadField(parameter);
          break;
        case DataType.listOfFonts:
          fields[label] = ListOfObjectsWidget(
            objectType: ObjectType.font,
            config: _parameters,
            parameter: parameter,
            allowDuplicates: widget.config.canDuplicate(parameter),
          );
        case DataType.listOfImages:
          fields[label] = ListOfObjectsWidget(
            objectType: ObjectType.image,
            config: _parameters,
            parameter: parameter,
            allowDuplicates: widget.config.canDuplicate(parameter),
          );
          break;
        case DataType.none:
          // We ignore unknown data types (may be a hidden parameter)
          break;
      }
    }

    fields.forEach((key, value) {
      children.add(Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              maxLines: 4,
              overflow: TextOverflow.visible,
              key,
              style: _defaultStyle.copyWith(
                  fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          divider(horizontal: true),
          Expanded(flex: 4, child: value),
        ],
      ));

      children.add(divider());
    });

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: children,
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
                  _save();
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
          style: _defaultStyle,
          config: _parameters,
          parameter: parameter,
        );
      default:
        return NumberField(
          style: _defaultStyle,
          parameters: _parameters,
          parameter: parameter,
        );
    }
  }

  Widget _buildDecimalField(String parameter) {
    return DecimalField(
      style: _defaultStyle,
      parameters: _parameters,
      parameter: parameter,
    );
  }

  Widget _buildTextField(String parameter) {
    switch (widget.config.getHintType(parameter)) {
      case HintType.field:
        return FieldDropdown(
          style: _defaultStyle,
          selectedField: _parameters[parameter],
          onFieldSelected: (param) {
            _parameters[parameter] = param?.name ?? '';
          },
        );
      case HintType.deviceId:
        return DeviceDropdown(
            style: _defaultStyle,
            selectedItem: _parameters[parameter],
            onDeviceSelected: (device) {
              _parameters[parameter] = device?.id ?? '';
            });
      case HintType.deviceModelId:
        return DeviceModelDropdown(
            style: _defaultStyle,
            selectedItem: _parameters[parameter],
            onDeviceModelSelected: (deviceModel) {
              _parameters[parameter] = deviceModel?.id ?? '';
            });
      case HintType.assetModelId:
        return AssetModelDropdown(
            style: _defaultStyle,
            selectedItem: _parameters[parameter],
            onAssetModelSelected: (assetModel) {
              _parameters[parameter] = assetModel?.id ?? '';
            });
      case HintType.assetId:
        return AssetDropdown(
            style: _defaultStyle,
            selectedItem: _parameters[parameter],
            onAssetSelected: (asset) {
              _parameters[parameter] = asset?.id ?? '';
            });
      case HintType.premiseId:
        return PremiseDropdown(
            style: _defaultStyle,
            selectedItem: _parameters[parameter],
            onPremiseSelected: (premise) {
              _parameters[parameter] = premise?.id ?? '';
            });
      case HintType.facilityId:
        return FacilityDropdown(
            style: _defaultStyle,
            selectedItem: _parameters[parameter],
            selectedPremise: null,
            onFacilitySelected: (facility) {
              _parameters[parameter] = facility?.id ?? '';
            });
      case HintType.floorId:
        return FloorDropdown(
            style: _defaultStyle,
            selectedItem: _parameters[parameter],
            selectedFacility: null,
            selectedPremise: null,
            onFloorSelected: (floor) {
              _parameters[parameter] = floor?.id ?? '';
            });
      default:
        return ParameterTextField(
            style: _defaultStyle, parameters: _parameters, parameter: parameter);
    }
  }

  Widget _buildYesNoField(String parameter) {
    return YesNoField(
        style: _defaultStyle, parameters: _parameters, parameter: parameter);
  }

  Widget _buildEnumeratedField(String parameter) {
    List<String> enumeratedValues =
        widget.config.getEnumeratedValues(parameter);
    return EnumeratedDropdown(
      style: _defaultStyle,
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
      style: _defaultStyle,
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
    final HintType hintType = widget.config.getHintType(parameter);
    switch (hintType) {
      case HintType.deviceId:
        return MultiDeviceDropdown(
            style: _defaultStyle,
            allowDuplicates: widget.config.canDuplicate(parameter),
            selectedItems: toList(_parameters[parameter]),
            onDevicesSelected: (items) {
              _parameters[parameter] = items.map((i) => i.id).toList();
            });
      case HintType.field:
        return MultiFieldDropdown(
            style: _defaultStyle,
            allowDuplicates: widget.config.canDuplicate(parameter),
            selectedItems: toList(_parameters[parameter]),
            onFieldsSelected: (fields) {
              debugPrint('SELECTED $fields');
              _parameters[parameter] = fields.map((i) => i.name).toList();
              if (widget.verbose) debugPrint('${_parameters[parameter]}');
            });
      case HintType.deviceModelId:
        return MultiDeviceModelDropdown(
            style: _defaultStyle,
            allowDuplicates: widget.config.canDuplicate(parameter),
            selectedItems: toList(_parameters[parameter]),
            onDeviceModelsSelected: (models) {
              _parameters[parameter] = models.map((i) => i.id).toList();
            });
      case HintType.assetId:
        return MultiAssetDropdown(
            style: _defaultStyle,
            allowDuplicates: widget.config.canDuplicate(parameter),
            selectedItems: toList(_parameters[parameter]),
            onAssetsSelected: (models) {
              _parameters[parameter] = models.map((i) => i.id).toList();
            });
      case HintType.assetModelId:
        return MultiAssetModelDropdown(
            style: _defaultStyle,
            allowDuplicates: widget.config.canDuplicate(parameter),
            selectedItems: toList(_parameters[parameter]),
            onAssetModelsSelected: (models) {
              debugPrint('ASSET MODELS: $models');
              _parameters[parameter] = models.map((i) => i.id).toList();
            });
      case HintType.premiseId:
        return MultiPremiseDropdown(
            style: _defaultStyle,
            allowDuplicates: widget.config.canDuplicate(parameter),
            selectedItems: toList(_parameters[parameter]),
            onPremisesSelected: (models) {
              _parameters[parameter] = models.map((i) => i.id).toList();
            });
      case HintType.facilityId:
        return MultiFacilityDropdown(
            style: _defaultStyle,
            allowDuplicates: widget.config.canDuplicate(parameter),
            selectedItems: toList(_parameters[parameter]),
            onFacilitiesSelected: (models) {
              _parameters[parameter] = models.map((i) => i.id).toList();
            });
      case HintType.floorId:
        return MultiFloorDropdown(
            style: _defaultStyle,
            allowDuplicates: widget.config.canDuplicate(parameter),
            selectedItems: toList(_parameters[parameter]),
            onFloorsSelected: (models) {
              _parameters[parameter] = models.map((i) => i.id).toList();
            });
      case HintType.clientId:
        return MultiClientDropdown(
          style: _defaultStyle,
          selectedItems: toList(_parameters[parameter]),
          allowDuplicates: widget.config.canDuplicate(parameter),
          onClientsSelected: (models) {
            _parameters[parameter] = models.map((i) => i.id).toList();
          },
        );
      case HintType.userId:
      // TODO: Handle this case.
      case HintType.none:
      case HintType.textArea:
      default:
        return ListOfObjectsWidget(
          style: _defaultStyle,
          objectType: ObjectType.text,
          config: _parameters,
          parameter: parameter,
          allowDuplicates: widget.config.canDuplicate(parameter),
          maxTextLines: hintType == HintType.textArea ? 3 : 1,
        );
    }
  }

  Widget _buildListOfNumbersField(String parameter) {
    switch (widget.config.getHintType(parameter)) {
      case HintType.color:
        return ListOfObjectsWidget(
          style: _defaultStyle,
          objectType: ObjectType.color,
          config: _parameters,
          parameter: parameter,
          allowDuplicates: widget.config.canDuplicate(parameter),
        );
      default:
        return ListOfObjectsWidget(
          style: _defaultStyle,
          objectType: ObjectType.number,
          config: _parameters,
          parameter: parameter,
          allowDuplicates: widget.config.canDuplicate(parameter),
        );
    }
  }

  Widget _buildListOfDecimalsField(String parameter) {
    return ListOfObjectsWidget(
      style: _defaultStyle,
      objectType: ObjectType.decimal,
      config: _parameters,
      parameter: parameter,
      allowDuplicates: widget.config.canDuplicate(parameter),
    );
  }

  Widget _buildListOfRangesField(String parameter) {
   
    List<dynamic> list = _parameters[parameter];
    List<Map<String, dynamic>> values = [];
    for (Map<String, dynamic> map in list) {
      values.add(map);
    }
    return RangeList(
      style: _defaultStyle,
      parameters: values,
      onRangeListSaved: (params) {
        _parameters[parameter] = params;
      },
    );
  }

  @override
  void setup() {}

  void _save() {
    bool valid = true;

    if (widget.verbose) debugPrint('*** SAVING ***');
    _parameters.forEach((parameter, value) {
      bool required = widget.config.isRequired(parameter);
      dynamic value = _parameters[parameter];

      if (required && null == value) {
        valid = false;
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
            if (value is! num) {
              valid = false;
              alert('Invalid', '$parameter must be a number');
            }
            break;
          case DataType.yesno:
            if (value is! bool) {
              valid = false;
              alert('Invalid', '$parameter must be a boolean');
            }
          case DataType.enumerated:
          case DataType.listOfTexts:
          case DataType.listOfNumbers:
          case DataType.listOfDecimals:
          case DataType.listOfRanges:
          case DataType.listOfFonts:
          case DataType.listOfImages:
            List<dynamic> values = value;
            if (values.isEmpty) {
              valid = false;
              alert('Invalid', '$parameter can not be an empty array');
            }
            break;
          case DataType.font:
          case DataType.none:
            break;
          // TODO: Handle this case.
        }
      }
    });

    if (valid) {
      Navigator.pop(context);
      if (widget.verbose) debugPrint('** PARAMETERS\n$_parameters **');
      widget.onConfigSaved(_parameters);
    }

    if (widget.verbose) debugPrint('** SAVING DONE **');
  }
}
