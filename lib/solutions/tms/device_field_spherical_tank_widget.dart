import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/level/liquid_container.dart';
import 'package:twin_commons/level/widgets/corked_bottle.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twinned_models/device_field_spherical_tank/device_field_spherical_tank.dart';
import 'package:twinned_models/models.dart';

class SphericalTank extends StatefulWidget {
  final bool shouldAnimate;

  final DeviceFieldSphericalTankWidgetConfig config;

  const SphericalTank({
    super.key,
    this.shouldAnimate = false,
    required this.config,
  });

  @override
  SphericalTankState createState() => SphericalTankState();
}

class SphericalTankState extends BaseState<SphericalTank>
    with TickerProviderStateMixin, LiquidContainer {
  double liquidLevel = 0;
  double value = 0;
  double minValue = 0;
  double maxValue = 100;
  bool isValidConfig = true;
  String subtitle = "";
 late String field ;
 late String deviceId ;
  String unit = "";
  String label = "";
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig subTitleFont;
  @override
  void initState() {deviceId=widget.config.deviceId;
  field=widget.config.field;
    titleFont = FontConfig.fromJson(widget.config.titleFont);
    subTitleFont = FontConfig.fromJson(widget.config.subTitleFont);
    valueFont = FontConfig.fromJson(widget.config.valueFont);
    super.initState();
    load();
  }

 

  @override
  Widget build(BuildContext context) {
    int percent = (liquidLevel * 100).toInt();
    return Container(
       decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(4), // Border radius
    border: Border.all(
      color: Colors.white, // Border color
      width: 1, // Border width
    ),
  ),
      child: Card( elevation: 0, // Elevation can be adjusted as needed
      color: Colors.transparent,
        child: Column(mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    label,
                    style: TwinUtils.getTextStyle(titleFont),
                  ),
                  Text(
                    subtitle,
                    style: TwinUtils.getTextStyle(subTitleFont),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.hardEdge,
                children: [
                  AspectRatio(
                    aspectRatio: 1 / 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomPaint(
                        painter: CircleTankPainter(
                            waterLevel: liquidLevel,
                            bottleColor: Color(widget.config.bottleColor),
                            capColor: Colors.transparent,
                            breakpoint: widget.config.breakPoint,
                            liquidColor: Color(widget.config.liquidColor)),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$percent',
                        style: TwinUtils.getTextStyle(valueFont),
                      ),
                      Text(
                        '$unit ',
                        style: TwinUtils.getTextStyle(titleFont).copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> load() async {
    if (!isValidConfig) return;
    if (loading) return;
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
            {
              "exists": {"field": "data.$field"}
            },
          ],
        ),
      );
      if (qRes.body != null &&
          qRes.body!.result != null &&
          validateResponse(qRes)) {
        Device? device = await TwinUtils.getDevice(deviceId: deviceId);
        if (device == null) return;

        DeviceModel? deviceModel =
            await TwinUtils.getDeviceModel(modelId: device.modelId);

        Map<String, dynamic>? json =
            qRes.body!.result! as Map<String, dynamic>?;

        if (json != null) {
          List<dynamic> hits = json['hits']['hits'];

          if (hits.isNotEmpty) {
            Map<String, dynamic> obj = hits[0] as Map<String, dynamic>;
            value = obj['p_source']['data'][field];

            setState(() {
              liquidLevel = value / 100;
              unit = TwinUtils.getParameterUnit(field, deviceModel!);
              subtitle = _getUpdatedTimeAgo(obj['p_source']['updatedStamp']);
              label = TwinUtils.getParameterLabel(field, deviceModel!);
            });
          }
        }
      }
    });
    loading = false;
    refresh();
  }

  String _getUpdatedTimeAgo(int updatedStamp) {
    DateTime updatedDateTime =
        DateTime.fromMillisecondsSinceEpoch(updatedStamp);
    return timeago.format(updatedDateTime);
  }

  @override
  void setup() {
    load();
  }
}

class CircleTankPainter extends WaterBottlePainter {
  final double breakpoint;

  CircleTankPainter({
    required double waterLevel,
    required Color bottleColor,
    required Color capColor,
    required this.breakpoint,
    required Color liquidColor,
  }) : super(
            waterLevel: waterLevel,
            bottleColor: bottleColor,
            capColor: capColor,
            liquidColor: liquidColor);

  @override
  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    if (size.height / size.width < breakpoint) {
      canvas.drawCircle(
          Offset(size.width / 2, size.height - r / 2), r / 2, paint);
      return;
    }
    final neckTop = size.width * 0.1;
    final neckBottom = size.height - r + 3;
    final neckRingOuter = size.width * 0.28;
    final neckRingOuterR = size.width - neckRingOuter;
    final neckRingInner = size.width * 0.35;
    final neckRingInnerR = size.width - neckRingInner;
    final path = Path();
    path.moveTo(neckRingOuter, neckTop);
    path.lineTo(neckRingInner, neckTop);
    path.lineTo(neckRingInner, neckBottom);
    path.moveTo(neckRingInnerR, neckBottom);
    path.lineTo(neckRingInnerR, neckTop);
    path.lineTo(neckRingOuterR, neckTop);
    canvas.drawArc(Rect.fromLTRB(0, size.height - r, size.width, size.height),
        math.pi * 1.59, math.pi * 1.82, true, paint);
  }

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    canvas.drawCircle(
        Offset(size.width / 2, size.height - r / 2), r / 2 - 5, paint);
    if (size.height / size.width < breakpoint) {
      return;
    }
    final neckTop = size.width * 0.1;
    final neckRingInner = size.width * 0.35;
    final neckRingInnerR = size.width - neckRingInner;
    canvas.drawRect(
        Rect.fromLTRB(neckRingInner + 5, neckTop, neckRingInnerR - 5,
            size.height - r / 2),
        paint);
  }

  @override
  void paintCap(Canvas canvas, Size size, Paint paint) {
    if (size.height / size.width < breakpoint) {
      return;
    }
    const capTop = 0.0;
    final capBottom = size.width * 0.2;
    final capMid = (capBottom - capTop) / 2;
    final capL = size.width * 0.33 + 5;
    final capR = size.width - capL;
    final neckRingInner = size.width * 0.35 + 5;
    final neckRingInnerR = size.width - neckRingInner;
    final path = Path();
    path.moveTo(capL, capTop);
    path.lineTo(neckRingInner, capMid);
    path.lineTo(neckRingInner, capBottom);
    path.lineTo(neckRingInnerR, capBottom);
    path.lineTo(neckRingInnerR, capMid);
    path.lineTo(capR, capTop);
    path.close();
    canvas.drawPath(path, paint);
  }
}
