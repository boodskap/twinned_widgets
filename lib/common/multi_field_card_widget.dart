import 'package:flutter/material.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/core/device_dropdown.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/field_card/multi_field_card.dart';

class MultiFieldCardWidget extends StatefulWidget {
  final MultiFieldCardWidgetConfig config;
  const MultiFieldCardWidget({super.key, required this.config});

  @override
  State<MultiFieldCardWidget> createState() => _MultiFieldCardWidgetState();
}

class _MultiFieldCardWidgetState extends BaseState<MultiFieldCardWidget> {
  bool isValidConfig = false;
  bool apiLoadingStatus = false;
  late String title;
  late String modelId;
  late List<String> fields;
  late FontConfig valueFont;
  late FontConfig headingFont;
  late FontConfig contentFont;
  late FontConfig titleFont;
  late Color bottomSectionColor;
  late double width;
  late double height;
  late double imageSize;
  late double topSectionHeight;
  late List<Map<String, dynamic>> fieldDataList;
  late double spacing;
  List<int> colors = [];
  String value = '-';
  String fiedLabel = '-';
  String fiedIcon = '-';
  String fiedDescription = '-';

  String? selectedDeviceId;
  @override
  void initState() {
    var config = widget.config;
    isValidConfig =
        widget.config.field.isNotEmpty && widget.config.modelId.isNotEmpty;
    title = config.title;
    fields = config.field;
    modelId = config.modelId;
    valueFont = FontConfig.fromJson(config.valueFont);
    headingFont = FontConfig.fromJson(config.headingFont);
    contentFont = FontConfig.fromJson(config.contentFont);
    titleFont = FontConfig.fromJson(config.titleFont);
    bottomSectionColor = Color(config.bottomSectionColor);
    width = config.width;
    height = config.height;
    imageSize = config.imageSize;
    spacing = config.spacing;
    topSectionHeight = config.topSectionHeight;

    colors = [
      0xFF189309,
      0XFF0096FF,
      0XFFffde21,
      0XFFFF0000,
      0XFFE1C16E,
      0XFF8A9A5B,
      0XFF00008B,
      0XFFFFA500,
      0XFFDE3163,
      0XFF673147,
      0XFF7393B3,
      0XFF93C572,
      0XFF7F00FF,
      0XFF800000,
      0XFF808080,
      0XFF708090,
      0XFFFAA0A0,
      0XFFF33A6A,
      0XFF5F9EA0,
      0XFF770737,
    ];

    super.initState();
  }

  @override
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
        if (title.isNotEmpty)
          Text(
            title,
            style: TextStyle(
              fontFamily: titleFont.fontFamily,
              fontSize: titleFont.fontSize,
              fontWeight:
                  titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
              color: Color(titleFont.fontColor),
            ),
          ),
        Wrap(
          spacing:spacing,
          runSpacing: spacing,
          children: fieldDataList.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> fieldData = entry.value;
            Color dynamicColor = Color(colors[index % colors.length]);
            return SizedBox(
              width: width,
              height: height,
              child: Card(
                color: Colors.white,
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Container(
                      height: topSectionHeight,
                      color: dynamicColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 100,
                              child: DeviceDropdown(
                                selectedItem: selectedDeviceId,
                                dropDownDialogPadding: EdgeInsets.zero,
                                isCollapse: true,
                                onDeviceSelected: (Device? device) {
                                  setState(() {
                                    selectedDeviceId = device?.id;
                                    _load();
                                  });
                                },
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                fieldData['value'],
                                style: TextStyle(
                                  fontFamily: valueFont.fontFamily,
                                  fontSize: valueFont.fontSize,
                                  fontWeight: valueFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: Color(valueFont.fontColor),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  fieldData['label'],
                                  style: TextStyle(
                                    fontFamily: headingFont.fontFamily,
                                    fontSize: headingFont.fontSize,
                                    fontWeight: headingFont.fontBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: Color(headingFont.fontColor),
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (fieldData['icon'].isEmpty)
                            Icon(
                              Icons.display_settings,
                              size: imageSize,
                              color: bottomSectionColor,
                            ),
                          if (fieldData['icon'].isNotEmpty)
                            SizedBox(
                              width: imageSize,
                              height: imageSize,
                              child: TwinImageHelper.getDomainImage(
                                  fieldData['icon']),
                            ),
                          const SizedBox(height: 10),
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
                            fieldData['description'],
                            style: TextStyle(
                              fontFamily: contentFont.fontFamily,
                              fontSize: contentFont.fontSize,
                              fontWeight: contentFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: Color(contentFont.fontColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future _load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;
    await execute(() async {
      var mustConditions = [
        {
          "match_phrase": {"modelId": widget.config.modelId}
        },
      ];

      if (selectedDeviceId != null && selectedDeviceId!.isNotEmpty) {
        mustConditions.add({
          "match_phrase": {"deviceId": selectedDeviceId!}
        });
      }

      var qRes = await TwinnedSession.instance.twin.queryDeviceData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          source: ["data"],
          page: 0,
          size: 1,
          mustConditions: mustConditions,
        ),
      );

      if (validateResponse(qRes)) {
        DeviceModel? deviceModel =
            await TwinUtils.getDeviceModel(modelId: widget.config.modelId);
        if (deviceModel == null) return;

        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        List<dynamic> values = json['hits']['hits'];

        fieldDataList = [];

        if (values.isNotEmpty) {
          Map<String, dynamic> obj = values[0];
          Map<String, dynamic> data = obj['p_source']['data'];

          List<String> deviceFields = TwinUtils.getSortedFields(deviceModel);

          for (String deviceField in deviceFields) {
            for (String field in fields) {
              if (deviceField == field) {
                setState(() {
                  fieldDataList.add({
                    'value': data[field].toString(),
                    'label': TwinUtils.getParameterLabel(field, deviceModel),
                    'icon': TwinUtils.getParameterIcon(field, deviceModel),
                    'description': getParameterDescription(field, deviceModel),
                  });
                });
              }
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

class MultiFieldCardWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return MultiFieldCardWidget(
        config: MultiFieldCardWidgetConfig.fromJson(config));
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
    return "Multi Field Card";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return MultiFieldCardWidgetConfig.fromJson(config);
    }
    return MultiFieldCardWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Multi Field Card";
  }
}
