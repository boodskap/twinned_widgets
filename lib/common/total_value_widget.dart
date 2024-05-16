import 'package:twinned_widgets/configs.dart';
import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_widgets/twinned_session.dart';

class TotalValueWidgetConfig {
  final String title;
  final String fieldPrefix;
  final String fieldSuffix;
  final int bgColor;
  final int borderColor;
  final double borderWidth;
  final double borderRadius;
  final BorderStyle borderStyle;
  final FontConfig headerFont;
  final FontConfig labelFont;
  final String field;
  final List<String> modelIds;
  TotalValueWidgetConfig({
    this.title = 'Total',
    this.fieldPrefix = '',
    this.fieldSuffix = '',
    this.bgColor = 0xFFFFFFFF,
    this.borderColor = 0xFFFFFFFF,
    this.borderWidth = 2,
    this.borderRadius = 0,
    this.borderStyle = BorderStyle.solid,
    this.headerFont = const FontConfig(fontSize: 20, fontBold: true),
    this.labelFont = const FontConfig(fontSize: 16, fontBold: true),
    this.field = '',
    this.modelIds = const [],
  });
}

class TotalValueWidget extends StatefulWidget {
  final TotalValueWidgetConfig config;
  const TotalValueWidget({super.key, required this.config});

  @override
  State<TotalValueWidget> createState() => _TotalValueWidgetState();
}

class _TotalValueWidgetState extends BaseState<TotalValueWidget> {
  int? value;

  @override
  Widget build(BuildContext context) {
    debugPrint('Building widget...');
    return SizedBox(
      width: 120,
      height: 120,
      child: Container(
          decoration: BoxDecoration(
            color: Color(widget.config.bgColor),
            borderRadius:
                BorderRadius.all(Radius.circular(widget.config.borderRadius)),
            border: Border.all(
              width: widget.config.borderWidth,
              color: Color(widget.config.borderColor),
              style: widget.config.borderStyle,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.config.title,
                style: TextStyle(
                    fontWeight: widget.config.headerFont.fontBold!
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: widget.config.headerFont.fontSize,
                    color: Color(widget.config.headerFont.fontColor!)),
              ),
              divider(),
              if (null != value)
                Text(
                  '${widget.config.fieldPrefix}$value${widget.config.fieldSuffix}',
                  style: TextStyle(
                      fontWeight: widget.config.headerFont.fontBold!
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: widget.config.headerFont.fontSize,
                      color: Color(widget.config.headerFont.fontColor!)),
                ),
            ],
          )),
    );
  }

  Future load() async {
    if (loading) return;
    loading = true;

    EqlCondition stats = EqlCondition(name: 'aggs', condition: {
      "stats": {
        "filter": {
          "terms": {"modelId": widget.config.modelIds}
        },
        "aggs": {
          "sum": {
            "sum": {"field": "data.${widget.config.field}"}
          }
        }
      }
    });
    await execute(() async {
      TwinnedSession session = TwinnedSession.instance;

      var sRes = await session.twin.queryDeviceData(
          apikey: session.authToken,
          body: EqlSearch(
              conditions: [stats],
              queryConditions: [],
              mustConditions: [],
              boolConditions: [],
              size: 0));

      if (validateResponse(sRes)) {
        debugPrint(sRes.body!.toString());
        var json = sRes.body!.result! as Map<String, dynamic>;
        value = json['aggregations']['stats']['sum']["value"];
      }
    });
    refresh();
    loading = false;
  }

  @override
  void setup() {
    load();
  }
}
