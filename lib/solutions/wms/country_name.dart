import 'package:country_pickers/country.dart';
import 'package:flutter/material.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:twin_commons/core/base_state.dart';

class CountryNamePicker extends StatefulWidget {
  const CountryNamePicker({super.key});

  @override
  State<CountryNamePicker> createState() => _CountryNamePickerState();
}

class _CountryNamePickerState extends State<CountryNamePicker> {
  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('IN');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Your city',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        divider(width: 10, horizontal: true),
        Flexible(
          child: SizedBox(
            width: 300,
            child: InkWell(
              onTap: _openCountryPickerDialog,
              child: InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                ),
                child: Row(
                  children: [
                    CountryPickerUtils.getDefaultFlagImage(
                        _selectedDialogCountry),
                    divider(width: 10, horizontal: true),
                    Expanded(
                      child: Text(
                        _selectedDialogCountry.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.4,
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: CountryPickerDialog(
              titlePadding: const EdgeInsets.all(8.0),
              searchCursorColor: Colors.pinkAccent,
              searchInputDecoration:
                  const InputDecoration(hintText: 'Search...'),
              isSearchable: true,
              title: const Text('Select your Country'),
              onValuePicked: (Country country) =>
                  setState(() => _selectedDialogCountry = country),
              itemBuilder: _buildDialogItem,
            ),
          ),
        ),
      );

  Widget _buildDialogItem(Country country) => Row(
        children: [
          CountryPickerUtils.getDefaultFlagImage(country),
          const SizedBox(width: 8.0),
          Flexible(child: Text(country.name))
        ],
      );
}
