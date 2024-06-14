import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:twinned_models/generic_value_card/generic_value_card.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/multi_device_field_card/multi_device_field_card.dart';
import 'package:twinned_widgets/common/generic_value_card_widget.dart';
import 'package:twinned_widgets/core/twin_image_helper.dart';
import 'package:twinned_widgets/core/twinned_utils.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';

class MultiDeviceFieldCardWidget extends StatefulWidget {
  final MultiDeviceFieldCardWidgetConfig config;
  const MultiDeviceFieldCardWidget({super.key, required this.config});

  @override
  State<MultiDeviceFieldCardWidget> createState() =>
      _MultiDeviceFieldCardWidgetState();
}

class _MultiDeviceFieldCardWidgetState
    extends BaseState<MultiDeviceFieldCardWidget> {
  bool isValidConfig = false;
  String deviceName = '';
  List<Map<String, String>> deviceData = [];
  Map<String, String> fieldIcons = <String, String>{};
  Map<String, String> fieldSuffix = <String, String>{};

  late List<String> deviceIds;
  late List<String> fields;
  late String iconId;
  late String title;
  late FontConfig titleFont;
  late String message;
  late FontConfig messageFont;
  late String topLabel;
  late FontConfig topFont;
  late FontConfig valueFont;
  late int messageWidth;
  late double iconHeight;
  late double iconWidth;
  late double fieldIconHeight;
  late double fieldIconWidth;
  late double fieldSpacing;
  late double fieldElevation;
  late double cardElevation;
  Widget? iconImage;
  @override
  void initState() {
    deviceIds = widget.config.deviceIds;
    fields = widget.config.fields;
    iconId = widget.config.iconId;
    title = widget.config.title;
    message = widget.config.message;
    topLabel = widget.config.topLabel;
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    messageFont = FontConfig.fromJson(widget.config.messageFont);
    topFont = FontConfig.fromJson(widget.config.topFont);
    valueFont = FontConfig.fromJson(widget.config.valueFont);
    messageWidth = widget.config.messageWidth;
    iconHeight = widget.config.iconHeight;
    iconWidth = widget.config.iconWidth;
    fieldIconWidth = widget.config.fieldIconWidth;
    fieldIconHeight = widget.config.fieldIconHeight;
    fieldSpacing = widget.config.fieldSpacing;
    fieldElevation = widget.config.fieldElevation;
    cardElevation = widget.config.cardElevation;
    isValidConfig =
        deviceIds.isNotEmpty && fields.isNotEmpty && iconId.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text(
          'Not configured properly',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: Card(
            elevation: cardElevation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (null != iconImage)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                              width: iconWidth,
                              height: iconHeight,
                              child: iconImage),
                        ),
                      const Divider(),
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: titleFont.fontFamily,
                          fontSize: titleFont.fontSize,
                          fontWeight: titleFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(titleFont.fontColor),
                        ),
                      ),
                      const Divider(),
                      Text(
                        message,
                        style: TextStyle(
                          fontFamily: messageFont.fontFamily,
                          fontSize: messageFont.fontSize,
                          fontWeight: messageFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(messageFont.fontColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          for (var deviceIndex = 0;
                              deviceIndex < deviceIds.length;
                              deviceIndex++)
                            for (var fieldIndex = 0;
                                fieldIndex < fields.length;
                                fieldIndex++)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: GenericValueCardWidget(
                                    config: GenericValueCardWidgetConfig(
                                      topLabel: fields[fieldIndex],
                                      deviceId: deviceIds[deviceIndex],
                                      field: fields[fieldIndex],
                                      iconId: fieldIcons[fields[fieldIndex]]!,
                                      iconHeight: fieldIconHeight,
                                      iconWidth: fieldIconWidth,
                                      bottomLabel:
                                          fieldSuffix[fields[fieldIndex]] ?? '',
                                    ),
                                  ),
                                ),
                              ),
                        ],
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

  Future<void> load(List<String> deviceIds,
      {String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    await execute(() async {
      for (String deviceId in deviceIds) {
        var qRes = await TwinnedSession.instance.twin.queryDeviceData(
          apikey: TwinnedSession.instance.authToken,
          body: EqlSearch(
            source: ["data"],
            page: 0,
            size: 1,
            mustConditions: [
              {
                "match_phrase": {"deviceId": deviceId}
              },
            ],
          ),
        );

        if (validateResponse(qRes)) {
          Device? device = await TwinnedUtils.getDevice(deviceId: deviceId);
          if (device == null) return;

          deviceName = device.name;
          DeviceModel? deviceModel =
              await TwinnedUtils.getDeviceModel(modelId: device.modelId);

          if (deviceModel == null) return;
          Map<String, dynamic> json =
              qRes.body!.result! as Map<String, dynamic>;

          List<String> deviceFields = NoCodeUtils.getSortedFields(deviceModel);

          List<dynamic> values = json['hits']['hits'];
          List<Map<String, String>> fetchedData = [];

          if (values.isNotEmpty) {
            Map<String, dynamic> obj = values[0];
            Map<String, dynamic> data = obj['p_source']['data'];
            for (String field in deviceFields) {
              String label = NoCodeUtils.getParameterLabel(field, deviceModel);
              String value = '${data[field] ?? '-'}';
              String unit = NoCodeUtils.getParameterUnit(field, deviceModel);
              String iconIds = NoCodeUtils.getParameterIcon(field, deviceModel);
              fieldSuffix[label] = unit;

              if (iconIds.isEmpty) {
                fieldIcons[label] = '';
              } else {
                fieldIcons[label] = iconIds;
              }

              fetchedData.add({
                'field': label,
                'value': value,
              });
            }

            setState(() {
              deviceData = fetchedData;
            });
          }
        }
      }
    });

    if (iconId.isNotEmpty) {
      iconImage = TwinImageHelper.getDomainImage(iconId);
    }

    loading = false;
    refresh();
  }

  @override
  void setup() {
    load(deviceIds);
  }
}

class MultiDeviceFieldCardWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return MultiDeviceFieldCardWidget(
      config: MultiDeviceFieldCardWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.message);
  }

  @override
  String getPaletteName() {
    return "Multi Device Field Card Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return MultiDeviceFieldCardWidgetConfig.fromJson(config);
    }
    return MultiDeviceFieldCardWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Multi Device Field Card Widget values';
  }
}
