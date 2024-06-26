import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/generic_value_card/generic_value_card.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/multi_device_field_card/multi_device_field_card.dart';
import 'package:twinned_widgets/common/generic_value_card_widget.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

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

  Future<void> load() async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    try {} catch (e) {
    } finally {
      loading = false;
    }

    if (iconId.isNotEmpty) {
      iconImage = TwinImageHelper.getDomainImage(iconId);
    }

    refresh();
  }

  @override
  void setup() {
    load();
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
