import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_models/twinned_models.dart';

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
              conditions: [],
              queryConditions: [],
              mustConditions: [terms],
              boolConditions: [],
              size: 0));

      if (validateResponse(sRes)) {
        totalAssets = sRes.body!.total;
      }

      sRes = await session.twin.queryCountAsset(
          apikey: session.authToken,
          body: EqlSearch(
              conditions: [],
              queryConditions: [],
              mustConditions: [terms],
              boolConditions: [],
              size: 0));

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
