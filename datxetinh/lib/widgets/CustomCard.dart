import 'package:flutter/material.dart';
import '/../../core/Constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? opacity;

  const CustomCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.opacity = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: Constants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.defaultBorderRadius),
      ),
      margin: margin ?? EdgeInsets.zero,
      color: (color ?? Constants.backgroundColor).withOpacity(opacity!),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        padding: padding ?? EdgeInsets.all(Constants.defaultPadding),
        child: child,
      ),
    );
  }
}
