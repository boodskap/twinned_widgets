import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/ems/vertical_progress_bar.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class VerticalProgressBarWidget extends StatefulWidget {
  final VerticalProgressBarWidgetConfig config;
  const VerticalProgressBarWidget({Key? key, required this.config})
      : super(key: key);

  @override
  State<VerticalProgressBarWidget> createState() =>
      _VerticalProgressBarWidgetState();
}

class _VerticalProgressBarWidgetState
    extends BaseState<VerticalProgressBarWidget> {
  bool isValidConfig = false;
  bool apiLoadingStatus = false;

  late String title;
  late String deviceId;
  late String unit;
  late String field;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late Color chartColor;

  late double height;
  late double dashCount;
  late double dashHeight;
  late double dashWidth;
  late double dashSpace;
  late double opacity;

  double progress = 0;

  @override
  void initState() {
    var config = widget.config;

    isValidConfig =
        widget.config.field.isNotEmpty && widget.config.deviceId.isNotEmpty;
    title = config.title;
    unit = config.unit;
    field = config.field;
    deviceId = config.deviceId;

    height = config.height;
    dashCount = config.dashCount;
    dashHeight = config.dashHeight;
    dashWidth = config.dashWidth;
    dashSpace = config.dashSpace;
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

    //  double maxInputValue = determineMax(value);

    // double calculateProgress(double input) {
    //   double maxInputValue = determineMax(input.toDouble());
    //   return (input / maxInputValue) * 100;
    // }

    return Center(
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            Text(title,
                style: TextStyle(
                    fontFamily: titleFont.fontFamily,
                    fontSize: titleFont.fontSize,
                    fontWeight: titleFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(titleFont.fontColor))),
            Text(
              '$progress $unit',
              style: TextStyle(
                  fontFamily: valueFont.fontFamily,
                  fontSize: valueFont.fontSize,
                  fontWeight:
                      valueFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(valueFont.fontColor)),
            ),
            Expanded(
                child: CustomPaint(
              painter: DashedLinePainter(
                  progress: progress,
                  dashCount: dashCount,
                  dashHeight: dashHeight,
                  dashWidth: dashWidth,
                  dashSpace: dashSpace,
                  chartColor: chartColor, opacity: opacity),
            )),
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
              progress = fetchedValue[field] ?? 0;
               progress = double.parse(progress.toStringAsFixed(2));
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

class DashedLinePainter extends CustomPainter {
  final double progress;
  final double dashCount;
  final double dashHeight;
  final double dashWidth;
  final double dashSpace;
  final Color chartColor;
  final double opacity;

  DashedLinePainter(
      {required this.progress,
      required this.dashCount,
      required this.dashHeight,
      required this.dashWidth,
      required this.dashSpace,
      required this.chartColor,
      required this.opacity
      });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = dashHeight;

    double startY = size.height;
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
    double maxInputValue = determineMax(progress);
    for (int i = 0; i < dashCount; i++) {
      if (i < (progress / maxInputValue * dashCount)) {
        paint.color = chartColor;
      } else {
        paint.color = chartColor.withOpacity(opacity);
      }
      startY -= (dashHeight + dashSpace);
      canvas.drawLine(Offset((size.width - dashWidth) / 2.5, startY),
          Offset((size.width + dashWidth) / 2.5, startY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class VerticalProgressBarWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return VerticalProgressBarWidget(
        config: VerticalProgressBarWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.vertical_distribute);
  }

  @override
  String getPaletteName() {
    return "Vertical Progress Bar";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return VerticalProgressBarWidgetConfig.fromJson(config);
    }
    return VerticalProgressBarWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Graph based on device field in vertical representaion";
  }
}
