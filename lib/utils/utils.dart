import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

double calculateHeight(
    {required double factor, required BuildContext context}) {
  return MediaQuery.of(context).size.height * factor;
}

double calculateWidth({required double factor, required BuildContext context}) {
  return MediaQuery.of(context).size.height * factor;
}

double calculateFontSize(
    {required double factor, required BuildContext context}) {
  return MediaQuery.of(context).textScaleFactor * factor;
}

class BasicUtils {
  static String calculateWeekOfYear(DateTime dateTime) {
    int noOfDaysInYear = int.parse(DateFormat("D").format(dateTime));
    return "W-${((noOfDaysInYear - 1) / 7).floor()}";
  }
}
