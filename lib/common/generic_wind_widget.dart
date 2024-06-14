import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/generic_wind/generic_wind.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GenericWindInfoWidget extends StatefulWidget {
  final GenericWindInfoWidgetConfig config;
  const GenericWindInfoWidget({super.key, required this.config});

  @override
  State<GenericWindInfoWidget> createState() => _GenericWindInfoWidgetState();
}

class _GenericWindInfoWidgetState extends BaseState<GenericWindInfoWidget> {
  bool isValidConfig = false;
  late FontConfig titleFont;
  late Color titleFontColor;
  late FontConfig labelFont;
  late Color labelFontColor;
  late String windTitle;
  late String deviceId;
  late String separator;
  late String gustTitle;
  late String speedTitle;
  late String windField;
  late String gustField;
  late String directionField;
  late double windValue;
  late double width;
  late double height;
  late double contentFontSize;
  bool apiLoadingStatus = false;

  @override
  void initState() {
    var config = widget.config;
    titleFont = FontConfig.fromJson(config.titleFont);
    titleFontColor =
        titleFont.fontColor <= 0 ? Colors.black : Color(titleFont.fontColor);

    labelFont = FontConfig.fromJson(config.labelFont);
    labelFontColor =
        labelFont.fontColor <= 0 ? Colors.black : Color(labelFont.fontColor);
    deviceId = widget.config.deviceId;
    windTitle = widget.config.windTitle;
    separator = widget.config.separator;
    gustTitle = widget.config.gustTitle;
    speedTitle = widget.config.speedTitle;
    windField = widget.config.windField;
    gustField = widget.config.gustField;
    directionField = widget.config.directionField;
    windValue = 0;
    width = widget.config.width.toDouble();
    height = widget.config.height.toDouble();
    contentFontSize = widget.config.contentFontSize.toDouble();
    isValidConfig = widget.config.deviceId.isNotEmpty;
    super.initState();
  }

  double getAngle(String direction) {
    switch (direction.toLowerCase().trim()) {
      case 'east':
        return 0;
      case 'southeast':
        return 45;
      case 'south':
        return 90;
      case 'southwest':
        return 135;
      case 'west':
        return 180;
      case 'northwest':
        return 225;
      case 'north':
        return 270;
      case 'northeast':
        return 315;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text(
          'Not configured properly',
          style: TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
        ),
      );
    }
    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.config.windTitle,
                  style: TextStyle(
                      fontWeight: titleFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: titleFont.fontSize,
                      color: titleFontColor)),
              const SizedBox(width: 20),
              Text(widget.config.separator,
                  style: TextStyle(
                      fontWeight: labelFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: labelFont.fontSize,
                      color: labelFontColor)),
              const SizedBox(width: 20),
              Text(widget.config.gustTitle,
                  style: TextStyle(
                      fontWeight: labelFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: labelFont.fontSize,
                      color: labelFontColor)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          startAngle: 0,
                          endAngle: 360,
                          minimum: 0,
                          maximum: 360,
                          showTicks: false,
                          showLabels: false,
                          axisLineStyle: AxisLineStyle(
                              dashArray: const <double>[2, 4],
                              color: labelFontColor),
                          pointers: <GaugePointer>[
                            MarkerPointer(
                                value: windValue,
                                markerHeight: 30,
                                markerWidth: 15,
                                color: titleFontColor)
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              angle: 0,
                              positionFactor: 0.87,
                              widget: Text(
                                'E',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: labelFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: labelFontColor),
                              ),
                            ),
                            GaugeAnnotation(
                              angle: 45,
                              positionFactor: 0.87,
                              widget: Text(
                                'SE',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: labelFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: labelFontColor),
                              ),
                            ),
                            GaugeAnnotation(
                              angle: 90,
                              positionFactor: 0.87,
                              widget: Text(
                                'S',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: labelFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: labelFontColor),
                              ),
                            ),
                            GaugeAnnotation(
                              angle: 135,
                              positionFactor: 0.87,
                              widget: Text(
                                'SW',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: labelFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: labelFontColor),
                              ),
                            ),
                            GaugeAnnotation(
                              angle: 180,
                              positionFactor: 0.87,
                              widget: Text(
                                'W',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: labelFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: labelFontColor),
                              ),
                            ),
                            GaugeAnnotation(
                              angle: 225,
                              positionFactor: 0.87,
                              widget: Text(
                                'NW',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: labelFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: labelFontColor),
                              ),
                            ),
                            GaugeAnnotation(
                              angle: 270,
                              positionFactor: 0.87,
                              widget: Text(
                                'N',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: labelFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: labelFontColor),
                              ),
                            ),
                            GaugeAnnotation(
                              angle: 315,
                              positionFactor: 0.87,
                              widget: Text(
                                'NE',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: labelFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: labelFontColor),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned.fill(
                      child: Center(
                        child: SizedBox(
                          width: width * 0.4,
                          height: height * 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(windField,
                                      style: TextStyle(
                                          fontSize: contentFontSize,
                                          fontWeight: titleFont.fontBold
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: titleFontColor)),
                                  SizedBox(width: 15),
                                  Text(widget.config.separator,
                                      style: TextStyle(
                                          fontSize: contentFontSize,
                                          fontWeight: labelFont.fontBold
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: labelFontColor)),
                                  SizedBox(width: 5),
                                  Text(gustField,
                                      style: TextStyle(
                                          fontSize: contentFontSize,
                                          fontWeight: labelFont.fontBold
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: labelFontColor))
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(widget.config.speedTitle,
                                      style: TextStyle(
                                          fontSize: contentFontSize * 0.35,
                                          fontWeight: labelFont.fontBold
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: labelFontColor)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("FROM",
                      style: TextStyle(
                          fontSize: contentFontSize * 0.4,
                          fontWeight: labelFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: labelFontColor)),
                  Text(directionField,
                      style: TextStyle(
                          fontSize: contentFontSize * 0.5,
                          fontWeight: titleFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: titleFontColor)),
                ],
              )
            ],
          ),
        ],
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
        ),
      );

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        List<dynamic> values = json['hits']['hits'];
        if (values.isNotEmpty) {
          for (Map<String, dynamic> obj in values) {
            dynamic fetchedValue = obj['p_source']['data'];
            refresh(sync: () {
              windField = fetchedValue[windField]?.toString() ?? '--';
              directionField = fetchedValue[directionField]?.toString() ?? '--';
              gustField = fetchedValue[gustField]?.toString() ?? '--';
              windValue = getAngle(directionField);
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

class GenericWindWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return GenericWindInfoWidget(
        config: GenericWindInfoWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.sensors);
  }

  @override
  String getPaletteName() {
    return "Generic Wind";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return GenericWindInfoWidgetConfig.fromJson(config);
    }
    return GenericWindInfoWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Generic Wind';
  }
}
