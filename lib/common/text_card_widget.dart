import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/text_card/text_card.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class TextCardWidget extends StatefulWidget {
  final TextCardWidgetConfig config;
  const TextCardWidget({super.key, required this.config});

  @override
  State<TextCardWidget> createState() => _TextCardWidgetState();
}

class _TextCardWidgetState extends BaseState<TextCardWidget> {
  bool isValidConfig = false;
  int totalDevices = 0;
  String deviceName = '';
  DeviceModel? deviceModel;
  late String devicemodelId;
  late double cardHeight;
  late double cardWidth;
  late double cardElevation;
  late double cardRadius;
  late double imageHeight;
  late double imageWidth;
  late double circleRadius;
  late Color cardBgColor;
  late Color circleBgColor;
  late FontConfig titleFont;
  late FontConfig valueFont;

  @override
  void initState() {
    var config = widget.config;
    devicemodelId = config.deviceModelId;
    cardHeight = config.cardHeight;
    cardWidth = config.cardWidth;
    cardElevation = config.cardElevation;
    cardRadius = config.cardRadius;
    imageHeight = config.imageHeight;
    imageWidth = config.imageWidth;
    circleRadius = config.circleRadius;
    cardBgColor = Color(config.cardBgColor);
    circleBgColor = Color(config.circleBgColor);
    titleFont = FontConfig.fromJson(config.titleFont);
    valueFont = FontConfig.fromJson(config.valueFont);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: cardHeight,
        width: cardWidth,
        child: Card(
          elevation: cardElevation,
          color: cardBgColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              divider(horizontal: true),
              CircleAvatar(
                radius: circleRadius,
                backgroundColor: circleBgColor,
                child: deviceModel?.images != null &&
                        deviceModel!.images!.isNotEmpty
                    ? TwinImageHelper.getDomainImage(
                        deviceModel!.images!.first,
                        height: 40,
                        width: 40,
                      )
                    : Container(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$totalDevices',
                    style: TwinUtils.getTextStyle(
                      valueFont,
                    ),
                  ),
                  Text(
                    'Total Devices in ${deviceName.isNotEmpty ? deviceName : '--'}',
                    style: TwinUtils.getTextStyle(
                      titleFont,
                    ),
                  ),
                ],
              ),
              divider(horizontal: true),
            ],
          ),
        ),
      ),
    );
  }

  Future load() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryEqlDevice(
          apikey: TwinnedSession.instance.authToken,
          body: EqlSearch(
            source: [],
            page: 0,
            size: 100,
            mustConditions: [
              {
                "match_phrase": {"modelId": devicemodelId}
              },
            ],
          ));

      deviceModel = await TwinUtils.getDeviceModel(
        modelId: devicemodelId,
      );

      if (deviceModel != null) {
        deviceName = deviceModel!.name;
      }

      if (validateResponse(qRes)) {
        totalDevices = qRes.body!.total;
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

class TextCardWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return TextCardWidget(config: TextCardWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.calendar_view_day_rounded);
  }

  @override
  String getPaletteName() {
    return "Text Card Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return TextCardWidgetConfig.fromJson(config);
    }
    return TextCardWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Text Card Widget";
  }
}
