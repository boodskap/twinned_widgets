import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/grid/grid_widget.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';


class AssetModelGridWidget extends StatefulWidget {
  final AssetModelGridWidgetConfig config;
  const AssetModelGridWidget({super.key, required this.config});

  @override
  State<AssetModelGridWidget> createState() => _AssetModelGridWidgetState();
}

class _AssetModelGridWidgetState extends BaseState<AssetModelGridWidget> {
  final List<dynamic> tankDataList = [];
  late List<Map<String, dynamic>> dataGridSource = [];
 
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
         Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.config.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: SfDataGrid(
            gridLinesVisibility: GridLinesVisibility.both,
            headerGridLinesVisibility: GridLinesVisibility.both,
            source: DynamicDataGridSource(dataSource: dataGridSource),
            columns: dataGridSource.isNotEmpty
                ? dataGridSource.first.entries.map((entry) {
                    dynamic columnName = entry.key;
                    return GridColumn(
                      columnName: columnName,
                      label: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          columnName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList()
                : [],
          ),
        ),
      ],
    );
  }

  Future _load() async {
    if (loading) return;
    loading = true;

    await execute(() async {
      var res = await TwinnedSession.instance.twin.queryDeviceData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          source: ["data"],
          page: 0,
          size: widget.config.pageSize,
          conditions: [],
          boolConditions: [],
          queryConditions: [],
          mustConditions: [
            {
              "terms": {"assetModelId.keyword": widget.config.modelIds}
            },
          ],
          sort: {'updatedStamp': 'desc'},
        ),
      );

      if (validateResponse(res)) {
        Map<String, dynamic> json = res.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];
        List<String> fieldsToCheck = widget.config.fields;
        List<String> fieldsLabels = widget.config.fieldLabels;

        if (values.isNotEmpty) {
          for (Map<String, dynamic> obj in values) {
            dynamic dataSource = obj['p_source']['data'];
            if (dataSource is Map<dynamic, dynamic>) {
              refresh(sync: () {
                Map<String, dynamic> dataEntry = {};
                for (int i = 0; i < fieldsToCheck.length; i++) {
                  String fieldToCheck = fieldsToCheck[i];
                  if (dataSource.containsKey(fieldToCheck)) {
                    dataEntry[fieldsLabels[i]] =
                        dataSource[fieldToCheck].toString();
                  }
                  else{
                     dataEntry[fieldsLabels[i]] =
                        '-';
                  }
                }
                dataGridSource.add(dataEntry);
              });
            }
          }
        }
      }
    });

    loading = false;
  }

  @override
  void setup() {
    _load();
  }
}

class DynamicDataGridSource extends DataGridSource {
  DynamicDataGridSource({required List<Map<String, dynamic>> dataSource}) {
    dataGridSource = dataSource
        .map<DataGridRow>((data) => DataGridRow(
            cells: data.entries
                .map<DataGridCell<dynamic>>((entry) => DataGridCell<dynamic>(
                    columnName: entry.key, value: entry.value))
                .toList()))
        .toList();
  }

  List<DataGridRow> dataGridSource = [];

  @override
  List<DataGridRow> get rows => dataGridSource;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataCell) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(dataCell.value.toString()),
        );
      }).toList(),
    );
  }
}

class AssetModelGridWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return AssetModelGridWidget(
        config: AssetModelGridWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.dataGrids;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.grid_on);
  }

  @override
  String getPaletteName() {
    return "Asset Model Grid";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return AssetModelGridWidgetConfig.fromJson(config);
    }
    return AssetModelGridWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Asset Model Based Dynamic Field Grid";
  }
}