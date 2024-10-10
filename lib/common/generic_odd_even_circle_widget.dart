import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/generic_odd_even_circle/generic_odd_even_circle.dart';
import 'package:twinned_models/models.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/twinned_session.dart';

class GenericOddEvenCircleWidget extends StatefulWidget {
  final GenericOddEvenCircleWidgetConfig config;

  const GenericOddEvenCircleWidget({super.key, required this.config});

  @override
  State<GenericOddEvenCircleWidget> createState() =>
      _GenericOddEvenCircleWidgetState();
}

class _GenericOddEvenCircleWidgetState
    extends BaseState<GenericOddEvenCircleWidget> {
  bool isValidConfig = false;
  late String deviceId;
  late String title;
  late String subTitle;
  late FontConfig titleFont;
  late FontConfig prefixFont;
  late FontConfig suffixFont;
  late FontConfig valueFont;
  late FontConfig subTitleFont;
  late Color oddCircleBGColor;
  late Color evenCircleBGColor;
  late Color oddCircleBorderColor;
  late Color evenCircleBorderColor;
  late double oddCircleRadius;
  late double evenCircleRadius;
  late List<Map<String, String>> deviceData;
  List<Map<String, String>> fetchedData = [];
  String mainIcon = "";
  bool apiLoadingStatus = false;
  late double imageSize;
  late double horizontalSpacing;
  late double verticalSpacing;
  late bool isBouncing;

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    title = config.title;
    subTitle = config.subTitle;
    oddCircleBGColor = Color(config.oddCircleBGColor);
    evenCircleBGColor = Color(config.evenCircleBGColor);
    oddCircleBorderColor = Color(config.oddCircleBorderColor);
    evenCircleBorderColor = Color(config.evenCircleBorderColor);

    titleFont = FontConfig.fromJson(config.titleFont);
    prefixFont = FontConfig.fromJson(config.prefixFont);
    suffixFont = FontConfig.fromJson(config.suffixFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    subTitleFont = FontConfig.fromJson(config.subTitleFont);
    oddCircleRadius = config.oddCircleRadius;
    evenCircleRadius = config.evenCircleRadius;
    isValidConfig = deviceId.isNotEmpty;

    verticalSpacing = config.verticalSpacing;
    horizontalSpacing = config.horizontalSpacing;
    imageSize = config.imageSize;

    deviceData = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
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

    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          softWrap: true,
          style: TextStyle(
            fontFamily: titleFont.fontFamily,
            fontSize: titleFont.fontSize,
            fontWeight:
                titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
            color: Color(titleFont.fontColor),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subTitle,
                  softWrap: true,
                  style: TextStyle(
                    fontFamily: subTitleFont.fontFamily,
                    fontSize: subTitleFont.fontSize,
                    fontWeight: subTitleFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(subTitleFont.fontColor),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildSameLevelCircles(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSameLevelCircles() {
    return deviceData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> item = entry.value;

      bool isEven = index % 2 == 0;

      Color bgColor = isEven ? oddCircleBGColor : evenCircleBGColor;
      Color borderColor = isEven ? oddCircleBorderColor : evenCircleBorderColor;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalSpacing),
        child: _buildCircle(
          item['prefix']!,
          item['value']!,
          item['suffix']!,
          item['icon']!,
          bgColor,
          borderColor,
        ),
      );
    }).toList();
  }

  Widget _buildCircle(String prefix, String value, String suffix, String iconId,
      Color bgColor, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor,
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: evenCircleRadius,
        backgroundColor: bgColor.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                prefix.isNotEmpty ? prefix : 'N/A',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: prefixFont.fontFamily,
                  fontSize: prefixFont.fontSize,
                  fontWeight:
                      prefixFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(prefixFont.fontColor),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconId.isNotEmpty)
                    SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: TwinImageHelper.getDomainImage(iconId),
                    ),
                  if (iconId.isEmpty)
                    Icon(Icons.display_settings, size: imageSize),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    value.isNotEmpty ? value : '0',
                    style: TextStyle(
                      fontFamily: valueFont.fontFamily,
                      fontSize: valueFont.fontSize,
                      fontWeight: valueFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(valueFont.fontColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                suffix.isNotEmpty ? suffix : 'N/A',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: suffixFont.fontFamily,
                  fontSize: suffixFont.fontSize,
                  fontWeight:
                      suffixFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(suffixFont.fontColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void setup() {
    _load();
    // TODO: implement setup
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
        ),
      );

      if (validateResponse(qRes)) {
        Device? device =
            await TwinUtils.getDevice(deviceId: widget.config.deviceId);
        if (null == device) return;
        DeviceModel? deviceModel =
            await TwinUtils.getDeviceModel(modelId: device.modelId);
        if (null == deviceModel) return;

        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        List<String> deviceFields = TwinUtils.getSortedFields(deviceModel);

        List<dynamic> values = json['hits']['hits'];
        List<Map<String, String>> fetchedData = [];

        if (values.isNotEmpty) {
          Map<String, dynamic> obj = values[0];
          Map<String, dynamic> data = obj['p_source']['data'];
          for (String field in deviceFields) {
            String label = TwinUtils.getParameterLabel(field, deviceModel);
            String value = '${data[field] ?? '-'}';
            String unit = TwinUtils.getParameterUnit(field, deviceModel);
            dynamic iconId = TwinUtils.getParameterIcon(field, deviceModel);

            fetchedData.add({
              'prefix': label,
              'value': value,
              'suffix': unit,
              'icon': iconId ?? ""
            });
          }
        }
        setState(() {
          deviceData = fetchedData;
        });
      }
    });

    loading = false;
    apiLoadingStatus = true;
    refresh();
  }
}

class GenericOddEvenCircleWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return GenericOddEvenCircleWidget(
        config: GenericOddEvenCircleWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.lens_rounded);
  }

  @override
  String getPaletteName() {
    return "Generic Odd Even Circle Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return GenericOddEvenCircleWidgetConfig.fromJson(config);
    }
    return GenericOddEvenCircleWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Generic Odd Even Circle Widget';
  }
}
