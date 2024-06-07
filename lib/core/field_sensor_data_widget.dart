import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:nocode_commons/sensor_widget.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:twinned_widgets/core/field_sensor_widget.dart';
import 'package:twinned_widgets/core/twin_image_helper.dart';

class FieldSensorDataWidget extends StatelessWidget {
  final List<String> fields;
  final twin.DeviceModel deviceModel;
  final TextStyle? labelStyle;
  final Map<String, dynamic> source;
  final MainAxisAlignment alignment;
  final double spacing;

  const FieldSensorDataWidget(
      {super.key,
      required this.fields,
      required this.deviceModel,
      this.labelStyle = const TextStyle(),
      this.spacing = 0,
      this.alignment = MainAxisAlignment.spaceEvenly,
      required this.source});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    for (String field in fields) {
      children.add(FieldSensorWidget(
        field: field,
        deviceModel: deviceModel,
        source: source,
        labelStyle: labelStyle,
      ));
      if (spacing > 0) {
        children.add(SizedBox(
          width: spacing,
        ));
      }
    }

    return Row(
      mainAxisAlignment: alignment,
      children: children,
    );
  }
}
