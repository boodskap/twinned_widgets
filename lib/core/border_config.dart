import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_widgets/core/color_picker_field.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:twinned_widgets/core/radius_config.dart';

typedef OnBorderConfigured = void Function(BorderConfig? config);

class BorderConfigWidget extends StatefulWidget {
  final BorderConfig? borderConfig;
  final OnBorderConfigured onBorderConfigured;
  const BorderConfigWidget(
      {super.key, this.borderConfig, required this.onBorderConfigured});

  @override
  State<BorderConfigWidget> createState() => _BorderConfigWidgetState();
}

class _BorderConfigWidgetState extends State<BorderConfigWidget> {
  static const labelStyle =
      TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

  BorderConfig? _borderConfig;
  BorderConfigType? borderConfigType;
  final Map<String, dynamic> _borderProperties = <String, dynamic>{
    'color': Colors.black.value,
    'width': 1.0,
  };

  void initState() {
    _borderConfig = widget.borderConfig;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int borderColor = _borderConfig?.color ?? Colors.black.value;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Border',
              style: labelStyle,
            ),
            divider(horizontal: true),
            Checkbox(
                value: (null != _borderConfig),
                onChanged: (value) {
                  setState(() {
                    if ((value ?? false)) {
                      if (null != widget.borderConfig) {
                        _borderConfig = widget.borderConfig;
                      } else {
                        _borderConfig = BorderConfig(
                            type: BorderConfigType.all,
                            color: Colors.black.value,
                            allRadius: const RadiusConfig(
                                type: RadiusConfigType.circular, radius: 45));
                      }
                    } else {
                      _borderConfig = null;
                    }
                  });
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
              const Text(
                'Border Color',
                style: labelStyle,
              ),
              divider(horizontal: true),
              ColorPickerField(
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
              const Text(
                'Border Width',
                style: labelStyle,
              ),
              divider(horizontal: true),
              SizedBox(
                height: 35,
                child: IntrinsicWidth(
                  child: SpinBox(
                    min: 1,
                    max: 100,
                    value: _borderConfig?.width ?? 1.0,
                    showCursor: true,
                    autofocus: true,
                    onChanged: (value) {
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
              const Text(
                'Border Type',
                style: labelStyle,
              ),
              divider(horizontal: true),
              DropdownButton<String>(
                  value: _borderConfig!.type.name,
                  items: [
                    DropdownMenuItem<String>(
                        value: BorderConfigType.zero.name,
                        child: const Text(
                          'Zero',
                          style: labelStyle,
                        )),
                    DropdownMenuItem<String>(
                        value: BorderConfigType.all.name,
                        child: const Text(
                          'All',
                          style: labelStyle,
                        )),
                    DropdownMenuItem<String>(
                        value: BorderConfigType.circular.name,
                        child: const Text(
                          'Circular',
                          style: labelStyle,
                        )),
                    DropdownMenuItem<String>(
                        value: BorderConfigType.vertical.name,
                        child: const Text(
                          'Vertical',
                          style: labelStyle,
                        )),
                    DropdownMenuItem<String>(
                        value: BorderConfigType.horizontal.name,
                        child: const Text(
                          'Horizontal',
                          style: labelStyle,
                        )),
                    DropdownMenuItem<String>(
                        value: BorderConfigType.only.name,
                        child: const Text(
                          'Only',
                          style: labelStyle,
                        )),
                  ],
                  onChanged: (type) {
                    setState(() {
                      _borderConfig = _borderConfig!.copyWith(
                          type: BorderConfigType.values
                              .byName(type ?? BorderConfigType.all.name));
                    });
                  }),
            ],
          ),
        if (null != _borderConfig) divider(),
        if (null != _borderConfig &&
            _borderConfig!.type == BorderConfigType.all)
          RadiusConfigWidget(
              radiusConfig: _borderConfig!.allRadius ??
                  const RadiusConfig(
                      type: RadiusConfigType.circular, radius: 45),
              onRadiusConfigured: (config) {
                setState(() {
                  _borderConfig = _borderConfig!.copyWith(allRadius: config);
                });
                widget.onBorderConfigured(_borderConfig);
              }),
        if (null != _borderConfig &&
            _borderConfig!.type == BorderConfigType.only)
          RadiusConfigWidget(
              radiusConfig: _borderConfig!.topLeftRadius ??
                  const RadiusConfig(
                      type: RadiusConfigType.circular, radius: 45),
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
              radiusConfig: _borderConfig!.topRightRadius ??
                  const RadiusConfig(
                      type: RadiusConfigType.circular, radius: 45),
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
              radiusConfig: _borderConfig!.bottomLeftRadius ??
                  const RadiusConfig(
                      type: RadiusConfigType.circular, radius: 45),
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
              radiusConfig: _borderConfig!.bottomRightRadius ??
                  const RadiusConfig(
                      type: RadiusConfigType.circular, radius: 45),
              onRadiusConfigured: (config) {
                setState(() {
                  _borderConfig =
                      _borderConfig!.copyWith(bottomRightRadius: config);
                });
                widget.onBorderConfigured(_borderConfig);
              }),
      ],
    );
  }
}
