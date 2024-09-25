import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnumeratedDropdown extends StatefulWidget {
  final List<String> enumeratedValues;
  final String selectedValue;
  final ValueChanged<String?> onChanged;
  final TextStyle? style;

  const EnumeratedDropdown({
    super.key,
    this.style,
    required this.enumeratedValues,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  _EnumeratedDropdownState createState() => _EnumeratedDropdownState();
}

class _EnumeratedDropdownState extends State<EnumeratedDropdown> {
  late String _selectedValue;

  @override
  void initState() {
    _selectedValue = widget.selectedValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = widget.style ??
        GoogleFonts.lato(
          // fontSize: 18,
          // fontWeight: FontWeight.bold,
          color: Colors.black,
        );
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black38),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButton<String>(
        style: style,
        value: _selectedValue,
        onChanged: (String? newValue) {
          setState(() {
            _selectedValue = newValue!;
          });
          widget.onChanged(newValue);
        },
        items: widget.enumeratedValues
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: style,
            ),
          );
        }).toList(),
      ),
    );
  }
}
