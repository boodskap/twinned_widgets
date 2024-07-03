import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:twin_commons/core/twin_image_helper.dart';
import 'package:twinned_models/models.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_widgets/palette_category.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_widgets/twinned_widget_builder.dart';
import 'package:twinned_models/ems/infrastructure_card.dart';

class InfrastructureCardWidget extends StatefulWidget {
  final InfrastructureCardWidgetConfig config;
  const InfrastructureCardWidget({Key? key, required this.config, String? deviceId})
      : super(key: key);

  @override
  State<InfrastructureCardWidget> createState() =>
      _InfrastructureCardWidgetState();
}

class _InfrastructureCardWidgetState
    extends BaseState<InfrastructureCardWidget> {
  bool isValidConfig = false;
  bool apiLoadingStatus = false;
  late String deviceModelId;
  late String deviceId;
  late Color backgroundColor;
  late String title;
  late String titleIcon;
  late String premiseHeading;
  late String premiseIcon;
  late String facilityHeading;
  late String facilityIcon;
  late String floorHeading;
  late String floorIcon;
  late String assetHeading;
  late String assetIcon;
  late FontConfig titleFont;
  late FontConfig headingFont;
  late FontConfig valueFont;
  late double width;
  late double height;

  String premiseName = '-';
  String facilityName = '-';
  String floorName = '-';
  String assetName = '-';
  final List<DeviceData> _data = [];
  @override
  void initState() {
    var config = widget.config;
    isValidConfig = 
        widget.config.deviceId.isNotEmpty;
    deviceModelId = config.deviceModelId;
    deviceId = config.deviceId;
    backgroundColor = Color(config.backgroundColor);
    title = config.title;
    titleIcon = config.titleIcon;
    premiseHeading = config.premiseHeading;
    premiseIcon = config.premiseIcon;
    facilityHeading = config.facilityHeading;
    facilityIcon = config.facilityIcon;
    floorHeading = config.floorHeading;
    floorIcon = config.floorIcon;
    assetHeading = config.assetHeading;
    assetIcon = config.assetIcon;
    titleFont = FontConfig.fromJson(config.titleFont);
    valueFont = FontConfig.fromJson(config.valueFont);
    headingFont = FontConfig.fromJson(config.headingFont);
    width = config.width;
    height = config.height;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!isValidConfig) {
      return const Wrap(
        spacing: 8.0,
        children: [
          Text(
            'Not configured properly',
            style: TextStyle(
                color: Color.fromARGB(255, 133, 11, 3),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }

    if (!apiLoadingStatus) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: 4.0,
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                          fontFamily: titleFont.fontFamily,
                          fontSize: titleFont.fontSize,
                          fontWeight: titleFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(titleFont.fontColor)),
                     ),
                  ),
                           titleIcon.isNotEmpty
                      ? SizedBox(
                          width: titleFont.fontSize,
                          height: titleFont.fontSize,
                          child: TwinImageHelper.getDomainImage(titleIcon),
                        )
                      : Icon(
                          Icons.maps_home_work,
                          color: Color(titleFont.fontColor),
                          size: titleFont.fontSize,
                        ),
                 
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  premiseIcon.isNotEmpty
                      ? SizedBox(
                           width: headingFont.fontSize,
                          height: headingFont.fontSize,
                          child: TwinImageHelper.getDomainImage(premiseIcon),
                        )
                      : Icon(
                          Icons.home,
                          color: Color(headingFont.fontColor),
                          size: headingFont.fontSize,
                        ),
                  const SizedBox(width: 5),
                  Text(premiseHeading,
                  overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: headingFont.fontFamily,
                          fontSize: headingFont.fontSize,
                          fontWeight: headingFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(headingFont.fontColor))),
                ],
              ),
               const SizedBox(height: 5),
              Text(premiseName,
              overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: valueFont.fontFamily,
                      fontSize: valueFont.fontSize,
                      fontWeight: valueFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(valueFont.fontColor))),
              const SizedBox(height: 20),
              Row(
                children: [
                   facilityIcon.isNotEmpty
                      ? SizedBox(
                          width: headingFont.fontSize,
                          height: headingFont.fontSize,
                          child: TwinImageHelper.getDomainImage(facilityIcon),
                        )
                      : Icon(
                          Icons.business,
                          color: Color(headingFont.fontColor),
                          size: headingFont.fontSize,
                        ),
                  const SizedBox(width: 5),
                  Text(facilityHeading,
                  overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: headingFont.fontFamily,
                          fontSize: headingFont.fontSize,
                          fontWeight: headingFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(headingFont.fontColor))),
                ],
              ),
               const SizedBox(height: 5),
              Text(facilityName,
              overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: valueFont.fontFamily,
                      fontSize: valueFont.fontSize,
                      fontWeight: valueFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(valueFont.fontColor))),
              const SizedBox(height: 20),
              Row(
                children: [
                   floorIcon.isNotEmpty
                      ? SizedBox(
                           width: headingFont.fontSize,
                          height: headingFont.fontSize,
                          child: TwinImageHelper.getDomainImage(floorIcon),
                        )
                      : Icon(
                          Icons.cabin,
                          color: Color(headingFont.fontColor),
                          size: headingFont.fontSize,
                        ),
                  const SizedBox(width: 5),
                  Text(floorHeading,
                  overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: headingFont.fontFamily,
                          fontSize: headingFont.fontSize,
                          fontWeight: headingFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(headingFont.fontColor))),
                ],
              ),
              const SizedBox(height: 5),
              Text(floorName,
              overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: valueFont.fontFamily,
                      fontSize: valueFont.fontSize,
                      fontWeight: valueFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(valueFont.fontColor))),
              const SizedBox(height: 20),
              Row(
                children: [
                   assetIcon.isNotEmpty
                      ? SizedBox(
                          width: headingFont.fontSize,
                          height: headingFont.fontSize,
                          child: TwinImageHelper.getDomainImage(assetIcon),
                        )
                      : Icon(
                          Icons.view_comfy,
                          color: Color(headingFont.fontColor),
                          size: headingFont.fontSize,
                        ),
                  const SizedBox(width: 5),
                  Text(assetHeading,
                  overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: headingFont.fontFamily,
                          fontSize: headingFont.fontSize,
                          fontWeight: headingFont.fontBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Color(headingFont.fontColor))),
                ],
              ),
               const SizedBox(height: 5),
              Text(assetName,
              overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontFamily: valueFont.fontFamily,
                      fontSize: valueFont.fontSize,
                      fontWeight: valueFont.fontBold
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Color(valueFont.fontColor))),
            ],
          ),
        ),
      ),
    );
  }

  Future load() async {
    if (!isValidConfig) return;

    if (loading) return;

    loading = true;

    await execute(() async {
      var dRes = await TwinnedSession.instance.twin.searchRecentDeviceData(
          apikey: TwinnedSession.instance.authToken,
          modelId: deviceModelId,
          body: const FilterSearchReq(search: '*', page: 0, size: 300));

      if (validateResponse(dRes)) {
        _data.addAll(dRes.body!.values!);
        for (var dd in _data) {
          if (dd.deviceId == deviceId) {
            premiseName = (dd.premise!= "" ?dd.premise  : '-')!;
            facilityName = (dd.facility!= "" ?dd.facility  : '-')!;
            floorName = (dd.floor!= "" ?dd.floor  : '-')!;
            assetName = (dd.asset!= "" ?dd.asset  : '-')!;

            return;
          }
        }
      }
    });
    refresh();
    loading = false;
    apiLoadingStatus = true;
  }

  @override
  void setup() {
    load();
  }
}

class InfrastructureCardWidgetBuilder extends TwinnedWidgetBuilder {
  @override
  Widget build(Map<String, dynamic> config) {
    return InfrastructureCardWidget(
        config: InfrastructureCardWidgetConfig.fromJson(config));
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
    return "Infrastructure Card";
  }

  @override
  BaseConfig getDefaultConfig({Map<String, dynamic>? config}) {
    if (config != null) {
      return InfrastructureCardWidgetConfig.fromJson(config);
    }
    return InfrastructureCardWidgetConfig();
  }

  @override
  String getPaletteTooltip() {
    return "Infrastructure Card";
  }
}
