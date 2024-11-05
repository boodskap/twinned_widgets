import 'package:flutter/material.dart';
import 'package:twin_commons/twin_commons.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/heat_map/heat_map.dart';
import 'package:intl/intl.dart';
import 'package:fl_heatmap/fl_heatmap.dart';

const hdivider = SizedBox(width: 3);
const vdivider = SizedBox(height: 3);

class HeatMapWidget extends StatefulWidget {
  final HeatMapWidgetConfig config;
  const HeatMapWidget({super.key, required this.config});

  @override
  State<HeatMapWidget> createState() => _HeatMapWidgetState();
}

class _HeatMapWidgetState extends BaseState<HeatMapWidget> {
  HeatmapItem? selectedItem;
  late HeatmapData heatmapDataPower;
  bool isValidConfig = false;
  bool apiLoadingStatus = false;
  late String title;
  late String deviceId;
  late String field;
  late FontConfig titleFont;

  final DateFormat dateFormat = DateFormat('HH');
  final DateFormat dayFormat = DateFormat('EEE');
  List<Map<String, dynamic>> heatMapFinalData = [];
  late ChartThemeColor chartThemeColor;
  List<Color> colorPalette = [];

  @override
  void initState() {
    var config = widget.config;
    isValidConfig = widget.config.deviceId.isNotEmpty;
    deviceId = config.deviceId;
    title = config.title;
    field = config.field;
    titleFont = FontConfig.fromJson(config.titleFont);
    chartThemeColor = config.chartThemeColor;
    colorPalette = _getChartType(chartThemeColor);
    super.initState();
  }

  void _heatMapPrefill() {
    const rows = ['Sun', 'Mon', 'Tue', 'Wed', 'Thurs', 'Fri', 'Sat'];
    const columns = [
      '12 am',
      '1 am',
      '2 am',
      '3 am',
      '4 am',
      '5 am',
      '6 am',
      '7 am',
      '8 am',
      '9 am',
      '10 am',
      '11 am',
      '12 pm',
      '1 pm',
      '2 pm',
      '3 pm',
      '4 pm',
      '5 pm',
      '6 pm',
      '7 pm',
      '8 pm',
      '9 pm',
      '10 pm',
      '11 pm'
    ];

    final List<double> sampleData =
        List.filled(rows.length * columns.length, 0.0);
        print("map");
        print(heatMapFinalData);
        print("rr");
    for (var entry in heatMapFinalData) {
      final dayIndex = rows.indexOf(entry['day']);
      final timeIndex = columns.indexOf(entry['time']);
      if (dayIndex != -1 && timeIndex != -1) {
        final index = dayIndex * columns.length + timeIndex;
        sampleData[index] = entry['data'];
      }
    }
    print(sampleData);
    final items = [
      for (int row = 0; row < rows.length; row++)
        for (int col = 0; col < columns.length; col++)
          HeatmapItem(
            value: sampleData[row * columns.length + col],
            style: HeatmapItemStyle.filled,
            xAxisLabel: columns[col],
            yAxisLabel: rows[row],
          ),
    ];

    heatmapDataPower = HeatmapData(
        rows: rows,
        columns: columns,
        radius: 2.0,
        items: items,
        colorPalette: colorPalette);

        print("power");
        print(heatmapDataPower);
  }

  List<Color> _getChartType(ChartThemeColor type) {
    switch (type) {
      case ChartThemeColor.red:
        return colorPaletteRed;
      case ChartThemeColor.blue:
        return colorPaletteBlue;
      case ChartThemeColor.green:
        return colorPaletteGreen;
      case ChartThemeColor.orange:
        return colorPaletteDeepOrange;
      case ChartThemeColor.yellow:
        return colorPaletteYellow;
      case ChartThemeColor.purple:
        return colorPalettePurple;
      case ChartThemeColor.pink:
        return colorPalettePink;
      default:
        return colorPaletteBlue;
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

    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        vdivider,
        vdivider,
        if (title != "")
          Text(title,
              style: TextStyle(
                  fontFamily: titleFont.fontFamily,
                  fontSize: titleFont.fontSize,
                  fontWeight:
                      titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
                  color: Color(titleFont.fontColor))),
        vdivider,
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.center,
                children: [
                  Heatmap(
                    rowsVisible: 7,
                    heatmapData: heatmapDataPower,
                    showAllButtonText: "",
                  ),
                  Positioned.fill(
                    left: 50,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: heatmapDataPower.columns.length,
                        childAspectRatio: 1,
                      ),
                      itemCount: heatmapDataPower.items.length,
                      itemBuilder: (context, index) {
                        final item = heatmapDataPower.items[index];
                        return Container(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              item.value != 0.0
                                  ? item.value.toStringAsFixed(0)
                                  : " ",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future _load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;
    EqlCondition filterRange = const EqlCondition(name: 'filter', condition: {
      "range": {
        "updatedStamp": {"gte": "now/w", "lte": "now+1w/w"}
      },
    });
    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
            source: ["data"],
            page: 0,
            boolConditions: [filterRange],
            mustConditions: [
              {
                "match_phrase": {"deviceId": widget.config.deviceId}
              },
              {
                "exists": {"field": "data.${widget.config.field}"}
              },
            ],
            sort: {'updatedStamp': 'desc'}),
      );

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];
        List<Map<String, dynamic>> heatMapSeries = [];
        refresh(sync: () {
          for (Map<String, dynamic> obj in values) {
            int millis = obj['p_source']['updatedStamp'];
            DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
            String formattedDay = dayFormat.format(dateTime);
            String formattedTime = DateFormat("h a").format(dateTime);
            Map<String, dynamic> fieldObj = {};
            fieldObj['data'] = obj['p_source']['data'][widget.config.field];
            fieldObj['stamp'] = dateTime;
            fieldObj['time'] = formattedTime.toLowerCase();
            fieldObj['day'] = formattedDay;
            heatMapSeries.add(fieldObj);
          }
          heatMapFinalData = mergeStepCounts(heatMapSeries);
        });
        _heatMapPrefill();
      }
    });

    loading = false;
    apiLoadingStatus = true;
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}

class HeatMapWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return HeatMapWidget(config: HeatMapWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.timeline);
  }

  @override
  String getPaletteName() {
    return "Heat Map";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return HeatMapWidgetConfig.fromJson(config);
    }
    return HeatMapWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Heat Map Widget";
  }
}

List<Map<String, dynamic>> mergeStepCounts(List<Map<String, dynamic>> data) {
  Map<String, Map<String, dynamic>> accumulator = {};

  for (var entry in data) {
    String key = '${entry['time']}-${entry['day']}';

    if (accumulator.containsKey(key)) {
      accumulator[key]!['data'] += entry['data'];
    } else {
      accumulator[key] = Map.from(entry);
    }
  }

  return accumulator.values.toList();
}

const colorPaletteBlue = [
  Color(0xffF5F5F5),
  Color(0xffBBDEFB),
  Color(0xff90CAF9),
  Color(0xff64B5F6),
  Color(0xff42A5F5),
  Color(0xff2196F3),
  Color(0xff1E88E5),
  Color(0xff1976D2),
  Color(0xff3a7ce4),
  Color(0xff1565C0),
];

const colorPaletteDeepOrange = [
  Color(0xffF5F5F5),
  Color(0xffFFCCBC),
  Color(0xffFFAB91),
  Color(0xffFF8A65),
  Color(0xffFF7043),
  Color(0xffFF5722),
  Color(0xffF4511E),
  Color(0xffE64A19),
  Color(0xffD84315),
  Color(0xffBF360C),
];

const colorPaletteGreen = [
  Color(0xffF5F5F5),
  Color(0xffC8E6C9),
  Color(0xffC5E1A5),
  Color(0xffA5D6A7),
  Color(0xff66BB6A),
  Color(0xff4CAF50),
  Color(0xff388E3C),
  Color(0xff388E3C),
  Color(0xff2E7D32),
  Color(0xff1B5E20),
];

const colorPaletteRed = [
  Color(0xffF5F5F5),
  Color(0xffFFCDD2),
  Color(0xffEF9A9A),
  Color(0xffEF9A9A),
  Color(0xffEF5350),
  Color(0xffF44336),
  Color(0xffF44336),
  Color(0xffD32F2F),
  Color(0xffC62828),
  Color(0xffB71C1C),
];

const colorPaletteYellow = [
  Color(0xffFFFDE7),
  Color(0xffFFF9C4),
  Color(0xffFFF59D),
  Color(0xffFFF176),
  Color(0xffFFEE58),
  Color(0xffFFEB3B),
  Color(0xffFDD835),
  Color(0xffFBC02D),
  Color(0xffF9A825),
  Color(0xffF57F17),
];

const colorPalettePurple = [
  Color(0xffF3E5F5),
  Color(0xffE1BEE7),
  Color(0xffd993ec),
  Color(0xffCE93D8),
  Color(0xffBA68C8),
  Color(0xffAB47BC),
  Color(0xff9C27B0),
  Color(0xff8E24AA),
  Color(0xffa433e9),
  Color(0xff7B1FA2),
];

const colorPalettePink = [
  Color(0xffFCE4EC),
  Color(0xffF8BBD0),
  Color(0xffF48FB1),
  Color(0xffF06292),
  Color(0xffEC407A),
  Color(0xffE91E63),
  Color(0xffdb2373),
  Color(0xffD81B60),
  Color(0xffC2185B),
  Color(0xffAD1457),
];
