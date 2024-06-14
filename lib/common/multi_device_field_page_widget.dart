import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/multi_device_field_page/multi_device_field_page.dart';
import 'package:twinned_models/models.dart';
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
  late String subText;
  late String contentText;
  late Color fillColor;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig subTextFont;
  late FontConfig contentTextFont;
  dynamic updatedStampValue;
  dynamic geoLocation;
  dynamic coOrdinates;
  dynamic value;
  Map<String, dynamic> additionalFields = {};

  void _initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    title = config.title;
    cityName = config.cityName;
    imageId = config.imageId;
    subText = config.subText;
    contentText = config.contentText;
    fillColor = Color(config.fillColor);
    titleFont = FontConfig.fromJson(config.titleFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    subTextFont = FontConfig.fromJson(config.subTextFont);
    contentTextFont = FontConfig.fromJson(config.contentTextFont);

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
          color: fillColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  cityName,
                  style: const TextStyle(
                    color: Color(0XFFFFFAFA),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  updatedStampValue ?? '--',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0XFFFFFAFA),
                  ),
                ),
                const SizedBox(height: 10),
                if (imageId.isNotEmpty)
                  SizedBox(
                      width: 100,
                      height: 100,
                      child: TwinImageHelper.getDomainImage(imageId)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
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
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    children: [
                      Text(
                        subText,
                        style: TextStyle(
                          fontSize: subTextFont.fontSize,
                          color: Color(subTextFont.fontColor),
                          fontFamily: subTextFont.fontFamily,
                          fontWeight: subTextFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      divider(height: 6),
                      Text(
                        contentText,
                        style: TextStyle(
                          fontSize: contentTextFont.fontSize,
                          fontFamily: contentTextFont.fontFamily,
                          color: Color(contentTextFont.fontColor),
                          fontWeight: contentTextFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
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
                            width: 60,
                            height: 80,
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
