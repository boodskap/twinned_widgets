import 'package:flutter/material.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/field_card/vertical_field_card.dart';

const hdivider = SizedBox(width: 3);
const vdivider = SizedBox(height: 3);

class VerticalFieldCardWidget extends StatefulWidget {
  final VerticalFieldCardWidgetConfig config;
  const VerticalFieldCardWidget({super.key, required this.config});

  @override
  State<VerticalFieldCardWidget> createState() =>
      _VerticalFieldCardWidgetState();
}

class _VerticalFieldCardWidgetState extends BaseState<VerticalFieldCardWidget> {
  bool isValidConfig = false;
  bool apiLoadingStatus = false;
  late String deviceId;
  late FontConfig labelFont;
  late FontConfig valueFont;
  late FontConfig contentFont;
  late FontConfig titleFont;
  late Color valueBgColor;
  late double width;
  late double height;
  late double borderWidth;
  late double imageSize;
  late double opacity;
  late Color borderColor;
  late double spacing;
  late double valueSectionWidth;
  List<Map<String, String>> fetchedData = [];
  List<int> colors = [];
  String title = "";
  @override
  void initState() {
    var config = widget.config;
    isValidConfig = widget.config.deviceId.isNotEmpty;
    deviceId = config.deviceId;
    labelFont = FontConfig.fromJson(config.labelFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    titleFont = FontConfig.fromJson(config.titleFont);
    valueBgColor = Color(config.valueBgColor);
    borderColor = Color(config.borderColor);
    width = config.width;
    height = config.height;
    borderWidth = config.borderWidth;
    imageSize = config.imageSize;
    opacity = config.opacity;
    spacing = config.spacing;
    valueSectionWidth = config.valueSectionWidth;
    colors = [
      0XFF967bb6,
      0xFFFFA0BE,
      0xFF89EEFD,
      0xFFA2E3C4,
      0XFFFBB84A,
      0XFF68B6A3,
      0XFFFA706D,
      0XFFAE9BF3,
      0XFFA87153,
      0XFFA87153,
      0XFF595741,
      0XFFCD483F,
      0XFFAEF88F,
      0XFFD38634,
      0XFFCFA96F,
    ];

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

    return Column(
      children: [
        vdivider,
        vdivider,
        if (title != "")
          Text(title,
              style: TextStyle(
                  fontFamily: titleFont.fontFamily,
                  fontSize: titleFont.fontSize,
                  fontWeight:
                      titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(titleFont.fontColor))),
        vdivider,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: width,
                height: height,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: (fetchedData.length / 2).ceil(),
                    itemBuilder: (context, index) {
                      int index1 = index * 2;
                      int index2 = index1 + 1;
                      bool hasSecondItem = index2 < fetchedData.length;

                      return Padding(
                        padding: index == 0
                            ? EdgeInsets.symmetric(vertical: 0)
                            : EdgeInsets.symmetric(vertical: spacing),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomCardWidget(
                              text: fetchedData[index1]['label'].toString(),
                              color: index <= colors.length
                                  ? Color(colors[index1])
                                  : Color(0XFF9bb67b),
                              isEven: index1 % 2 != 0,
                              value: fetchedData[index1]['value'].toString(),
                              iconId: fetchedData[index1]['icon'].toString(),
                              size: imageSize,
                              labelTextStyle: TextStyle(
                                  fontFamily: labelFont.fontFamily,
                                  fontSize: labelFont.fontSize,
                                  fontWeight: labelFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Color(labelFont.fontColor)),
                              opacity: opacity,
                              unit: fetchedData[index1]['unit'].toString(),
                              borderWidth: borderWidth,
                              valueTextStyle: TextStyle(
                                  fontFamily: valueFont.fontFamily,
                                  fontSize: valueFont.fontSize,
                                  fontWeight: valueFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Color(valueFont.fontColor)),
                              borderColor: borderColor,
                              valueBgColor: valueBgColor,
                              valueSectionWidth: valueSectionWidth,
                            ),
                            SizedBox(width: spacing),
                            hasSecondItem
                                ? CustomCardWidget(
                                    text:
                                        fetchedData[index2]['label'].toString(),
                                    color: index <= colors.length
                                        ? Color(colors[index2])
                                        : const Color(0XFF9bb67b),
                                    isEven: index2 % 2 != 0,
                                    value:
                                        fetchedData[index2]['value'].toString(),
                                    iconId:
                                        fetchedData[index2]['icon'].toString(),
                                    size: imageSize,
                                    labelTextStyle: TextStyle(
                                        fontFamily: labelFont.fontFamily,
                                        fontSize: labelFont.fontSize,
                                        fontWeight: labelFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(labelFont.fontColor)),
                                    opacity: opacity,
                                    unit:
                                        fetchedData[index2]['unit'].toString(),
                                    valueTextStyle: TextStyle(
                                        fontFamily: valueFont.fontFamily,
                                        fontSize: valueFont.fontSize,
                                        fontWeight: valueFont.fontBold
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: Color(valueFont.fontColor)),
                                    borderWidth: borderWidth,
                                    borderColor: borderColor,
                                    valueBgColor: valueBgColor,
                                    valueSectionWidth: valueSectionWidth)
                                : const PlainWidget(),
                          ],
                        ),
                      );
                    }),
              ),
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
        ),
      );

      if (validateResponse(qRes)) {
        Map<String, dynamic> deviceReportingData =
            qRes.body!.result as Map<String, dynamic>;
        Map<String, dynamic> source =
            deviceReportingData['hits']['hits'][0]['p_source'];
        Device? device =
            await TwinUtils.getDevice(deviceId: widget.config.deviceId);
        if (null == device) return;
        DeviceModel? deviceModel =
            await TwinUtils.getDeviceModel(modelId: device.modelId);
        if (null == deviceModel) return;

        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        List<String> deviceFields = TwinUtils.getSortedFields(deviceModel);
        List<dynamic> values = json['hits']['hits'];
        fetchedData = [];
        title = source['asset'] != "" ? source['asset'] : source['deviceName'];
        if (values.isNotEmpty) {
          Map<String, dynamic> obj = values[0];
          Map<String, dynamic> data = obj['p_source']['data'];

          for (String field in deviceFields) {
            String label = TwinUtils.getParameterLabel(field, deviceModel);
            String value = '${data[field].toStringAsFixed(2) ?? '-'}';
            dynamic iconId = TwinUtils.getParameterIcon(field, deviceModel);
            String unit = TwinUtils.getParameterUnit(field, deviceModel);
            fetchedData.add({
              'label': label,
              'value': value,
              'description': getParameterDescription(field, deviceModel),
              'icon': iconId ?? "",
              'unit': unit
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

getParameterDescription(String name, DeviceModel deviceModel) {
  for (var p in deviceModel.parameters) {
    if (p.name == name) {
      return p.description ?? '-';
    }
  }
  return '-';
}

class PlainWidget extends StatelessWidget {
  const PlainWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(flex: 2, child: Container());
  }
}

class CustomCardWidget extends StatelessWidget {
  final String text;
  final Color color;
  final bool isEven;
  final String value;
  final String iconId;
  final double size;
  final TextStyle labelTextStyle;
  final double opacity;
  final String unit;
  final TextStyle valueTextStyle;
  final double borderWidth;
  final Color borderColor;
  final Color valueBgColor;
  final double valueSectionWidth;
  const CustomCardWidget(
      {super.key,
      required this.text,
      required this.color,
      required this.isEven,
      required this.value,
      required this.iconId,
      required this.size,
      required this.labelTextStyle,
      required this.opacity,
      required this.unit,
      required this.valueTextStyle,
      required this.borderWidth,
      required this.borderColor,
      required this.valueBgColor,
      required this.valueSectionWidth});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 50,
          maxHeight: 80,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(opacity),
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: isEven
              ? const BorderRadius.only(
                  topRight: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                ),
        ),
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isEven
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      constraints: BoxConstraints(
                        minWidth: valueSectionWidth / 2 != 0
                            ? valueSectionWidth / 2
                            : 30,
                        maxWidth: valueSectionWidth,
                      ),
                      decoration: BoxDecoration(
                          color: valueBgColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: borderColor, width: borderWidth)),
                      child: Tooltip(
                        message: '$value $unit',
                        child: Flexible(
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            '$value $unit',
                            style: valueTextStyle,
                          ),
                        ),
                      ),
                    ),
                    hdivider,
                    Flexible(
                      child: Text(
                        softWrap: true,
                        text,
                        style: labelTextStyle,
                      ),
                    ),
                    hdivider,
                    CircleAvatar(
                        radius: size,
                        backgroundColor: color,
                        child: ClipOval(
                          child: iconId != ""
                              ? SizedBox(
                                  width: size * 1.4,
                                  height: size * 1.4,
                                  child: TwinImageHelper.getDomainImage(iconId))
                              : Icon(
                                  Icons.display_settings,
                                  size: size,
                                ),
                        )),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                        radius: size,
                        backgroundColor: color,
                        child: ClipOval(
                          child: iconId != ""
                              ? SizedBox(
                                  width: size * 1.4,
                                  height: size * 1.4,
                                  child: TwinImageHelper.getDomainImage(iconId))
                              : Icon(
                                  Icons.display_settings,
                                  size: size,
                                ),
                        )),
                    hdivider,
                    Flexible(
                      child: Text(
                        softWrap: true,
                        text,
                        style: labelTextStyle,
                      ),
                    ),
                    hdivider,
                    Container(
                      padding: const EdgeInsets.all(4),
                      constraints: BoxConstraints(
                        minWidth: valueSectionWidth / 2 != 0
                            ? valueSectionWidth / 2
                            : 30,
                        maxWidth: valueSectionWidth,
                      ),
                      decoration: BoxDecoration(
                          color: valueBgColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: borderColor, width: borderWidth)),
                      child: Tooltip(
                        message: '$value $unit',
                        child: Flexible(
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            '$value $unit',
                            style: valueTextStyle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class VerticalFieldCardWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return VerticalFieldCardWidget(
        config: VerticalFieldCardWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.credit_card);
  }

  @override
  String getPaletteName() {
    return "Vertical Field Card";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return VerticalFieldCardWidgetConfig.fromJson(config);
    }
    return VerticalFieldCardWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Device Timeline";
  }
}
