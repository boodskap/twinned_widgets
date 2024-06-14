import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_models/timeline/timeline.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class StaticTimelineWidget extends StatefulWidget {
  final StaticTimelineWidgetConfig config;
  const StaticTimelineWidget({super.key, required this.config});

  @override
  State<StaticTimelineWidget> createState() => _StaticTimelineWidgetState();
}

class _StaticTimelineWidgetState extends BaseState<StaticTimelineWidget> {
  bool isValidConfig = false;
  late FontConfig titleFont;
  late Color titleFontColor;
  late FontConfig headerFont;
  late Color headerFontColor;
  late FontConfig subHeaderFont;
  late Color subHeaderFontColor;
  late FontConfig messageFont;
  late Color messageFontColor;

  late String title;
  List<String> heading = [];
  List<String> subHeading = [];
  List<String> message = [];
  List<int> colors = [];

  late double width;
  late double height;
  late int section;
  List<TimelineEvent> events = [];

  @override
  void initState() {
    super.initState();
    _initializeConfig();
    _validateConfig();
  }

  void _initializeConfig() {
    var config = widget.config;
    titleFont = FontConfig.fromJson(config.titleFont);
    titleFontColor = _getColor(titleFont.fontColor);
    headerFont = FontConfig.fromJson(config.headingFont);
    headerFontColor = _getColor(headerFont.fontColor);
    subHeaderFont = FontConfig.fromJson(config.subHeadingFont);
    subHeaderFontColor = _getColor(subHeaderFont.fontColor);
    messageFont = FontConfig.fromJson(config.messageFont);
    messageFontColor = _getColor(messageFont.fontColor);
    title = config.title;
    heading = config.heading;
    subHeading = config.subHeading;
    message = config.message;
    colors = [
      0xFFFFA0BE,
      0xFF89EEFD,
      0xFFA2E3C4,
      0XFFFBB84A,
      0XFF68B6A3,
      0XFFFA706D,
      0XFFAE9BF3,
      0XFFA87153,
      0XFFA87153,
      0XFF595741,
      0XFFCD483F,
      0XFFAEF88F,
      0XFFD38634,
      0XFFCFA96F,
      0XFF5E4366
    ];
    width = config.width;
    height = config.height;
    section = config.section;
  }

  Color _getColor(int colorValue) {
    return colorValue <= 0 ? Colors.black : Color(colorValue);
  }

  void _validateConfig() {
    isValidConfig = heading.length == section &&
        subHeading.length == section &&
        message.length == section;
  }

  void _loadEvents() {
    refresh(sync: () {
      events = List.generate(section, (index) {
        return TimelineEvent(
          heading: heading[index],
          subHeading: subHeading[index],
          color: colors[index],
          message: message[index],
          isLast: index == section - 1,
          width: width,
          height: height,
          title: title,
          headerFont: headerFont,
          headerFontColor: headerFontColor,
          subHeaderFont: subHeaderFont,
          subHeaderFontColor: subHeaderFontColor,
          messageFont: messageFont,
          messageFontColor: messageFontColor,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text(
          'Not configured properly',
          style: TextStyle(color: Colors.red, overflow: TextOverflow.ellipsis),
        ),
      );
    }

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
                fontWeight:
                    titleFont.fontBold ? FontWeight.bold : FontWeight.normal,
                fontSize: titleFont.fontSize,
                color: titleFontColor),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: events,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void setup() {
    _loadEvents();
  }
}

class TimelineEvent extends StatelessWidget {
  final String title;
  final String heading;
  final String subHeading;
  final int color;
  final String message;
  final bool isLast;
  final double width;
  final double height;
  final FontConfig headerFont;
  final Color headerFontColor;
  final FontConfig subHeaderFont;
  final Color subHeaderFontColor;
  final FontConfig messageFont;
  final Color messageFontColor;

  const TimelineEvent({
    required this.message,
    required this.heading,
    required this.color,
    required this.isLast,
    required this.width,
    required this.height,
    required this.subHeading,
    required this.title,
    required this.headerFont,
    required this.headerFontColor,
    required this.subHeaderFont,
    required this.subHeaderFontColor,
    required this.messageFont,
    required this.messageFontColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomPaint(
              size: const Size(35, 35), // Adjust size as needed
              painter: DiamondShapePainter(color: Color(color)),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              height: 3.0,
              width: width - 35,
              color: isLast ? Colors.transparent : Color(color),
            )
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: width,
          height: height,
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Color(color),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: Color(color),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          heading,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                              fontWeight: headerFont.fontBold
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: headerFont.fontSize,
                              color: headerFontColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: width,
                    decoration: BoxDecoration(
                      color: Color(color).withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subHeading,
                            style: TextStyle(
                                fontWeight: subHeaderFont.fontBold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: subHeaderFont.fontSize,
                                color: subHeaderFontColor),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            message,
                            style: TextStyle(
                                fontWeight: messageFont.fontBold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: messageFont.fontSize,
                                color: messageFontColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DiamondShapePainter extends CustomPainter {
  final Color color;

  DiamondShapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class StaticTimelineWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return StaticTimelineWidget(
        config: StaticTimelineWidgetConfig.fromJson(config));
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.credit_card);
  }

  @override
  String getPaletteName() {
    return "Static Timeline";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (null != config) {
      return StaticTimelineWidgetConfig.fromJson(config);
    }
    return StaticTimelineWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Static Timeline";
  }
}
