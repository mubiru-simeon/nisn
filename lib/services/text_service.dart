
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class TextService {
  String putCommas(String text) {
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    // ignore: prefer_function_declarations_over_variables
    Function mathFunc = (Match match) => '${match[1]},';
    return text.replaceAllMapped(reg, mathFunc);
  }

  String removeWhiteSpaces(String text) {
    String gh = text.replaceAll(RegExp(r"\s+"), "");
    return gh;
  }

  String formatter(int number) {
    try {
      double value = number.toDouble();
      // suffix = {' ', 'k', 'M', 'B', 'T', 'P', 'E'};

      if (value < 1000) {
        // less than a thousand
        return value.toStringAsFixed(0);
      } else if (value >= 1000 && value < (1000 * 1000)) {
        // in the thousands
        double result = value / 1000;
        return "${result.toStringAsFixed(0)}K";
      } else if (value < 1000000) {
        // less than a million
        return value.toStringAsFixed(0);
      } else if (value >= 1000000 && value < (1000000 * 10 * 100)) {
        // less than 100 million
        double result = value / 1000000;
        return "${result.toStringAsFixed(0)}M";
      } else if (value >= (1000000 * 10 * 100) &&
          value < (1000000 * 10 * 100 * 100)) {
        // less than 100 billion
        double result = value / (1000000 * 10 * 100);
        return "${result.toStringAsFixed(0)}B";
      } else if (value >= (1000000 * 10 * 100 * 100) &&
          value < (1000000 * 10 * 100 * 100 * 100)) {
        // less than 100 trillion
        double result = value / (1000000 * 10 * 100 * 100);
        return "${result.toStringAsFixed(0)}T";
      } else {
        double result = value / (1000000 * 10 * 100 * 100);
        return "${result.toStringAsFixed(0)}T";
      }
    } catch (e) {
      return "0";
    }
  }
}

extension CapExtension on String {
  String get inCaps =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String get allInCaps => toUpperCase();
  String get capitalizeFirstOfEach => replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.inCaps)
      .join(" ");
}

class CustomTextInputFormatter extends TextInputFormatter {
  final int decimalDigits;

  CustomTextInputFormatter({this.decimalDigits = 2})
      : assert(decimalDigits >= 0);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText;

    if (decimalDigits == 0) {
      newText = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    } else {
      newText = newValue.text.replaceAll(RegExp('[^0-9.]'), '');
    }

    if (newText.contains('.')) {
      //in case if user's first input is "."
      if (newText.trim() == '.') {
        return newValue.copyWith(
          text: '0.',
          selection: TextSelection.collapsed(offset: 2),
        );
      }
      //in case if user tries to input multiple "."s or tries to input
      //more than the decimal place
      else if ((newText.split(".").length > 2) ||
          (newText.split(".")[1].length > decimalDigits)) {
        return oldValue;
      } else {
        return newValue;
      }
    }

    //in case if input is empty or zero
    if (newText.trim() == '' || newText.trim() == '0') {
      return newValue.copyWith(text: '');
    } else if (int.parse(newText) < 1) {
      return newValue.copyWith(text: '');
    }

    double newDouble = double.parse(newText);
    var selectionIndexFromTheRight =
        newValue.text.length - newValue.selection.end;

    String newString = NumberFormat("#,##0.##").format(newDouble);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(
        offset: newString.length - selectionIndexFromTheRight,
      ),
    );
  }
}
