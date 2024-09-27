import 'package:flutter/material.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/field_card/field_card.dart';

class FieldCardWidget extends StatefulWidget {
  final FieldCardWidgetConfig config;
  const FieldCardWidget({super.key, required this.config});

  @override
  State<FieldCardWidget> createState() => _FieldCardWidgetState();
}

class _FieldCardWidgetState extends BaseState<FieldCardWidget> {
  bool isValidConfig = false;
  bool apiLoadingStatus = false;
  late String title;
  late String deviceId;
  late String field;
  late FontConfig valueFont;
  late FontConfig headingFont;
  late FontConfig contentFont;
  late FontConfig titleFont;
  late Color topSectionColor;
  late Color bottomSectionColor;
  late double width;
  late double height;
  late double imageSize;
  late double topSectionHeight;
  String value = '-';
  String fiedLabel = '-';
  String fiedIcon = '-';
  String fiedDescription = '-';
  
  @override
  void initState() {
    var config = widget.config;
    isValidConfig =
        widget.config.field.isNotEmpty && widget.config.deviceId.isNotEmpty;
    title = config.title;
    field = config.field;
    deviceId = config.deviceId;
    valueFont = FontConfig.fromJson(config.valueFont);
    headingFont = FontConfig.fromJson(config.headingFont);
    contentFont = FontConfig.fromJson(config.contentFont);
    titleFont = FontConfig.fromJson(config.titleFont);
    topSectionColor = Color(config.topSectionColor);
    bottomSectionColor = Color(config.bottomSectionColor);
    width = config.width;
    height = config.height;
    imageSize = config.imageSize;
    topSectionHeight = config.topSectionHeight;
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
        if (title != "")
          Text(title,
              style: TextStyle(
                  fontFamily: titleFont.fontFamily,
                  fontSize: titleFont.fontSize,
                  fontWeight:
                      titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(titleFont.fontColor))),
        SizedBox(
          width: width,
          height: height,
          child: Card(
            color: Colors.white,
            elevation: 4.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            child: Column(
              children: [
                Container(
                  height: topSectionHeight,
                  color: topSectionColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          Text(
                            value,
                            style: TextStyle(
                                fontFamily: valueFont.fontFamily,
                                fontSize: valueFont.fontSize,
                                fontWeight: valueFont.fontBold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: Color(valueFont.fontColor)),
                          ),
                          const SizedBox(width: 15),
                          Flexible(
                            child: Text(
                              fiedLabel,
                              style: TextStyle(
                                fontFamily: headingFont.fontFamily,
                                fontSize: headingFont.fontSize,
                                fontWeight: headingFont.fontBold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: Color(headingFont.fontColor)),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (fiedIcon == "")
                        Icon(
                          Icons.display_settings,
                          size: imageSize,
                          color: bottomSectionColor,
                        ),
                      if (fiedIcon != "")
                        SizedBox(
                            width: imageSize,
                            height: imageSize,
                            child: TwinImageHelper.getDomainImage(fiedIcon))
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: bottomSectionColor,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        fiedDescription,
                        style: TextStyle(
                            fontFamily: contentFont.fontFamily,
                            fontSize: contentFont.fontSize,
                            fontWeight: contentFont.fontBold
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Color(contentFont.fontColor)),
                      ),
                    ),
                  ),
                ),
              ],
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

        if (values.isNotEmpty) {
          Map<String, dynamic> obj = values[0];
          Map<String, dynamic> data = obj['p_source']['data'];

          for (String deviceField in deviceFields) {
            if (deviceField == field) {
              refresh(sync: () {
                value = data[field].toString();
                fiedLabel = TwinUtils.getParameterLabel(field, deviceModel);
                fiedIcon = TwinUtils.getParameterIcon(field, deviceModel);
                fiedDescription = getParameterDescription(field, deviceModel);
              });
            }
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

class FieldCardWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return FieldCardWidget(config: FieldCardWidgetConfig.fromJson(config));
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
    return "Field Card";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return FieldCardWidgetConfig.fromJson(config);
    }
    return FieldCardWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Field Card";
  }
}
