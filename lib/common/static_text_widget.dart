import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/twinned_models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class StaticTextWidget extends StatefulWidget {
  final StaticTextWidgetConfig config;
  const StaticTextWidget({super.key, required this.config});

  @override
  State<StaticTextWidget> createState() => _StaticTextWidgetState();
}

class _StaticTextWidgetState extends BaseState<StaticTextWidget> {
  bool isValidConfig = false;
  late String value;
  late int fontSize;
  late Color fontColor;
  late bool fontBold;
  late FontConfig font;
  late String fontFamily;
  final TextEditingController _txtController = TextEditingController();

  @override
  void initState() {
    isValidConfig = widget.config.value.isNotEmpty;
    isValidConfig = isValidConfig && widget.config.value.isNotEmpty;
    var config = widget.config;
    value = config.value.isNotEmpty ? config.value : "Default Text"; 
    // value = config.value;
    font = FontConfig.fromJson(config.font);
    fontColor = font.fontColor <= 0 ? Colors.black : Color(font.fontColor);
    _txtController.text = value;
    fontBold = font.fontBold;
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
            style:
                TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }
    return Center(
      child: Text(
        value,
        style: TextStyle(
          color: fontColor,
          fontSize: font.fontSize,
          fontFamily: font.fontFamily,
          fontWeight: fontBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}

class StaticTextWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return StaticTextWidget(config: StaticTextWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.text_fields);
  }

  @override
  String getPaletteName() {
    return "Static Text";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return StaticTextWidgetConfig.fromJson(config);
    }
    return StaticTextWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Static Text Field';
  }
}
