import 'package:flutter/material.dart';
import 'package:twinned_models/calendar_widget/calendar_widget.dart';
import 'package:twinned_models/bar_chart_widget/bar_chart_widget.dart';
import 'package:twinned_models/ecg_graph_widget/ecg_graph_widget.dart';
import 'package:twinned_models/profile_card_widget.dart/profile_card_widget.dart';
import 'package:twinned_models/progress/progress.dart';
import 'package:twinned_widgets/common/bar_chart_widget.dart';
import 'package:twinned_widgets/common/calendar_widget.dart';
import 'package:twinned_widgets/common/device_field_percentage_widget.dart';
import 'package:twinned_widgets/common/ecg_chart_widget.dart';
import 'package:twinned_widgets/common/profile_card_widget.dart';

class PatientHealthcareDashboard extends StatefulWidget {
  const PatientHealthcareDashboard({super.key});

  @override
  State<PatientHealthcareDashboard> createState() =>
      _PatientHealthcareDashboardState();
}

class _PatientHealthcareDashboardState
    extends State<PatientHealthcareDashboard> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 75,
          child: Column(
            children: [
              Expanded(
                flex: 60,
                child: Row(
                  children: [
                    Expanded(
                      flex: 40,
                      child: ProfileCardWidget(
                        config: ProfileCardWidgetConfig(
                            cardBgColor: 0xFFFFFFFF,
                            patientName: 'Thirumal',
                            age: 25,
                            bloodGroup: 'B+',
                            height: 168,
                            weight: 72,
                            phoneNumber: 9875578578),
                      ),
                    ),
                    Expanded(
                      flex: 60,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 40,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Card(
                                elevation: 4,
                                color: Colors.white,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: DeviceFieldPercentageWidget(
                                        config: DeviceFieldPercentageWidgetConfig(
                                            circularRadius: 50,
                                            progressbarWidth: 10,
                                            shape: PercentageWidgetShape.circle,
                                            field: 'oxygen_level',
                                            title: 'Blood Oxygen Level',
                                            titleFont: {
                                              "fontSize": 16,
                                              "fontColor": 0xff000000,
                                              "fontBold": true
                                            },
                                            deviceId:
                                                'ce9738d2-60e9-4573-bd8b-b16dfced7e8a'),
                                      ),
                                    ),
                                    Expanded(
                                      child: DeviceFieldPercentageWidget(
                                        config: DeviceFieldPercentageWidgetConfig(
                                            circularRadius: 50,
                                            progressbarWidth: 10,
                                            shape: PercentageWidgetShape.circle,
                                            field: 'water_level',
                                            title: 'Water Level',
                                            titleFont: {
                                              "fontSize": 16,
                                              "fontColor": 0xff000000,
                                              "fontBold": true
                                            },
                                            deviceId:
                                                'ce9738d2-60e9-4573-bd8b-b16dfced7e8a'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 60,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: DeviceFieldBarChartWidget(
                                config: BarChartWidgetConfig(
                                  deviceId:
                                      'ce9738d2-60e9-4573-bd8b-b16dfced7e8a',
                                  title: 'Your Health Conditions',
                                  field: 'steps_count',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: EcgChartWidget(
                        config: EcgGraphWidgetConfig(
                          title: 'ECG Monitor',
                          deviceId: '2b1d374a-d59b-4c86-a485-f6482f115385',
                          field: 'heart_rate_ecg',
                          borderColor: 0xFFF44336,
                          borderWidth: 3,
                          chartBgColor: 0xFFFFFFFF,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 25,
          child: CalendarWidget(
            config: CalendarWidgetConfig(
                deviceId: 'ce9738d2-60e9-4573-bd8b-b16dfced7e8a'),
          ),
        )
      ],
    );
  }
}
