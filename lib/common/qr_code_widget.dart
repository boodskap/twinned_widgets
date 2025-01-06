import 'package:flutter/material.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twinned_models/models.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/qr_code_widget/qr_code_widget.dart';
import 'package:syncfusion_flutter_barcodes/barcodes.dart';

class QrCodeWidget extends StatefulWidget {
  final QrCodeWidgetConfig config;
  const QrCodeWidget({super.key, required this.config});

  @override
  State<QrCodeWidget> createState() => _QrCodeWidgetState();
}

class _QrCodeWidgetState extends BaseState<QrCodeWidget> {
  bool isValidConfig = false;
  late String title;
  late FontConfig titleFont;
  late double width;
  late double height;
  late String url;
  late Color barColor;
  late Color backgroundColor;
  late bool showUrlText;
  late double textspacing;
  late FontConfig urlTextFont;
  late UrlTextAlign urlTextAlign;

  @override
  void initState() {
    var config = widget.config;
    isValidConfig = widget.config.url.isNotEmpty;
    title = config.title;
    titleFont = FontConfig.fromJson(config.titleFont);
    width = config.width;
    height = config.height;
    url = config.url;
    barColor = Color(config.barColor);
    backgroundColor = Color(config.backgroundColor);
    showUrlText = config.showUrlText;
    textspacing = config.textspacing;
    urlTextFont = FontConfig.fromJson(config.urlTextFont);
    urlTextAlign = config.urlTextAlign;
    super.initState();
  }

  TextAlign _textAlign(UrlTextAlign type) {
    switch (type) {
      case UrlTextAlign.left:
        return TextAlign.left;
      case UrlTextAlign.right:
        return TextAlign.right;
      case UrlTextAlign.start:
        return TextAlign.start;
      case UrlTextAlign.end:
        return TextAlign.end;
      case UrlTextAlign.justify:
        return TextAlign.justify;
      default:
        return TextAlign.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Wrap(
        spacing: 8.0,
        children: [
          Text(
            'Not configured properly',
            style: TextStyle(
                color: Color.fromARGB(255, 133, 11, 3),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

   

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (title != "")
            Text(title,
                style: TextStyle(
                    fontFamily: titleFont.fontFamily,
                    fontSize: titleFont.fontSize,
                    fontWeight:
                        titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
                    color: Color(titleFont.fontColor))),
          Center(
            child: SizedBox(
              width: width,
              height: height,
              child: SfBarcodeGenerator(
                value: url,
                symbology: QRCode(),
                showValue: showUrlText,
                backgroundColor: backgroundColor,
                barColor: barColor,
                textSpacing: textspacing,
                textStyle: TextStyle(
                    fontFamily: urlTextFont.fontFamily,
                    fontSize: urlTextFont.fontSize,
                    fontWeight:
                        urlTextFont.fontBold ? FontWeight.bold : FontWeight.normal,
                    color: Color(urlTextFont.fontColor)),
                textAlign: _textAlign(urlTextAlign),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void setup() {}
}

class QrCodeWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return QrCodeWidget(config: QrCodeWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.qr_code_scanner);
  }

  @override
  String getPaletteName() {
    return "QR Code";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return QrCodeWidgetConfig.fromJson(config);
    }
    return QrCodeWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "QR Code";
  }
}
