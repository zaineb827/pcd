import 'package:flutter/material.dart';

class AppColors {
  static Color getBackground(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color.fromARGB(255, 30, 30, 30)
        : const Color.fromARGB(255, 255, 243, 243);
  }

  static Color gettextcolor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color.fromARGB(255, 255, 255, 255)
        : const Color.fromARGB(255, 0, 0, 0);
  }

  static String getBackgroundImage(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? 'assets/images/bg1.png'
        : 'assets/images/bg.png';
  }
}
