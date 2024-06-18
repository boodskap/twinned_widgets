import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:twinned_models/multi_device_field_page/multi_device_field_page.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/core/twinned_utils.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_widgets/core/twin_image_helper.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class MultiDeviceFieldPageWidget extends StatefulWidget {
  final MultiDeviceFieldPageWidgetConfig config;

  const MultiDeviceFieldPageWidget({super.key, required this.config});

  @override
  State<MultiDeviceFieldPageWidget> createState() =>
      _MultiDeviceFieldPageWidgetState();
}

class _MultiDeviceFieldPageWidgetState
    extends BaseState<MultiDeviceFieldPageWidget> {
  bool isValidConfig = false;
  late String field;
  late String deviceId;
  late String title;
  late String cityName;
  late String imageId;
  late String paraTitle;
  late String paraText;
  late Color startFillColor;
  late Color endFillColor;
  late FontConfig titleFont;
  late FontConfig timeStampFont;
  late FontConfig valueFont;
  late FontConfig labelFont;
  late FontConfig suffixFont;
  late FontConfig paraTitleFont;
  late FontConfig paraTextFont;
  dynamic updatedStampValue;
  dynamic value;
  Map<String, dynamic> additionalFields = {};
  List<Map<String, String>> deviceData = [];
  Map<String, String> fieldIcons = <String, String>{};
  Map<String, String> fieldSuffix = <String, String>{};

  void _initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    title = config.title;
    cityName = config.cityName;
    imageId = config.imageId;
    paraTitle = config.paraTitle;
    paraText = config.paraText;
    titleFont = FontConfig.fromJson(config.titleFont);
    timeStampFont = FontConfig.fromJson(config.timeStampFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    suffixFont = FontConfig.fromJson(config.suffixFont);
    paraTitleFont = FontConfig.fromJson(config.paraTitleFont);
    paraTextFont = FontConfig.fromJson(config.paraTextFont);
    startFillColor = Color(config.startFillColor);
    endFillColor = Color(config.endFillColor);

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
              'Not Configure Properly',
              style:
                  TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
            )
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: titleFont.fontSize,
              color: Color(titleFont.fontColor),
              fontFamily: titleFont.fontFamily,
              fontWeight:
                  titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          // color: fillColor,
          child: Container(
            decoration:  BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              gradient: LinearGradient(
                colors: [startFillColor, endFillColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Text(
                  //   cityName,
                  //   style: const TextStyle(
                  //     color: Color(0XFFFFFAFA),
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  Text(
                    updatedStampValue ?? '--',
                    style: TextStyle(
                      fontSize: timeStampFont.fontSize,
                      fontFamily: timeStampFont.fontFamily,
                      color: Color(timeStampFont.fontColor),
                      fontWeight: timeStampFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  divider(height: 8),
                  // if (imageId.isNotEmpty)
                  //   SizedBox(
                  //     width: 100,
                  //     height: 100,
                  //     child: TwinImageHelper.getDomainImage(imageId),
                  //   ),
                  if (fieldIcons[field] != null)
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: TwinImageHelper.getDomainImage(fieldIcons[field]!),
                    ),
                  divider(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Wrap(
                        verticalDirection: VerticalDirection.down,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5,
                        children: [
                          Text(
                            field,
                            style: TextStyle(
                              fontSize: labelFont.fontSize,
                              fontFamily: labelFont.fontFamily,
                              color: Color(labelFont.fontColor),
                              fontWeight: labelFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          divider(horizontal: true, width: 8),
                          Text(
                            value != null ? formatFieldValue(value) : '--',
                            style: TextStyle(
                              fontSize: valueFont.fontSize,
                              fontFamily: valueFont.fontFamily,
                              color: Color(valueFont.fontColor),
                              fontWeight: valueFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          divider(horizontal: true, width: 8),
                          if (fieldSuffix[field] != null)
                            Text(
                              fieldSuffix[field]!,
                              style: TextStyle(
                                fontSize: suffixFont.fontSize,
                                fontFamily: suffixFont.fontFamily,
                                color: Color(suffixFont.fontColor),
                                fontWeight: suffixFont.fontBold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  divider(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        Text(
                          paraTitle,
                          style: TextStyle(
                            fontSize: paraTitleFont.fontSize,
                            color: Color(paraTitleFont.fontColor),
                            fontFamily: paraTitleFont.fontFamily,
                            fontWeight: paraTitleFont.fontBold
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        divider(height: 6),
                        Text(
                          paraText,
                          style: TextStyle(
                            fontSize: paraTextFont.fontSize,
                            fontFamily: paraTextFont.fontFamily,
                            color: Color(paraTextFont.fontColor),
                            fontWeight: paraTextFont.fontBold
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        CustomPaint(
                          size: const Size(400, 50),
                          painter: CurvePainter(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Additional Fields
                  if (additionalFields.isNotEmpty)
                    SizedBox(
                      height: 180,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: GridView.builder(
                          clipBehavior: Clip.antiAlias,
                          scrollDirection: Axis.vertical,
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2.0,
                            mainAxisSpacing: 4.0,
                            childAspectRatio: 1.6,
                          ),
                          itemCount: additionalFields.entries.length,
                          itemBuilder: (BuildContext context, int index) {
                            final entry =
                                additionalFields.entries.elementAt(index);
                            return SizedBox(
                              // width: 60,
                              // height: 80,
                              child: Card(
                                // color: Colors.tealAccent,
                                color: const Color(0xffeeeeee),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatFieldValue(entry.value),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  if (additionalFields.isEmpty)
                    const Center(
                      child: Wrap(
                        spacing: 8,
                        children: [
                          Text(
                            'No other parameter found',
                            style: TextStyle(
                                color: Colors.red,
                                overflow: TextOverflow.ellipsis),
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> load() async {
    _initState();

    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    try {
      await execute(() async {
        var query = EqlSearch(
          source: ["data"],
          page: 0,
          size: 1,
          mustConditions: [
            {
              "match_phrase": {"deviceId": deviceId}
            },
            {
              "exists": {"field": "data.$field"}
            },
          ],
        );

        var qRes = await TwinnedSession.instance.twin.queryDeviceData(
          apikey: TwinnedSession.instance.authToken,
          body: query,
        );

        if (qRes.body != null &&
            qRes.body!.result != null &&
            validateResponse(qRes)) {
          Map<String, dynamic>? json =
              qRes.body!.result! as Map<String, dynamic>?;

          if (validateResponse(qRes)) {
            Device? device =
                await TwinnedUtils.getDevice(deviceId: widget.config.deviceId);
            if (null == device) return;
            // deviceName = device.name;
            DeviceModel? deviceModel =
                await TwinnedUtils.getDeviceModel(modelId: device.modelId);
            if (null == deviceModel) return;

            Map<String, dynamic> json =
                qRes.body!.result! as Map<String, dynamic>;

            List<String> deviceFields =
                NoCodeUtils.getSortedFields(deviceModel);

            List<dynamic> values = json['hits']['hits'];
            List<Map<String, String>> fetchedData = [];

            if (values.isNotEmpty) {
              Map<String, dynamic> obj = values[0];
              Map<String, dynamic> data = obj['p_source']['data'];

              for (String field in deviceFields) {
                String label =
                    NoCodeUtils.getParameterLabel(field, deviceModel);
                String value = '${data[field] ?? '-'}';
                String unit = NoCodeUtils.getParameterUnit(field, deviceModel);
                String iconId =
                    NoCodeUtils.getParameterIcon(field, deviceModel);
                fieldSuffix[label] = unit;
                fieldIcons[label] = iconId;

                fetchedData.add({
                  'field': label,
                  'value': value,
                });
              }
            }
            // debugPrint('DEVICE DATA: $fetchedData');
            setState(() {
              deviceData = fetchedData;
            });
          }

          if (json != null) {
            List<dynamic> hits = json['hits']['hits'];

            if (hits.isNotEmpty) {
              Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
              Map<String, dynamic> source =
                  obj['p_source'] as Map<String, dynamic>;
              Map<String, dynamic> data =
                  source['data'] as Map<String, dynamic>;

              value = obj['p_source']['data'][widget.config.field];
              updatedStampValue = obj['p_source']['updatedStamp'];

              additionalFields = Map<String, dynamic>.from(data);
              additionalFields.remove(widget.config.field);

              if (updatedStampValue is int) {
                DateTime updatedStampTime =
                    DateTime.fromMillisecondsSinceEpoch(updatedStampValue);
                updatedStampValue = DateFormat('MMM-dd-yyyy - hh:mm:ss a')
                    .format(updatedStampTime);
              } else {
                updatedStampValue = "--";
              }
            }
          }
        }
      });
    } catch (e) {
      // Handle error
    } finally {
      loading = false;
      refresh();
    }
  }

  String formatFieldValue(dynamic value) {
    if (value is int && value.toString().length >= 10) {
      try {
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(value);
        return DateFormat('hh:mm:ss a').format(dateTime);
      } catch (e) {
        // If parsing fails, return the original value
        return value.toString();
      }
    }
    return value.toString();
  }

  @override
  void setup() {
    load();
  }
}

class MultiDeviceFieldPageWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return MultiDeviceFieldPageWidget(
      config: MultiDeviceFieldPageWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.wb_iridescent_rounded);
  }

  @override
  String getPaletteName() {
    return "Multi Device Field Page";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return MultiDeviceFieldPageWidgetConfig.fromJson(config);
    }
    return MultiDeviceFieldPageWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Multi device field page widget';
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0XFFFFFAFA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.4);
    path1.quadraticBezierTo(
        size.width / 4, size.height * 0.7, size.width / 2, size.height * 0.4);
    path1.quadraticBezierTo(
        size.width * 3 / 4, size.height * 0.1, size.width, size.height * 0.4);

    final paint2 = Paint()
      ..color = const Color(0XFFFFFAFA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
        size.width / 4, size.height * 0.9, size.width / 2, size.height * 0.6);
    path2.quadraticBezierTo(
        size.width * 3 / 4, size.height * 0.3, size.width, size.height * 0.6);

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
