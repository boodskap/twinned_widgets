import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/generic_multi_shape_widget/generic_multi_shape_widget.dart';
import 'package:twinned_models/models.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'dart:math' as math;

class GenericMultiShapeWidget extends StatefulWidget {
  final GenericMultiShapeWidgetConfig config;

  const GenericMultiShapeWidget({super.key, required this.config});

  @override
  State<GenericMultiShapeWidget> createState() =>
      _GenericMultiShapeWidgetState();
}

class _GenericMultiShapeWidgetState extends BaseState<GenericMultiShapeWidget> {
  bool isValidConfig = false;
  late String deviceId;
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

  String mainPrefixValue = "";
  String mainValue = "";
  String mainSufficValue = "";
  String mainIcon = "";
  bool apiLoadingStatus = false;
  late double imageSize;
  late double horizontalSpacing;

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    title = config.title;
    subTitle = config.subTitle;

    titleFont = FontConfig.fromJson(config.titleFont);
    prefixFont = FontConfig.fromJson(config.prefixFont);
    suffixFont = FontConfig.fromJson(config.suffixFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    subTitleFont = FontConfig.fromJson(config.subTitleFont);
    isValidConfig = deviceId.isNotEmpty;

    horizontalSpacing = config.horizontalSpacing;
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

    return Column(
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
        Expanded(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildSameLevelCards(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSameLevelCards() {
    return deviceData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, String> item = entry.value;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalSpacing),
        child: _buildShape(item['prefix']!, item['value']!, item['suffix']!,
            item['icon']!, index),
      );
    }).toList();
  }

  Widget _buildShape(
      String prefix, String value, String suffix, String iconId, int index) {
    switch (index % 9) {
      case 0:
        return _buildCircle(prefix, value, suffix, iconId);
      case 1:
        return _buildTriangle(prefix, value, suffix, iconId);
      case 2:
        return _buildDiamond(prefix, value, suffix, iconId);
      case 3:
        return _buildPentagon(prefix, value, suffix, iconId);
      case 4:
        return _buildOval(prefix, value, suffix, iconId);
      case 5:
        return _buildHexagon(prefix, value, suffix, iconId);
      case 6:
        return _buildCard(prefix, value, suffix, iconId);
      case 7:
        return _buildDecagon(prefix, value, suffix, iconId);
      case 8:
        return _buildEllipse(prefix, value, suffix, iconId);
      default:
        return _buildCircle(prefix, value, suffix, iconId);
    }
  }

  Widget _buildCircle(
      String prefix, String value, String suffix, String iconId) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.yellow.shade400,
      ),
      child: _buildShapeContent(prefix, value, suffix, iconId),
    );
  }

  Widget _buildTriangle(
    String prefix,
    String value,
    String suffix,
    String iconId,
  ) {
    return CustomPaint(
      size: const Size(
        150,
        150,
      ),
      painter: TrianglePainter(),
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

  Widget _buildDiamond(
      String prefix, String value, String suffix, String iconId) {
    return ClipPath(
      clipper: DiamondClipper(),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.blue.shade200,
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

  Widget _buildPentagon(
      String prefix, String value, String suffix, String iconId) {
    return ClipPath(
      clipper: PentagonClipper(),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.pink.shade300,
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

  Widget _buildOval(String prefix, String value, String suffix, String iconId) {
    return ClipPath(
      clipper: OvalClipper(),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.cyan.shade700,
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

  Widget _buildHexagon(
      String prefix, String value, String suffix, String iconId) {
    return ClipPath(
      clipper: HexagonClipper(),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.indigo.shade400,
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

  Widget _buildCard(
    String prefix,
    String value,
    String suffix,
    String iconId,
  ) {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.hardEdge,
      color: Colors.green,
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

  Widget _buildDecagon(
      String prefix, String value, String suffix, String iconId) {
    return ClipPath(
      clipper: DecagonClipper(),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.orange.shade400,
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

  Widget _buildEllipse(
      String prefix, String value, String suffix, String iconId) {
    return ClipPath(
      clipper: EllipseClipper(),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.purple.shade400,
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

  Widget _buildShapeContent(
      String prefix, String value, String suffix, String iconId) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prefix.isNotEmpty ? prefix : ''),
        if (iconId.isNotEmpty)
          SizedBox(
            width: imageSize,
            height: imageSize,
            child: TwinImageHelper.getDomainImage(iconId),
          ),
        if (iconId.isEmpty) Icon(Icons.display_settings, size: imageSize),
        Text(value.isNotEmpty ? value : '0'),
        Text(suffix.isNotEmpty ? suffix : ''),
      ],
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
        List<Map<String, String>> fetchedData = [];

        if (values.isNotEmpty) {
          Map<String, dynamic> obj = values[0];
          Map<String, dynamic> data = obj['p_source']['data'];
          for (String field in deviceFields) {
            String label = TwinUtils.getParameterLabel(field, deviceModel);
            String value = '${data[field] ?? '-'}';
            String unit = TwinUtils.getParameterUnit(field, deviceModel);
            dynamic iconId = TwinUtils.getParameterIcon(field, deviceModel);
            if (field != value) {
              fetchedData.add({
                'prefix': label,
                'value': value,
                'suffix': unit,
                'icon': iconId ?? ""
              });
            } else {
              mainPrefixValue = label;
              mainSufficValue = unit;
              mainValue = value;
              mainIcon = iconId ?? "";
            }
          }
        }
        setState(() {
          deviceData = fetchedData;
        });
      }
    });

    loading = false;
    apiLoadingStatus = true;
    refresh();
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.red;
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

class GenericMultiShapeWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return GenericMultiShapeWidget(
        config: GenericMultiShapeWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.map_rounded);
  }

  @override
  String getPaletteName() {
    return "Generic Multi Shape Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return GenericMultiShapeWidgetConfig.fromJson(config);
    }
    return GenericMultiShapeWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Generic Multi Shape Widget';
  }
}
