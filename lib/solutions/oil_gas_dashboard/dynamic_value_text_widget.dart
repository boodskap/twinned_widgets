import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/api/twinned.swagger.dart';
import 'package:twinned_models/dynamic_text_value_widget/dynamic_text_value_widget.dart';

class DynamicValueTextCardWidget extends StatefulWidget {
  final DynamicTextValueWidgetConfig config;
  const DynamicValueTextCardWidget({super.key, required this.config});

  @override
  State<DynamicValueTextCardWidget> createState() =>
      _DynamicValueTextCardWidgetState();
}

class _DynamicValueTextCardWidgetState
    extends BaseState<DynamicValueTextCardWidget> {
  late String field;
  late String deviceId;
  String fieldName = '--';
  bool isValidConfig = false;
  double? rawValue;

  @override
  void initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;

    isValidConfig = field.isNotEmpty && deviceId.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              fieldName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              rawValue != null ? '$rawValue K psi' : '--',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future load({String? filter, String search = '*'}) async {
    if (!isValidConfig) return;

    if (loading) return;
    loading = true;

    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          page: 0,
          size: 100,
          source: ["data.$field"],
          mustConditions: [
            {
              "exists": {"field": "data.$field"}
            },
            {
              "match_phrase": {"deviceId": widget.config.deviceId}
            },
          ],
        ),
      );

      if (validateResponse(qRes)) {
        Device? device = await TwinUtils.getDevice(deviceId: deviceId);
        if (device == null) return;

        DeviceModel? deviceModel =
            await TwinUtils.getDeviceModel(modelId: device.modelId);

        fieldName = TwinUtils.getParameterLabel(field, deviceModel!);
        Map<String, dynamic> json = qRes.body!.result! as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];
        if (values.isNotEmpty) {
          for (Map<String, dynamic> obj in values) {
            rawValue = double.tryParse(
                    obj['p_source']['data'][widget.config.field].toString()) ??
                0.0;
          }
        }
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
