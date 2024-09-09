import 'package:flutter/material.dart';
import 'package:twinned_widgets/core/color_picker_field.dart';
import 'package:twinned_widgets/core/decimal_field.dart';
import 'package:twinned_widgets/core/parameter_text_field.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

typedef OnRangeListSaved = void Function(List<Map<String, dynamic>> parameters);
typedef OnRangeDelete = void Function(int index);
typedef OnRangeUpdate = void Function(int index);

class RangeList extends StatefulWidget {
  final List<Map<String, dynamic>> parameters;
  final OnRangeListSaved onRangeListSaved;
  final TextStyle? style;
  const RangeList(
      {super.key,
      this.style,
      required this.parameters,
      required this.onRangeListSaved});

  @override
  State<RangeList> createState() => _RangeListState();
}

class _RangeListState extends State<RangeList> {
  @override
  Widget build(BuildContext context) {
    final TextStyle style = widget.style ??
        GoogleFonts.lato(
          // fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        );
    List<Widget> children = [];
    for (int i = 0; i < widget.parameters.length; i++) {
      var map = widget.parameters[i];
      children.add(Range(
        style: style,
        index: i,
        parameters: map,
        onRangeDelete: (index) {
          setState(() {
            widget.parameters.removeAt(index);
          });
          widget.onRangeListSaved(widget.parameters);
        },
        onRangeUpdate: (index) {
          setState(() {});
          widget.onRangeListSaved(widget.parameters);
        },
      ));
    }
    return Column(
      key: Key(Uuid().v4()),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                style: ButtonStyle(textStyle: WidgetStatePropertyAll(style)),
                onPressed: () {
                  setState(() {
                    widget.parameters.add(<String, dynamic>{
                      'from': null,
                      'to': null,
                      'label': 'New Segment',
                      'color': Colors.red.value
                    });
                  });
                  widget.onRangeListSaved(widget.parameters);
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.green,
                ))
          ],
        ),
        ...children
      ],
    );
  }
}

class Range extends StatefulWidget {
  final int index;
  final Map<String, dynamic> parameters;
  final OnRangeDelete onRangeDelete;
  final OnRangeUpdate onRangeUpdate;
  final TextStyle? style;
  const Range(
      {super.key,
      required this.index,
      this.style,
      required this.parameters,
      required this.onRangeDelete,
      required this.onRangeUpdate});

  @override
  State<Range> createState() => _RangeState();
}

class _RangeState extends State<Range> {
  // final TextStyle labelStyle =
  //     const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = widget.style ??
        GoogleFonts.lato(
          // fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        );
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              'From',
              style: labelStyle,
            ),
            const SizedBox(
              width: 5.0,
            ),
            DecimalField(
              style: labelStyle,
              parameters: widget.parameters,
              parameter: 'from',
              changeNotifier: () {
                widget.onRangeUpdate(widget.index);
              },
            ),
          ],
        ),
        const SizedBox(
          width: 5.0,
        ),
        Row(
          children: [
            Text(
              'To',
              style: labelStyle,
            ),
            const SizedBox(
              width: 5.0,
            ),
            DecimalField(
              style: labelStyle,
              parameters: widget.parameters,
              parameter: 'to',
              changeNotifier: () {
                widget.onRangeUpdate(widget.index);
              },
            ),
          ],
        ),
        const SizedBox(
          width: 5.0,
        ),
        Row(
          children: [
            Text(
              'Label',
              style: labelStyle,
            ),
            const SizedBox(
              width: 5.0,
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                  minWidth: 50, maxWidth: 225, maxHeight: 40),
              child: ParameterTextField(
                style: labelStyle,
                parameters: widget.parameters,
                parameter: 'label',
                changeNotifier: () {
                  widget.onRangeUpdate(widget.index);
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 5.0,
        ),
        ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100, maxHeight: 40),
            child: ColorPickerField(
              style: labelStyle,
              config: widget.parameters,
              parameter: 'color',
              changeNotifier: () {
                widget.onRangeUpdate(widget.index);
              },
            )),
        const SizedBox(
          width: 5.0,
        ),
        IconButton(
            style: ButtonStyle(textStyle: WidgetStatePropertyAll(labelStyle)),
            onPressed: () {
              widget.onRangeDelete(widget.index);
            },
            icon: const Icon(Icons.delete_forever))
      ],
    );
  }
}
