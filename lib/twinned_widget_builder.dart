import 'package:flutter/material.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';

abstract class TwinnedWidgetBuilder {
  Widget build(Map<String, dynamic> config);

  BaseConfig getDefaultConfig({Map<String, dynamic>? config});

  String getPaletteName();

  PaletteCategory getPaletteCategory();

  Widget getPaletteIcon();

  String getPaletteTooltip();
}
