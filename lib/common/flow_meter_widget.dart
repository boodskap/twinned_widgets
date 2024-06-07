import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/flow_meter/flow_meter.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';

class FlowMeterWidget extends StatefulWidget {
  final FlowMeterWidgetConfig config;
  const FlowMeterWidget({super.key, required this.config});

  @override
  State<FlowMeterWidget> createState() => _FlowMeterWidgetState();
}

class _FlowMeterWidgetState extends BaseState<FlowMeterWidget> {
  late String title;
  late String deviceId;
  late String field;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late Color innerFillColor;
  late Color innerIndicatorColor;
  late Color innerBorderColor;
  late Color flowColor;
  late Color outerDialColor;
  late Color bodyColor;
  bool isValidConfig = false;
  String value = '';
  String? percentageValue;

  @override
  void initState() {
    var config = widget.config;
    deviceId = widget.config.deviceId;
    title = widget.config.title;
    field = widget.config.field;
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    innerFillColor = config.innerFillColor <= 0
        ? Colors.black
        : Color(config.innerFillColor);
    innerIndicatorColor = config.innerIndicatorColor <= 0
        ? Colors.black
        : Color(config.innerIndicatorColor);
    innerBorderColor = config.innerBorderColor <= 0
        ? Colors.black
        : Color(config.innerBorderColor);
    flowColor = config.flowColor <= 0 ? Colors.black : Color(config.flowColor);
    outerDialColor = config.outerDialColor <= 0
        ? Colors.black
        : Color(config.outerDialColor);
    bodyColor = config.bodyColor <= 0 ? Colors.black : Color(config.bodyColor);
    isValidConfig = widget.config.deviceId.isNotEmpty;
    isValidConfig = isValidConfig && widget.config.field.isNotEmpty;

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
    double percentage = double.tryParse(percentageValue ?? '0') ?? 0;
    return Card(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          height: 450,
          width: 410,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFont.fontSize,
                    color: Color(titleFont.fontColor),
                    fontFamily: titleFont.fontFamily,
                    fontWeight: titleFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        color: bodyColor,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        height: 30,
                        width: 80,
                        color: bodyColor,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          color: bodyColor,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          color: bodyColor,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          color: bodyColor,
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Stack(
                      children: [
                        Container(
                          height: 110,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            border: Border.all(
                              color: outerDialColor,
                              width: 3.0,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            height: 110 * (percentage / 100),
                            width: 50,
                            color: flowColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 6.0, color: outerDialColor),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: innerFillColor,
                          border:
                              Border.all(width: 6.0, color: innerBorderColor),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 40,
                                width: 130,
                                decoration: BoxDecoration(
                                    color: flowColor,
                                    border: Border.all(
                                        color: innerBorderColor, width: 4.0),
                                    borderRadius: BorderRadius.circular(4.0)),
                                child: Center(
                                    child: Text(
                                  value,
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    fontSize: labelFont.fontSize,
                                    color: Color(labelFont.fontColor),
                                    fontFamily: titleFont.fontFamily,
                                    fontWeight: titleFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                )),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: innerIndicatorColor,
                                  border: Border.all(
                                    color: innerBorderColor,
                                    width: 4.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        Container(
                          height: 110,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            border: Border.all(
                              color: outerDialColor,
                              width: 3.0,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            height: 110 * (percentage / 100),
                            width: 50,
                            color: flowColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Column(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          color: bodyColor,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          color: bodyColor,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          color: bodyColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          source: ["data.${widget.config.field}"],
          page: 0,
          size: 1,
          mustConditions: [
            {
              "match_phrase": {"deviceId": widget.config.deviceId}
            },
            {
              "exists": {"field": "data.${widget.config.field}"}
            },
          ],
        ),
      );

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        List<dynamic> values = json['hits']['hits'];
        if (values.isNotEmpty) {
          for (Map<String, dynamic> obj in values) {
            dynamic fetchedValue = obj['p_source']['data'][widget.config.field];
            value = '$fetchedValue';
            double maxValue = 100.0;
            double percentageValueDouble = (fetchedValue / maxValue) * 100;
            percentageValue = percentageValueDouble.toStringAsFixed(2);
          }
        }
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {
    load();
  }
}

class FlowMeterWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return FlowMeterWidget(config: FlowMeterWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.electric_meter);
  }

  @override
  String getPaletteName() {
    return "Flow Meter";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return FlowMeterWidgetConfig.fromJson(config);
    }
    return FlowMeterWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Flow Meter';
  }
}
