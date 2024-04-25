import 'package:flutter/material.dart';
import 'package:twinned_widgets/level/widgets/settings/conicaltank_settings.dart';
import 'package:twinned_widgets/level/widgets/settings/corkedbottle_settings.dart';
import 'package:twinned_widgets/level/widgets/settings/cylindertank_settings.dart';
import 'package:twinned_widgets/level/widgets/settings/cylindricaltank_settings.dart';
import 'package:twinned_widgets/level/widgets/settings/pressuregauge_settings.dart';
import 'package:twinned_widgets/level/widgets/settings/rectangulartank_settings.dart';
import 'package:twinned_widgets/level/widgets/settings/speedometer_settings.dart';
import 'package:twinned_widgets/level/widgets/settings/sphericaltank_settings.dart';
import 'package:twinned_widgets/sensor_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double width = 150;
  double height = 170;
  SensorWidgetType? widgetType = SensorWidgetType.none;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            SensorTypesDropdown(
                selected: widgetType,
                onSensorSelected: (value) {
                  setState(() {
                    widgetType = value;
                  });
                }),
            const SizedBox(
              height: 8,
            ),
            if (widgetType == SensorWidgetType.speedometer)
              SizedBox(
                  width: 500,
                  child: SpeedometerSettings(
                      label: 'Speedometer',
                      unit: 'kmph',
                      settings: const {},
                      onSettingsSaved: (settings) {
                        debugPrint('$settings');
                      })),
            if (widgetType == SensorWidgetType.pressureGauge)
              SizedBox(
                  width: 500,
                  child: PressureGaugeSettings(
                      label: 'Pressure Gauge',
                      unit: 'psi',
                      settings: const {},
                      onSettingsSaved: (settings) {
                        debugPrint('$settings');
                      })),
            if (widgetType == SensorWidgetType.conicalTank)
              SizedBox(
                  width: 500,
                  child: ConicalTankSettings(
                      label: 'Conical Tank',
                      settings: const {},
                      onSettingsSaved: (settings) {
                        debugPrint('$settings');
                      })),
            if (widgetType == SensorWidgetType.corkedBottle)
              SizedBox(
                  width: 500,
                  child: CorkedBottleSettings(
                      label: 'Corked Bottle',
                      settings: const {},
                      onSettingsSaved: (settings) {
                        debugPrint('$settings');
                      })),
            if (widgetType == SensorWidgetType.cylindricalTank)
              SizedBox(
                  width: 500,
                  child: CylindricalTankSettings(
                      label: 'Cylindrical Tank',
                      settings: const {},
                      onSettingsSaved: (settings) {
                        debugPrint('$settings');
                      })),
            if (widgetType == SensorWidgetType.rectangularTank)
              SizedBox(
                  width: 500,
                  child: RectangularTankSettings(
                      label: 'Rectangular Tank',
                      settings: const {},
                      onSettingsSaved: (settings) {
                        debugPrint('$settings');
                      })),
            if (widgetType == SensorWidgetType.sphericalTank)
              SizedBox(
                  width: 500,
                  child: SphericalTankSettings(
                      label: 'Spherical Tank',
                      settings: const {},
                      onSettingsSaved: (settings) {
                        debugPrint('$settings');
                      })),
                      if (widgetType == SensorWidgetType.cylinderTank)
              SizedBox(
                  width: 500,
                  child: CylinderTankSettings(
                      label: 'Cylinder Tank',
                      settings: const {},
                      onSettingsSaved: (settings) {
                        debugPrint('$settings');
                      })),
          ]),
        ),
      ),
    );
  }
}
