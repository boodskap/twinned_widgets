import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/range_gauge/range_gauge.dart';
import 'package:twinned_models/models.dart';
import 'package:timeago/timeago.dart' as timeago;

class DeviceFieldRadialGaugeWidget extends StatefulWidget {
  final DeviceFieldRangeGaugeWidgetConfig config;
  const DeviceFieldRadialGaugeWidget({Key? key, required this.config})
      : super(key: key);

  @override
  _DeviceFieldRadialGaugeWidgetState createState() =>
      _DeviceFieldRadialGaugeWidgetState();
}

class _DeviceFieldRadialGaugeWidgetState
    extends BaseState<DeviceFieldRadialGaugeWidget> {
  String title = "Temperature";
  String subtitle = "";
  double value = 0;
  bool isValidConfig = true;

  late String deviceId;
  late String field;
  late double annotationAngle;
  late double axisLineThickness;
  late double endAngle;
  late double startAngle;
  late ElementsPosition elementsPosition;
  late List<dynamic> gaugeRanges;
  late List<Color> gradientColors;
  late double interval;
  late double labelOffset;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late FontConfig subTitleFont;
  late FontConfig valueFont;
  late Color markerColor;
  late double markerElevation;
  late double markerHeight;
  late double markeroffset;
  late bool markerpointerEnableAnimation;
  late double minimum;
  late double maximum;
  late double positionFactor;
  late bool showFirstLabel;
  late bool showLabel;
  late bool showLastLabel;
  late List<double> stops;
  String fieldName = "--";
  String unit = "--";

  @override
  void initState() {
    deviceId = widget.config.deviceId;
    field = widget.config.field;
    annotationAngle = widget.config.annotationAngle;
    axisLineThickness = widget.config.axisLineThickness;
    elementsPosition = widget.config.elementsPosition;
    endAngle = widget.config.endAngle;
    gaugeRanges = widget.config.gaugeRanges;
    gradientColors = widget.config.gradientColors
        .map((colorInt) => Color(colorInt))
        .toList();
    interval = widget.config.interval;
    labelOffset = widget.config.labelOffset;
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    subTitleFont = FontConfig.fromJson(widget.config.subTitleFont);
    labelFont = FontConfig.fromJson(widget.config.labelFont);
    valueFont = FontConfig.fromJson(widget.config.valueFont);

    markerColor = Color(widget.config.markerColor);
    markerElevation = widget.config.markerElevation;
    markerHeight = widget.config.markerHeight;
    markeroffset = widget.config.markeroffset;
    markerpointerEnableAnimation = widget.config.markerpointerEnableAnimation;
    maximum = widget.config.maximum;
    minimum = widget.config.minimum;
    positionFactor = widget.config.positionFactor;
    showFirstLabel = widget.config.showFirstLabel;
    showLabel = widget.config.showLabel;
    showLastLabel = widget.config.showLastLabel;
    startAngle = widget.config.startAngle;
    stops = widget.config.stops;
    subTitleFont = FontConfig.fromJson(widget.config.subTitleFont);
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    valueFont = FontConfig.fromJson(widget.config.valueFont);

    super.initState();

    load();
  }

  @override
  Widget build(BuildContext context) {
    return Container( decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(4), // Border radius
    border: Border.all(
      color: Colors.white, // Border color
      width: 1, // Border width
    ),
  ),
      child: Card(
        elevation: 0, // Elevation can be adjusted as needed
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    fieldName,
                    style: TwinUtils.getTextStyle(titleFont),
                  ),
                  Text(
                    subtitle,
                    style: TwinUtils.getTextStyle(subTitleFont),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 90,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: minimum,
                    maximum: maximum,
                    interval: interval,
                    showLastLabel: true,
                    showLabels: true,
                    showTicks: false,
                    labelsPosition: ElementsPosition.outside,
                    labelOffset: 20,
                    axisLineStyle: AxisLineStyle(
                      thickness: 15,
                      gradient: SweepGradient(
                        colors: gradientColors,
                      ),
                    ),
                    pointers: <GaugePointer>[
                      MarkerPointer(
                        value: value,
                        enableAnimation: true,
                        markerOffset: 10,
                        markerHeight: 20,
                        elevation: 5,
                        color: Color(0xff000000),
                        text: 'Current Value',
                      )
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        angle: 90,
                        positionFactor: 0,
                        widget: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '$value',
                              style: TwinUtils.getTextStyle(valueFont),
                            ),
                            Text(
                              unit.isNotEmpty ? unit : '--',
                              style: TwinUtils.getTextStyle(labelFont),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> load() async {
    if (!isValidConfig || loading) return;
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
              "match_phrase": {"deviceId": deviceId}
            },
            {
              "exists": {"field": "data.$field"}
            },
          ],
        ),
      );
      if (qRes.body != null &&
          qRes.body!.result != null &&
          validateResponse(qRes)) {
        Device? device = await TwinUtils.getDevice(deviceId: deviceId);
        if (device == null) return;

        DeviceModel? deviceModel =
            await TwinUtils.getDeviceModel(modelId: device.modelId);
        // print(deviceModel);

        Map<String, dynamic>? json =
            qRes.body!.result! as Map<String, dynamic>?;
        fieldName = TwinUtils.getParameterLabel(field, deviceModel!);
        unit = TwinUtils.getParameterUnit(field, deviceModel);
        if (json != null) {
          List<dynamic> hits = json['hits']['hits'];

          if (hits.isNotEmpty) {
            Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
            value = obj['p_source']['data'][field];

            setState(() {
              value = value;
              subtitle = _getUpdatedTimeAgo(obj['p_source']['updatedStamp']);
            });
          }
        }
      }
    });
    loading = false;
    refresh();
  }

  String _getUpdatedTimeAgo(int updatedStamp) {
    DateTime updatedDateTime =
        DateTime.fromMillisecondsSinceEpoch(updatedStamp);
    return timeago.format(updatedDateTime);
  }

  @override
  void setup() {
    load();
  }
}
