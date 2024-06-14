import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_models/twinned_models.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class TotalAndReportingAssetWidget extends StatefulWidget {
  final TotalAndReportingAssetWidgetConfig config;
  const TotalAndReportingAssetWidget({super.key, required this.config});

  @override
  State<TotalAndReportingAssetWidget> createState() =>
      _TotalAndReportingAssetWidgetState();
}

class _TotalAndReportingAssetWidgetState
    extends BaseState<TotalAndReportingAssetWidget> {
  int? totalAssets;
  int? reportingAssets;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Future load() async {
    if (loading) return;
    loading = true;

    totalAssets = null;
    reportingAssets = null;

    Map<String, dynamic> terms = {
      "terms": {"assetModelId.keyword": widget.config.assetModelIds}
    };

    await execute(() async {
      TwinnedSession session = TwinnedSession.instance;

      var sRes = await session.twin.queryCountAsset(
          apikey: session.authToken,
          body: EqlSearch(
              source: [],
              mustConditions: [terms],
              boolConditions: [],
              size: 0,
              conditions: [],
              queryConditions: []));

      if (validateResponse(sRes)) {
        totalAssets = sRes.body!.total;
      }

      sRes = await session.twin.queryCountAsset(
          apikey: session.authToken,
          body: EqlSearch(
              source: [],
              mustConditions: [terms],
              size: 0,
              conditions: [],
              queryConditions: [],
              boolConditions: []));

      if (validateResponse(sRes)) {
        reportingAssets = sRes.body!.total;
      }
    });
    refresh();
    loading = false;
  }

  @override
  void setup() {
    // TODO: implement setup
  }
}

class TotalAndReportingAssetWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return TotalAndReportingAssetWidget(
        config: TotalAndReportingAssetWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.pie_chart);
  }

  @override
  String getPaletteName() {
    return "Reporting Assets";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return TotalAndReportingAssetWidgetConfig.fromJson(config);
    }
    return TotalAndReportingAssetWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Total & Reporting Assets';
  }
}
