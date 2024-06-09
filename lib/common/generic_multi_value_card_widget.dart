import 'package:flutter/material.dart';
import 'package:twinned_models/generic_muti_value_card/generic_multi_value_card.dart';
import 'package:twinned_models/generic_value_card/generic_value_card.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

import 'generic_value_card_widget.dart';

class GenericMultiValueCardWidget extends StatefulWidget {
  final GenericMultiValueCardWidgetConfig config;
  const GenericMultiValueCardWidget({super.key, required this.config});

  @override
  State<GenericMultiValueCardWidget> createState() =>
      _GenericMultiValueCardWidgetState();
}

class _GenericMultiValueCardWidgetState
    extends State<GenericMultiValueCardWidget> {
  bool isValidConfig = false;

  void _initState() {
    int count = widget.config.fields.length;

    isValidConfig = widget.config.fields.length == count &&
        widget.config.deviceIds.length == count &&
        widget.config.topFonts.length == count &&
        widget.config.topLabels.length == count &&
        widget.config.bottomLabels.length == count &&
        widget.config.bottomFonts.length == count &&
        widget.config.valueBgColors.length == count &&
        widget.config.iconIds.length == count;
    widget.config.iconWidth;
    widget.config.iconHeight;
  }

  @override
  Widget build(BuildContext context) {
    _initState();

    if (!isValidConfig) {
      return const Center(
        child: Wrap(
          spacing: 8,
          children: [
            Text(
              'Not configured properly',
              style:
                  TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
            )
          ],
        ),
      );
    }

    ScrollPhysics? scrollPhysics;

    if (widget.config.allowScrolling) {
      scrollPhysics = const NeverScrollableScrollPhysics();
    }

    return Align(
      alignment: Alignment.center,
      child: GridView.builder(
        shrinkWrap: true,
        physics: scrollPhysics,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.config.columns),
        itemBuilder: (_, index) => _buildCard(index),
        itemCount: widget.config.fields.length,
      ),
    );
  }

  Widget _buildCard(int i) {
    var c = widget.config;
    return GenericValueCardWidget(
      config: GenericValueCardWidgetConfig(
        field: c.fields[i],
        deviceId: c.deviceIds[i],
        bottomFont: c.bottomFonts[i],
        bottomLabel: c.bottomLabels[i],
        elevation: c.elevation,
        iconHeight: c.iconHeight,
        iconWidth: c.iconWidth,
        iconId: c.iconIds[i],
        topFont: c.topFonts[i],
        topLabel: c.topLabels[i],
        valueBgColor: c.valueBgColors[i],
        valueFont: c.valueFonts[i],
        bottomLabelAsSuffix: c.bottomLabelAsSuffix,
      ),
    );
  }
}

class GenericMultiValueCardWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return GenericMultiValueCardWidget(
      config: GenericMultiValueCardWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.all_out_sharp);
  }

  @override
  String getPaletteName() {
    return "Generic Multi Value Card";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return GenericMultiValueCardWidgetConfig.fromJson(config);
    }
    return GenericMultiValueCardWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Multiple sensor field values are displayed in cards';
  }
}
