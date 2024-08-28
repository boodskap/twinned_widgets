import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/current_day_status/current_day_status.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class CurrentDayTemperatureWidget extends StatefulWidget {
  final CurrentDayStatusWidgetConfig config;
  const CurrentDayTemperatureWidget({
    super.key,
    required this.config,
  });

  @override
  State<CurrentDayTemperatureWidget> createState() =>
      _CurrentDayTemperatureWidgetState();
}

class _CurrentDayTemperatureWidgetState
    extends BaseState<CurrentDayTemperatureWidget> {
  String _currentDate = '';
  String _currentTime = '';
  double currentTemperature = 0;
  double humidityValue = 0;
  bool isValidConfig = false;
  late String deviceId;
  late List<String> fields;
  late FontConfig labelFont;
  late FontConfig dateFont;
  late FontConfig valueFont;

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    fields = config.fields;
    labelFont = FontConfig.fromJson(config.labelFont);
    dateFont = FontConfig.fromJson(config.dateFont);
    valueFont = FontConfig.fromJson(config.valueFont);

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
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white,
          width: 1,
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
                  Text('$_currentTime $_currentDate',
                      style: TwinUtils.getTextStyle(dateFont)),
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
                    '$currentTemperature°C',
                    style: TwinUtils.getTextStyle(labelFont)
                        .copyWith(fontSize: 34, color: const Color(0xFFF44336)),
                    // style: const TextStyle(
                    //   fontSize: 34,
                    //   fontWeight: FontWeight.bold,
                    // ),
                  ),
                ],
              ),
            ),
            divider(height: 8),
            Expanded(
              child: Text('Cloudy', style: TwinUtils.getTextStyle(labelFont)),
            ),
            divider(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'Humidity',
                      style: TwinUtils.getTextStyle(labelFont).copyWith(
                        color: const Color(0XFFB3B3B3),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    divider(height: 10),
                    Text(
                      '$humidityValue%',
                      style: TwinUtils.getTextStyle(valueFont),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      'Humidity',
                      style: TwinUtils.getTextStyle(labelFont).copyWith(
                          color: Colors.red,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                    divider(),
                    Text('$humidityValue',
                    style: TwinUtils.getTextStyle(valueFont).copyWith(),)
                  ],
                )
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
            // debugPrint(currentTemperature.toString());
            // debugPrint(humidityValue.toString());

            setState(() {
              currentTemperature = currentTemperature;
              humidityValue = humidityValue;
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

class CountryNamePicker extends StatefulWidget {
  const CountryNamePicker({super.key});

  @override
  State<CountryNamePicker> createState() => _CountryNamePickerState();
}

class _CountryNamePickerState extends State<CountryNamePicker> {
  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('IN');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Your city',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        divider(width: 10, horizontal: true),
        Flexible(
          child: SizedBox(
            width: 300,
            child: InkWell(
              onTap: _openCountryPickerDialog,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                child: Row(
                  children: [
                    CountryPickerUtils.getDefaultFlagImage(
                        _selectedDialogCountry),
                    divider(width: 10, horizontal: true),
                    Expanded(
                      child: Text(
                        _selectedDialogCountry.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.4,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: CountryPickerDialog(
              titlePadding: const EdgeInsets.all(8.0),
              searchCursorColor: Colors.pinkAccent,
              searchInputDecoration:
                  const InputDecoration(hintText: 'Search...'),
              isSearchable: true,
              title: const Text('Select your Country'),
              onValuePicked: (Country country) =>
                  setState(() => _selectedDialogCountry = country),
              itemBuilder: _buildDialogItem,
            ),
          ),
        ),
      );

  Widget _buildDialogItem(Country country) => Row(
        children: [
          CountryPickerUtils.getDefaultFlagImage(country),
          const SizedBox(width: 8.0),
          Flexible(child: Text(country.name))
        ],
      );
}

class CurrentDayTemperatureWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return CurrentDayTemperatureWidget(
      config: CurrentDayStatusWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.ac_unit_sharp);
  }

  @override
  String getPaletteName() {
    return "Current Day widget ";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return CurrentDayStatusWidgetConfig.fromJson(config);
    }
    return CurrentDayStatusWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Current day device field widget';
  }
}
