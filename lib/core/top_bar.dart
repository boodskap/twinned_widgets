import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFF0C244A);

class TopBar extends StatelessWidget {
  final String title;
  final double? height;

  //Profile Name
  String getFirstLetterAndSpace(String fullName) {
    String firstLetter = fullName.isNotEmpty ? fullName[0].toUpperCase() : '';
    int spaceIndex = fullName.indexOf(' ');
    if (spaceIndex != -1) {
      String secondLetter = fullName[spaceIndex + 1].toUpperCase();
      return '$firstLetter$secondLetter';
    } else {
      return firstLetter;
    }
  }

  const TopBar({super.key, required this.title, this.height = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: height,
      color: primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Tooltip(
            message: 'Go back',
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.keyboard_double_arrow_left,
                  color: Colors.white,
                )),
          ),
          Expanded(
              child: Center(
            child: Text(
              title,
              style: GoogleFonts.acme(color: Colors.white, fontSize: 25),
            ),
          )),
        ],
      ),
    );
  }
}
