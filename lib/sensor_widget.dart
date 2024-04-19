import 'package:animated_battery_gauge/battery_gauge.dart';
import 'package:flutter/material.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twinned;
import 'package:twinned_widgets/level/widgets/battery_gauge.dart';
import 'package:twinned_widgets/level/widgets/semi_circle.dart';
import 'package:twinned_widgets/level/widgets/conical_tank.dart';
import 'package:twinned_widgets/level/widgets/corked_bottle.dart';
import 'package:twinned_widgets/level/widgets/cylinder_tank.dart';
import 'package:twinned_widgets/level/widgets/cylindrical_tank.dart';
import 'package:twinned_widgets/level/widgets/cylindrical_tank2.dart';
import 'package:twinned_widgets/level/widgets/gauge.dart';
import 'package:twinned_widgets/level/widgets/rectangular_tank.dart';
import 'package:twinned_widgets/level/widgets/spherical_tank.dart';
import 'package:twinned_widgets/util/TwinnedWidgetUtils.dart';
import 'package:twinned_widgets/level/widgets/prism_tank.dart';
import 'package:twinned_widgets/level/widgets/roof_top_tank.dart';
import 'package:twinned_widgets/level/widgets/trapezoid_tank.dart';
import 'package:twinned_widgets/level/widgets/triangle_tank.dart';
typedef OnSensorSelected = Function(SensorWidgetType? type);
typedef OnSettingsSaved = Function(Map<String, dynamic> settings);

enum SensorWidgetType {
  none('None'),
  speedometer('Speedometer'),
  pressureGauge('Pressure Gauge'),
  conicalTank('Cone'),
  corkedBottle('Corked Bottle'),
  cylindricalTank('Cylinder'),
  rectangularTank('Rectangle'),
  sphericalTank('Sphere'),
  batteryGauge('Battery Gauge'),
  cylinderTank('Cylinder Tank'),
  prismTank('Prism'),
  triangleTank('Triangle'),
  semiCircleTank('Semi Circle'),
  trapezoidTank('Trapezoid'),
  hexagonTank('Hexagon'),
  roofTopTank('Roof Top');

  const SensorWidgetType(this.label);

  final String label;
}

class SensorWidget extends StatefulWidget {
  final twinned.Parameter parameter;
  final twinned.DeviceData deviceData;
  final twinned.DeviceModel deviceModel;
  final bool tiny;

  const SensorWidget(
      {super.key,
      required this.parameter,
      required this.deviceData,
      required this.deviceModel,
      required this.tiny});

  @override
  State<SensorWidget> createState() => _SensorWidgetState();
}

class _SensorWidgetState extends State<SensorWidget> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> settings =
        widget.parameter.sensorWidget!.attributes as Map<String, dynamic>;
    final Map<String, dynamic> data =
        widget.deviceData.data as Map<String, dynamic>;
    final String field = widget.parameter.name;
    final String unit = widget.parameter.unit ?? '';
    String label =
        TwinnedWidgetUtils.getParameterLabel(field, widget.deviceModel);

    if (widget.parameter.sensorWidget!.widgetId == 'none' ||
        !SensorWidgetType.values
            .asNameMap()
            .containsKey(widget.parameter.sensorWidget!.widgetId)) {
      return const Placeholder(
        color: Colors.yellow,
      );
    }

    switch (SensorWidgetType.values
        .byName(widget.parameter.sensorWidget!.widgetId)) {
      case SensorWidgetType.speedometer:
        return Gauge(
          min: settings['minValue'] ?? 0,
          max: settings['maxValue'] ?? 250,
          interval: settings['interval'] ?? 5,
          startAngle: settings['startAngle'] ?? 45,
          endAngle: settings['endAngle'] ?? 15,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          tiny: widget.tiny,
          label: label,
          unit: unit,
          value: data[field] ?? 0,
        );
      case SensorWidgetType.pressureGauge:
        return Gauge(
          min: settings['minValue'] ?? 0,
          max: settings['maxValue'] ?? 3000,
          interval: settings['interval'] ?? 5,
          startAngle: settings['startAngle'] ?? 150,
          endAngle: settings['endAngle'] ?? 30,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          tiny: widget.tiny,
          label: label,
          unit: unit,
          value: data[field] ?? 0,
        );
      case SensorWidgetType.conicalTank:
        return ConicalTank(
          liquidColor: Color(settings['liquidColor'] ?? Colors.blue.value),
          bottleColor: Color(settings['bottleColor'] ?? Colors.black.value),
          shouldAnimate: settings['shouldAnimate'] ?? false,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          breakpoint: settings['breakpoint'] ?? 1.2,
          smoothCorner: settings['smoothCorner'] ?? true,
          label: label,
          liquidLevel: data[field] ?? 0,
        );
      case SensorWidgetType.corkedBottle:
        return CorkedBottle(
          liquidColor: Color(settings['liquidColor'] ?? Colors.blue.value),
          bottleColor: Color(settings['bottleColor'] ?? Colors.black.value),
          capColor: Color(settings['capColor'] ?? Colors.grey.value),
          shouldAnimate: settings['shouldAnimate'] ?? false,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          label: label,
          liquidLevel: data[field] ?? 0,
        );
      case SensorWidgetType.cylindricalTank:
        return CylindricalTank(
          liquidColor: Color(settings['liquidColor'] ?? Colors.blue.value),
          bottleColor: Color(settings['bottleColor'] ?? Colors.black.value),
          shouldAnimate: settings['shouldAnimate'] ?? false,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          breakpoint: settings['breakpoint'] ?? 1.2,
          label: label,
          liquidLevel: data[field] ?? 0,
        );
      case SensorWidgetType.rectangularTank:
        return RectangularTank(
          liquidColor: Color(settings['liquidColor'] ?? Colors.blue.value),
          bottleColor: Color(settings['bottleColor'] ?? Colors.black.value),
          shouldAnimate: settings['shouldAnimate'] ?? false,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          label: label,
          liquidLevel: data[field] ?? 0,
        );
      case SensorWidgetType.sphericalTank:
        return SphericalTank(
          liquidColor: Color(settings['liquidColor'] ?? Colors.blue.value),
          bottleColor: Color(settings['bottleColor'] ?? Colors.black.value),
          shouldAnimate: settings['shouldAnimate'] ?? false,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          breakpoint: settings['breakpoint'] ?? 3,
          label: label,
          liquidLevel: data[field] ?? 0,
        );
      case SensorWidgetType.batteryGauge:
        return SimpleBatteryGauge(
          animated: settings['shouldAnimate'] ?? false,
          label: label,
          poorColor: Color(settings['poorColor'] ?? Colors.red.value),
          lowColor: Color(settings['lowColor'] ?? Colors.orange.value),
          mediumColor:
              Color(settings['mediumColor'] ?? Colors.lightGreen.value),
          highColor: Color(settings['highColor'] ?? Colors.green.value),
          borderColor: Color(settings['borderColor'] ?? Colors.black.value),
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          horizontal: settings['horizontal'] ?? true,
          mode: BatteryGaugePaintMode.values
              .byName(settings['mode'] ?? BatteryGaugePaintMode.none.name),
          tiny: widget.tiny,
          value: 35,
        );
         case SensorWidgetType.cylinderTank:
        return CylinderTank(
          liquidColor: Color(settings['liquidColor'] ?? Colors.blue.value),
          bottleColor: Color(settings['bottleColor'] ?? Colors.black.value),
          shouldAnimate: settings['shouldAnimate'] ?? false,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          label: label,
          liquidLevel: data[field] ?? 0,
        );
        
         case SensorWidgetType.prismTank:
        return PrismTank(
          liquidColor: Color(settings['liquidColor'] ?? Colors.blue.value),
          bottleColor: Color(settings['bottleColor'] ?? Colors.black.value),
          shouldAnimate: settings['shouldAnimate'] ?? false,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          breakpoint: settings['breakpoint'] ?? 1.2,
          label: label,
          liquidLevel: data[field] ?? 0, tiny: widget.tiny,
        );
      case SensorWidgetType.triangleTank:
        return TriangleTank(
          tiny: widget.tiny,
          liquidColor: Color(settings['liquidColor'] ?? Colors.blue.value),
          bottleColor: Color(settings['bottleColor'] ?? Colors.black.value),
          shouldAnimate: settings['shouldAnimate'] ?? false,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          breakpoint: settings['breakpoint'] ?? 1.2,
          label: label,
          liquidLevel: data[field] ?? 0,
        );
      case SensorWidgetType.semiCircleTank:
        return SemiCircleTank(
          tiny: widget.tiny,
          liquidColor: Color(settings['liquidColor'] ?? Colors.blue.value),
          bottleColor: Color(settings['bottleColor'] ?? Colors.black.value),
          shouldAnimate: settings['shouldAnimate'] ?? false,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          breakpoint: settings['breakpoint'] ?? 1.2,
          label: label,
          liquidLevel: data[field] ?? 0,
        );
        case SensorWidgetType.trapezoidTank:
        return TrapezoidTank(
          tiny: widget.tiny,
          liquidColor: Color(settings['liquidColor'] ?? Colors.blue.value),
          bottleColor: Color(settings['bottleColor'] ?? Colors.black.value),
          shouldAnimate: settings['shouldAnimate'] ?? false,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          breakpoint: settings['breakpoint'] ?? 1.2,
          label: label,
          liquidLevel: data[field] ?? 0,
        );
         case SensorWidgetType.hexagonTank:
        return TrapezoidTank(
          tiny: widget.tiny,
          liquidColor: Color(settings['liquidColor'] ?? Colors.blue.value),
          bottleColor: Color(settings['bottleColor'] ?? Colors.black.value),
          shouldAnimate: settings['shouldAnimate'] ?? false,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          breakpoint: settings['breakpoint'] ?? 1.2,
          label: label,
          liquidLevel: data[field] ?? 0,
        );
        case SensorWidgetType.roofTopTank:
        return RoofTopTank(
          tiny: widget.tiny,
          liquidColor: Color(settings['liquidColor'] ?? Colors.blue.value),
          bottleColor: Color(settings['bottleColor'] ?? Colors.black.value),
          shouldAnimate: settings['shouldAnimate'] ?? false,
          fontSize: settings['fontSize'] ?? 10,
          fontWeight: settings['fontBold'] ?? true
              ? FontWeight.bold
              : FontWeight.normal,
          breakpoint: settings['breakpoint'] ?? 1.2,
          label: label,
          liquidLevel: data[field] ?? 0,
        );
      case SensorWidgetType.none:
        break;
    }

    return const Placeholder(
      color: Colors.red,
    );
  }
}

class SensorTypesDropdown extends StatefulWidget {
  final OnSensorSelected onSensorSelected;
  final SensorWidgetType? selected;
  const SensorTypesDropdown(
      {super.key, required this.onSensorSelected, this.selected});

  @override
  State<SensorTypesDropdown> createState() => _SensorTypesDropdownState();
}

class _SensorTypesDropdownState extends State<SensorTypesDropdown> {
  static const Map<SensorWidgetType, String> icons = {
    SensorWidgetType.conicalTank: 'conical_tank.png',
    SensorWidgetType.corkedBottle: 'corked_bottle.png',
    SensorWidgetType.cylindricalTank: 'cylindrical_tank.png',
    SensorWidgetType.pressureGauge: 'pressure_gauge.png',
    SensorWidgetType.rectangularTank: 'rectangular_tank.png',
    SensorWidgetType.speedometer: 'speedometer.png',
    SensorWidgetType.sphericalTank: 'spherical_tank.png',
    SensorWidgetType.batteryGauge: 'battery_gauge.png',
    SensorWidgetType.prismTank: 'prism_tank.png',
    SensorWidgetType.triangleTank: 'triangle_tank.png',
    SensorWidgetType.semiCircleTank: 'semicircle_tank.png',
    SensorWidgetType.trapezoidTank: 'trapezoid_tank.png',
    SensorWidgetType.hexagonTank: 'hexagon_tank.png',
    SensorWidgetType.roofTopTank: 'roof_top_tank.png',
    SensorWidgetType.cylinderTank: 'cylinder_tank.png',
  };

  SensorWidgetType? selected;

  @override
  void initState() {
    selected = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<SensorWidgetType>(
        value: selected,
        iconSize: 64,
        underline: const SizedBox.shrink(),
        items: SensorWidgetType.values.map((e) {
          return DropdownMenuItem<SensorWidgetType>(
              value: e,
              child: Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (e != SensorWidgetType.none)
                    SizedBox(
                        width: 48,
                        height: 48,
                        child: Image.asset(
                          'images/${icons[e]}',
                          fit: BoxFit.contain,
                          package: 'twinned_widgets',
                        )),
                  Text(
                    e.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ));
        }).toList(),
        onChanged: (SensorWidgetType? value) {
          setState(() {
            selected = value;
          });
          widget.onSensorSelected(value);
        });
  }
}
