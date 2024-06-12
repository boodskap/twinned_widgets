import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_models/multi_device_field_page/multi_device_field_page.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/core/twin_image_helper.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class MultiDeviceFieldPageWidget extends StatefulWidget {
  final MultiDeviceFieldPageWidgetConfig config;

  const MultiDeviceFieldPageWidget({super.key, required this.config});

  @override
  State<MultiDeviceFieldPageWidget> createState() =>
      _MultiDeviceFieldPageWidgetState();
}

class _MultiDeviceFieldPageWidgetState
    extends BaseState<MultiDeviceFieldPageWidget> {
  bool isValidConfig = false;
  late String field;
  late String deviceId;
  late String title;
  late String cityName;
  late String imageId;
  late String subText;
  late String contentText;
  dynamic dateTime;
  late Color fillColor;
  late Color borderColor;
  late FontConfig valueFont;
  late FontConfig preSuffixTextFont;
  late FontConfig subTextFont;
  late FontConfig contentTextFont;

  void _initState() {
    var config = widget.config;
    field = config.field;
    deviceId = config.deviceId;
    title = config.title;
    cityName = config.cityName;
    imageId = config.imageId;
    subText = config.subText;
    contentText = config.contentText;
    dateTime = config.dateTime;
    fillColor = Color(config.fillColor);
    borderColor = Color(config.borderColor);
    valueFont = FontConfig.fromJson(config.valueFont);
    preSuffixTextFont = FontConfig.fromJson(config.preSuffixTextFont);
    subTextFont = FontConfig.fromJson(config.subTextFont);
    contentTextFont = FontConfig.fromJson(config.contentTextFont);

    isValidConfig = deviceId.isNotEmpty && field.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    _initState();

    if (!isValidConfig) {
      return const Center(
        child: Wrap(
          spacing: 8,
          children: [
            Text(
              'Not Configure Properly',
              style:
                  TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
            )
          ],
        ),
      );
    }
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              color: fillColor,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      cityName,
                      style: const TextStyle(
                        color: Color(0XFFFFFAFA),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEE, MMM d, hh:mm a')
                          .format(dateTime as DateTime),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0XFFFFFAFA),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (imageId.isNotEmpty)
                      SizedBox(
                          width: 100,
                          height: 100,
                          child: TwinImageHelper.getDomainImage(imageId)),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Text(
                              '2',
                              style: TextStyle(
                                fontSize: 50,
                                color: Color(0XFFF8F8FF),
                              ),
                            ),
                            Text(
                              '°',
                              style: TextStyle(
                                fontSize: 40,
                                color: Color(0XFFF8F8FF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    divider(height: 10),
                    const Text(
                      'Hey Cameron',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0XFFFFFAFA),
                      ),
                    ),
                    divider(height: 10),
                    const Column(
                      children: [
                        Text(
                          "It's gonna be a cold & stromy night...",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0XFFFFFAFA),
                          ),
                        ),
                        Text(
                          'Better get your umbrella with you.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0XFFFFFAFA),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Add a curved wave line here
                    CustomPaint(
                      size: const Size(400, 50),
                      painter: CurvePainter(),
                    ),
                    divider(height: 10),
                    // Add the list of days of the week here
                    const WeekdaysRow(),
                    divider(height: 10),
                  ],
                ),
              ),
            ),
            // Add the SfCalendar widget here
          ],
        ),
      ),
    );
  }

  @override
  void setup() {}
}

class MultiDeviceFieldPageWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return MultiDeviceFieldPageWidget(
      config: MultiDeviceFieldPageWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.wb_iridescent_rounded);
  }

  @override
  String getPaletteName() {
    return "Multi Device Field Page";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return MultiDeviceFieldPageWidgetConfig.fromJson(config);
    }
    return MultiDeviceFieldPageWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Multi device field page widget';
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0XFFFFFAFA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.4);
    path1.quadraticBezierTo(
        size.width / 4, size.height * 0.7, size.width / 2, size.height * 0.4);
    path1.quadraticBezierTo(
        size.width * 3 / 4, size.height * 0.1, size.width, size.height * 0.4);

    final paint2 = Paint()
      ..color = const Color(0XFFFFFAFA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.6);
    path2.quadraticBezierTo(
        size.width / 4, size.height * 0.9, size.width / 2, size.height * 0.6);
    path2.quadraticBezierTo(
        size.width * 3 / 4, size.height * 0.3, size.width, size.height * 0.6);

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class WeekdaysRow extends StatelessWidget {
  const WeekdaysRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> days = [
      {'day': 'Mon', 'icon': Icons.wb_sunny, 'min': '22°', 'max': '28°'},
      {'day': 'Tue', 'icon': Icons.wb_cloudy, 'min': '18°', 'max': '29°'},
      {'day': 'Wed', 'icon': Icons.wb_sunny, 'min': '25°', 'max': '39°'},
      {'day': 'Thu', 'icon': Icons.grain, 'min': '20°', 'max': '36°'},
      {'day': 'Fri', 'icon': Icons.wb_sunny, 'min': '23°', 'max': '33°'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((dayInfo) {
        return Column(
          children: [
            Text(
              dayInfo['day']!,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0XFFFFFAFA),
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              dayInfo['icon'] as IconData,
              color: const Color(0XFFFFFAFA),
            ),
            const SizedBox(height: 4),
            Text(
              dayInfo['min']!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0XFFFFFAFA),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayInfo['max']!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0XFFDFDFDE),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

Widget divider({bool horizontal = false, double width = 0, double height = 0}) {
  return horizontal ? SizedBox(width: width) : SizedBox(height: height);
}
