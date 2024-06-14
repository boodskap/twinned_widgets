import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/generic_air_quality/generic_air_quality_circle.dart';
import 'package:twinned_models/models.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_widgets/core/twinned_utils.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/twinned_session.dart';


class GenericAirQualityCircleWidget extends StatefulWidget {
  final GenericAirQualityCircleWidgetConfig config;

  const GenericAirQualityCircleWidget({super.key, required this.config});

  @override
  State<GenericAirQualityCircleWidget> createState() =>
      _GenericAirQualityCircleWidgetState();
}

class _GenericAirQualityCircleWidgetState
    extends BaseState<GenericAirQualityCircleWidget> {
  bool isValidConfig = false;
  late String deviceId;
  late String title;
  late String subTitle;
  late String mainText;
  late String mainField;
  late FontConfig titleFont;
  late FontConfig prefixFont;
  late FontConfig suffixFont;
  late FontConfig valueFont;
  late FontConfig prefixMainFont;
  late FontConfig suffixMainFont;
  late FontConfig valueMainFont;
  late FontConfig mainTextFont;
  late FontConfig subTitleFont;
  late Color activeCircleBGColor;
  late Color inactiveCircleBGColor;
  late Color activeCircleBorderColor;
  late Color inactiveCircleBorderColor;
  late double activeCircleRadius;
  late double inactiveCircleRadius;
  late List<Map<String, String>> deviceData;
  List<Map<String, String>> fetchedData = [];

  String mainPrefixValue = "";
  String mainValue = "";
  String mainSufficValue = "";
  String mainIcon = "";
  bool apiLoadingStatus = false;
  late double imageSize;
  late double horizontalSpacing;
  late double verticalSpacing;

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    title = config.title;
    subTitle = config.subTitle;
    mainField = config.mainField;
    activeCircleBGColor = Color(config.activeCircleBGColor);
    inactiveCircleBGColor = Color(config.inactiveCircleBGColor);
    activeCircleBorderColor = Color(config.activeCircleBorderColor);
    inactiveCircleBorderColor = Color(config.inactiveCircleBorderColor);

    titleFont = FontConfig.fromJson(config.titleFont);
    prefixFont = FontConfig.fromJson(config.prefixFont);
    suffixFont = FontConfig.fromJson(config.suffixFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    prefixMainFont = FontConfig.fromJson(config.prefixMainFont);
    suffixMainFont = FontConfig.fromJson(config.suffixMainFont);
    valueMainFont = FontConfig.fromJson(config.valueMainFont);
    mainTextFont = FontConfig.fromJson(config.mainTextFont);
    subTitleFont = FontConfig.fromJson(config.subTitleFont);
    activeCircleRadius = config.activeCircleRadius;
    inactiveCircleRadius = config.inactiveCircleRadius;
    isValidConfig = deviceId.isNotEmpty;

    verticalSpacing = config.verticalSpacing;
    horizontalSpacing = config.horizontalSpacing;
    imageSize = config.imageSize;
    mainText = config.mainText;

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
        SizedBox(height: 20),
        Text(title,
            style: TextStyle(
                fontFamily: titleFont.fontFamily,
                fontSize: titleFont.fontSize,
                fontWeight:
                    titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
                color: Color(titleFont.fontColor))),
        Expanded(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(subTitle,
                    softWrap: true,
                    style: TextStyle(
                        fontFamily: subTitleFont.fontFamily,
                        fontSize: subTitleFont.fontSize,
                        fontWeight: subTitleFont.fontBold
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: Color(subTitleFont.fontColor))),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMainCircle(),
                      const SizedBox(width: 10),
                      ..._buildMinorCircleList()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMinorCircleList() {
    return deviceData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> item = entry.value;
      bool isEven = index % 2 == 0;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEven)
            Padding(
              padding: EdgeInsets.only(
                  bottom: verticalSpacing,
                  left: horizontalSpacing,
                  right: horizontalSpacing),
              child: _buildMinorCircle(
                item['prefix'],
                item['value'],
                item['suffix'],
                item['icon'],
              ),
            ),
          if (!isEven) ...[
            SizedBox(height: verticalSpacing),
            SizedBox(width: horizontalSpacing)
          ],
          if (!isEven)
            _buildMinorCircle(
              item['prefix'],
              item['value'],
              item['suffix'],
              item['icon'],
            ),
          if (isEven) ...[
            SizedBox(height: verticalSpacing),
            SizedBox(width: horizontalSpacing)
          ],
        ],
      );
    }).toList();
  }

  Widget _buildMainCircle() {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: activeCircleBorderColor, width: 2),
          boxShadow: [
            BoxShadow(
                color: activeCircleBorderColor,
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 0))
          ]),
      child: CircleAvatar(
        radius: activeCircleRadius,
        backgroundColor: activeCircleBGColor.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(mainPrefixValue,
                  style: TextStyle(
                      fontFamily: prefixMainFont.fontFamily,
                      fontSize: prefixMainFont.fontSize,
                      fontWeight: prefixMainFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(prefixMainFont.fontColor))),
              Text(mainText,
                  style: TextStyle(
                      fontFamily: mainTextFont.fontFamily,
                      fontSize: mainTextFont.fontSize,
                      fontWeight: mainTextFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(mainTextFont.fontColor))),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (mainIcon == "")
                    Icon(Icons.display_settings, size: imageSize),
                  if (mainIcon != "")
                    SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: TwinImageHelper.getDomainImage(mainIcon)),
                  SizedBox(width: 5),
                  Text(mainValue.toString(),
                      style: TextStyle(
                          fontFamily: valueMainFont.fontFamily,
                          fontSize: valueMainFont.fontSize,
                          fontWeight: valueMainFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(valueMainFont.fontColor)))
                ],
              ),
              Text(mainSufficValue,
                  style: TextStyle(
                      fontFamily: suffixMainFont.fontFamily,
                      fontSize: suffixMainFont.fontSize,
                      fontWeight: suffixMainFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(suffixMainFont.fontColor))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinorCircle(
      String prefix, String value, String suffix, String iconId) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: inactiveCircleBorderColor, width: 1),
      ),
      child: CircleAvatar(
        radius: inactiveCircleRadius,
        backgroundColor: inactiveCircleBGColor.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(prefix,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: prefixFont.fontFamily,
                      fontSize: prefixFont.fontSize,
                      fontWeight: prefixFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(prefixFont.fontColor))),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconId == "")
                    Icon(Icons.display_settings, size: imageSize),
                  if (iconId != "")
                    SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: TwinImageHelper.getDomainImage(iconId)),
                  SizedBox(width: 5),
                  Text(value.toString(),
                      style: TextStyle(
                          fontFamily: valueFont.fontFamily,
                          fontSize: valueFont.fontSize,
                          fontWeight: valueFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(valueFont.fontColor)))
                ],
              ),
              Text(suffix,
                  style: TextStyle(
                      fontFamily: suffixFont.fontFamily,
                      fontSize: suffixFont.fontSize,
                      fontWeight: suffixFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(suffixFont.fontColor))),
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
            if (field != mainField) {
              fetchedData.add({
                'prefix': label,
                'value': value,
                'suffix': unit,
                'icon': iconId ?? ""
              });
            } else {
              mainPrefixValue = label;
              mainSufficValue = unit;
              mainValue = value;
              mainIcon = iconId ?? "";
            }
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

class GenericAirQualityCircleWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return GenericAirQualityCircleWidget(
        config: GenericAirQualityCircleWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.cloud_circle);
  }

  @override
  String getPaletteName() {
    return "Generic Circle Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return GenericAirQualityCircleWidgetConfig.fromJson(config);
    }
    return GenericAirQualityCircleWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Generic Circle Widget';
  }
}
