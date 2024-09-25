import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/twinned_models.dart';
import 'package:google_fonts/google_fonts.dart';

class TotalValueWidget extends StatefulWidget {
  final TotalValueWidgetConfig config;
  final TextStyle? style;
  const TotalValueWidget({super.key, this.style, required this.config});

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
  late List<String> assetModelIds;
  late List<String> premiseIds;
  late List<String> facilityIds;
  late List<String> floorIds;
  late List<String> assetIds;
  late List<String> clientIds;
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
    field = config.field;
    modelIds = config.modelIds;
    assetModelIds = config.assetModelIds;
    premiseIds = config.premiseIds;
    facilityIds = config.facilityIds;
    floorIds = config.floorIds;
    assetIds = config.assetIds;
    clientIds = config.clientIds;

    headerFontColor =
        headerFont.fontColor <= 0 ? Colors.black : Color(headerFont.fontColor);
    labelFontColor =
        labelFont.fontColor <= 0 ? Colors.black : Color(labelFont.fontColor);

    isValidConfig = field.isNotEmpty;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = widget.style ??
        GoogleFonts.lato(
          // fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        );
    if (!isValidConfig) {
      return Wrap(
        spacing: 8.0,
        children: [
          Text(
            'Not configured properly - ${_counter++}',
            style: labelStyle.copyWith(
                color: Colors.red, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

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
              style: labelStyle.copyWith(
                  fontWeight:
                      headerFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: headerFont.fontSize,
                  color: headerFontColor),
            ),
            divider(),
            if (null != value)
              Text(
                '${widget.config.fieldPrefix}$value${widget.config.fieldSuffix}',
                style: labelStyle.copyWith(
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
        "sum": {"field": "data.$field"}
      }
    });
    await execute(() async {
      TwinnedSession session = TwinnedSession.instance;

      var sRes = await session.twin.queryDeviceData(
          apikey: session.authToken,
          body: EqlSearch(
              source: [],
              conditions: [stats],
              size: 0,
              queryConditions: [],
              boolConditions: [],
              mustConditions: [
                if (modelIds.isNotEmpty)
                  {
                    "terms": {"modelId": modelIds}
                  },
                if (assetModelIds.isNotEmpty)
                  {
                    "terms": {"assetModelId": assetModelIds}
                  },
                if (premiseIds.isNotEmpty)
                  {
                    "terms": {"premiseId": premiseIds}
                  },
                if (facilityIds.isNotEmpty)
                  {
                    "terms": {"facilityId": facilityIds}
                  },
                if (floorIds.isNotEmpty)
                  {
                    "terms": {"floorId": floorIds}
                  },
                if (assetIds.isNotEmpty)
                  {
                    "terms": {"assetId": assetIds}
                  },
                if (clientIds.isNotEmpty)
                  {
                    "terms": {"clientIds.keyword": clientIds}
                  },
              ]));

      if (validateResponse(sRes)) {
        var json = sRes.body!.result! as Map<String, dynamic>;
        value = json['aggregations']['stats']["value"];
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
