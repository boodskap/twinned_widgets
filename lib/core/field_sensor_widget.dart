import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twin_commons/core/sensor_widget.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:twinned_widgets/core/twin_image_helper.dart';

class FieldSensorWidget extends StatelessWidget {
  final String field;
  final twin.DeviceModel deviceModel;
  final TextStyle? labelStyle;
  final Map<String, dynamic> source;

  const FieldSensorWidget(
      {super.key,
      required this.field,
      required this.deviceModel,
      this.labelStyle = const TextStyle(),
      required this.source});

  @override
  Widget build(BuildContext context) {
    SensorWidgetType type = TwinUtils.getSensorWidgetType(field, deviceModel);
    twin.Parameter? parameter = TwinUtils.getParameter(field, deviceModel);

    if (null == parameter) {
      return const SizedBox(
        width: 80,
        height: 80,
        child: Placeholder(
          color: Colors.red,
        ),
      );
    }

    Widget sensorWidget;

    if (type == SensorWidgetType.none) {
      Widget icon;
      Map<String, dynamic> data = source['data'];
      if (parameter!.icon?.isEmpty ?? true) {
        icon = const Icon(Icons.device_unknown_sharp);
      } else {
        icon = SizedBox(
            width: 24, child: TwinImageHelper.getDomainImage(parameter!.icon!));
      }
      String label = TwinUtils.getParameterLabel(field, deviceModel);
      String unit = TwinUtils.getParameterUnit(field, deviceModel);
      String value = '${data[field] ?? '-'} $unit';
      sensorWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: labelStyle,
          ),
          divider(),
          icon,
          Text(
            value,
            style: labelStyle,
          )
        ],
      );
    } else {
      twin.DeviceData dd = twin.DeviceData.fromJson(source);

      sensorWidget = SizedBox(
        width: 70,
        height: 70,
        child: SensorWidget(
          parameter: parameter!,
          tiny: false,
          deviceData: dd,
          deviceModel: deviceModel,
        ),
      );
    }

    return sensorWidget;
  }
}
