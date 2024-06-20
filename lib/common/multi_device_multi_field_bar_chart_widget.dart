import 'package:flutter/material.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/multi_device_multi_field_bar_chart/multi_device_multi_field_bar_chart.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class MultiDeviceMultiFieldBarChartWidget extends StatefulWidget {
  final MultiDeviceMultiFieldBarChartWidgetConfig config;
  const MultiDeviceMultiFieldBarChartWidget({super.key, required this.config});

  @override
  State<MultiDeviceMultiFieldBarChartWidget> createState() =>
      _MultiDeviceMultiFieldBarChartWidgetState();
}

class _MultiDeviceMultiFieldBarChartWidgetState
    extends State<MultiDeviceMultiFieldBarChartWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


class MultiDeviceMultiFieldBarChartWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return MultiDeviceMultiFieldBarChartWidget(
        config: MultiDeviceMultiFieldBarChartWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.bar_chart);
  }

  @override
  String getPaletteName() {
    return "Multi Device Multi Field Bar Chart";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return MultiDeviceMultiFieldBarChartWidgetConfig.fromJson(config);
    }
    return MultiDeviceMultiFieldBarChartWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Bar Chart based on Multi Device Multi Field';
  }
}

