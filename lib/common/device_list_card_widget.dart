import 'dart:math';

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_models/device_list_card_widget/device_list_card_widget.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';

class DeviceListCardWidget extends StatefulWidget {
  final DeviceListCardWidgetConfig config;
  const DeviceListCardWidget({super.key, required this.config});

  @override
  State<DeviceListCardWidget> createState() => _DeviceListCardWidgetState();
}

class _DeviceListCardWidgetState extends BaseState<DeviceListCardWidget> {
  final List<Device> _entities = [];
  final Random _random = Random();

  late String deviceModelId;
  late FontConfig titleFont;
  late FontConfig valueFont;
  late FontConfig labelFont;
  late double cardElevation;
  bool isValidConfig = false;

  @override
  void initState() {
    var config = widget.config;
    deviceModelId = config.deviceModelId;
    titleFont = FontConfig.fromJson(config.titleFont);
    labelFont = FontConfig.fromJson(config.labelFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    cardElevation = config.cardElevation;
    isValidConfig = deviceModelId.isNotEmpty;
    super.initState();
  }

  Color _getRandomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Center(
        child: Text(
          "Not Configured Properly",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Container(
      color: Colors.white,
      height: 400,
      width: 800,
      child: Center(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _entities.length,
          itemBuilder: (context, index) {
            var device = _entities[index];

            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 3,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipPath(
                            clipper: CurvedAppBarClipper(),
                            child: Container(
                              height: 160,
                              color: _getRandomColor(),
                            ),
                          ),
                          Text(
                            'Device Name: ${device.name}',
                            style: TwinUtils.getTextStyle(labelFont),
                          ),
                          const SizedBox(height: 8),
                          Text('Hardware ID: ${device.deviceId}',
                              style: TwinUtils.getTextStyle(labelFont)),
                          const SizedBox(height: 8),
                          Text(
                              'Last Reported: ${_getTimeAgo(device.updatedStamp)}',
                              overflow: TextOverflow.ellipsis,
                              style: TwinUtils.getTextStyle(labelFont)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: device.images != null && device.images!.isNotEmpty
                          ? TwinImageHelper.getDomainImage(
                              device.images!.first,
                              height: 40,
                              width: 40,
                            )
                          : const Icon(Icons.device_unknown, size: 40),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getTimeAgo(int? timestamp) {
    if (timestamp == null) return 'Unknown';

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return timeago.format(dateTime);
  }

  Future<void> _load() async {
    if (!isValidConfig || loading) return;
    loading = true;
    await execute(
      () async {
        var qRes = await TwinnedSession.instance.twin.queryDeviceData(
          apikey: TwinnedSession.instance.authToken,
          body: EqlSearch(
            source: [],
            page: 0,
            size: 100,
            mustConditions: [
              {
                "match_phrase": {
                  "modelId": deviceModelId,
                }
              },
            ],
          ),
        );

        if (validateResponse(qRes)) {
          Map<String, dynamic> json =
              qRes.body!.result! as Map<String, dynamic>;
          List<Map<String, dynamic>> values =
              List<Map<String, dynamic>>.from(json['hits']['hits']);

          List<String> deviceIds = values
              .map((device) => device['p_source']['deviceId'] as String)
              .toList();

          for (String deviceId in deviceIds) {
            var deviceDetail = await TwinUtils.getDevice(deviceId: deviceId);
            if (deviceDetail != null) {
              bool exists =
                  _entities.any((d) => d.deviceId == deviceDetail.deviceId);
              if (!exists) {
                setState(() {
                  _entities.add(deviceDetail);
                });
              }
            }
          }
        }
      },
    );
    loading = false;
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}

class CurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height * 0.4);
    path.lineTo(size.width * 0.35, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.50,
      size.height * 0.73,
      size.width * 0.65,
      size.height * 0.4,
    );
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DeviceListCardWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return DeviceListCardWidget(
      config: DeviceListCardWidgetConfig.fromJson(config),
    );
  }

  @override
  PaletteCategory getPaletteCategory() {
    return PaletteCategory.chartsAndGraphs;
  }

  @override
  Widget getPaletteIcon() {
    return const Icon(Icons.add_card_sharp);
  }

  @override
  String getPaletteName() {
    return "Device List Card Widget";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return DeviceListCardWidgetConfig.fromJson(config);
    }
    return DeviceListCardWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return 'Device List Card Widget';
  }
}
