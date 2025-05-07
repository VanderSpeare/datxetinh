import 'package:flutter/material.dart';
import '../core/Constants.dart';

Widget buildErrorMessage(String message,
    {TextAlign textAlign = TextAlign.center,
    int? maxLines,
    EdgeInsetsGeometry? padding}) {
  return Padding(
    padding:
        padding ?? EdgeInsets.symmetric(vertical: Constants.defaultPadding / 2),
    child: Text(
      message,
      textAlign: textAlign,
      maxLines: maxLines,
      style: TextStyle(
        color: Constants.errorColor,
        fontSize: Constants.fontSizeMedium,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

Widget buildLoadingIndicator(
    {double size = 20.0,
    Color color = Colors.white,
    EdgeInsetsGeometry? padding}) {
  return Padding(
    padding: padding ?? EdgeInsets.all(Constants.defaultPadding / 2),
    child: Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: 2.0,
        ),
      ),
    ),
  );
}
