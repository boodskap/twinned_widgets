import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:twinned_models/generic_value_card/generic_value_card.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/core/twin_image_helper.dart';
import 'package:twinned_widgets/core/twinned_utils.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';

class GenericValueCardWidget extends StatefulWidget {
  final GenericValueCardWidgetConfig config;

  const GenericValueCardWidget({
    super.key,
    required this.config,
  });

  @override
  State<GenericValueCardWidget> createState() => _GenericValueCardWidgetState();
}

class _GenericValueCardWidgetState extends BaseState<GenericValueCardWidget> {
  bool isValidConfig = false;
  late String field;
  late String deviceId;
  late String topLabel;
  late String bottomLabel;
  late String iconId;
  late double elevation;
  late double iconWidth;
  late double iconHeight;
  late FontConfig topFont;
  late FontConfig valueFont;
  late FontConfig bottomFont;
  dynamic value;
  Widget? iconImage;

  void _initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    topLabel = config.topLabel;
    bottomLabel = config.bottomLabel;
    iconId = config.iconId;
    elevation = config.elevation;
    iconHeight = config.iconHeight;
    iconWidth = config.iconWidth;
    topFont = FontConfig.fromJson(config.topFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    bottomFont = FontConfig.fromJson(config.bottomFont);

    isValidConfig = deviceId.isNotEmpty && field.isNotEmpty;
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
    return Card(
      color: Colors.transparent,
      elevation: elevation,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (null != iconImage)
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                  width: iconWidth, height: iconHeight, child: iconImage),
            ),
          //divider(horizontal: true, width: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  topLabel,
                  style: TwinnedUtils.getTextStyle(topFont),
                ),
                divider(),
                Container(
                  decoration: BoxDecoration(
                    color: Color(widget.config.valueBgColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Wrap(
                      spacing: 8.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${value ?? ''}',
                          style: TwinnedUtils.getTextStyle(valueFont),
                        ),
                        if (widget.config.bottomLabelAsSuffix)
                          Text(
                            bottomLabel,
                            style: TwinnedUtils.getTextStyle(bottomFont),
                          ),
                      ],
                    ),
                  ),
                ),
                if (!widget.config.bottomLabelAsSuffix) divider(),
                if (!widget.config.bottomLabelAsSuffix)
                  Text(
                    bottomLabel,
                    style: TwinnedUtils.getTextStyle(bottomFont),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void setup() {
    load();
  }

  Future<void> load() async {
    _initState();

    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    try {
      await execute(() async {
        var qRes = await TwinnedSession.instance.twin.queryDeviceData(
            apikey: TwinnedSession.instance.authToken,
            body: EqlSearch(
                source: ["data"],
                page: 0,
                size: 1,
                mustConditions: [
                  {
                    "match_phrase": {"deviceId": widget.config.deviceId}
                  },
                  {
                    "exists": {"field": "data.$field"}
                  },
                ]));

        if (qRes.body != null &&
            qRes.body!.result != null &&
            validateResponse(qRes)) {
          Map<String, dynamic>? json =
              qRes.body!.result! as Map<String, dynamic>?;

          if (json != null) {
            List<dynamic> hits = json['hits']['hits'];

            if (hits.isNotEmpty) {
              Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;

              value = obj['p_source']['data'][widget.config.field];
              // debugPrint(value.toString());
            } else {
              // debugPrint('No hits found in response.');
            }
          } else {
            // debugPrint('Failed to parse JSON response.');
          }
        } else {
          // debugPrint('Failed to validate response: ${qRes.statusCode}');
        }
      });
    } catch (e, stackTrace) {
      // debugPrint('Error loading data: $e');
      // debugPrint('Stack trace: $stackTrace');
    } finally {
      loading = false;
    }

    if (null != iconId && iconId.isNotEmpty) {
      iconImage = TwinImageHelper.getDomainImage(iconId);
    }

    refresh();
  }
}

class GenericValueCardWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return GenericValueCardWidget(
      config: GenericValueCardWidgetConfig.fromJson(config),
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
    return "Generic Value Card";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return GenericValueCardWidgetConfig.fromJson(config);
    }
    return GenericValueCardWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Generic value device field widget';
  }
}
