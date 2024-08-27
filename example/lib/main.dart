import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/common/total_value_widget.dart';
import 'package:twinned_widgets/common/value_distribution_pie_widget.dart';
import 'package:twinned_widgets/twinned_config_builder.dart';
import 'package:twinned_models/twinned_models.dart';
import 'package:twin_commons/core/twinned_session.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twinned Widgets Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Twinned Widgets Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends BaseState<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    if (!TwinnedSession.instance.authToken.isNotEmpty) {
      return Scaffold(
          appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 25.0,
          children: [
            InkWell(
                onTap: () {
                  super.alertDialog(
                      title: '',
                      body: TwinnedConfigBuilder(
                          verbose: true,
                          config: TotalValueWidgetConfig(),
                          parameters: TotalValueWidgetConfig().toJson(),
                          defaultParameters: TotalValueWidgetConfig().toJson(),
                          onConfigSaved: (data) {
                            debugPrint(jsonEncode(data));
                          }));
                },
                child: const Icon(Icons.settings)),
            SizedBox(
              width: 200,
              height: 200,
              child: TotalValueWidget(
                config: TotalValueWidgetConfig(
                  title: 'Total',
                  field: 'volume',
                  fieldSuffix: ' gals',
                  borderRadius: 180,
                  modelIds: [
                    'e4781f46-28bf-4d71-a2ea-e5748dde28a5',
                    '9fcd0f33-092a-416e-90c1-ba84dd77fde8'
                  ],
                  bgColor: Colors.orange.value,
                  borderColor: Colors.red.value,
                  borderWidth: 4.0,
                ),
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: TotalValueWidget(
                config: TotalValueWidgetConfig(
                  title: 'Total',
                  field: 'volume',
                  fieldSuffix: ' gals',
                  borderRadius: 0,
                  modelIds: [
                    'e4781f46-28bf-4d71-a2ea-e5748dde28a5',
                    '9fcd0f33-092a-416e-90c1-ba84dd77fde8'
                  ],
                  bgColor: Colors.green.value,
                  borderColor: Colors.red.value,
                  borderWidth: 4.0,
                ),
              ),
            ),
            SizedBox(
              width: 200,
              height: 200,
              child: TotalValueWidget(
                config: TotalValueWidgetConfig(
                  title: 'Total',
                  field: 'volume',
                  fieldSuffix: ' gals',
                  borderRadius: 45,
                  modelIds: [
                    'e4781f46-28bf-4d71-a2ea-e5748dde28a5',
                    '9fcd0f33-092a-416e-90c1-ba84dd77fde8'
                  ],
                  bgColor: Colors.transparent.value,
                  borderColor: Colors.red.value,
                  borderWidth: 4.0,
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: ValueDistributionPieChartWidget(
                config: ValueDistributionPieChartWidgetConfig(
                    field: 'level',
                    title: 'Tanks',
                    type: DistributionChartType.pie,
                    modelIds: [
                      'e4781f46-28bf-4d71-a2ea-e5748dde28a5',
                      '9fcd0f33-092a-416e-90c1-ba84dd77fde8'
                    ],
                    segments: [
                      Range(
                          from: 0,
                          to: 25,
                          label: 'Critical Tanks',
                          color: Colors.red.value),
                      Range(
                          from: 26,
                          to: 50,
                          label: 'Low Tanks',
                          color: Colors.orange.value),
                      Range(
                          from: 51,
                          to: 75,
                          label: 'Moderate Tanks',
                          color: Colors.lightGreen.value),
                      Range(
                          from: 76,
                          label: 'Good Tanks',
                          color: Colors.green.value),
                    ]),
              ),
            ),
            SizedBox(
              width: 300,
              child: ValueDistributionPieChartWidget(
                config: ValueDistributionPieChartWidgetConfig(
                    field: 'level',
                    title: 'Tanks',
                    type: DistributionChartType.doughnut,
                    modelIds: [
                      'e4781f46-28bf-4d71-a2ea-e5748dde28a5',
                      '9fcd0f33-092a-416e-90c1-ba84dd77fde8'
                    ],
                    segments: [
                      Range(
                          from: 0,
                          to: 25,
                          label: 'Critical Tanks',
                          color: Colors.red.value),
                      Range(
                          from: 26,
                          to: 50,
                          label: 'Low Tanks',
                          color: Colors.orange.value),
                      Range(
                          from: 51,
                          to: 75,
                          label: 'Moderate Tanks',
                          color: Colors.lightGreen.value),
                      Range(
                          from: 76,
                          label: 'Good Tanks',
                          color: Colors.green.value),
                    ]),
              ),
            ),
            SizedBox(
              width: 300,
              child: ValueDistributionPieChartWidget(
                config: ValueDistributionPieChartWidgetConfig(
                    field: 'level',
                    title: 'Tanks',
                    type: DistributionChartType.radial,
                    modelIds: [
                      'e4781f46-28bf-4d71-a2ea-e5748dde28a5',
                      '9fcd0f33-092a-416e-90c1-ba84dd77fde8'
                    ],
                    segments: [
                      Range(
                          from: 0,
                          to: 25,
                          label: 'Critical Tanks',
                          color: Colors.red.value),
                      Range(
                          from: 26,
                          to: 50,
                          label: 'Low Tanks',
                          color: Colors.orange.value),
                      Range(
                          from: 51,
                          to: 75,
                          label: 'Moderate Tanks',
                          color: Colors.lightGreen.value),
                      Range(
                          from: 76,
                          label: 'Good Tanks',
                          color: Colors.green.value),
                    ]),
              ),
            ),
            SizedBox(
              width: 300,
              child: ValueDistributionPieChartWidget(
                config: ValueDistributionPieChartWidgetConfig(
                    field: 'level',
                    title: 'Tanks',
                    type: DistributionChartType.pyramid,
                    modelIds: [
                      'e4781f46-28bf-4d71-a2ea-e5748dde28a5',
                      '9fcd0f33-092a-416e-90c1-ba84dd77fde8'
                    ],
                    segments: [
                      Range(
                          from: 0,
                          to: 25,
                          label: 'Critical Tanks',
                          color: Colors.red.value),
                      Range(
                          from: 26,
                          to: 50,
                          label: 'Low Tanks',
                          color: Colors.orange.value),
                      Range(
                          from: 51,
                          to: 75,
                          label: 'Moderate Tanks',
                          color: Colors.lightGreen.value),
                      Range(
                          from: 76,
                          label: 'Good Tanks',
                          color: Colors.green.value),
                    ]),
              ),
            ),
            SizedBox(
              width: 300,
              child: ValueDistributionPieChartWidget(
                config: ValueDistributionPieChartWidgetConfig(
                    field: 'level',
                    title: 'Tanks',
                    type: DistributionChartType.funnel,
                    modelIds: [
                      'e4781f46-28bf-4d71-a2ea-e5748dde28a5',
                      '9fcd0f33-092a-416e-90c1-ba84dd77fde8'
                    ],
                    segments: [
                      Range(
                          from: 0,
                          to: 25,
                          label: 'Critical Tanks',
                          color: Colors.red.value),
                      Range(
                          from: 26,
                          to: 50,
                          label: 'Low Tanks',
                          color: Colors.orange.value),
                      Range(
                          from: 51,
                          to: 75,
                          label: 'Moderate Tanks',
                          color: Colors.lightGreen.value),
                      Range(
                          from: 76,
                          label: 'Good Tanks',
                          color: Colors.green.value),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future load() async {
    if (loading) return;
    loading = true;

    TwinnedSession.instance.init(
        orgId: 'a154b385-fe1f-4c64-a768-686203ba0504',
        debug: true,
        host: 'twinned.digital',
        authToken: '',
        domainKey: '',
        noCodeAuthToken: '');

    loading = false;
    refresh();
  }

  @override
  void setup() {
    load();
  }
}
