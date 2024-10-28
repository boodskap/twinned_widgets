import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_models/calendar_widget/calendar_widget.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class CalendarWidget extends StatefulWidget {
  final CalendarWidgetConfig config;
  const CalendarWidget({super.key, required this.config});

  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends BaseState<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool isValidConfig = false;
  late String deviceId;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig labelFont;

  Map<String, Map<String, String>> patientDetails = {
    'Blood Pressure': {'value': 'No Data', 'iconId': ''},
    'Cholesterol': {'value': 'No Data', 'iconId': ''},
    'Blood Glucose Level': {'value': 'No Data', 'iconId': ''},
    'Heart Rate': {'value': 'No Data', 'iconId': ''},
    'Body Temperature': {'value': 'No Data', 'iconId': ''},
  };

  @override
  void initState() {
    var config = widget.config;
    deviceId = config.deviceId;
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    isValidConfig = deviceId.isNotEmpty;

    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Wrap(
          spacing: 8.0,
          children: [
            Text(
              'Not configured properly',
              style:
                  TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: 400,
      child: Column(
        children: [
          TableCalendar(
            weekNumbersVisible: false,
            focusedDay: _focusedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2050),
            headerVisible: true,
            onHeaderTapped: (focusedDay) async {
              // Show a date picker dialog when the header is tapped
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: _focusedDay,
                firstDate: DateTime(2020),
                lastDate: DateTime(2050),
              );

              if (selectedDate != null && selectedDate != _focusedDay) {
                setState(() {
                  _focusedDay = selectedDate;
                  _selectedDay = selectedDate; // Update selected day
                });
                _load(selectedDate); // Load data for the selected day
              }
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _load(selectedDay);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: patientDetails.values
                      .any((detail) => detail['value'] != 'No Data')
                  ? SingleChildScrollView(
                      child: Column(
                        children: patientDetails.entries.map((entry) {
                          return PatientDetailCard(
                            title: entry.key,
                            value: entry.value['value']!,
                            iconId: entry.value['iconId']!,
                            color: getColorForParameter(entry.key),
                          );
                        }).toList(),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'No records found.',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Color getColorForParameter(String parameter) {
    switch (parameter) {
      case 'Blood Pressure':
        return Colors.redAccent;
      case 'Cholesterol':
        return Colors.green;
      case 'Blood Glucose Level':
        return Colors.orange;
      case 'Heart Rate':
        return Colors.purple;
      case 'Body Temperature':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }
Future<void> _load(DateTime day) async {
    if (!isValidConfig) return;
    if (loading) return;
    loading = true;

    DateTime startOfDay = DateTime(day.year, day.month, day.day);
    DateTime endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);

    String startOfStartDateStr = startOfDay.toUtc().toIso8601String();
    String endOfEndDateStr = endOfDay.toUtc().toIso8601String();

    EqlCondition filterRange = EqlCondition(name: 'filter', condition: {
      "range": {
        "updatedStamp": {
          "gte": startOfStartDateStr,
          "lte": endOfEndDateStr,
        }
      }
    });
    await execute(() async {
      var qRes = await TwinnedSession.instance.twin.queryDeviceHistoryData(
        apikey: TwinnedSession.instance.authToken,
        body: EqlSearch(
          page: 0,
          size: 1,
          source: [],
          mustConditions: [
            {
              "match_phrase": {"deviceId": deviceId}
            },
          ],
          sort: {'updatedStamp': 'desc'},
          boolConditions: [filterRange],
        ),
      );

      if (validateResponse(qRes)) {
        Map<String, dynamic> json = qRes.body!.result as Map<String, dynamic>;
        List<dynamic> values = json['hits']['hits'];

        if (values.isNotEmpty) {
          var data = values[0]['p_source']['data'];
          var modelId = values[0]['p_source']['modelId'];
          DeviceModel? deviceModel =
              await TwinUtils.getDeviceModel(modelId: modelId);

          updatePatientDetails(data, deviceModel);
        } else {
          resetPatientDetails();
        }
      } else {
        resetPatientDetails();
      }
    });

    loading = false;
    refresh();
  }

  void updatePatientDetails(
      Map<String, dynamic> data, DeviceModel? deviceModel) {
    patientDetails['Blood Pressure']!['iconId'] =
        TwinUtils.getParameterIcon('blood_pressure', deviceModel!);
    patientDetails['Cholesterol']!['iconId'] =
        TwinUtils.getParameterIcon('cholestrol', deviceModel);
    patientDetails['Blood Glucose Level']!['iconId'] =
        TwinUtils.getParameterIcon('blood_glucose_level', deviceModel);
    patientDetails['Heart Rate']!['iconId'] =
        TwinUtils.getParameterIcon('heart_rate', deviceModel);
    patientDetails['Body Temperature']!['iconId'] =
        TwinUtils.getParameterIcon('temperature', deviceModel);

    setState(() {
      patientDetails['Blood Pressure']!['value'] =
          '${data['blood_pressure']} mmHg';
      patientDetails['Cholesterol']!['value'] = '${data['cholestrol']} mg/dL';
      patientDetails['Blood Glucose Level']!['value'] =
          '${data['blood_glucose_level']} mg/dL';
      patientDetails['Heart Rate']!['value'] = '${data['heart_rate']} bpm';
      patientDetails['Body Temperature']!['value'] =
          '${data['temperature']} °C';
    });
  }

  void resetPatientDetails() {
    patientDetails.forEach((key, value) {
      value['value'] = 'No Data';
      value['iconId'] = '';
    });
    setState(() {});
  }

  @override
  void setup() {
    _load(_focusedDay);
  }
}

class PatientDetailCard extends StatelessWidget {
  final String title;
  final String value;
  final String iconId;
  final Color color;

  const PatientDetailCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconId,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: iconId.isNotEmpty
              ? TwinImageHelper.getCachedDomainImage(iconId,
                  width: 30, height: 30)
              : Container(
                  color: color,
                ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class CalendarWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return CalendarWidget(
      config: CalendarWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.calendar_month_outlined);
  }

  @override
  String getPaletteName() {
    return "Calendar Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return CalendarWidgetConfig.fromJson(config);
    }
    return CalendarWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Calendar Widget';
  }
}
