import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/ems/generic_card_image.dart';

class GenericCardImageWidget extends StatefulWidget {
  final GenericCardImageWidgetConfig config;
  const GenericCardImageWidget({Key? key, required this.config})
      : super(key: key);

  @override
  State<GenericCardImageWidget> createState() => _GenericCardImageWidgetState();
}

class _GenericCardImageWidgetState extends BaseState<GenericCardImageWidget> {
  bool isValidConfig = false;
  bool apiLoadingStatus = false;

  late String deviceId;
  late String heading;
  late String field;
  late String content;
  late String contentImage;
  late String backgroundImage;
  late String unit;
  late FontConfig valueFont;
  late FontConfig headingFont;
  late FontConfig contentFont;
  late Color backgroundColor;
  late double width;
  late double height;
  late double opacity;
  late double backgroundImageHeight;
  late int seconds;

  double value = 0;
  @override
  void initState() {
    var config = widget.config;
    isValidConfig =
        widget.config.field.isNotEmpty && widget.config.deviceId.isNotEmpty;
    heading = config.heading;
    content = config.content;
    field = config.field;
    deviceId = config.deviceId;
    valueFont = FontConfig.fromJson(config.valueFont);
    headingFont = FontConfig.fromJson(config.headingFont);
    contentFont = FontConfig.fromJson(config.contentFont);
    backgroundColor = Color(config.backgroundColor);
    unit = config.unit;
    width = config.width;
    height = config.height;
    opacity = config.opacity;
    seconds = config.seconds;
    backgroundImageHeight = config.backgroundImageHeight;
    contentImage = config.contentImage;
    backgroundImage = config.backgroundImage;
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
            style: TextStyle(
                color: Color.fromARGB(255, 133, 11, 3),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 4.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                backgroundImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(4.0)),
                        child: Image.network(
                          'https://${TwinnedSession.instance.host}/rest/nocode/TwinImage/download/${TwinnedSession.instance.domainKey}/$backgroundImage',
                          height: backgroundImageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          color: backgroundColor.withOpacity(opacity),
                          colorBlendMode: BlendMode.darken,
                        ))
                    : Container(
                        height: backgroundImageHeight,
                        width: double.infinity,
                        color: backgroundColor,
                      ),
                Positioned(
                  top: height * 0.3,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heading,
                        style: TextStyle(
                            fontFamily: headingFont.fontFamily,
                            fontSize: headingFont.fontSize,
                            fontWeight: headingFont.fontBold
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Color(headingFont.fontColor)),
                      ),
                      Text(
                        '$value $unit',
                        style: TextStyle(
                            fontFamily: valueFont.fontFamily,
                            fontSize: valueFont.fontSize,
                            fontWeight: valueFont.fontBold
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Color(valueFont.fontColor)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        contentImage.isNotEmpty
                            ? SizedBox(
                                width: 30,
                                height: 30,
                                child: TwinImageHelper.getDomainImage(
                                    contentImage),
                              )
                            : const Icon(Icons.devices_other,
                                color: Colors.white),
                        SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            content,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: contentFont.fontFamily,
                                fontSize: contentFont.fontSize,
                                fontWeight: contentFont.fontBold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: Color(contentFont.fontColor)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future load() async {
    if (!isValidConfig) return;

    if (loading) return;

    loading = true;

    EqlCondition stats = EqlCondition(name: 'aggs', condition: {
      "totalValue": {
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
              size: 100,
              sort: {'updatedStamp': 'desc'},
              queryConditions: [],
              boolConditions: [],
              mustConditions: [
                {
                  "match_phrase": {"deviceId": widget.config.deviceId}
                },
              ]));

      if (validateResponse(sRes)) {
        var json = sRes.body!.result! as Map<String, dynamic>;
        value = json['aggregations']['totalValue']['value'];
        value = double.parse(
            convertKWhToWattMinutes(value, seconds).toStringAsFixed(2));
      }
    });
    refresh();
    loading = false;
    apiLoadingStatus = true;
  }

  @override
  void setup() {
    load();
  }
}

double convertKWhToWattMinutes(double kWh, int seconds) {
  if (seconds != 0) {
    return kWh / seconds;
  } else {
    return kWh / seconds;
  }
}

class GenericCardImageWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return GenericCardImageWidget(
        config: GenericCardImageWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.waves);
  }

  @override
  String getPaletteName() {
    return "Generic Card Image";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return GenericCardImageWidgetConfig.fromJson(config);
    }
    return GenericCardImageWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Generic Card Image";
  }
}
