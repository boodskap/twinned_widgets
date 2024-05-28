import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/twinned_models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';

class DynamicTextWidget extends StatefulWidget {
  final DynamicTextWidgetConfig config;
  const DynamicTextWidget({super.key, required this.config});

  @override
  State<DynamicTextWidget> createState() => _DynamicTextWidgetState();
}

class _DynamicTextWidgetState extends BaseState<DynamicTextWidget> {
  late String title;
  bool isValidConfig = false;
  String value = '';
  late FontConfig font;
  late Color fontColor;
  late FontConfig titleFont;
  late Color titleFontColor;

  @override
  void initState() {
    title = widget.config.title;
    isValidConfig = widget.config.field.isNotEmpty;
    isValidConfig = isValidConfig && widget.config.deviceId.isNotEmpty;
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

    font = FontConfig.fromJson(widget.config.font);
    titleFont = FontConfig.fromJson(widget.config.titleFont);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            widget.config.title,
            style: TextStyle(
              color: Color(titleFont.fontColor),
              fontSize: titleFont.fontSize,
              fontFamily: titleFont.fontFamily,
              fontWeight:
                  titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              color: Color(font.fontColor),
              fontSize: font.fontSize,
              fontFamily: font.fontFamily,
              fontWeight: font.fontBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Future load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          source: ["data.${widget.config.field}"],
          page: 0,
          size: 1,
          mustConditions: [
            {
              "match_phrase": {"deviceId": widget.config.deviceId}
            },
            {
              "exists": {"field": "data.${widget.config.field}"}
            },
          ],
        ),
      );

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        List<dynamic> values = json['hits']['hits'];
        if (values.isNotEmpty) {
          for (Map<String, dynamic> obj in values) {
            dynamic fetchedValue = obj['p_source']['data'][widget.config.field];
            value = '$fetchedValue';
          }
        }
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {
    load();
  }
}

class DynamicTextWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DynamicTextWidget(config: DynamicTextWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.text_format);
  }

  @override
  String getPaletteName() {
    return "Dynamic Text";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return DynamicTextWidgetConfig.fromJson(config);
    }
    return DynamicTextWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Dynamic Text Field';
  }
}
