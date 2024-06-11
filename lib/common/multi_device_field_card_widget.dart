import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/multi_device_field_card/multi_device_field_card.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/grid/grid_widget.dart';
import 'package:twinned_widgets/common/generic_value_card_widget.dart';
import 'package:twinned_models/generic_value_card/generic_value_card.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_models/models.dart';

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
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_circle_rounded, size: 48),
                      Divider(),
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
                      Divider(),
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
                  child: ListView.builder(
                    itemCount: deviceIds.length * fields.length,
                    itemBuilder: (context, index) {
                      final deviceIndex = index ~/ fields.length;
                      final fieldIndex = index % fields.length;
                      return GenericValueCardWidget(
                        config: GenericValueCardWidgetConfig(
                          topLabel: fields[fieldIndex],
                          deviceId: deviceIds[deviceIndex],
                          field: fields[fieldIndex],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void setup() {}
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
