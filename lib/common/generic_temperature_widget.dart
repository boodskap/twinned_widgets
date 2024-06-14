import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/generic_temperature/generic_temperature.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';

class GenericTemperatureWidget extends StatefulWidget {
  final GenericTemperatureWidgetConfig config;
  const GenericTemperatureWidget({super.key, required this.config});

  @override
  State<GenericTemperatureWidget> createState() =>
      _GenericTemperatureWidgetState();
}

class _GenericTemperatureWidgetState
    extends BaseState<GenericTemperatureWidget> {
  late String title;
  late String deviceId;
  late String currentTitle;
  late String dewPointTitle;
  late String humidityTitle;
  late String windChillTitle;
  late String temperatureField;
  late String dewPointField;
  late String humidityField;
  late String windChillField;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late Color widgetColor;
  bool isValidConfig = false;
  late bool displayInCelcius;

  @override
  void initState() {
    var config = widget.config;
    deviceId = widget.config.deviceId;
    title = widget.config.title;
    currentTitle = widget.config.currentTitle;
    dewPointTitle = widget.config.dewPointTitle;
    humidityTitle = widget.config.humidityTitle;
    windChillTitle = widget.config.windChillTitle;
    temperatureField = widget.config.temperatureField;
    dewPointField = widget.config.dewPointField;
    humidityField = widget.config.humidityField;
    windChillField = widget.config.windChillField;
    widgetColor =
        config.widgetColor <= 0 ? Colors.black : Color(config.widgetColor);
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    displayInCelcius = widget.config.displayInCelcius;
    isValidConfig = widget.config.deviceId.isNotEmpty;
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(titleFont.fontColor),
            fontSize: titleFont.fontSize,
            fontFamily: titleFont.fontFamily,
            fontWeight:
                titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Expanded(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 150.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: widgetColor, width: 8.0),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.config.currentTitle,
                            style: TextStyle(
                              color: Color(labelFont.fontColor),
                              fontSize: labelFont.fontSize,
                              fontFamily: labelFont.fontFamily,
                              fontWeight: labelFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ('$temperatureField°'),
                                style: TextStyle(
                                  color: widgetColor,
                                  fontSize: 40,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(-12.0, 7.0),
                                child: Text(
                                  displayInCelcius ? 'C' : 'F',
                                  style: TextStyle(
                                    color: Color(labelFont.fontColor),
                                    fontSize: 12,
                                    fontFamily: labelFont.fontFamily,
                                    fontWeight: labelFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.config.dewPointTitle,
                            style: TextStyle(
                              color: Color(labelFont.fontColor),
                              fontSize: labelFont.fontSize,
                              fontFamily: labelFont.fontFamily,
                              fontWeight: labelFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Text(
                            dewPointField,
                            style: TextStyle(
                              color: Color(titleFont.fontColor),
                              fontSize: titleFont.fontSize,
                              fontFamily: titleFont.fontFamily,
                              fontWeight: titleFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            widget.config.humidityTitle,
                            style: TextStyle(
                              color: Color(labelFont.fontColor),
                              fontSize: labelFont.fontSize,
                              fontFamily: labelFont.fontFamily,
                              fontWeight: labelFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Text(
                            humidityField,
                            style: TextStyle(
                              color: Color(titleFont.fontColor),
                              fontSize: titleFont.fontSize,
                              fontFamily: titleFont.fontFamily,
                              fontWeight: titleFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            widget.config.windChillTitle,
                            style: TextStyle(
                              color: Color(labelFont.fontColor),
                              fontSize: labelFont.fontSize,
                              fontFamily: labelFont.fontFamily,
                              fontWeight: labelFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Text(
                            windChillField,
                            style: TextStyle(
                              color: Color(titleFont.fontColor),
                              fontSize: titleFont.fontSize,
                              fontFamily: titleFont.fontFamily,
                              fontWeight: titleFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ),
      ],
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
            setState(() {
              temperatureField =
                  fetchedValue[temperatureField]?.toString() ?? '--';
              dewPointField = fetchedValue[dewPointField]?.toString() ?? '--';
              humidityField = fetchedValue[humidityField]?.toString() ?? '--';
              windChillField = fetchedValue[windChillField]?.toString() ?? '--';
            });
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

class GenericTemperatureWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return GenericTemperatureWidget(
        config: GenericTemperatureWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.thermostat);
  }

  @override
  String getPaletteName() {
    return "Generic Temperature";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return GenericTemperatureWidgetConfig.fromJson(config);
    }
    return GenericTemperatureWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Generic Temperature';
  }
}
