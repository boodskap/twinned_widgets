import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_widgets/core/color_picker_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twinned_widgets/core/radius_config.dart';

typedef OnBorderConfigured = void Function(BorderConfig? config);

class BorderConfigWidget extends StatefulWidget {
  final BorderConfig? borderConfig;
  final OnBorderConfigured onBorderConfigured;
  final TextStyle? style;
  const BorderConfigWidget(
      {super.key,
      this.borderConfig,
      this.style,
      required this.onBorderConfigured});

  @override
  State<BorderConfigWidget> createState() => _BorderConfigWidgetState();
}

class _BorderConfigWidgetState extends State<BorderConfigWidget> {
  BorderConfig? _borderConfig;
  BorderConfigType? borderConfigType;
  final Map<String, dynamic> _borderProperties = <String, dynamic>{
    'color': Colors.black.value,
    'width': 1.0,
  };

  @override
  void initState() {
    _borderConfig = widget.borderConfig;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int borderColor = _borderConfig?.color ?? Colors.black.value;
    final TextStyle labelStyle = widget.style ??
        GoogleFonts.lato(
          // fontSize: 18,
          // fontWeight: FontWeight.bold,
          color: Colors.black,
        );
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Border',
              style: labelStyle,
            ),
            divider(horizontal: true),
            Checkbox(
                value: (null != _borderConfig),
                onChanged: (value) {
                  if ((value ?? false)) {
                    if (null != widget.borderConfig) {
                      _borderConfig = widget.borderConfig;
                    } else {
                      _borderConfig = BorderConfig(
                          type: BorderConfigType.all,
                          color: Colors.black.value,
                          allRadius: const RadiusConfig(
                              radType: RadiusConfigRadType.circular, rad: 45));
                    }
                  } else {
                    _borderConfig = null;
                  }
                  setState(() {});
                  widget.onBorderConfigured(_borderConfig);
                }),
          ],
        ),
        divider(),
        if (null != _borderConfig) divider(),
        if (null != _borderConfig)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Border Color',
                style: labelStyle,
              ),
              divider(horizontal: true),
              ColorPickerField(
                style: labelStyle,
                config: _borderProperties,
                parameter: 'color',
                changeNotifier: () {
                  setState(() {
                    _borderConfig = _borderConfig!.copyWith(
                        color: _borderProperties['color'] ?? Colors.black);
                  });
                  widget.onBorderConfigured(_borderConfig);
                },
              ),
            ],
          ),
        if (null != _borderConfig) divider(),
        if (null != _borderConfig)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Border Width',
                style: labelStyle,
              ),
              divider(horizontal: true),
              SizedBox(
                height: 35,
                child: IntrinsicWidth(
                  child: SpinBox(
                    textStyle: labelStyle,
                    min: 1,
                    max: 100,
                    value: _borderConfig?.width ?? 1.0,
                    showCursor: true,
                    autofocus: false,
                    onSubmitted: (value) {
                      setState(() {
                        _borderConfig = _borderConfig!.copyWith(width: value);
                      });
                      widget.onBorderConfigured(_borderConfig);
                    },
                  ),
                ),
              ),
            ],
          ),
        if (null != _borderConfig)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Border Type',
                style: labelStyle,
              ),
              divider(horizontal: true),
              DropdownButton<String>(
                  value: _borderConfig!.type.name,
                  items: [
                    DropdownMenuItem<String>(
                        value: BorderConfigType.zero.name,
                        child: Text(
                          'Zero',
                          style: labelStyle.copyWith(
                              fontWeight: FontWeight.normal),
                        )),
                    DropdownMenuItem<String>(
                        value: BorderConfigType.all.name,
                        child: Text(
                          'All',
                          style: labelStyle.copyWith(
                              fontWeight: FontWeight.normal),
                        )),
                    DropdownMenuItem<String>(
                        value: BorderConfigType.circular.name,
                        child: Text(
                          'Circular',
                          style: labelStyle.copyWith(
                              fontWeight: FontWeight.normal),
                        )),
                    DropdownMenuItem<String>(
                        value: BorderConfigType.vertical.name,
                        child: Text(
                          'Vertical',
                          style: labelStyle.copyWith(
                              fontWeight: FontWeight.normal),
                        )),
                    DropdownMenuItem<String>(
                        value: BorderConfigType.horizontal.name,
                        child: Text(
                          'Horizontal',
                          style: labelStyle.copyWith(
                              fontWeight: FontWeight.normal),
                        )),
                    DropdownMenuItem<String>(
                        value: BorderConfigType.only.name,
                        child: Text(
                          'Only',
                          style: labelStyle.copyWith(
                              fontWeight: FontWeight.normal),
                        )),
                  ],
                  onChanged: (type) {
                    BorderConfigType borderConfigType = BorderConfigType.values
                        .byName(type ?? BorderConfigType.all.name);
                    setState(() {
                      switch (borderConfigType) {
                        case BorderConfigType.swaggerGeneratedUnknown:
                        case BorderConfigType.zero:
                          _borderConfig = BorderConfig(
                              type: borderConfigType,
                              width: _borderConfig!.width,
                              color: _borderConfig!.color);
                          break;
                        case BorderConfigType.all:
                          _borderConfig = BorderConfig(
                              type: borderConfigType,
                              allRadius: const RadiusConfig(
                                  radType: RadiusConfigRadType.circular,
                                  rad: 45.0),
                              width: _borderConfig!.width,
                              color: _borderConfig!.color);
                          break;
                        case BorderConfigType.only:
                          _borderConfig = BorderConfig(
                              type: borderConfigType,
                              topLeftRadius: const RadiusConfig(
                                  radType: RadiusConfigRadType.circular,
                                  rad: 45.0),
                              topRightRadius: const RadiusConfig(
                                  radType: RadiusConfigRadType.circular,
                                  rad: 45.0),
                              bottomLeftRadius: const RadiusConfig(
                                  radType: RadiusConfigRadType.circular,
                                  rad: 45.0),
                              bottomRightRadius: const RadiusConfig(
                                  radType: RadiusConfigRadType.circular,
                                  rad: 45.0),
                              width: _borderConfig!.width,
                              color: _borderConfig!.color);
                          break;
                        case BorderConfigType.horizontal:
                          _borderConfig = BorderConfig(
                              type: borderConfigType,
                              leftRadius: const RadiusConfig(
                                  radType: RadiusConfigRadType.circular,
                                  rad: 45.0),
                              rightRadius: const RadiusConfig(
                                  radType: RadiusConfigRadType.circular,
                                  rad: 45.0),
                              width: _borderConfig!.width,
                              color: _borderConfig!.color);
                          break;
                        case BorderConfigType.vertical:
                          _borderConfig = BorderConfig(
                              type: borderConfigType,
                              topRadius: const RadiusConfig(
                                  radType: RadiusConfigRadType.circular,
                                  rad: 45.0),
                              bottomRadius: const RadiusConfig(
                                  radType: RadiusConfigRadType.circular,
                                  rad: 45.0),
                              width: _borderConfig!.width,
                              color: _borderConfig!.color);
                          break;
                        case BorderConfigType.circular:
                          _borderConfig = BorderConfig(
                              type: borderConfigType,
                              circularRadius: 45.0,
                              width: _borderConfig!.width,
                              color: _borderConfig!.color);
                          break;
                      }
                    });
                    widget.onBorderConfigured(_borderConfig);
                  }),
            ],
          ),
        if (null != _borderConfig) divider(),
        if (null != _borderConfig &&
            _borderConfig!.type == BorderConfigType.all)
          RadiusConfigWidget(
              style: widget.style,
              radiusConfig: _borderConfig!.allRadius ??
                  const RadiusConfig(
                      radType: RadiusConfigRadType.circular, rad: 45),
              onRadiusConfigured: (config) {
                setState(() {
                  _borderConfig = _borderConfig!.copyWith(allRadius: config);
                });
                widget.onBorderConfigured(_borderConfig);
              }),
        if (null != _borderConfig &&
            _borderConfig!.type == BorderConfigType.only)
          RadiusConfigWidget(
              title: 'Top Left',
              style: widget.style,
              radiusConfig: _borderConfig!.topLeftRadius ??
                  const RadiusConfig(
                      radType: RadiusConfigRadType.circular, rad: 45),
              onRadiusConfigured: (config) {
                setState(() {
                  _borderConfig =
                      _borderConfig!.copyWith(topLeftRadius: config);
                });
                widget.onBorderConfigured(_borderConfig);
              }),
        if (null != _borderConfig &&
            _borderConfig!.type == BorderConfigType.only)
          RadiusConfigWidget(
              title: 'Top Right',
              style: widget.style,
              radiusConfig: _borderConfig!.topRightRadius ??
                  const RadiusConfig(
                      radType: RadiusConfigRadType.circular, rad: 45),
              onRadiusConfigured: (config) {
                setState(() {
                  _borderConfig =
                      _borderConfig!.copyWith(topRightRadius: config);
                });
                widget.onBorderConfigured(_borderConfig);
              }),
        if (null != _borderConfig &&
            _borderConfig!.type == BorderConfigType.only)
          RadiusConfigWidget(
              title: 'Bottom Left',
              style: widget.style,
              radiusConfig: _borderConfig!.bottomLeftRadius ??
                  const RadiusConfig(
                      radType: RadiusConfigRadType.circular, rad: 45),
              onRadiusConfigured: (config) {
                setState(() {
                  _borderConfig =
                      _borderConfig!.copyWith(bottomLeftRadius: config);
                });
                widget.onBorderConfigured(_borderConfig);
              }),
        if (null != _borderConfig &&
            _borderConfig!.type == BorderConfigType.only)
          RadiusConfigWidget(
              title: 'Bottom Right',
              style: widget.style,
              radiusConfig: _borderConfig!.bottomRightRadius ??
                  const RadiusConfig(
                      radType: RadiusConfigRadType.circular, rad: 45),
              onRadiusConfigured: (config) {
                setState(() {
                  _borderConfig =
                      _borderConfig!.copyWith(bottomRightRadius: config);
                });
                widget.onBorderConfigured(_borderConfig);
              }),
        if (null != _borderConfig &&
            _borderConfig!.type == BorderConfigType.horizontal)
          RadiusConfigWidget(
              title: 'Left',
              style: widget.style,
              radiusConfig: _borderConfig!.leftRadius ??
                  const RadiusConfig(
                      radType: RadiusConfigRadType.circular, rad: 45),
              onRadiusConfigured: (config) {
                setState(() {
                  _borderConfig = _borderConfig!.copyWith(leftRadius: config);
                });
                widget.onBorderConfigured(_borderConfig);
              }),
        if (null != _borderConfig &&
            _borderConfig!.type == BorderConfigType.horizontal)
          RadiusConfigWidget(
              title: 'Right',
              style: widget.style,
              radiusConfig: _borderConfig!.rightRadius ??
                  const RadiusConfig(
                      radType: RadiusConfigRadType.circular, rad: 45),
              onRadiusConfigured: (config) {
                setState(() {
                  _borderConfig = _borderConfig!.copyWith(rightRadius: config);
                });
                widget.onBorderConfigured(_borderConfig);
              }),
        if (null != _borderConfig &&
            _borderConfig!.type == BorderConfigType.vertical)
          RadiusConfigWidget(
              title: 'Top',
              style: widget.style,
              radiusConfig: _borderConfig!.topRadius ??
                  const RadiusConfig(
                      radType: RadiusConfigRadType.circular, rad: 45),
              onRadiusConfigured: (config) {
                setState(() {
                  _borderConfig = _borderConfig!.copyWith(topRadius: config);
                });
                widget.onBorderConfigured(_borderConfig);
              }),
        if (null != _borderConfig &&
            _borderConfig!.type == BorderConfigType.vertical)
          RadiusConfigWidget(
              title: 'Bottom',
              style: widget.style,
              radiusConfig: _borderConfig!.bottomRadius ??
                  const RadiusConfig(
                      radType: RadiusConfigRadType.circular, rad: 45),
              onRadiusConfigured: (config) {
                setState(() {
                  _borderConfig = _borderConfig!.copyWith(bottomRadius: config);
                });
                widget.onBorderConfigured(_borderConfig);
              }),
        if (null != _borderConfig &&
            _borderConfig!.type == BorderConfigType.circular)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Radius',
                style: labelStyle,
              ),
              SizedBox(
                height: 35,
                child: IntrinsicWidth(
                  child: SpinBox(
                    textStyle: labelStyle,
                    min: 1,
                    max: 180,
                    value: _borderConfig?.circularRadius ?? 45.0,
                    showCursor: true,
                    autofocus: false,
                    onSubmitted: (value) {
                      setState(() {
                        _borderConfig =
                            _borderConfig!.copyWith(circularRadius: value);
                      });
                      widget.onBorderConfigured(_borderConfig);
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
