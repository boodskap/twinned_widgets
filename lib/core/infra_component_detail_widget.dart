import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:nocode_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart' as twin;
import 'package:twinned_widgets/core/field_sensor_data_widget.dart';
import 'package:twinned_widgets/core/top_bar.dart';
import 'package:twinned_widgets/core/twin_image_helper.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:timeago/timeago.dart' as timeago;

class InfraComponentDetailWidget extends StatefulWidget {
  final TwinInfraType twinInfraType;
  final String componentId;
  final int historySize;
  const InfraComponentDetailWidget(
      {super.key,
      required this.twinInfraType,
      required this.componentId,
      this.historySize = 25});

  @override
  State<InfraComponentDetailWidget> createState() =>
      _InfraComponentDetailWidgetState();
}

class _InfraComponentDetailWidgetState
    extends BaseState<InfraComponentDetailWidget> {
  String? _imageId;

  twin.Premise? _premise;
  twin.Facility? _facility;
  twin.Floor? _floor;
  twin.Asset? _asset;
  twin.Device? _device;

  Widget? _image;
  String _createdOn = '';
  String _updatedOn = '';
  String title = '';
  final List<Widget> _infraDetails = [];
  final List<twin.DeviceData> _deviceData = [];
  final Map<String, twin.DeviceModel> _deviceModels =
      <String, twin.DeviceModel>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(
              title: title,
            ),
            divider(),
            Row(
              children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: _image,
                ),
                divider(horizontal: true),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Created:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              divider(horizontal: true),
                              Text(_createdOn ?? '-'),
                              const Text(','),
                            ],
                          ),
                          divider(horizontal: true),
                          Row(
                            children: [
                              const Text('Last Reported:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              divider(horizontal: true),
                              Text(_updatedOn ?? '-'),
                            ],
                          ),
                        ],
                      ),
                      divider(),
                      if (_infraDetails.isNotEmpty)
                        Row(
                          children: _infraDetails,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            divider(),
            Flexible(
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                empty: const Text('No data found'),
                columns: [
                  const DataColumn2(
                    label: Text(
                      'Last Reported',
                    ),
                    size: ColumnSize.S,
                    fixedWidth: 180,
                  ),
                  if (widget.twinInfraType != TwinInfraType.device)
                    const DataColumn2(
                        label: Text(
                          'Device',
                        ),
                        size: ColumnSize.S,
                        fixedWidth: 150),
                  const DataColumn2(
                      label: Text(
                        'Location',
                      ),
                      size: ColumnSize.S,
                      fixedWidth: 150),
                  const DataColumn2(
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sensor Data',
                        ),
                      ],
                    ),
                    size: ColumnSize.L,
                  ),
                ],
                rows: _buildRows(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timestampToString(int millis) {
    var dt = DateTime.fromMillisecondsSinceEpoch(millis);
    return timeago.format(dt, locale: 'en');
  }

  List<DataRow2> _buildRows() {
    List<DataRow2> list = [];

    for (var dd in _deviceData) {
      twin.DeviceModel deviceModel = _deviceModels[dd.modelId]!;
      List<String> fields = NoCodeUtils.getSortedFields(deviceModel);
      list.add(DataRow2(specificRowHeight: 100, cells: [
        DataCell(_buildReportedStamp(dd.updatedStamp)),
        if (widget.twinInfraType != TwinInfraType.device)
          DataCell(_buildDeviceName(dd)),
        DataCell(_buildLocation()),
        DataCell(Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldSensorDataWidget(
              fields: fields,
              deviceModel: deviceModel,
              source: dd.toJson(),
              spacing: 10,
              alignment: MainAxisAlignment.start,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        )),
      ]));
    }

    return list;
  }

  Widget _buildReportedStamp(int millis) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _timestampToString(millis),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        //divider(),
        Text(DateTime.fromMillisecondsSinceEpoch(millis).toString()),
      ],
    );
  }

  Widget _buildDeviceName(twin.DeviceData dd) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dd.deviceName ?? '-',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        //divider(),
        Text(_deviceModels[dd.modelId]?.name ?? ''),
      ],
    );
  }

  Widget _buildLocation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _premise?.name ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        //divider(),
        Text('${_facility?.name ?? ''}, ${_floor?.name ?? ''}'),
      ],
    );
  }

  Future _loadPremise(bool setImage, String premiseId) async {
    await execute(() async {
      var res = await TwinnedSession.instance.twin.getPremise(
          apikey: TwinnedSession.instance.authToken, premiseId: premiseId);
      if (validateResponse(res)) {
        _premise = res.body!.entity;
        if (setImage) {
          _imageId = _premise?.images?.first;
        }
      }
    });
  }

  Future _loadFacility(bool setImage, String facilityId) async {
    await execute(() async {
      var res = await TwinnedSession.instance.twin.getFacility(
          apikey: TwinnedSession.instance.authToken, facilityId: facilityId);
      if (validateResponse(res)) {
        _facility = res.body!.entity;
        if (setImage) {
          _imageId = _facility?.images?.first;
        }
      }
    });
  }

  Future _loadFloor(bool setImage, String floorId) async {
    await execute(() async {
      var res = await TwinnedSession.instance.twin.getFloor(
          apikey: TwinnedSession.instance.authToken, floorId: floorId);
      if (validateResponse(res)) {
        _floor = res.body!.entity;
        if (setImage) {
          _imageId = _floor?.floorPlan;
        }
      }
    });
  }

  Future _loadAsset(bool setImage, String assetId) async {
    await execute(() async {
      var res = await TwinnedSession.instance.twin.getAsset(
          apikey: TwinnedSession.instance.authToken, assetId: assetId);
      if (validateResponse(res)) {
        _asset = res.body!.entity;
        if (setImage) {
          _imageId = _asset?.images?.first;
        }
      }
    });
  }

  Future _loadDevice(bool setImage, String deviceId) async {
    await execute(() async {
      var res = await TwinnedSession.instance.twin.getDevice(
          apikey: TwinnedSession.instance.authToken, deviceId: deviceId);
      if (validateResponse(res)) {
        _device = res.body!.entity;
        if (setImage) {
          _imageId = _device?.images?.first;
        }
      }
    });
  }

  Future _loadDeviceData() async {
    twin.DeviceDataArrayRes? res;

    String? deviceId;
    String? premiseId;
    String? facilityId;
    String? floorId;
    String? assetId;

    switch (widget.twinInfraType) {
      case TwinInfraType.premise:
        premiseId = _premise!.id;
        break;
      case TwinInfraType.facility:
        facilityId = _facility!.id;
        break;
      case TwinInfraType.floor:
        floorId = _floor!.id;
        break;
      case TwinInfraType.asset:
        assetId = _asset!.id;
        break;
      case TwinInfraType.device:
        deviceId = _device!.id;
        break;
    }

    await execute(() async {
      var sRes = await TwinnedSession.instance.twin.searchDeviceHistoryData(
          apikey: TwinnedSession.instance.authToken,
          deviceId: deviceId,
          floorId: floorId,
          assetId: assetId,
          premiseId: premiseId,
          facilityId: facilityId,
          body: twin.FilterSearchReq(
              search: '*', page: 0, size: widget.historySize));

      if (validateResponse(sRes)) {
        res = sRes.body!;
      }

      _deviceData.addAll(res?.values ?? []);

      for (var dd in _deviceData) {
        if (_deviceModels.containsKey(dd.modelId)) continue;

        var dmRes = await TwinnedSession.instance.twin.getDeviceModel(
            apikey: TwinnedSession.instance.authToken, modelId: dd.modelId);

        if (validateResponse(dmRes)) {
          _deviceModels[dd.modelId] = dmRes.body!.entity!;
        }
      }
    });
  }

  void _build() {
    if (null != _imageId) {
      _image = TwinImageHelper.getDomainImage(_imageId!);
    }

    switch (widget.twinInfraType) {
      case TwinInfraType.premise:
        _createdOn = _timestampToString(_premise!.createdStamp);
        _updatedOn = _timestampToString(_premise!.updatedStamp);
        break;
      case TwinInfraType.facility:
        _createdOn = _timestampToString(_facility!.createdStamp);
        _updatedOn = _timestampToString(_facility!.updatedStamp);
        _infraDetails.add(_createInfoWidget(
            imageId: _premise!.images?.first,
            label: _premise!.name,
            infra: 'Premise',
            defIcon: const Icon(Icons.home)));
        break;
      case TwinInfraType.floor:
        _createdOn = _timestampToString(_floor!.createdStamp);
        _updatedOn = _timestampToString(_floor!.updatedStamp);
        _infraDetails.add(_createInfoWidget(
            imageId: _premise!.images?.first,
            label: _premise!.name,
            infra: 'Premise',
            defIcon: const Icon(Icons.home)));
        _infraDetails.add(_createInfoWidget(
            imageId: _facility!.images?.first,
            label: _facility!.name,
            infra: 'Facility',
            defIcon: const Icon(Icons.business)));
        break;
      case TwinInfraType.asset:
        _createdOn = _timestampToString(_asset!.createdStamp);
        _updatedOn = _timestampToString(_asset!.updatedStamp);
        _infraDetails.add(_createInfoWidget(
            imageId: _premise!.images?.first,
            label: _premise!.name,
            infra: 'Premise',
            defIcon: const Icon(Icons.home)));
        _infraDetails.add(_createInfoWidget(
            imageId: _facility!.images?.first,
            label: _facility!.name,
            infra: 'Facility',
            defIcon: const Icon(Icons.business)));
        _infraDetails.add(_createInfoWidget(
            imageId: _floor!.floorPlan,
            label: _floor!.name,
            infra: 'Floor',
            defIcon: const Icon(Icons.cabin)));
        break;
      case TwinInfraType.device:
        if (null != _premise) {
          _infraDetails.add(_createInfoWidget(
              imageId: _premise!.images?.first,
              label: _premise!.name,
              infra: 'Premise',
              defIcon: const Icon(Icons.home)));
        }
        if (null != _facility) {
          _infraDetails.add(_createInfoWidget(
              imageId: _facility!.images?.first,
              label: _facility!.name,
              infra: 'Facility',
              defIcon: const Icon(Icons.business)));
        }
        if (null != _floor) {
          _infraDetails.add(_createInfoWidget(
              imageId: _floor!.floorPlan,
              label: _floor!.name,
              infra: 'Floor',
              defIcon: const Icon(Icons.cabin)));
        }
        if (null != _asset) {
          _infraDetails.add(_createInfoWidget(
              imageId: _asset!.images?.first,
              label: _asset!.name,
              infra: 'Asset',
              defIcon: const Icon(Icons.view_comfy)));
        }

        if (null != _device) {
          _createdOn = _timestampToString(_device!.createdStamp);
          _updatedOn = _timestampToString(_device!.updatedStamp);

          twin.DeviceModel deviceModel = _deviceModels[_device!.modelId]!;
          _infraDetails.add(_createInfoWidget(
              imageId: deviceModel.images?.first,
              label: deviceModel.name,
              infra: 'Model',
              defIcon: const Icon(Icons.bluetooth_audio)));
        }
        break;
    }
  }

  Widget _createInfoWidget(
      {String? imageId,
      required String label,
      required Icon defIcon,
      required String infra}) {
    Widget image = defIcon;

    if (null != imageId) {
      image = TwinImageHelper.getDomainImage(imageId!, fit: BoxFit.contain);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Tooltip(
        message: label,
        child: Column(
          children: [
            Text(
              infra,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
            divider(),
            IntrinsicHeight(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 48),
                  child: image),
            ),
          ],
        ),
      ),
    );
  }

  Future _load() async {
    if (loading) return;

    loading = true;

    _image = null;
    ;
    _createdOn = '';
    _updatedOn = '';
    _infraDetails.clear();
    _deviceData.clear();
    _deviceModels.clear();

    switch (widget.twinInfraType) {
      case TwinInfraType.premise:
        await _loadPremise(true, widget.componentId);
        title = 'Premise - ${_premise?.name}';
        break;
      case TwinInfraType.facility:
        await _loadFacility(true, widget.componentId);
        await _loadPremise(false, _facility!.premiseId);
        title = 'Facility - ${_facility?.name}';
        break;
      case TwinInfraType.floor:
        await _loadFloor(true, widget.componentId);
        await _loadFacility(false, _floor!.facilityId);
        await _loadPremise(false, _facility!.premiseId);
        title = 'Floor - ${_floor?.name}';
        break;
      case TwinInfraType.asset:
        await _loadAsset(true, widget.componentId);
        await _loadFloor(false, _asset!.floorId);
        await _loadFacility(false, _floor!.facilityId);
        await _loadPremise(false, _facility!.premiseId);
        title = 'Asset - ${_asset?.name}';
        break;
      case TwinInfraType.device:
        await _loadDevice(true, widget.componentId);
        title = 'Device - ${_device?.name}';
        break;
    }

    await _loadDeviceData();

    if (widget.twinInfraType == TwinInfraType.device) {
      twin.DeviceData dd = _deviceData.first;

      if (null != dd.assetId) {
        await _loadAsset(false, dd.assetId!);
        await _loadFloor(false, _asset!.floorId);
        await _loadFacility(false, _floor!.facilityId);
        await _loadPremise(false, _facility!.premiseId);
      }
    }

    _build();

    refresh();

    loading = false;
  }

  @override
  void setup() {
    _load();
  }
}
