import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:timeago/timeago.dart' as timeago;

class DeviceFieldTemperatureGaugeWidget extends StatefulWidget {
  final double minimum;
  final double maximum;

  final double temperatureValue;
  final String deviceId;
  final String field;
  final Color backgroundColor;
  final Color gaugeColor;
  final Color pointerColor;
  final Color aboveTemperatureColor;
  final Color belowTemperatureColor;

  const DeviceFieldTemperatureGaugeWidget({
    super.key,
    this.minimum = 0,
    this.maximum = 150,
    
    this.temperatureValue = 0,
    required this.deviceId,
    required this.field,
    this.backgroundColor = Colors.white,
    this.gaugeColor = const Color(0xFFB3B1B1),
    this.pointerColor = Colors.transparent,
    this.aboveTemperatureColor = const Color(0xffFF7B7B),
    this.belowTemperatureColor = const Color(0xff0074E3),
  });

  @override
  State<DeviceFieldTemperatureGaugeWidget> createState() =>
      _DeviceFieldTemperatureGaugeWidgetState();
}

class _DeviceFieldTemperatureGaugeWidgetState
    extends BaseState<DeviceFieldTemperatureGaugeWidget> {
  bool isValidConfig = false;
  bool loading = false;

  late String deviceId;
  late String field;
  String subtitle = "";
  double value = 0;
  String fieldName = "--";
  String unit = "--";

  @override
  void initState() {
    super.initState();
    deviceId = widget.deviceId;
    field = widget.field;
    isValidConfig = deviceId.isNotEmpty && field.isNotEmpty;

    if (isValidConfig) {
      load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Column(
        children: [
          Text(
            "Not Configured Properly",
            style: TextStyle(color: Colors.red),
          )
        ],
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: widget.backgroundColor,
          width: 1,
        ),
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                fieldName,
               style: const TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Color(0xff000000)),
              ),
              Text(
                subtitle,
               style: const TextStyle(fontSize: 12,color: Color(0xff000000)),
              ),
              Expanded(
                child: SfLinearGauge(
                  minimum: widget.minimum,
                  maximum: widget.maximum,
                  interval: 30,
                  isMirrored: true,
                  minorTicksPerInterval: 20,
                  axisTrackExtent:1,
                  axisTrackStyle: LinearAxisTrackStyle(
                    thickness: 12,
                    color: widget.gaugeColor,
                    borderWidth: 1,
                    edgeStyle: LinearEdgeStyle.bothCurve,
                  ),
                  tickPosition: LinearElementPosition.outside,
                  labelPosition: LinearLabelPosition.outside,
                  orientation: LinearGaugeOrientation.vertical,
                  markerPointers: <LinearMarkerPointer>[
                    LinearWidgetPointer(
                      markerAlignment: LinearMarkerAlignment.end,
                      value: value,
                      enableAnimation: false,
                      position: LinearElementPosition.inside,
                      offset: 8,
                      child: SizedBox(
                        height: 30,
                        child: Text('$value°C'),
                      ),
                    ),
                    LinearShapePointer(
                      value: widget.minimum,
                      markerAlignment: LinearMarkerAlignment.start,
                      shapeType: LinearShapePointerType.circle,
                      borderWidth: 6,
                      borderColor: Colors.transparent,
                      color: value > widget.temperatureValue
                          ? widget.aboveTemperatureColor
                          : widget.belowTemperatureColor,
                      position: LinearElementPosition.cross,
                      width: 24,
                      height: 24,
                    ),
                    LinearWidgetPointer(
                      value: widget.minimum,
                      markerAlignment: LinearMarkerAlignment.start,
                      child: Container(
                        width: 10,
                        height: 3.4,
                        decoration: BoxDecoration(
                          border: const Border(
                            left: BorderSide(width: 2.0, color: Colors.black),
                            right: BorderSide(width: 2.0, color: Colors.blueAccent),
                          ),
                          color: value > widget.temperatureValue
                              ? widget.aboveTemperatureColor
                              : widget.belowTemperatureColor,
                        ),
                      ),
                    ),
                    LinearShapePointer(
                      value: value,
                      width: 20,
                      height: 20,
                      enableAnimation: false,
                      color: widget.pointerColor,
                      position: LinearElementPosition.cross,
                    ),
                  ],
                  barPointers: <LinearBarPointer>[
                    LinearBarPointer(
                      value: value,
                      enableAnimation: false,
                      thickness: 6,
                      edgeStyle: LinearEdgeStyle.endCurve,
                      color: value > widget.temperatureValue
                          ? widget.aboveTemperatureColor
                          : widget.belowTemperatureColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> load() async {
    if (!isValidConfig || loading) return;

    setState(() {
      loading = true;
    });

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
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
        ),
      );
      if (qRes.body != null &&
          qRes.body!.result != null &&
          validateResponse(qRes)) {
        Device? device = await TwinUtils.getDevice(deviceId: deviceId);
        if (device == null) return;

        DeviceModel? deviceModel =
            await TwinUtils.getDeviceModel(modelId: device.modelId);

        fieldName = TwinUtils.getParameterLabel(field, deviceModel!);
        unit = TwinUtils.getParameterUnit(field, deviceModel);

        Map<String, dynamic>? json = qRes.body!.result as Map<String, dynamic>?;
        if (json != null) {
          List<dynamic> hits = json['hits']['hits'];

          if (hits.isNotEmpty) {
            Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
            value = obj['p_source']['data'][field];

            setState(() {
              value = value;
              subtitle = _getUpdatedTimeAgo(obj['p_source']['updatedStamp']);
            });
          }
        }
      }
    });

    setState(() {
      loading = false;
    });
  }

  String _getUpdatedTimeAgo(int updatedStamp) {
    DateTime updatedDateTime =
        DateTime.fromMillisecondsSinceEpoch(updatedStamp);
    return timeago.format(updatedDateTime);
  }

  @override
  void setup() {
    load();
  }
}
