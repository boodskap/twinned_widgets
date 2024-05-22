import 'package:flutter/material.dart';

class EnumeratedDropdown extends StatefulWidget {
  final List<String> enumeratedValues;
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  EnumeratedDropdown({
    Key? key,
    required this.enumeratedValues,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: Colors.black38),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButton<String>(
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
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
