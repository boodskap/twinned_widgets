import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_widgets/twinned_session.dart';
import 'package:twinned_widgets/common/total_value_widget.dart';
import 'package:configs/models.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (!TwinnedSession.instance.inited)
              const Icon(Icons.hourglass_bottom),
            if (TwinnedSession.instance.inited)
              SizedBox(
                width: 400,
                height: 300,
                child: TotalValueWidget(
                  config: TotalValueWidgetConfig(
                      field: 'volume',
                      fieldSuffix: ' gals',
                      modelIds: ['9fcd0f33-092a-416e-90c1-ba84dd77fde8'],
                      bgColor: Colors.orange.value,
                      borderColor: Colors.red.value,
                      borderWidth: 4.0,
                      headerFont: FontConfig(
                          fontColor: Colors.black.value,
                          fontBold: true,
                          fontSize: 40),
                      labelFont: FontConfig(
                          fontColor: Colors.black.value,
                          fontBold: true,
                          fontSize: 32)),
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

    await TwinnedSession.instance.load(host: 'twinned.boodskap.io');

    TwinnedSession.instance.authToken = '';

    loading = false;
    refresh();
  }

  @override
  void setup() {
    load();
  }
}
