import 'package:flutter/material.dart';
import 'package:twinned_widgets/core/twin_image_helper.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart' as twinned;
import 'package:twinned_models/models.dart';
import 'package:twinned_models/grid/grid_widget.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:nocode_commons/sensor_widget.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class AssetModelDataGridWidget extends StatefulWidget {
  final AssetModelDataGridWidgetConfig config;
  const AssetModelDataGridWidget({super.key, required this.config});

  @override
  State<AssetModelDataGridWidget> createState() =>
      _AssetModelDataGridWidgetState();
}

class _AssetModelDataGridWidgetState
    extends BaseState<AssetModelDataGridWidget> {
  late TextStyle titleStyle;
  late TextStyle labelStyle;
  late TextStyle headerStyle;
  final List<DataRow2> _rows = [];
  bool isValidConfig = true;
  final Map<String, twinned.DeviceModel> _models =
      <String, twinned.DeviceModel>{};
  Widget empty = const Text('Loading..,');

  void _validate() {
    isValidConfig = widget.config.modelIds.isNotEmpty;

    if (!isValidConfig) return;

    var fc = FontConfig.fromJson(widget.config.titleFont);

    titleStyle = GoogleFonts.getFont(fc.fontFamily,
        color: Color(fc.fontColor),
        fontSize: fc.fontSize,
        fontWeight: fc.fontBold ? FontWeight.bold : FontWeight.normal);

    fc = FontConfig.fromJson(widget.config.labelFont);

    labelStyle = GoogleFonts.getFont(fc.fontFamily,
        color: Color(fc.fontColor),
        fontSize: fc.fontSize,
        fontWeight: fc.fontBold ? FontWeight.bold : FontWeight.normal);

    headerStyle = labelStyle.copyWith(fontSize: labelStyle.fontSize! + 2);
  }

  @override
  Widget build(BuildContext context) {
    _validate();

    if (!isValidConfig) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Not configured properly',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          )
        ],
      );
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.config.title,
            style: titleStyle,
          ),
        ),
        Expanded(
          child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 600,
            headingTextStyle: headerStyle,
            empty: empty,
            columns: [
              if (widget.config.showTimestamp)
                const DataColumn2(
                  label: Text(
                    'Last Reported',
                  ),
                  size: ColumnSize.S,
                ),
              if (widget.config.showAsset)
                const DataColumn2(
                  label: Text(
                    'Asset',
                  ),
                  size: ColumnSize.S,
                ),
              if (widget.config.showDevice)
                const DataColumn2(
                  label: Text(
                    'Device',
                  ),
                  size: ColumnSize.S,
                ),
              if (widget.config.showPremise)
                const DataColumn2(
                  label: Text(
                    'Premise',
                  ),
                  size: ColumnSize.S,
                ),
              if (widget.config.showFacility)
                const DataColumn2(
                  label: Text(
                    'Facility',
                  ),
                  size: ColumnSize.S,
                ),
              if (widget.config.showFloor)
                const DataColumn2(
                  label: Text(
                    'Floor',
                  ),
                  size: ColumnSize.S,
                ),
              if (widget.config.showData)
                DataColumn2(
                    label: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sensor Data',
                        ),
                      ],
                    ),
                    size: ColumnSize.L,
                    fixedWidth: widget.config.dataWidth.toDouble()),
            ],
            rows: _rows,
          ),
        ),
      ],
    );
  }

  String timestampToString(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    return timeago.format(dt, locale: 'en');
  }

  Future _load() async {
    _validate();

    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    _rows.clear();

    await execute(() async {
      Object? sort;

      if (widget.config.sortField.isNotEmpty) {
        sort = {"data.${widget.config.sortField}": widget.config.sortType.name};
      } else {
        sort = {"updatedStamp": "desc"};
      }

      debugPrint('API STARTING');

      twinned.EqlSearch search = twinned.EqlSearch(source: [
        "data",
        "deviceId",
        "modelId",
        "hardwareDeviceId",
        "deviceName",
        "modelName",
        "premise",
        "facility",
        "floor",
        "asset",
        "updatedStamp"
      ], mustConditions: [
        {
          "terms": {
            "assetModelId${widget.config.oldSearchVersion ? '.keyword' : ''}":
                widget.config.modelIds
          }
        }
      ], page: 0, size: widget.config.pageSize, sort: sort);

      debugPrint(search.toString());

      var res = await TwinnedSession.instance.twin.queryDeviceData(
          apikey: TwinnedSession.instance.authToken, body: search);

      debugPrint('API COMPLETED');

      if (validateResponse(res)) {
        Map<String, dynamic> json = res.body!.result as Map<String, dynamic>;
        int length = json['hits']['hits'].length;

        for (int i = 0; i < length; i++) {
          Map<String, dynamic> source = json['hits']['hits'][i]['p_source'];
          Map<String, dynamic> data = source['data'];

          _rows.add(DataRow2(specificRowHeight: 80, cells: [
            if (widget.config.showTimestamp)
              DataCell(Text(
                timestampToString(source['updatedStamp']),
                style: labelStyle,
              )),
            if (widget.config.showAsset)
              DataCell(Text(
                '${source['asset']}',
                style: labelStyle,
              )),
            if (widget.config.showDevice)
              DataCell(Text(
                '${source['deviceName']}',
                style: labelStyle,
              )),
            if (widget.config.showPremise)
              DataCell(Text(
                '${source['premise']}',
                style: labelStyle,
              )),
            if (widget.config.showFacility)
              DataCell(Text(
                '${source['facility']}',
                style: labelStyle,
              )),
            if (widget.config.showFloor)
              DataCell(Text(
                '${source['floor']}',
                style: labelStyle,
              )),
            if (widget.config.showData) await _buildCell(source),
          ]));
        }
      }
    });

    refresh(sync: () {
      if (_rows.isEmpty) {
        empty = Text(
          'No data found',
          style: labelStyle,
        );
      }
    });

    loading = false;
  }

  Widget _buildWidget(String field, twinned.DeviceModel deviceModel,
      Map<String, dynamic> source) {
    SensorWidgetType type = NoCodeUtils.getSensorWidgetType(field, deviceModel);
    twinned.Parameter? parameter = NoCodeUtils.getParameter(field, deviceModel);

    if (null == parameter) {
      return const SizedBox(
        width: 80,
        height: 80,
        child: Placeholder(
          color: Colors.red,
        ),
      );
    }

    Widget sensorWidget;

    if (type == SensorWidgetType.none) {
      Widget icon;
      Map<String, dynamic> data = source['data'];
      if (parameter!.icon?.isEmpty ?? true) {
        icon = const Icon(Icons.device_unknown_sharp);
      } else {
        icon = SizedBox(
            width: 24, child: TwinImageHelper.getDomainImage(parameter!.icon!));
      }
      String label = NoCodeUtils.getParameterLabel(field, deviceModel);
      String unit = NoCodeUtils.getParameterUnit(field, deviceModel);
      String value = '${data[field] ?? '-'} $unit';
      sensorWidget = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: labelStyle,
          ),
          divider(),
          icon,
          Text(
            value,
            style: labelStyle,
          )
        ],
      );
    } else {
      twinned.DeviceData dd = twinned.DeviceData.fromJson(source);

      sensorWidget = SizedBox(
        width: 70,
        height: 70,
        child: SensorWidget(
          parameter: parameter!,
          tiny: false,
          deviceData: dd,
          deviceModel: deviceModel,
        ),
      );
    }

    return sensorWidget;
  }

  Future<DataCell> _buildCell(Map<String, dynamic> source) async {
    String modelId = source['modelId'];
    if (!_models.containsKey(modelId)) {
      var res = await TwinnedSession.instance.twin.getDeviceModel(
          apikey: TwinnedSession.instance.authToken, modelId: modelId);
      if (validateResponse(res)) {
        _models[modelId] = res.body!.entity!;
      }
    }

    List<String> allFields = NoCodeUtils.getSortedFields(_models[modelId]!);

    if (widget.config.filterFields.isNotEmpty) {
      allFields.clear();
      allFields.addAll(widget.config.filterFields);
    }

    List<Widget> children = [];

    for (String field in allFields) {
      children.add(_buildWidget(field, _models[modelId]!, source));
    }

    return DataCell(Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: children,
    ));
  }

  @override
  void setup() {
    _load();
  }
}

class AssetModelDataGridWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return AssetModelDataGridWidget(
        config: AssetModelDataGridWidgetConfig.fromJson(config));
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return AssetModelDataGridWidgetConfig.fromJson(config);
    }
    return AssetModelDataGridWidgetConfig();
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.grid_4x4);
  }

  @override
  String getPaletteName() {
    return 'Asset Data Grid';
  }

  @override
  String getPaletteTooltip() {
    return 'Data grid based on asset models and field filters';
  }
}
