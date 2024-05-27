import 'package:flutter/material.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

typedef OnRadiusConfigured = void Function(RadiusConfig config);

class RadiusConfigWidget extends StatefulWidget {
  final String title;
  final RadiusConfig radiusConfig;
  final OnRadiusConfigured onRadiusConfigured;
  const RadiusConfigWidget(
      {super.key,
      required this.title,
      required this.radiusConfig,
      required this.onRadiusConfigured});

  @override
  State<RadiusConfigWidget> createState() => _RadiusConfigWidgetState();
}

class _RadiusConfigWidgetState extends State<RadiusConfigWidget> {
  static const labelStyle =
      TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Radius Type',
              style: labelStyle,
            ),
            DropdownButton<RadiusConfigType>(
                value: widget.radiusConfig.type,
                items: const [
                  DropdownMenuItem<RadiusConfigType>(
                      value: RadiusConfigType.zero,
                      child: Text(
                        'Zero',
                        style: labelStyle,
                      )),
                  DropdownMenuItem<RadiusConfigType>(
                      value: RadiusConfigType.circular,
                      child: Text(
                        'Circular',
                        style: labelStyle,
                      )),
                  DropdownMenuItem<RadiusConfigType>(
                      value: RadiusConfigType.elliptical,
                      child: Text(
                        'Elliptical',
                        style: labelStyle,
                      )),
                ],
                onChanged: (type) {
                  widget.onRadiusConfigured(widget.radiusConfig
                      .copyWith(type: type ?? RadiusConfigType.circular));
                }),
          ],
        ),
        divider(),
        if (widget.radiusConfig.type == RadiusConfigType.circular)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Radius',
                style: labelStyle,
              ),
              SizedBox(
                height: 35,
                child: IntrinsicWidth(
                  child: SpinBox(
                    min: 0,
                    max: 180,
                    value: widget.radiusConfig.radius ?? 45,
                    showCursor: true,
                    autofocus: true,
                    onChanged: (value) {
                      widget.onRadiusConfigured(
                          widget.radiusConfig.copyWith(radius: value));
                    },
                  ),
                ),
              ),
            ],
          ),
        divider(),
        if (widget.radiusConfig.type == RadiusConfigType.elliptical)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'X Radius',
                style: labelStyle,
              ),
              SizedBox(
                height: 35,
                child: IntrinsicWidth(
                  child: SpinBox(
                    min: 0,
                    max: 180,
                    value: widget.radiusConfig.xRadius ?? 45,
                    showCursor: true,
                    autofocus: true,
                    onChanged: (value) {
                      widget.onRadiusConfigured(
                          widget.radiusConfig.copyWith(xRadius: value));
                    },
                  ),
                ),
              ),
            ],
          ),
        if (widget.radiusConfig.type == RadiusConfigType.elliptical)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Y Radius',
                style: labelStyle,
              ),
              SizedBox(
                height: 35,
                child: IntrinsicWidth(
                  child: SpinBox(
                    min: 0,
                    max: 180,
                    value: widget.radiusConfig.xRadius ?? 45,
                    showCursor: true,
                    autofocus: true,
                    onChanged: (value) {
                      widget.onRadiusConfigured(
                          widget.radiusConfig.copyWith(yRadius: value));
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
