library twinned_widgets;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/common/asset_model_data_grid_widget.dart';
import 'package:twinned_widgets/common/asset_model_grid_widget.dart';
import 'package:twinned_widgets/common/device_cartesian_chart_widget.dart';
import 'package:twinned_widgets/common/device_data_accordion_widget.dart';
import 'package:twinned_widgets/common/device_field_percentage_widget.dart';
import 'package:twinned_widgets/common/device_field_range_label_dial_widget.dart';
import 'package:twinned_widgets/common/device_min_max_avg_widget.dart';
import 'package:twinned_widgets/common/device_multi_field_chart_widget.dart';
import 'package:twinned_widgets/common/device_multi_field_dial_widget.dart';
import 'package:twinned_widgets/common/dynamic_text_widget.dart';
import 'package:twinned_widgets/common/flow_meter_widget.dart';
import 'package:twinned_widgets/common/generic_day_weather_widget.dart';
import 'package:twinned_widgets/common/generic_multi_value_card_widget.dart';
import 'package:twinned_widgets/common/generic_temperature_widget.dart';
import 'package:twinned_widgets/common/generic_value_card_widget.dart';
import 'package:twinned_widgets/common/generic_wind_widget.dart';
import 'package:twinned_widgets/common/multiple_device_model_chart_widget.dart';
import 'package:twinned_widgets/common/static_text_widget.dart';
import 'package:twinned_widgets/common/timestamp_widget.dart';
import 'package:twinned_widgets/common/total_and_reporting_asset_widget.dart';
import 'package:twinned_widgets/common/total_value_widget.dart';
import 'package:twinned_widgets/common/value_distribution_pie_widget.dart';
import 'package:twinned_widgets/common/static_timeline_widget.dart';
import 'package:twinned_widgets/common/generic_air_quality_widget.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'common/multiple_device_cartesian_chart_widget.dart';
import 'package:twinned_widgets/common/single_value_slider_widget.dart';
export 'common/total_value_widget.dart';
export 'common/value_distribution_pie_widget.dart';
export 'common/total_and_reporting_asset_widget.dart';
export 'twinned_config_builder.dart';
export 'twinned_widget_builder.dart';
export 'twinned_session.dart';

final Map<String, TwinnedWidgetBuilder> _builders = {
  'TWTotalValueWidget': TotalValueWidgetBuilder(),
  'TWValueDistributionPieChartWidget': ValueDistributionPieChartWidgetBuilder(),
  'TWTotalAndReportingAssetWidget': TotalAndReportingAssetWidgetBuilder(),
  'TWDeviceCartesianChartWidget': DeviceCartesianChartWidgetBuilder(),
  'TWMultipleDeviceCartesianChartWidget':
      MultipleDeviceCartesianChartWidgetBuilder(),
  'TWDeviceMultiFieldChartWidget': DeviceMultiFieldChartWidgetBuilder(),
  'TWDeviceFieldPercentageWidget': DeviceFieldPercentageWidgetBuilder(),
  'TWStaticTextWidget': StaticTextWidgetBuilder(),
  'TWDeviceMinMaxAvgWidget': DeviceMinMaxAvgWidgetBuilder(),
  'TWDynamicTextWidget': DynamicTextWidgetBuilder(),
  'TWMultipleDeviceModelChartWidget': MultipleDeviceModelChartWidgetBuilder(),
  'TWTimeStampWidget': TimeStampWidgetBuilder(),
  'TWAssetModelGridWidget': AssetModelGridWidgetBuilder(),
  'TWDeviceMultiFieldDialWidget': DeviceMultiFieldDialWidgetBuilder(),
  'TWAssetModelDataGridWidget': AssetModelDataGridWidgetBuilder(),
  'TWDeviceFieldRangeLabelDialWidget': DeviceFieldRangeLabelDialWidgetBuilder(),
  'TWGenericTemperatureWidget': GenericTemperatureWidgetBuilder(),
  'TWGenericDayWeatherWidget': GenericDayWeatherWidgetBuilder(),
  'TWGenericValueCardWidget': GenericValueCardWidgetBuilder(),
  'TWGenericWindWidget': GenericWindWidgetBuilder(),
  'TWSingleValueSliderWidget': SingleValueSliderWidgetBuilder(),
  'TWGenericMultiValueCardWidget': GenericMultiValueCardWidgetBuilder(),
  'TWFlowMeterWidget': FlowMeterWidgetBuilder(),
  'TWDeviceDataAccordionWidget': DeviceDataAccordionWidgetBuilder(),
  'TWStaticTimelineWidget': StaticTimelineWidgetBuilder(),
  'TWGenericAirQualityWidget': GenericAirQualityWidgetBuilder(),
};

class Tuple<K extends String, V extends TwinnedWidgetBuilder> {
  final K key;
  final V value;
  Tuple({required this.key, required this.value});
}

class TwinnedWidgets {
  static Widget build(String widgetId, Map<String, dynamic> config) {
    return _builders[widgetId]?.build(config) ??
        const SizedBox.shrink(
          child: Placeholder(
            color: Colors.red,
          ),
        );
  }

  static BaseConfig getConfig(
      {required String widgetId, Map<String, dynamic>? config}) {
    return _builders[widgetId]!.getDefaultConfig(config: config);
  }

  static List<Tuple<String, TwinnedWidgetBuilder>> filterBuilders(
      PaletteCategory category) {
    List<Tuple<String, TwinnedWidgetBuilder>> list = [];

    _builders.forEach((k, v) {
      if (v.getPaletteCategory() == category) {
        list.add(Tuple(key: k, value: v));
      }
    });

    return list;
  }

  static void register(String widgetId, TwinnedWidgetBuilder builder) {
    if (widgetId.startsWith('TW')) {
      throw UnsupportedError(
          'Invalid widget id: $widgetId, custom widget ids should not start with TW');
    }
    _builders[widgetId] = builder;
  }

  static TwinnedWidgetBuilder? builder(String widgetId) {
    return _builders[widgetId];
  }
}
