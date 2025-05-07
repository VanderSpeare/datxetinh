import 'package:flutter/material.dart';
import '/../../core/Constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, Constants.buttonHeight),
        padding: EdgeInsets.symmetric(
          horizontal: Constants.defaultPadding * 2,
          vertical: Constants.defaultPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
        ),
        elevation: Constants.cardElevation,
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              width: Constants.fontSizeMedium,
              height: Constants.fontSizeMedium,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontSize: Constants.fontSizeMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
