library twinned_widgets;

import 'package:flutter/cupertino.dart';
import 'package:twinned_widgets/common/total_value_widget.dart';
import 'package:twinned_widgets/common/value_distribution_pie_widget.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

export 'common/total_value_widget.dart';
export 'common/value_distribution_pie_widget.dart';
export 'common/total_and_reporting_asset_widget.dart';
export 'twinned_config_builder.dart';
export 'twinned_widget_builder.dart';
export 'twinned_session.dart';

final Map<String, TwinnedWidgetBuilder> _builders = {
  'TotalValueWidget': TotalValueWidgetBuilder(),
  'ValueDistributionPieChartWidget': ValueDistributionPieChartWidgetBuilder(),
};

class TwinnedWidgets {
  static Widget build(String widgetId, Map<String, dynamic> config) {
    return _builders[widgetId]?.build(config) ?? const SizedBox.shrink();
  }
}
