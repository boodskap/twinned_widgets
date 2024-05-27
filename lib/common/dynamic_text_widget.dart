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
  bool isValidConfig = false;
  late String field;
  late String value;
  late String deviceId;
  late int fontSize;
  late Color fontColor;
  late bool fontBold;
  late FontConfig font;
  late String fontFamily;
  final TextEditingController _txtController = TextEditingController();

  @override
  void initState() {
    isValidConfig = widget.config.field.isNotEmpty;
    // isValidConfig = isValidConfig && widget.config.field.isNotEmpty;
    var config = widget.config;
    field = widget.config.field;
    font = FontConfig.fromJson(config.font);
    fontColor = font.fontColor <= 0 ? Colors.black : Color(font.fontColor);
    _txtController.text = field;
    fontBold = font.fontBold;
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
    return Center(
      child: Text(
        value,
        style: TextStyle(
          color: fontColor,
          fontSize: font.fontSize,
          fontFamily: font.fontFamily,
          fontWeight: fontBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

Future load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    await execute(() async {
      var deviceIds = widget.config.deviceId;
      for (var i = 0; i < deviceIds.length; i++) {
        var deviceId = deviceIds[i];
        var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
          apikey: TwinnedSession.instance.authToken,
          body: EqlSearch(
            source: ["data.$field"],
            page: 0,
            size: 100,
            conditions: [],
            boolConditions: [],
            queryConditions: [],
            mustConditions: [
              {
                "match_phrase": {"deviceId": deviceId}
              },
            ],
          ),
        );

        if (validateResponse(qRes)) {
          Map<String, dynamic> json =
              qRes.body!.result! as Map<String, dynamic>;

         List<dynamic> values = json['hits']['hits'];
          if (values.isNotEmpty) {
            for (Map<String, dynamic> obj in values) {
              dynamic fetchedValue =
                  obj['_source']['data'][widget.config.value];
              print('Fetched Value: $fetchedValue');
              setState(() {
                value = fetchedValue.toString();
              });
            }
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
