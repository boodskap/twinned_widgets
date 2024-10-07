import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/generic_up_down_triangle/generic_up_down_triangle.dart';
import 'package:twinned_models/models.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'dart:math' as math;

class GenericUpDownTriangleWidget extends StatefulWidget {
  final GenericUpDownTriangleWidgetConfig config;

  const GenericUpDownTriangleWidget({super.key, required this.config});

  @override
  State<GenericUpDownTriangleWidget> createState() =>
      _GenericUpDownTriangleWidgetState();
}

class _GenericUpDownTriangleWidgetState
    extends BaseState<GenericUpDownTriangleWidget> {
  bool isValidConfig = false;
  late String deviceId;
  late String title;
  late String subTitle;
  late FontConfig titleFont;
  late FontConfig prefixFont;
  late FontConfig suffixFont;
  late FontConfig valueFont;
  late FontConfig prefixMainFont;
  late FontConfig suffixMainFont;
  late FontConfig valueMainFont;
  late FontConfig subTitleFont;
  late Color upTriangleBGColor;
  late Color downTriangleBGColor;
  late List<Map<String, String>> deviceData;
  List<Map<String, String>> fetchedData = [];

  String mainPrefixValue = "";
  String mainValue = "";
  String mainSufficValue = "";
  String mainIcon = "";
  bool apiLoadingStatus = false;
  late double imageSize;
  late double horizontalSpacing;

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    title = config.title;
    subTitle = config.subTitle;
    upTriangleBGColor = Color(config.upTriangleBGColor);
    downTriangleBGColor = Color(config.downTriangleBGColor);

    titleFont = FontConfig.fromJson(config.titleFont);
    prefixFont = FontConfig.fromJson(config.prefixFont);
    suffixFont = FontConfig.fromJson(config.suffixFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    prefixMainFont = FontConfig.fromJson(config.prefixMainFont);
    suffixMainFont = FontConfig.fromJson(config.suffixMainFont);
    valueMainFont = FontConfig.fromJson(config.valueMainFont);
    subTitleFont = FontConfig.fromJson(config.subTitleFont);
    isValidConfig = deviceId.isNotEmpty;

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
                    children: _buildSameLevelTriangles(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSameLevelTriangles() {
    return deviceData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> item = entry.value;

      bool isEven = index % 2 == 0;

      Color bgColor = isEven ? upTriangleBGColor : downTriangleBGColor;
      bool flip = isEven;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalSpacing),
        child: _buildTriangle(
          item['prefix']!,
          item['value']!,
          item['suffix']!,
          item['icon']!,
          bgColor,
          flip,
        ),
      );
    }).toList();
  }

  Widget _buildTriangle(String prefix, String value, String suffix, String iconId,
      Color bgColor, bool isEven) {
    return Transform(
      alignment: Alignment.center,
      transform: isEven ? Matrix4.rotationX(math.pi) : Matrix4.identity(),
      child: ClipPath(
        clipper: TriangleClipper(),
        child: Container(
          height: 150,
          width: 150,
          color: bgColor.withOpacity(0.7),
          child: Transform(
            alignment: Alignment.center,
            transform: isEven ? Matrix4.rotationX(math.pi) : Matrix4.identity(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: isEven
                  ? [
                      // For odd triangles
                      Text(
                        prefix.isNotEmpty ? prefix : 'N/A',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: prefixFont.fontFamily,
                          fontSize: prefixFont.fontSize,
                          fontWeight: prefixFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(prefixFont.fontColor),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            suffix.isNotEmpty ? suffix : 'N/A',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: suffixFont.fontFamily,
                              fontSize: suffixFont.fontSize,
                              fontWeight: suffixFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: Color(suffixFont.fontColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      if (iconId.isNotEmpty)
                        SizedBox(
                          width: imageSize,
                          height: imageSize,
                          child: TwinImageHelper.getDomainImage(iconId),
                        ),
                    ]
                  : [
                      // For even triangles
                      if (iconId.isNotEmpty)
                        SizedBox(
                          width: imageSize,
                          height: imageSize,
                          child: TwinImageHelper.getDomainImage(iconId),
                        ),
                      const SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            suffix.isNotEmpty ? suffix : 'N/A',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: suffixFont.fontFamily,
                              fontSize: suffixFont.fontSize,
                              fontWeight: suffixFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: Color(suffixFont.fontColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        prefix.isNotEmpty ? prefix : 'N/A',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: prefixFont.fontFamily,
                          fontSize: prefixFont.fontSize,
                          fontWeight: prefixFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(prefixFont.fontColor),
                        ),
                      ),
                    ],
            ),
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
            if (field != value) {
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

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Calculate height of an equilateral triangle using Pythagoras' theorem
    double height = size.width * (math.sqrt(3) / 2);

    Path path = Path();
    // Start at the bottom left corner
    path.moveTo(0, height);
    // Draw a line to the top center of the triangle
    path.lineTo(size.width / 2, 0);
    // Draw a line to the bottom right corner
    path.lineTo(size.width, height);
    // Close the path to form the triangle
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class GenericUpDownTriangleWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return GenericUpDownTriangleWidget(
        config: GenericUpDownTriangleWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.change_history_rounded);
  }

  @override
  String getPaletteName() {
    return "Generic Triangle Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return GenericUpDownTriangleWidgetConfig.fromJson(config);
    }
    return GenericUpDownTriangleWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Generic Up Down Triangle Widget';
  }
}
