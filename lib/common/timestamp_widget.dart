import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';

class TimeStampWidget extends StatefulWidget {
  final TimeStampWidgetConfig config;
  const TimeStampWidget({super.key, required this.config});

  @override
  State<TimeStampWidget> createState() => _TimeStampWidgetState();
}

class _TimeStampWidgetState extends BaseState<TimeStampWidget> {
  late String field;
  late String deviceId;
  late FontConfig meridiemFont;
  late Color meridiemFontColor;
  late FontConfig yearFont;
  late Color yearFontColor;
  late FontConfig monthFont;
  late Color monthFontColor;
  late FontConfig dateFont;
  late Color dateFontColor;
  late FontConfig timeFont;
  late Color timeFontColor;
  bool isValidConfig = false;
  final DateFormat dateFormat = DateFormat('MM/dd/yyyy hh:mm:ss a');
  String? formattedDate;
  String? year;
  String? month;
  String? date;
  String? time;
  String? meridiem;

  @override
  void initState() {
    isValidConfig = widget.config.deviceId.isNotEmpty;
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
    meridiemFont = FontConfig.fromJson(widget.config.meridiemFont);
    yearFont = FontConfig.fromJson(widget.config.yearFont);
    monthFont = FontConfig.fromJson(widget.config.monthFont);
    dateFont = FontConfig.fromJson(widget.config.dateFont);
    timeFont = FontConfig.fromJson(widget.config.timeFont);
    yearFontColor =
        yearFont.fontColor <= 0 ? Colors.black : Color(yearFont.fontColor);
    monthFontColor =
        monthFont.fontColor <= 0 ? Colors.black : Color(monthFont.fontColor);
    dateFontColor =
        dateFont.fontColor <= 0 ? Colors.black : Color(dateFont.fontColor);
    timeFontColor =
        timeFont.fontColor <= 0 ? Colors.black : Color(timeFont.fontColor);
    meridiemFontColor = meridiemFont.fontColor <= 0
        ? Colors.black
        : Color(meridiemFont.fontColor);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IntrinsicWidth(
          child: IntrinsicHeight(
            child: Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Card(
                        elevation: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: IntrinsicWidth(
                            child: IntrinsicHeight(
                              child: Text(
                                time ?? '-',
                                style: TextStyle(
                                  fontSize: timeFont.fontSize,
                                  color: timeFontColor,
                                  fontWeight: timeFont.fontBold
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontFamily: timeFont.fontFamily,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        meridiem ?? '-',
                        style: TextStyle(
                          fontSize: meridiemFont.fontSize,
                          color: meridiemFontColor,
                          fontWeight: meridiemFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontFamily: meridiemFont.fontFamily,
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        year ?? '-',
                        style: TextStyle(
                          fontSize: yearFont.fontSize,
                          color: yearFontColor,
                          fontWeight: yearFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontFamily: yearFont.fontFamily,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        month ?? '-',
                        style: TextStyle(
                          fontSize: monthFont.fontSize,
                          color: monthFontColor,
                          fontWeight: monthFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontFamily: monthFont.fontFamily,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        date ?? '-',
                        style: TextStyle(
                          fontSize: dateFont.fontSize,
                          color: dateFontColor,
                          fontWeight: dateFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontFamily: dateFont.fontFamily,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Future load() async {
    if (!isValidConfig) return;

    if (loading) return;

    loading = true;

    await execute(() async {
      TwinnedSession session = TwinnedSession.instance;

      var sRes = await session.twin.queryDeviceData(
        apikey: session.authToken,
        body: EqlSearch(
          source: [],
          conditions: [],
          size: 10,
          queryConditions: [],
          boolConditions: [],
          mustConditions: [
            {
              "match_phrase": {"deviceId": widget.config.deviceId}
            },
          ],
          sort: {'updatedStamp': 'desc'},
        ),
      );
      if (validateResponse(sRes)) {
        Map<String, dynamic> json = sRes.body!.result! as Map<String, dynamic>;
        Map<String, dynamic> source = json['hits']['hits'][0]['p_source'];
        int millis;
        if (widget.config.field.isNotEmpty) {
          millis = source['data'][widget.config.field];
        } else {
          millis = source['updatedStamp'];
        }
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
        String formattedDateTime = dateFormat.format(dateTime);

        setState(() {
          formattedDate = formattedDateTime;
          formattedDate = dateFormat.format(dateTime);
          year = DateFormat('yyyy').format(dateTime);
          month = DateFormat('MMM').format(dateTime);
          date = DateFormat('dd').format(dateTime);
          time = DateFormat('hh:mm').format(dateTime);
          meridiem = DateFormat('a').format(dateTime);
        });
      }
    });
    refresh();
    loading = false;
  }

  @override
  void setup() {
    load();
  }
}

class TimeStampWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return TimeStampWidget(config: TimeStampWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.access_time);
  }

  @override
  String getPaletteName() {
    return "Time Stamp";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return TimeStampWidgetConfig.fromJson(config);
    }
    return TimeStampWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Time Stamp Field';
  }
}
