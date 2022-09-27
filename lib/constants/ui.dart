import 'package:flutter/material.dart';

const standardElevation = 5.0;
const borderDouble = 8.0;
BorderRadius standardBorderRadius = BorderRadius.circular(borderDouble);

getTabColor(
  BuildContext context,
  bool selected,
) {
  Color selectedColor = Colors.black;
  Color notSelectedColor = selectedColor.withOpacity(0.5);

  return selected ? selectedColor : notSelectedColor;
}

const primaryColor = MaterialColor(0xFF00c04b, {
  50: Color.fromARGB(226, 1, 184, 92),
  100: Color.fromARGB(226, 1, 184, 92),
  200: Color.fromARGB(226, 1, 184, 92),
  300: Color.fromARGB(226, 1, 184, 92),
  400: Color.fromARGB(226, 1, 184, 92),
  500: Color.fromARGB(226, 1, 184, 92),
  600: Color.fromARGB(226, 1, 184, 92),
  700: Color.fromARGB(226, 1, 184, 92),
  800: Color.fromARGB(226, 1, 184, 92),
  900: Color.fromARGB(226, 1, 184, 92),
});
