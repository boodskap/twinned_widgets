import 'package:flutter/material.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:google_fonts/google_fonts.dart';

typedef OnRadiusConfigured = void Function(RadiusConfig config);

class RadiusConfigWidget extends StatefulWidget {
  final String? title;
  final RadiusConfig radiusConfig;
  final OnRadiusConfigured onRadiusConfigured;
  final TextStyle? style;
  const RadiusConfigWidget(
      {super.key,
      this.title,
      this.style,
      required this.radiusConfig,
      required this.onRadiusConfigured});

  @override
  State<RadiusConfigWidget> createState() => _RadiusConfigWidgetState();
}

class _RadiusConfigWidgetState extends State<RadiusConfigWidget> {
  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = widget.style ??
        GoogleFonts.lato(
          // fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        );
    String value = widget.radiusConfig.radType.name;

    switch (widget.radiusConfig.radType) {
      case RadiusConfigRadType.swaggerGeneratedUnknown:
        value = RadiusConfigRadType.zero.name;
      default:
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (null != widget.title)
          Align(
              alignment: Alignment.topCenter,
              child: Text(
                widget.title!,
                style: labelStyle,
              )),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              'Radius Type',
              style: labelStyle,
            ),
            DropdownButton<String>(
                value: value,
                items: [
                  DropdownMenuItem<String>(
                      value: RadiusConfigRadType.zero.name,
                      child:  Text(
                        'Zero',
                        style: labelStyle.copyWith(fontWeight:FontWeight.normal),
                      )),
                  DropdownMenuItem<String>(
                      value: RadiusConfigRadType.circular.name,
                      child:  Text(
                        'Circular',
                       style: labelStyle.copyWith(fontWeight:FontWeight.normal),
                      )),
                  DropdownMenuItem<String>(
                      value: RadiusConfigRadType.elliptical.name,
                      child:  Text(
                        'Elliptical',
                       style: labelStyle.copyWith(fontWeight:FontWeight.normal),
                      )),
                ],
                onChanged: (type) {
                  double? radius;
                  double? xRadius;
                  double? yRadius;
                  RadiusConfigRadType radiusType = RadiusConfigRadType.values
                      .byName(type ?? RadiusConfigRadType.circular.name);
                  switch (radiusType) {
                    case RadiusConfigRadType.swaggerGeneratedUnknown:
                    case RadiusConfigRadType.zero:
                      break;
                    case RadiusConfigRadType.circular:
                      radius = 45.0;
                      break;
                    case RadiusConfigRadType.elliptical:
                      xRadius = 45.0;
                      yRadius = 45.0;
                      break;
                  }
                  widget.onRadiusConfigured(RadiusConfig(
                      radType: radiusType,
                      rad: radius,
                      xRad: xRadius,
                      yRad: yRadius));
                }),
          ],
        ),
        divider(),
        if (widget.radiusConfig.radType == RadiusConfigRadType.circular)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Border Radius',
                style: labelStyle,
              ),
              SizedBox(
                height: 35,
                child: IntrinsicWidth(
                  child: SpinBox(  textStyle: labelStyle,
                    min: 0,
                    max: 360,
                    value: widget.radiusConfig.rad ?? 45,
                    showCursor: true,
                    autofocus: false,
                    onSubmitted: (value) {
                      widget.onRadiusConfigured(
                          widget.radiusConfig.copyWith(rad: value));
                    },
                  ),
                ),
              ),
            ],
          ),
        divider(),
        if (widget.radiusConfig.radType == RadiusConfigRadType.elliptical)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Border X Radius',
                style: labelStyle,
              ),
              SizedBox(
                height: 35,
                child: IntrinsicWidth(
                  child: SpinBox(  textStyle: labelStyle,
                    min: 0,
                    max: 360,
                    value: widget.radiusConfig.xRad ?? 45,
                    showCursor: true,
                    autofocus: false,
                    onSubmitted: (value) {
                      widget.onRadiusConfigured(
                          widget.radiusConfig.copyWith(xRad: value));
                    },
                  ),
                ),
              ),
            ],
          ),
        if (widget.radiusConfig.radType == RadiusConfigRadType.elliptical)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Border Y Radius',
                style: labelStyle,
              ),
              SizedBox(
                height: 35,
                child: IntrinsicWidth(
                  child: SpinBox(  textStyle: labelStyle,
                    min: 0,
                    max: 360,
                    value: widget.radiusConfig.yRad ?? 45,
                    showCursor: true,
                    autofocus: false,
                    onSubmitted: (value) {
                      widget.onRadiusConfigured(
                          widget.radiusConfig.copyWith(yRad: value));
                    },
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
