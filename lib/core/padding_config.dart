import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

typedef OnPaddingConfigSaved = void Function(PaddingConfig? config);

class PaddingConfigWidget extends StatefulWidget {
  final String title;
  final PaddingConfig? paddingConfig;
  final OnPaddingConfigSaved onPaddingConfigSaved;
  const PaddingConfigWidget(
      {super.key,
      required this.title,
      required this.paddingConfig,
      required this.onPaddingConfigSaved});

  @override
  State<PaddingConfigWidget> createState() => _PaddingConfigWidgetState();
}

class _PaddingConfigWidgetState extends State<PaddingConfigWidget> {
  static const labelStyle =
      TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);

  PaddingConfig? _paddingConfig;

  @override
  void initState() {
    _paddingConfig = (null != widget.paddingConfig)
        ? widget.paddingConfig!.copyWith()
        : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.title,
              style: labelStyle,
            ),
            Checkbox(
                value: null != _paddingConfig,
                onChanged: (selected) {
                  _setSelected(selected ?? false);
                })
          ],
        ),
        if (null != _paddingConfig) divider(),
        if (null != _paddingConfig)
          Wrap(
            spacing: 10,
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Top',
                style: labelStyle,
              ),
              SizedBox(
                height: 35,
                child: IntrinsicWidth(
                  child: SpinBox(
                    min: 0,
                    max: 2048,
                    step: 1,
                    showCursor: true,
                    value: _paddingConfig!.top ?? 8,
                    onSubmitted: (value) {
                      setState(() {
                        _paddingConfig = _paddingConfig!.copyWith(top: value);
                      });
                      widget.onPaddingConfigSaved(_paddingConfig);
                    },
                  ),
                ),
              ),
            ],
          ),
        if (null != _paddingConfig) divider(),
        if (null != _paddingConfig)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
                spacing: 10,
                direction: Axis.horizontal,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Left',
                    style: labelStyle,
                  ),
                  SizedBox(
                    height: 35,
                    child: IntrinsicWidth(
                      child: SpinBox(
                        min: 0,
                        max: 2048,
                        step: 1,
                        showCursor: true,
                        value: _paddingConfig!.left ?? 8,
                        onSubmitted: (value) {
                          setState(() {
                            _paddingConfig =
                                _paddingConfig!.copyWith(left: value);
                          });
                          widget.onPaddingConfigSaved(_paddingConfig);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 10,
                direction: Axis.horizontal,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    height: 35,
                    child: IntrinsicWidth(
                      child: SpinBox(
                        min: 0,
                        max: 2048,
                        step: 1,
                        showCursor: true,
                        value: _paddingConfig!.right ?? 8,
                        onSubmitted: (value) {
                          setState(() {
                            _paddingConfig =
                                _paddingConfig!.copyWith(right: value);
                          });
                          widget.onPaddingConfigSaved(_paddingConfig);
                        },
                      ),
                    ),
                  ),
                  const Text(
                    'Right',
                    style: labelStyle,
                  ),
                ],
              ),
            ],
          ),
        if (null != _paddingConfig) divider(),
        if (null != _paddingConfig)
          Wrap(
            spacing: 10,
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                height: 35,
                child: IntrinsicWidth(
                  child: SpinBox(
                    min: 0,
                    max: 2048,
                    step: 1,
                    showCursor: true,
                    value: _paddingConfig!.bottom ?? 8,
                    onSubmitted: (value) {
                      setState(() {
                        _paddingConfig =
                            _paddingConfig!.copyWith(bottom: value);
                      });
                      widget.onPaddingConfigSaved(_paddingConfig);
                    },
                  ),
                ),
              ),
              const Text(
                'Bottom',
                style: labelStyle,
              ),
            ],
          ),
      ],
    );
  }

  void _setSelected(bool selected) {
    setState(() {
      if (selected) {
        if (null != widget.paddingConfig) {
          _paddingConfig = widget.paddingConfig!.copyWith();
        } else {
          _paddingConfig =
              const PaddingConfig(left: 8, top: 8, right: 8, bottom: 8);
        }
      } else {
        _paddingConfig = null;
      }
    });
    widget.onPaddingConfigSaved(_paddingConfig);
  }
}
