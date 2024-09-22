import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void toastInfo({
  required String msg,
  Color backgroundColor = Colors.black,
  Color textColor = Colors.white,
}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    textColor: textColor,
    backgroundColor: backgroundColor,
  );
}
