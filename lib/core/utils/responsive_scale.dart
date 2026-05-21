import 'package:flutter/material.dart';

/// Figma design frame width (px).
const double kFigmaDesignWidth = 412;

/// `MediaQuery.sizeOf(context).width / 412` — multiply Figma sizes by this value.
double responsiveScale(BuildContext context) {
  return MediaQuery.sizeOf(context).width / kFigmaDesignWidth;
}
