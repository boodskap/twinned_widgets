import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/directional_widget/directional_widget.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class ArrowData {
  final String label;
  final String value;

  ArrowData({
    required this.label,
    required this.value,
  });
}

class DirectionalWidget extends StatefulWidget {
  final DirectionalWidgetConfig config;

  const DirectionalWidget({super.key, required this.config});

  @override
  State<DirectionalWidget> createState() => _DirectionalWidgetState();
}

class _DirectionalWidgetState extends BaseState<DirectionalWidget> {
  bool isConfigValid = false;
  Map<String, dynamic> fieldValues = {};
  late String title;
  late Color bgColor;
  late Color widgetColor;
  late FontConfig titleFont;
  late FontConfig labelFont;
  late FontConfig valueFont;
  late String deviceIds;
  List<String> fields = [];

  @override
  void initState() {
    title = widget.config.title;
    widgetColor = Color(widget.config.widgetColor);
    bgColor = Color(widget.config.bgColor);
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    labelFont = FontConfig.fromJson(widget.config.labelFont);
    valueFont = FontConfig.fromJson(widget.config.valueFont);

    fields = widget.config.fields;
    deviceIds = widget.config.deviceId;

    isConfigValid = fields.isNotEmpty && deviceIds.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isConfigValid) {
      return const Center(
        child: Wrap(
          spacing: 8.0,
          children: [
            Text(
              'Not configured properly',
              style:
                  TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
    }

    List<ArrowData> arrows = fieldValues.entries.map((entry) {
      return ArrowData(label: entry.key, value: entry.value.toString());
    }).toList();

    return loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: TwinUtils.getTextStyle(titleFont),
                ),
              ),
              divider(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  double arrowHeight = 30;
                  double arrowPadding = 20;
                  double totalHeightPerArrow = arrowHeight + arrowPadding;

                  return SingleChildScrollView(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: arrows.isNotEmpty
                                ? arrows.length * totalHeightPerArrow
                                : totalHeightPerArrow,
                            child: CustomPaint(
                              size: Size(constraints.maxWidth * 0.8,
                                  arrows.length * totalHeightPerArrow),
                              painter: SignalDiagramPainter(arrows, 1.0,
                                  widgetColor, valueFont, labelFont),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
  }

  Future<void> load() async {
    if (!isConfigValid) return;
    if (loading) return;
    loading = true;

    await execute(() async {
      var query = EqlSearch(
        source: ["data"],
        page: 0,
        size: 1,
        mustConditions: [
          {
            "match_phrase": {"deviceId": widget.config.deviceId}
          }
        ],
      );

      var qRes = await TwinnedSession.instance.twin.queryDeviceData(
        apikey: TwinnedSession.instance.authToken,
        body: query,
      );

      if (qRes.body != null &&
          qRes.body!.result != null &&
          validateResponse(qRes)) {
        Map<String, dynamic>? json =
            qRes.body!.result! as Map<String, dynamic>?;

        if (json != null) {
          List<dynamic> hits = json['hits']['hits'];

          if (hits.isNotEmpty) {
            Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
            Map<String, dynamic> source =
                obj['p_source'] as Map<String, dynamic>;
            Map<String, dynamic> data = source['data'] as Map<String, dynamic>;

            for (var field in widget.config.fields) {
              fieldValues[field] = data[field] ?? 0.0;
            }
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

class SignalDiagramPainter extends CustomPainter {
  final List<ArrowData> arrows;
  final double scaleFactor;
  final Color arrowColor;
  final FontConfig valueFont;
  final FontConfig labelFont;

  SignalDiagramPainter(this.arrows, this.scaleFactor, this.arrowColor,
      this.valueFont, this.labelFont);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    const double poleWidth = 20.0;
    const double arrowHeight = 30.0;
    const double arrowPadding = 20.0;

    final double scaledArrowHeight = arrowHeight * scaleFactor;
    final double poleHeight =
        arrows.length * (scaledArrowHeight + arrowPadding) + arrowPadding;
    final double poleLeft = (size.width - poleWidth) / 2;
    final double poleTop = (size.height - poleHeight) / 2;

    Rect pole = Rect.fromLTWH(poleLeft, poleTop, poleWidth, poleHeight);
    RRect roundedPole =
        RRect.fromRectAndRadius(pole, const Radius.circular(10));
    canvas.drawRRect(roundedPole, paint);

    Rect base = Rect.fromLTWH(poleLeft - 30, poleTop + poleHeight, 80, 30);
    RRect roundedBase =
        RRect.fromRectAndRadius(base, const Radius.circular(10));
    canvas.drawRRect(roundedBase, paint);

    for (int i = 0; i < arrows.length; i++) {
      final arrow = arrows[i];
      String direction = (i % 2 == 0) ? 'left' : 'right';

      Offset position = Offset(
          poleLeft, poleTop + (i * (scaledArrowHeight + arrowPadding)) + 10);

      drawArrow(
        canvas,
        paint,
        position,
        const Offset(140, 40),
        arrow.label,
        arrow.value,
        direction: direction,
        height: scaledArrowHeight,
      );
    }
  }

  void drawArrow(Canvas canvas, Paint paint, Offset position, Offset arrowSize,
      String label, String value,
      {required String direction, required double height}) {
    Path arrowPath = Path();

    double lineStartX =
        direction == 'left' ? position.dx - 80 : position.dx + 20;
    double lineEndX = direction == 'left' ? position.dx : position.dx + 100;

    canvas.drawLine(
      Offset(lineStartX, position.dy),
      Offset(lineEndX, position.dy),
      paint,
    );
    canvas.drawLine(
      Offset(lineStartX, position.dy + height),
      Offset(lineEndX, position.dy + height),
      paint,
    );

    if (direction == 'left') {
      arrowPath.moveTo(lineStartX, position.dy);
      arrowPath.lineTo(lineStartX - arrowSize.dx / 4, position.dy + height / 2);
      arrowPath.lineTo(lineStartX, position.dy + height);
    } else {
      arrowPath.moveTo(lineEndX, position.dy);
      arrowPath.lineTo(lineEndX + arrowSize.dx / 4, position.dy + height / 2);
      arrowPath.lineTo(lineEndX, position.dy + height);
    }

    canvas.drawPath(arrowPath, paint);

    TextSpan valueSpan = TextSpan(
        text: value,
        style: TextStyle(
          fontSize: valueFont.fontSize,
          fontWeight: valueFont.fontBold ? FontWeight.bold : FontWeight.normal,
          color: Color(valueFont.fontColor),
        ));
    TextPainter valueTp = TextPainter(
      text: valueSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    valueTp.layout();

    double valueX = lineStartX + (lineEndX - lineStartX - valueTp.width) / 2;
    double valueY = position.dy + (height - valueTp.height) / 2;
    valueTp.paint(canvas, Offset(valueX, valueY));

    TextSpan labelSpan = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: labelFont.fontSize,
          fontWeight: labelFont.fontBold ? FontWeight.bold : FontWeight.normal,
          color: Color(labelFont.fontColor),
        ));
    TextPainter labelTp = TextPainter(
      text: labelSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    labelTp.layout();
    labelTp.paint(
        canvas,
        Offset(lineStartX + (lineEndX - lineStartX - labelTp.width) / 2,
            position.dy - labelTp.height - 4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class DirectionalWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DirectionalWidget(config: DirectionalWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.directions);
  }

  @override
  String getPaletteName() {
    return "Directional Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return DirectionalWidgetConfig.fromJson(config);
    }
    return DirectionalWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Directional Widget";
  }
}
