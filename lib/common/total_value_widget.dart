import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/twinned_models.dart';

class TotalValueWidget extends StatefulWidget {
  final TotalValueWidgetConfig config;
  const TotalValueWidget({super.key, required this.config});

  @override
  State<TotalValueWidget> createState() => _TotalValueWidgetState();
}

class _TotalValueWidgetState extends BaseState<TotalValueWidget> {
  late Color bgColor;
  late Color borderColor;
  late double borderWidth;
  late double borderRadius;
  late BorderStyle borderStyle;
  late FontConfig headerFont;
  late Color headerFontColor;
  late FontConfig labelFont;
  late Color labelFontColor;
  late String field;
  late List<String> modelIds;
  bool isValidConfig = false;
  int? value;
  int _counter = 0;

  @override
  void initState() {
    //Copy all the config
    var config = widget.config;
    bgColor = config.bgColor <= 0 ? Colors.black : Color(config.bgColor);
    borderColor = config.bgColor <= 0 ? Colors.black : Color(config.bgColor);
    borderWidth = config.borderWidth;
    borderRadius = config.borderRadius;
    borderStyle = config.borderStyle;
    headerFont = FontConfig.fromJson(config.headerFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    field = widget.config.field;
    modelIds = widget.config.modelIds;

    headerFontColor =
        headerFont.fontColor <= 0 ? Colors.black : Color(headerFont.fontColor);
    labelFontColor =
        labelFont.fontColor <= 0 ? Colors.black : Color(labelFont.fontColor);

    isValidConfig = field.isNotEmpty;
    isValidConfig = isValidConfig && modelIds.isNotEmpty;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return Wrap(
        spacing: 8.0,
        children: [
          Text(
            'Not configured properly - ${_counter++}',
            style: const TextStyle(
                color: Colors.red, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

    debugPrint('Value: $value');

    return Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          border: Border.all(
            width: borderWidth,
            color: borderColor,
            style: borderStyle,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.config.title,
              style: TextStyle(
                  fontWeight:
                      headerFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: headerFont.fontSize,
                  color: headerFontColor),
            ),
            divider(),
            if (null != value)
              Text(
                '${widget.config.fieldPrefix}$value${widget.config.fieldSuffix}',
                style: TextStyle(
                    fontWeight: labelFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: labelFont.fontSize,
                    color: labelFontColor),
              ),
          ],
        ));
  }

  Future load() async {
    if (!isValidConfig) return;

    if (loading) return;

    loading = true;

    EqlCondition stats = EqlCondition(name: 'aggs', condition: {
      "stats": {
        "filter": {
          "terms": {"modelId": modelIds}
        },
        "aggs": {
          "sum": {
            "sum": {"field": "data.$field"}
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

class TotalValueWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return TotalValueWidget(config: TotalValueWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.bar_chart);
  }

  @override
  String getPaletteName() {
    return "Total Value";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return TotalValueWidgetConfig.fromJson(config);
    }
    return TotalValueWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Sum of a specific field from the device data';
  }
}
