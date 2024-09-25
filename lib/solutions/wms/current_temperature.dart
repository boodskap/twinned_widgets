import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:intl/intl.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/range_gauge/range_gauge.dart';
import 'package:twinned_widgets/solutions/wms/country_name.dart';

class CurrentTemperatureWidget extends StatefulWidget {
  final DeviceFieldRangeGaugeWidgetConfig config;
  const CurrentTemperatureWidget({
    super.key,
    required this.config,
  });

  @override
  State<CurrentTemperatureWidget> createState() =>
      _CurrentTemperatureWidgetState();
}

class _CurrentTemperatureWidgetState
    extends BaseState<CurrentTemperatureWidget> {
  String _currentDate = '';
  String _currentTime = '';
  double currentTemperature = 0;
  double humidityValue = 0;
  double windSpeed = 0;
  bool isValidConfig = false;
  late String deviceId;
  late List<String> fields;
  bool loading = false;

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    fields = config.fields;
    _updateDateTime();

    isValidConfig = fields.isNotEmpty && deviceId.isNotEmpty;
    super.initState();
  }

  void _updateDateTime() {
    setState(() {
      _currentDate = DateFormat('EEE, MMM d, yyyy').format(DateTime.now());
      _currentTime = DateFormat('h:mm a,').format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4), // Border radius
        border: Border.all(
          color: Colors.white, // Border color
          width: 1, // Border width
        ),
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CountryNamePicker(),
              ),
            ),
            divider(height: 8),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_currentTime $_currentDate',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.cloudSun,
                    size: 50,
                    color: Colors.blueAccent.shade200,
                  ),
                  divider(width: 5, horizontal: true),
                  Text(
                    '${currentTemperature}°C',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            divider(height: 8),
            const Expanded(
              child: Text(
                'Cloudy',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            divider(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text(
                      'Humidity',
                      style: TextStyle(
                          color: Color(0XFFB3B3B3),
                          fontSize: 16,
                          fontWeight: FontWeight.w300),
                    ),
                    divider(height: 10),
                    Text(
                      '${humidityValue}%',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                divider(width: 10, horizontal: true),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'Wind Speed',
                      style: TextStyle(
                          color: Color(0XFFB3B3B3),
                          fontSize: 16,
                          fontWeight: FontWeight.w300),
                    ),
                    divider(height: 10),
                    Text(
                      '${windSpeed}m/s',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            divider(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> load() async {
    if (!isValidConfig || loading) return;
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
              "match_phrase": {"deviceId": deviceId}
            },
          ],
        ),
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
            currentTemperature = obj['p_source']['data'][fields[0]];
            humidityValue = obj['p_source']['data'][fields[1]];
            windSpeed = obj['p_source']['data'][fields[2]];
            // debugPrint(currentTemperature.toString());
            // debugPrint(humidityValue.toString());
            // debugPrint(windSpeed.toString());

            setState(() {
              currentTemperature = currentTemperature;
              humidityValue = humidityValue;
              windSpeed = windSpeed;
            });
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
