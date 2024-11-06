import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/device_field_shape_widget/device_field_shape_widget.dart';
import 'package:twinned_models/models.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'dart:math' as math;

class DeviceFieldShapeWidget extends StatefulWidget {
  final DeviceFieldShapeWidgetConfig config;

  const DeviceFieldShapeWidget({super.key, required this.config});

  @override
  State<DeviceFieldShapeWidget> createState() => _DeviceFieldShapeWidgetState();
}

class _DeviceFieldShapeWidgetState extends BaseState<DeviceFieldShapeWidget> {
  bool isValidConfig = false;
  late String deviceId;
  late String field;
  late String title;
  late String subTitle;
  late FontConfig titleFont;
  late FontConfig prefixFont;
  late FontConfig suffixFont;
  late FontConfig valueFont;
  late FontConfig prefixMainFont;
  late FontConfig suffixMainFont;
  late FontConfig valueMainFont;
  late FontConfig subTitleFont;
  late List<Map<String, String>> deviceData;
  List<Map<String, String>> fetchedData = [];
  late Color shapeWidgetColor;
  late DeviceFieldShape shape;

  String label = "";
  String mainValue = "";
  String mainSufficValue = "";
  String mainIcon = "";
  bool apiLoadingStatus = false;
  late double imageSize;

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    title = config.title;
    subTitle = config.subTitle;
    shape = config.shape;
    field = config.field;

    titleFont = FontConfig.fromJson(config.titleFont);
    shapeWidgetColor = Color(config.shapeWidgetColor);
    prefixFont = FontConfig.fromJson(config.prefixFont);
    suffixFont = FontConfig.fromJson(config.suffixFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    subTitleFont = FontConfig.fromJson(config.subTitleFont);
    isValidConfig = deviceId.isNotEmpty;

    imageSize = config.imageSize;

    deviceData = [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Wrap(
          spacing: 8.0,
          children: [
            Text(
              'Not configured properly',
              style:
                  TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
    }

    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            title,
            softWrap: true,
            style: TextStyle(
              fontFamily: titleFont.fontFamily,
              fontSize: titleFont.fontSize,
              fontWeight:
                  titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
              color: Color(titleFont.fontColor),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: Column(
              children: [
                Text(
                  subTitle,
                  softWrap: true,
                  style: TextStyle(
                    fontFamily: subTitleFont.fontFamily,
                    fontSize: subTitleFont.fontSize,
                    fontWeight: subTitleFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(subTitleFont.fontColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          if (widget.config.shape == DeviceFieldShape.circle)
            _buildCircle(
              label,
              mainValue,
              mainSufficValue,
              mainIcon,
              shapeWidgetColor,
            ),
          if (widget.config.shape == DeviceFieldShape.oval)
            _buildOval(
              label,
              mainValue,
              mainSufficValue,
              mainIcon,
              shapeWidgetColor,
            ),
          if (widget.config.shape == DeviceFieldShape.triangle)
            _buildTriangle(
              label,
              mainValue,
              mainSufficValue,
              mainIcon,
              shapeWidgetColor,
            ),
          if (widget.config.shape == DeviceFieldShape.diamond)
            _buildDiamond(
              label,
              mainValue,
              mainSufficValue,
              mainIcon,
              shapeWidgetColor,
            ),
          if (widget.config.shape == DeviceFieldShape.pentagon)
            _buildPentagon(
              label,
              mainValue,
              mainSufficValue,
              mainIcon,
              shapeWidgetColor,
            ),
          if (widget.config.shape == DeviceFieldShape.hexagon)
            _buildHexagon(
              label,
              mainValue,
              mainSufficValue,
              mainIcon,
              shapeWidgetColor,
            ),
          if (widget.config.shape == DeviceFieldShape.square)
            _buildCard(
              label,
              mainValue,
              mainSufficValue,
              mainIcon,
              shapeWidgetColor,
            ),
          if (widget.config.shape == DeviceFieldShape.decagon)
            _buildDecagon(
              label,
              mainValue,
              mainSufficValue,
              mainIcon,
              shapeWidgetColor,
            ),
          if (widget.config.shape == DeviceFieldShape.octagon)
            _buildOctagon(
              label,
              mainValue,
              mainSufficValue,
              mainIcon,
              shapeWidgetColor,
            ),
          if (widget.config.shape == DeviceFieldShape.ellipse)
            _buildEllipse(
              label,
              mainValue,
              mainSufficValue,
              mainIcon,
              shapeWidgetColor,
            )
        ],
      ),
    );
  }

  Widget _buildCircle(String prefix, String value, String suffix, String iconId,
      Color shapeWidgetColor) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: shapeWidgetColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: shapeWidgetColor,
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 50.0,
        backgroundColor: shapeWidgetColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                prefix.isNotEmpty ? prefix : '',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: prefixFont.fontFamily,
                  fontSize: prefixFont.fontSize,
                  fontWeight:
                      prefixFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(prefixFont.fontColor),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (iconId.isNotEmpty)
                    SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: TwinImageHelper.getDomainImage(iconId),
                    ),
                  if (iconId.isEmpty)
                    Icon(Icons.display_settings, size: imageSize),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    value.isNotEmpty ? value : '0',
                    style: TextStyle(
                      fontFamily: valueFont.fontFamily,
                      fontSize: valueFont.fontSize,
                      fontWeight: valueFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(valueFont.fontColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                suffix.isNotEmpty ? suffix : '',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: suffixFont.fontFamily,
                  fontSize: suffixFont.fontSize,
                  fontWeight:
                      suffixFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(suffixFont.fontColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTriangle(
    String prefix,
    String value,
    String suffix,
    String iconId,
    Color shapeWidgetColor,
  ) {
    return CustomPaint(
      size: const Size(
        150,
        150,
      ),
      painter: TrianglePainter(shapeWidgetColor),
      child: Container(
        height: 150,
        width: 150,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              prefix.isNotEmpty ? prefix : '',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: prefixFont.fontFamily,
                fontSize: prefixFont.fontSize,
                fontWeight:
                    prefixFont.fontBold ? FontWeight.bold : FontWeight.normal,
                color: Color(prefixFont.fontColor),
              ),
            ),
            divider(),
            if (iconId.isNotEmpty)
              SizedBox(
                width: imageSize,
                height: imageSize,
                child: TwinImageHelper.getDomainImage(iconId),
              ),
            divider(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.isNotEmpty ? value : '0',
                  style: TextStyle(
                    fontFamily: valueFont.fontFamily,
                    fontSize: valueFont.fontSize,
                    fontWeight: valueFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(valueFont.fontColor),
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  suffix.isNotEmpty ? suffix : '',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: suffixFont.fontFamily,
                    fontSize: suffixFont.fontSize,
                    fontWeight: suffixFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(suffixFont.fontColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiamond(String prefix, String value, String suffix,
      String iconId, Color shapeWidgetColor) {
    return ClipPath(
      clipper: DiamondClipper(),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: shapeWidgetColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              prefix.isNotEmpty ? prefix : '',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: prefixFont.fontFamily,
                fontSize: prefixFont.fontSize,
                fontWeight:
                    prefixFont.fontBold ? FontWeight.bold : FontWeight.normal,
                color: Color(prefixFont.fontColor),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconId.isNotEmpty)
                  SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: TwinImageHelper.getDomainImage(iconId),
                  ),
                if (iconId.isEmpty)
                  Icon(Icons.display_settings, size: imageSize),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.isNotEmpty ? value : '0',
                  style: TextStyle(
                    fontFamily: valueFont.fontFamily,
                    fontSize: valueFont.fontSize,
                    fontWeight: valueFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(valueFont.fontColor),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  suffix.isNotEmpty ? suffix : '',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: suffixFont.fontFamily,
                    fontSize: suffixFont.fontSize,
                    fontWeight: suffixFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(suffixFont.fontColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPentagon(String prefix, String value, String suffix,
      String iconId, Color shapeWidgetColor) {
    return ClipPath(
      clipper: PentagonClipper(),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: shapeWidgetColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              prefix.isNotEmpty ? prefix : '',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: prefixFont.fontFamily,
                fontSize: prefixFont.fontSize,
                fontWeight:
                    prefixFont.fontBold ? FontWeight.bold : FontWeight.normal,
                color: Color(prefixFont.fontColor),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconId.isNotEmpty)
                  SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: TwinImageHelper.getDomainImage(iconId),
                  ),
                if (iconId.isEmpty)
                  Icon(Icons.display_settings, size: imageSize),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.isNotEmpty ? value : '0',
                  style: TextStyle(
                    fontFamily: valueFont.fontFamily,
                    fontSize: valueFont.fontSize,
                    fontWeight: valueFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(valueFont.fontColor),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  suffix.isNotEmpty ? suffix : '',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: suffixFont.fontFamily,
                    fontSize: suffixFont.fontSize,
                    fontWeight: suffixFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(suffixFont.fontColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOval(String prefix, String value, String suffix, String iconId,
      Color shapeWidgetColor) {
    return ClipPath(
      clipper: OvalClipper(),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: shapeWidgetColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              prefix.isNotEmpty ? prefix : '',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: prefixFont.fontFamily,
                fontSize: prefixFont.fontSize,
                fontWeight:
                    prefixFont.fontBold ? FontWeight.bold : FontWeight.normal,
                color: Color(prefixFont.fontColor),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconId.isNotEmpty)
                  SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: TwinImageHelper.getDomainImage(iconId),
                  ),
                if (iconId.isEmpty)
                  Icon(Icons.display_settings, size: imageSize),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.isNotEmpty ? value : '0',
                  style: TextStyle(
                    fontFamily: valueFont.fontFamily,
                    fontSize: valueFont.fontSize,
                    fontWeight: valueFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(valueFont.fontColor),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  suffix.isNotEmpty ? suffix : '',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: suffixFont.fontFamily,
                    fontSize: suffixFont.fontSize,
                    fontWeight: suffixFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(suffixFont.fontColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHexagon(String prefix, String value, String suffix,
      String iconId, Color shapeWidgetColor) {
    return ClipPath(
      clipper: HexagonClipper(),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: shapeWidgetColor,
          border: Border.all(color: shapeWidgetColor),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              prefix.isNotEmpty ? prefix : '',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: prefixFont.fontFamily,
                fontSize: prefixFont.fontSize,
                fontWeight:
                    prefixFont.fontBold ? FontWeight.bold : FontWeight.normal,
                color: Color(prefixFont.fontColor),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconId.isNotEmpty)
                  SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: TwinImageHelper.getDomainImage(iconId),
                  ),
                if (iconId.isEmpty)
                  Icon(Icons.display_settings, size: imageSize),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.isNotEmpty ? value : '0',
                  style: TextStyle(
                    fontFamily: valueFont.fontFamily,
                    fontSize: valueFont.fontSize,
                    fontWeight: valueFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(valueFont.fontColor),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  suffix.isNotEmpty ? suffix : '',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: suffixFont.fontFamily,
                    fontSize: suffixFont.fontSize,
                    fontWeight: suffixFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(suffixFont.fontColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String prefix, String value, String suffix, String iconId,
      Color shapeWidgetColor) {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.hardEdge,
      color: shapeWidgetColor,
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            8.0,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              prefix.isNotEmpty ? prefix : '',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: prefixFont.fontFamily,
                fontSize: prefixFont.fontSize,
                fontWeight:
                    prefixFont.fontBold ? FontWeight.bold : FontWeight.normal,
                color: Color(prefixFont.fontColor),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconId.isNotEmpty)
                  SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: TwinImageHelper.getDomainImage(iconId),
                  ),
                if (iconId.isEmpty)
                  Icon(Icons.display_settings, size: imageSize),
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.isNotEmpty ? value : '0',
                  style: TextStyle(
                    fontFamily: valueFont.fontFamily,
                    fontSize: valueFont.fontSize,
                    fontWeight: valueFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(valueFont.fontColor),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  suffix.isNotEmpty ? suffix : '',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: suffixFont.fontFamily,
                    fontSize: suffixFont.fontSize,
                    fontWeight: suffixFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(suffixFont.fontColor),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDecagon(String prefix, String value, String suffix,
      String iconId, Color shapeWidgetColor) {
    return ClipPath(
      clipper: DecagonClipper(),
      child: Container(
        height: 150,
        width: 150,
        color: shapeWidgetColor,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              prefix.isNotEmpty ? prefix : '',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: prefixFont.fontFamily,
                fontSize: prefixFont.fontSize,
                fontWeight:
                    prefixFont.fontBold ? FontWeight.bold : FontWeight.normal,
                color: Color(prefixFont.fontColor),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconId.isNotEmpty)
                  SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: TwinImageHelper.getDomainImage(iconId),
                  ),
                if (iconId.isEmpty)
                  Icon(Icons.display_settings, size: imageSize),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.isNotEmpty ? value : '0',
                  style: TextStyle(
                    fontFamily: valueFont.fontFamily,
                    fontSize: valueFont.fontSize,
                    fontWeight: valueFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(valueFont.fontColor),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  suffix.isNotEmpty ? suffix : '',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: suffixFont.fontFamily,
                    fontSize: suffixFont.fontSize,
                    fontWeight: suffixFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(suffixFont.fontColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOctagon(String prefix, String value, String suffix,
      String iconId, Color shapeWidgetColor) {
    return ClipPath(
      clipper: OctagonClipper(),
      child: Container(
        height: 150,
        width: 150,
        color: shapeWidgetColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              prefix.isNotEmpty ? prefix : '',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: prefixFont.fontFamily,
                fontSize: prefixFont.fontSize,
                fontWeight:
                    prefixFont.fontBold ? FontWeight.bold : FontWeight.normal,
                color: Color(prefixFont.fontColor),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            if (iconId.isNotEmpty)
              SizedBox(
                width: imageSize,
                height: imageSize,
                child: TwinImageHelper.getDomainImage(iconId),
              ),
            const SizedBox(
              height: 6,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.isNotEmpty ? value : '0',
                  style: TextStyle(
                    fontFamily: valueFont.fontFamily,
                    fontSize: valueFont.fontSize,
                    fontWeight: valueFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(valueFont.fontColor),
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  suffix.isNotEmpty ? suffix : '',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: suffixFont.fontFamily,
                    fontSize: suffixFont.fontSize,
                    fontWeight: suffixFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(suffixFont.fontColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEllipse(String prefix, String value, String suffix,
      String iconId, Color shapeWidgetColor) {
    return ClipPath(
      clipper: EllipseClipper(),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: shapeWidgetColor,
          border: Border.all(color: Colors.grey),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              prefix.isNotEmpty ? prefix : '',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: prefixFont.fontFamily,
                fontSize: prefixFont.fontSize,
                fontWeight:
                    prefixFont.fontBold ? FontWeight.bold : FontWeight.normal,
                color: Color(prefixFont.fontColor),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconId.isNotEmpty)
                  SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: TwinImageHelper.getDomainImage(iconId),
                  ),
                if (iconId.isEmpty)
                  Icon(Icons.display_settings, size: imageSize),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.isNotEmpty ? value : '0',
                  style: TextStyle(
                    fontFamily: valueFont.fontFamily,
                    fontSize: valueFont.fontSize,
                    fontWeight: valueFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(valueFont.fontColor),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  suffix.isNotEmpty ? suffix : '',
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: suffixFont.fontFamily,
                    fontSize: suffixFont.fontSize,
                    fontWeight: suffixFont.fontBold
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: Color(suffixFont.fontColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void setup() {
    _load();
    // TODO: implement setup
  }

  Future _load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;
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
          ],
        ),
      );

      if (validateResponse(qRes)) {
        Device? device =
            await TwinUtils.getDevice(deviceId: widget.config.deviceId);
        if (null == device) return;
        DeviceModel? deviceModel =
            await TwinUtils.getDeviceModel(modelId: device.modelId);
        if (null == deviceModel) return;

        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        List<String> deviceFields = TwinUtils.getSortedFields(deviceModel);
        List<dynamic> values = json['hits']['hits'];

        if (values.isNotEmpty) {
          Map<String, dynamic> obj = values[0];
          Map<String, dynamic> data = obj['p_source']['data'];

          for (String deviceField in deviceFields) {
            if (deviceField == field) {
              refresh(sync: () {
                mainValue = data[field].toString();
                label = TwinUtils.getParameterLabel(field, deviceModel);
                mainIcon = TwinUtils.getParameterIcon(field, deviceModel);
                mainSufficValue =
                    TwinUtils.getParameterUnit(field, deviceModel);
              });
            }
          }
        }
      }
    });

    loading = false;
    apiLoadingStatus = true;
    refresh();
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;
    var path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DiamondClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class PentagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.38);
    path.lineTo(size.width * 0.8, size.height);
    path.lineTo(size.width * 0.2, size.height);
    path.lineTo(0, size.height * 0.38);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class OvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.height,
    ));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final double width = size.width;
    final double height = size.height;
    final double centerX = width / 2;
    final double centerY = height / 2;
    final double radius = math.min(width, height) / 2;

    for (int i = 0; i < 6; i++) {
      double angle = (i * 60.0) * (math.pi / 180.0);
      double x = centerX + radius * math.cos(angle);
      double y = centerY + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class DecagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;

    int numSides = 10;

    double radius = width / 2;

    double angle = (2 * math.pi) / numSides;

    Path path = Path();

    double startAngle = -math.pi / 2 + angle / 2;

    for (int i = 0; i < numSides; i++) {
      double x = width / 2 + radius * math.cos(startAngle + angle * i);
      double y = height / 2 + radius * math.sin(startAngle + angle * i);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class OctagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;

    double sideLength = width * 0.293;

    Path path = Path();

    path.moveTo(sideLength, 0);
    path.lineTo(width - sideLength, 0);
    path.lineTo(width, sideLength);
    path.lineTo(width, height - sideLength);
    path.lineTo(width - sideLength, height);
    path.lineTo(sideLength, height);
    path.lineTo(0, height - sideLength);
    path.lineTo(0, sideLength);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class EllipseClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height * 0.7,
    ));
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class DeviceFieldShapeWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceFieldShapeWidget(
        config: DeviceFieldShapeWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.shape_line_rounded);
  }

  @override
  String getPaletteName() {
    return "Single Field Single Shape Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return DeviceFieldShapeWidgetConfig.fromJson(config);
    }
    return DeviceFieldShapeWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Device Field Shape Widget';
  }
}
