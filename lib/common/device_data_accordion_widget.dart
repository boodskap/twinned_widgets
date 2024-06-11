import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/device_data_accordion/device_data_accordion.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_api/twinned_api.dart';

class DeviceDataAccordionWidget extends StatefulWidget {
  final DeviceDataAccordionWidgetConfig config;
  const DeviceDataAccordionWidget({super.key, required this.config});

  @override
  State<DeviceDataAccordionWidget> createState() =>
      _DeviceDataAccordionWidgetState();
}

class _DeviceDataAccordionWidgetState
    extends BaseState<DeviceDataAccordionWidget> {
  late String title;
  late String deviceId;
  bool isValidConfig = false;
  late FontConfig titleFont;
  late FontConfig accordionTitleFont;
  late FontConfig tableColumnFont;
  late FontConfig tableRowFont;
  late Color headerOpenedColor;
  late Color headerClosedColor;
  late Color tableContentColor;
  String field = '';
  String value = '';
  List<Map<String, String>> deviceData = [];

  @override
  void initState() {
    var config = widget.config;
    deviceId = widget.config.deviceId;
    title = widget.config.title;
    titleFont = FontConfig.fromJson(config.titleFont);
    accordionTitleFont = FontConfig.fromJson(config.accordionTitleFont);
    tableColumnFont = FontConfig.fromJson(config.tableColumnFont);
    tableRowFont = FontConfig.fromJson(config.tableRowFont);
    headerOpenedColor = config.headerOpenedColor <= 0
        ? Colors.black
        : Color(config.headerOpenedColor);
    headerClosedColor = config.headerClosedColor <= 0
        ? Colors.black
        : Color(config.headerClosedColor);
    tableContentColor = config.tableContentColor <= 0
        ? Colors.black
        : Color(config.tableContentColor);
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
    return Column(children: [
      Text(
        title,
        style: TextStyle(
            fontSize: titleFont.fontSize,
            color: Color(titleFont.fontColor),
            fontFamily: titleFont.fontFamily,
            fontWeight:
                titleFont.fontBold ? FontWeight.bold : FontWeight.normal),
      ),
      Accordion(
        headerBorderColor: headerClosedColor,
        headerBorderColorOpened: Colors.transparent,
        headerBorderWidth: 1,
        headerBackgroundColor: headerClosedColor,
        headerBackgroundColorOpened: headerOpenedColor,
        contentBackgroundColor: tableContentColor,
        contentBorderColor: headerOpenedColor,
        contentBorderWidth: 3,
        contentHorizontalPadding: 20,
        scaleWhenAnimating: true,
        openAndCloseAnimation: true,
        headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
        sectionClosingHapticFeedback: SectionHapticFeedback.light,
        children: [
          AccordionSection(
            isOpen: false,
            leftIcon: const Icon(Icons.devices_other, color: Colors.white),
            header: Text(
              deviceId,
              style: TextStyle(
                  fontSize: accordionTitleFont.fontSize,
                  fontFamily: accordionTitleFont.fontFamily,
                  fontWeight: accordionTitleFont.fontBold
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: Color(accordionTitleFont.fontColor)),
            ),
            content: MyDataTable(deviceData: deviceData),
          ),
        ],
      ),
    ]);
  }

  Future load({String? filter, String search = '*'}) async {
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
            {
              "exists": {"field": "data.$field"}
            },
          ],
        ),
      );

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;

        List<dynamic> values = json['hits']['hits'];
        List<Map<String, String>> fetchedData = [];
        if (values.isNotEmpty) {
          for (Map<String, dynamic> obj in values) {
            var data = obj['p_source']['data'];
            var fieldData = data['field']?.toString() ?? '';
            var valueData = data['value']?.toString() ?? '';

            fetchedData.add({
              'field': fieldData,
              'value': valueData,
            });
          }
        }
        setState(() {
          deviceData = fetchedData;
        });
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

class MyDataTable extends StatelessWidget {
  final List<Map<String, String>> deviceData;

  const MyDataTable({super.key, required this.deviceData});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      sortAscending: true,
      sortColumnIndex: 1,
      showBottomBorder: false,
      columns: const [
        DataColumn(
            label: Text(
          'Device Data',
        )),
        DataColumn(
            label: Text(
              'Values',
            ),
            numeric: true),
      ],
      rows: deviceData
          .map(
            (data) => DataRow(
              cells: [
                DataCell(Text(data['field'] ?? '')),
                DataCell(Text(data['value'] ?? '')),
              ],
            ),
          )
          .toList(),
    );
  }
}

class DeviceDataAccordionWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceDataAccordionWidget(
        config: DeviceDataAccordionWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.devices_fold);
  }

  @override
  String getPaletteName() {
    return "Device Data Accordion";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return DeviceDataAccordionWidgetConfig.fromJson(config);
    }
    return DeviceDataAccordionWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Device Data Accordion';
  }
}
