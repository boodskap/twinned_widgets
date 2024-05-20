import 'package:configs/models.dart';
import 'package:flutter/material.dart';
import 'package:twinned_widgets/common/total_value_widget.dart';
import 'package:twinned_widgets/common/value_distribution_pie_widget.dart';

abstract class TwinnedWidgetBuilder {
  Widget build(Map<String, dynamic> config);
}
