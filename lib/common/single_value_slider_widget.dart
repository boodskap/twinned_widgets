import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/slider/slider.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class SingleValueSliderWidget extends StatefulWidget {
  final SingleValueSliderWidgetConfig config;
  const SingleValueSliderWidget({super.key, required this.config});

  @override
  State<SingleValueSliderWidget> createState() =>
      _SingleValueSliderWidgetState();
}

class _SingleValueSliderWidgetState extends BaseState<SingleValueSliderWidget> {
  bool isValidConfig = false;
  late FontConfig titleFont;
  late Color titleFontColor;
  late FontConfig labelFont;
  late Color labelFontColor;
  late FontConfig valueFont;
  late Color valueFontColor;
  late String title;
  late String deviceId;
  late String field;
  late String label;
  late double min;
  late double max;
  late double width;
  late double height;
  late int activeColor;
  late int inactiveColor;
  late double value;
  bool apiLoadingStatus = false;
  bool isMaxValueStatus = false;
  bool isMinValueStatus = false;
  @override
  void initState() {
    var config = widget.config;
    titleFont = FontConfig.fromJson(config.titleFont);
    titleFontColor =
        titleFont.fontColor <= 0 ? Colors.black : Color(titleFont.fontColor);

    labelFont = FontConfig.fromJson(config.labelFont);
    labelFontColor =
        labelFont.fontColor <= 0 ? Colors.black : Color(labelFont.fontColor);

    valueFont = FontConfig.fromJson(config.valueFont);
    valueFontColor =
        valueFont.fontColor <= 0 ? Colors.black : Color(valueFont.fontColor);
    deviceId = widget.config.deviceId;
    title = widget.config.title;
    field = widget.config.field;
    label = widget.config.label;
    min = widget.config.min;
    max = widget.config.max;
    width = widget.config.width;
    height = widget.config.height;
    activeColor = widget.config.activeColor;
    inactiveColor = widget.config.inactiveColor;
    value = 0;
    isValidConfig =
        widget.config.deviceId.isNotEmpty && widget.config.field.isNotEmpty;
    super.initState();
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

    if (!isMinValueStatus) {
      return Center(
        child: Text(
          "Min value should be lesser than $value",
          style: TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
        ),
      );
    }
    if (!isMaxValueStatus) {
      return Center(
        child: Text(
          "Max value should be greater than $value",
          style: TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
              fontWeight:
                  titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
              fontSize: titleFont.fontSize,
              color: titleFontColor),
        ),
        Center(
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          value.toStringAsFixed(0),
                          style: TextStyle(
                              fontWeight: valueFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: valueFont.fontSize,
                              color: valueFontColor),
                        ),
                        Text(
                          label,
                          style: TextStyle(
                              fontWeight: labelFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: labelFont.fontSize,
                              color: labelFontColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    SfSliderTheme(
                      data: SfSliderThemeData(
                          overlayRadius: 0,
                          thumbRadius: 0,
                          activeTrackColor: Color(activeColor),
                          inactiveTrackColor: Color(inactiveColor)),
                      child: SfSlider(
                        min: min,
                        max: max,
                        value: value,
                        thumbShape: _SfThumbShape(),
                        onChanged: (dynamic newValue) {
                          // setState(() {
                          //   _value = newValue;
                          // });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
              value = fetchedValue[field] ?? 0;
              if (value <= max) {
                isMaxValueStatus = true;
              }
              if (value > min) {
                isMinValueStatus = true;
              }
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

class _SfThumbShape extends SfThumbShape {
  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
      required RenderBox? child,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required TextDirection textDirection,
      required SfThumb? thumb}) {
    final Path path = Path();
    final double thumbHeight = -10;

    path.moveTo(center.dx, center.dy - thumbHeight / 2);

    path.quadraticBezierTo(center.dx + 20, center.dy - thumbHeight / 2 + 28,
        center.dx, center.dy - thumbHeight / 2 + 28);

    path.quadraticBezierTo(center.dx - 20, center.dy - thumbHeight / 2 + 28,
        center.dx, center.dy - thumbHeight / 2);

    path.close();

    context.canvas.drawPath(
      path,
      Paint()
        ..color = themeData.activeTrackColor!
        ..style = PaintingStyle.fill
        ..strokeWidth = 1,
    );
  }
}

class SingleValueSliderWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return SingleValueSliderWidget(
        config: SingleValueSliderWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.linear_scale);
  }

  @override
  String getPaletteName() {
    return "Slider";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return SingleValueSliderWidgetConfig.fromJson(config);
    }
    return SingleValueSliderWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Slider';
  }
}
