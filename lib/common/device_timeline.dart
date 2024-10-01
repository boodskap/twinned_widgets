import 'package:flutter/material.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/timeline/device_timeline.dart';

const hdivider = SizedBox(width: 3);
const vdivider = SizedBox(height: 3);

class DeviceTimelineWidget extends StatefulWidget {
  final DeviceTimelineWidgetConfig config;
  const DeviceTimelineWidget({super.key, required this.config});

  @override
  State<DeviceTimelineWidget> createState() => _DeviceTimelineWidgetState();
}

class _DeviceTimelineWidgetState extends BaseState<DeviceTimelineWidget> {
  bool isValidConfig = false;
  bool apiLoadingStatus = false;
  late String title;
  late String deviceId;
  late FontConfig labelFont;
  late FontConfig indicatorFont;
  late FontConfig contentFont;
  late FontConfig titleFont;
  late Color indicatorColor;
  late double width;
  late double height;
  late double borderWidth;
  late double imageSize;
  late double opacity;
  List<Map<String, String>> fetchedData = [];
  List<int> colors = [];

  @override
  void initState() {
    var config = widget.config;
    isValidConfig = widget.config.deviceId.isNotEmpty;
    title = config.title;
    deviceId = config.deviceId;
    labelFont = FontConfig.fromJson(config.labelFont);
    indicatorFont = FontConfig.fromJson(config.indicatorFont);
    contentFont = FontConfig.fromJson(config.contentFont);
    titleFont = FontConfig.fromJson(config.titleFont);
    indicatorColor = Color(config.indicatorColor);
    width = config.width;
    height = config.height;
    borderWidth = config.borderWidth;
    imageSize = config.imageSize;
    opacity = config.opacity;

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
            child: SizedBox(
              width: width,
              height: height,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: fetchedData.length,
                itemBuilder: (context, index) {
                  bool isEven = index % 2 == 0;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: isEven
                        ? [
                            DescriptionTimelineWidget(
                              text: fetchedData[index]['description'].toString(),
                              descTextStyle: TextStyle(
                                  fontFamily: contentFont.fontFamily,
                                  fontSize: contentFont.fontSize,
                                  fontWeight: contentFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Color(contentFont.fontColor)),
                            ),
                            hdivider,
                            CircleIndicator(
                              index: index,
                              total: fetchedData.length,
                              indicatorColor: indicatorColor,
                              indicatorTextStyle: TextStyle(
                                  fontFamily: indicatorFont.fontFamily,
                                  fontSize: indicatorFont.fontSize,
                                  fontWeight: indicatorFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Color(indicatorFont.fontColor)), borderWidth: borderWidth,
                            ),
                            hdivider,
                            NameTimelineWidget(
                              text: fetchedData[index]['label'].toString(),
                              color: index <= colors.length
                                  ? Color(colors[index])
                                  : Color(0XFF9bb67b),
                              isEven: isEven,
                              value: fetchedData[index]['value'].toString(),
                              iconId: fetchedData[index]['icon'].toString(),
                              size: imageSize,
                              labelTextStyle: TextStyle(
                                  fontFamily: labelFont.fontFamily,
                                  fontSize: labelFont.fontSize,
                                  fontWeight: labelFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Color(labelFont.fontColor)),
                              opacity: opacity,
                            ),
                          ]
                        : [
                            NameTimelineWidget(
                              text: fetchedData[index]['label'].toString(),
                              color: index <= colors.length
                                  ? Color(colors[index])
                                  : Color(0XFF9bb67b),
                              isEven: isEven,
                              value: fetchedData[index]['value'].toString(),
                              iconId: fetchedData[index]['icon'].toString(),
                              size: imageSize,
                              labelTextStyle: TextStyle(
                                  fontFamily: labelFont.fontFamily,
                                  fontSize: labelFont.fontSize,
                                  fontWeight: labelFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Color(labelFont.fontColor)),
                              opacity: opacity,
                            ),
                            hdivider,
                            CircleIndicator(
                              index: index,
                              total: fetchedData.length,
                              indicatorColor: indicatorColor,
                              indicatorTextStyle: TextStyle(
                                  fontFamily: indicatorFont.fontFamily,
                                  fontSize: indicatorFont.fontSize,
                                  fontWeight: indicatorFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Color(indicatorFont.fontColor)), borderWidth: borderWidth,
                            ),
                            hdivider,
                            DescriptionTimelineWidget(
                              text: fetchedData[index]['description'].toString(),
                              descTextStyle: TextStyle(
                                  fontFamily: contentFont.fontFamily,
                                  fontSize: contentFont.fontSize,
                                  fontWeight: contentFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Color(contentFont.fontColor)),
                            ),
                          ],
                  );
                },
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
        if (values.isNotEmpty) {
          Map<String, dynamic> obj = values[0];
          Map<String, dynamic> data = obj['p_source']['data'];

          for (String field in deviceFields) {
            String label = TwinUtils.getParameterLabel(field, deviceModel);
            String value = '${data[field] ?? '-'}';
            dynamic iconId = TwinUtils.getParameterIcon(field, deviceModel);
            fetchedData.add({
              'label': label,
              'value': value,
              'description': getParameterDescription(field, deviceModel),
              'icon': iconId ?? ""
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

class CircleIndicator extends StatelessWidget {
  final int index;
  final int total;
  final Color indicatorColor;
  final TextStyle indicatorTextStyle;
  final double borderWidth;
  const CircleIndicator(
      {super.key,
      required this.index,
      required this.total,
      required this.indicatorColor,
      required this.indicatorTextStyle, required this.borderWidth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: index == 0 ? 0 : 0),
      child: Column(
        children: [
          Container(
            width: borderWidth,
            height: 25,
            color: Colors.black,
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: indicatorColor,
            child: Text(
              '${index + 1}',
              style: indicatorTextStyle,
            ),
          ),
          Container(
            width: borderWidth,
            height: index == total - 1 ? 25 : 45,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}

class DescriptionTimelineWidget extends StatelessWidget {
  final String text;
  final TextStyle descTextStyle;
  const DescriptionTimelineWidget(
      {super.key, required this.text, required this.descTextStyle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 2,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 50,
            maxHeight: 100,
          ),
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              style: descTextStyle,
            ),
          ),
        ));
  }
}

class NameTimelineWidget extends StatelessWidget {
  final String text;
  final Color color;
  final bool isEven;
  final String value;
  final String iconId;
  final double size;
  final TextStyle labelTextStyle;
  final double opacity;
  const NameTimelineWidget(
      {super.key,
      required this.text,
      required this.color,
      required this.isEven,
      required this.value,
      required this.iconId,
      required this.size,
      required this.labelTextStyle,
      required this.opacity});

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
                    Text(
                      value,
                      style: labelTextStyle,
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
                    Text(
                      value,
                      style: labelTextStyle,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class DeviceTimelineWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceTimelineWidget(
        config: DeviceTimelineWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.timeline);
  }

  @override
  String getPaletteName() {
    return "Device Timeline";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return DeviceTimelineWidgetConfig.fromJson(config);
    }
    return DeviceTimelineWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Device Timeline";
  }
}
