import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:twinned_widgets/core/twinned_utils.dart';
import 'package:twinned_models/models.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/ems/circular_progress_bar.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class CircularProgressBarWidget extends StatefulWidget {
  final CircularProgressBarWidgetConfig config;
  const CircularProgressBarWidget({Key? key, required this.config})
      : super(key: key);

  @override
  State<CircularProgressBarWidget> createState() =>
      _CircularProgressBarWidgetState();
}

class _CircularProgressBarWidgetState
    extends BaseState<CircularProgressBarWidget> {
  bool isValidConfig = false;
  bool apiLoadingStatus = false;

  late String title;
  late String deviceId;
  late String unit;
  late String field;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late Color chartColor;
  late double width;
  late double height;
  late double opacity;

  double progressValue = 0;

  @override
  void initState() {
    var config = widget.config;

    isValidConfig =
        widget.config.field.isNotEmpty && widget.config.deviceId.isNotEmpty;
    title = config.title;
    unit = config.unit;
    field = config.field;
    deviceId = config.deviceId;
    width = config.width;
    height = config.height;
    opacity = config.opacity;
    titleFont = FontConfig.fromJson(config.titleFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    chartColor = Color(config.chartColor);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Wrap(
        spacing: 8.0,
        children: [
          Text(
            'Not configured properly',
            style:
                TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    double determineMax(double value) {
      if (value <= 100) {
        return 100;
      } else if (value <= 1000) {
        return 1000;
      } else if (value <= 10000) {
        return 10000;
      } else if (value <= 100000) {
        return 100000;
      } else {
        return value;
      }
    }

    double _maxValue = determineMax(progressValue);

    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: SfRadialGauge(
          title: GaugeTitle(
              text: title,
              textStyle: TextStyle(
                  fontFamily: titleFont.fontFamily,
                  fontSize: titleFont.fontSize,
                  fontWeight:
                      titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(titleFont.fontColor))),
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: _maxValue,
              showLabels: false,
              showTicks: false,
              startAngle: 270,
              endAngle: 270,
              axisLineStyle: AxisLineStyle(
                thicknessUnit: GaugeSizeUnit.factor,
                thickness: 0.37,
                dashArray: const <double>[3, 2],
                color: chartColor.withOpacity(opacity),
              ),
              pointers: <GaugePointer>[
                RangePointer(
                  value: progressValue,
                  width: 0.37,
                  sizeUnit: GaugeSizeUnit.factor,
                  color: chartColor,
                  enableAnimation: true,
                  animationDuration: 1000,
                  dashArray: const <double>[3, 2],
                ),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.2,
                  widget: Text(
                    '$progressValue $unit',
                    style: TextStyle(
                        fontFamily: valueFont.fontFamily,
                        fontSize: valueFont.fontSize,
                        fontWeight: valueFont.fontBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: Color(valueFont.fontColor)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceData(
          apikey: TwinnedSession.instance.authToken,
          body: EqlSearch(
            source: ["data"],
            page: 0,
            size: 1,
            mustConditions: [
              {
                "match_phrase": {"deviceId": widget.config.deviceId}
              },
            ],
            sort: {'updatedStamp': 'desc'},
          ));

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        List<dynamic> values = json['hits']['hits'];
        if (values.isNotEmpty) {
          for (Map<String, dynamic> obj in values) {
            dynamic fetchedValue = obj['p_source']['data'];
            refresh(sync: () {
              progressValue = fetchedValue[field] ?? 0;
              progressValue = double.parse(progressValue.toStringAsFixed(2));
            });
          }
        }
      }
    });

    loading = false;
    apiLoadingStatus = true;
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}

class CircularProgressBarWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return CircularProgressBarWidget(
        config: CircularProgressBarWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.cloud_circle);
  }

  @override
  String getPaletteName() {
    return "Circular Progress Bar";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return CircularProgressBarWidgetConfig.fromJson(config);
    }
    return CircularProgressBarWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Graph based on device field in circular representaion";
  }
}
