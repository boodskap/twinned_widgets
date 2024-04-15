import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twinned_widgets/widget_util.dart';

class Gauge extends StatelessWidget {
  final double min;
  final double max;
  final double fontSize;
  final FontWeight fontWeight;
  final double value;
  final bool tiny;
  final String unit;
  final int interval;
  final String label;
  final double startAngle;
  final double endAngle;

  Gauge({
    super.key,
    this.min = 0,
    this.max = 250,
    required this.value,
    required String label,
    required this.tiny,
    this.unit = 'psi',
    this.interval = 5,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
    required this.startAngle,
    required this.endAngle,
  }) : label = WidgetUtil.getStrippedLabel(label);

  @override
  Widget build(BuildContext context) {
    if (tiny) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: [
          SfRadialGauge(axes: <RadialAxis>[
            RadialAxis(
              startAngle: startAngle,
              endAngle: endAngle,
              radiusFactor: 1,
              minimum: min,
              maximum: max,
              labelOffset: 4,
              interval: tiny ? max : max / interval,
              showFirstLabel: true,
              showLastLabel: true,
              showTicks: true,
              canScaleToFit: true,
              axisLabelStyle: const GaugeTextStyle(fontSize: 8),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: value,
                  needleEndWidth: 3,
                )
              ],
            )
          ]),
          Text(
            '$value $unit',
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$label : $value $unit',
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
        ),
        const SizedBox(
          height: 8,
        ),
        Expanded(
          child: SfRadialGauge(axes: <RadialAxis>[
            RadialAxis(
              startAngle: startAngle,
              endAngle: endAngle,
              radiusFactor: 1,
              minimum: min,
              maximum: max,
              labelOffset: 4,
              interval: tiny ? max : max / interval,
              showFirstLabel: true,
              showLastLabel: true,
              showTicks: true,
              canScaleToFit: true,
              axisLabelStyle: const GaugeTextStyle(fontSize: 8),
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: value,
                  needleEndWidth: 3,
                )
              ],
            )
          ]),
        ),
      ],
    );
  }
}
