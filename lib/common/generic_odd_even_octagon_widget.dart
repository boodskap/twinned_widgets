import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/models.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_models/generic_odd_even_octagon/generic_odd_even_octagon.dart';

class GenericOddEvenOctagonWidget extends StatefulWidget {
  final GenericOddEvenOctagonWidgetConfig config;

  const GenericOddEvenOctagonWidget({super.key, required this.config});

  @override
  State<GenericOddEvenOctagonWidget> createState() =>
      _GenericOddEvenOctagonWidgetState();
}

class _GenericOddEvenOctagonWidgetState
    extends BaseState<GenericOddEvenOctagonWidget> {
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
  late Color oddOctagonBGColor;
  late Color evenOctagonBGColor;
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
    oddOctagonBGColor = Color(config.oddOctagonBGColor);
    evenOctagonBGColor = Color(config.evenOctagonBGColor);

    titleFont = FontConfig.fromJson(config.titleFont);
    prefixFont = FontConfig.fromJson(config.prefixFont);
    suffixFont = FontConfig.fromJson(config.suffixFont);
    valueFont = FontConfig.fromJson(config.valueFont);
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
                    children: _buildSameLevelOctagons(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSameLevelOctagons() {
    return deviceData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> item = entry.value;

      bool isEven = index % 2 == 0;

      Color bgColor = isEven ? oddOctagonBGColor : evenOctagonBGColor;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalSpacing),
        child: _buildCard(
          item['prefix']!,
          item['value']!,
          item['suffix']!,
          item['icon']!,
          bgColor,
        ),
      );
    }).toList();
  }

  Widget _buildCard(String prefix, String value, String suffix, String iconId,
      Color bgColor) {
    return ClipPath(
      clipper: OctagonClipper(),
      child: Container(
        height: 150,
        width: 150,
        color: bgColor,
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
              height: 8,
            ),
            if (iconId.isNotEmpty)
              SizedBox(
                width: imageSize,
                height: imageSize,
                child: TwinImageHelper.getDomainImage(iconId),
              ),
            const SizedBox(
              height: 6,
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
                const SizedBox(width: 3),
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
          ],
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

class OctagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;

    double sideLength = width * 0.293;

    Path path = Path();

    path.moveTo(sideLength, 0);
    path.lineTo(width - sideLength, 0);
    path.lineTo(width, sideLength);
    path.lineTo(width, height - sideLength);
    path.lineTo(width - sideLength, height);
    path.lineTo(sideLength, height);
    path.lineTo(0, height - sideLength);
    path.lineTo(0, sideLength);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class GenericOddEvenOctagonWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return GenericOddEvenOctagonWidget(
        config: GenericOddEvenOctagonWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.assistant);
  }

  @override
  String getPaletteName() {
    return "Generic Octagon Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return GenericOddEvenOctagonWidgetConfig.fromJson(config);
    }
    return GenericOddEvenOctagonWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Generic Odd Even Octagon Widget';
  }
}
