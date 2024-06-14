import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_models/twinned_models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twin_commons/core/twinned_session.dart';
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
  late FontConfig prefixFont;
  late Color prefixFontColor;
  late FontConfig suffixFont;
  late Color suffixFontColor;
  late TextAlignment prefixTextAlignment;
  late TextAlignment suffixTextAlignment;
  late TextAlignment valueTextAlignment;

  @override
  void initState() {
    var config = widget.config;
    title = widget.config.title;
    isValidConfig = widget.config.field.isNotEmpty;
    isValidConfig = isValidConfig && widget.config.deviceId.isNotEmpty;
    font = FontConfig.fromJson(config.font);
    fontColor = font.fontColor <= 0 ? Colors.black : Color(font.fontColor);

    titleFont = FontConfig.fromJson(config.titleFont);
    titleFontColor =
        titleFont.fontColor <= 0 ? Colors.black : Color(titleFont.fontColor);

    prefixFont = FontConfig.fromJson(config.prefixFont);
    prefixFontColor =
        prefixFont.fontColor <= 0 ? Colors.black : Color(prefixFont.fontColor);
    suffixFont = FontConfig.fromJson(config.suffixFont);
    suffixFontColor =
        suffixFont.fontColor <= 0 ? Colors.black : Color(suffixFont.fontColor);

    super.initState();
  }

  Alignment _getAlignment(TextAlignment alignment) {
    switch (alignment) {
      case TextAlignment.bottomLeft:
        return Alignment.bottomLeft;
      case TextAlignment.bottomCenter:
        return Alignment.bottomCenter;
      case TextAlignment.bottomRight:
        return Alignment.bottomRight;
      case TextAlignment.topLeft:
        return Alignment.topLeft;
      case TextAlignment.topCenter:
        return Alignment.topCenter;
      case TextAlignment.topRight:
        return Alignment.topRight;
      case TextAlignment.centerLeft:
        return Alignment.centerLeft;
      case TextAlignment.centerRight:
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text(
          'Not configured properly',
          style: TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Text(
            widget.config.title,
            style: TextStyle(
              color: titleFontColor,
              fontSize: titleFont.fontSize,
              fontFamily: titleFont.fontFamily,
              fontWeight:
                  titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        SizedBox(
          width: widget.config.width.toDouble(),
          height: widget.config.height.toDouble(),
          child: Stack(
            children: <Widget>[
              Align(
                alignment: _getAlignment(widget.config.prefixTextAlignment),
                child: Text(
                  widget.config.prefixText,
                  style: TextStyle(
                    color: prefixFontColor,
                    fontSize: prefixFont.fontSize,
                    fontFamily: prefixFont.fontFamily,
                    fontWeight: prefixFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              Align(
                alignment: _getAlignment(widget.config.valueTextAlignment),
                child: Text(
                  value,
                  style: TextStyle(
                    color: fontColor,
                    fontSize: font.fontSize,
                    fontFamily: font.fontFamily,
                    fontWeight:
                        font.fontBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Align(
                alignment: _getAlignment(widget.config.suffixTextAlignment),
                child: Text(
                  widget.config.suffixText,
                  style: TextStyle(
                    color: suffixFontColor,
                    fontSize: suffixFont.fontSize,
                    fontFamily: suffixFont.fontFamily,
                    fontWeight: suffixFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
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
