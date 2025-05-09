import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'main.dart';  // Assurez-vous que MainNavigationWrapper est importé

class SensorService {
  static const platform = MethodChannel('com.example.ey/sensor'); // Canal Flutter <-> Kotlin

  Future<void> startService() async {
    try {
      await platform.invokeMethod('startService');
    } on PlatformException catch (e) {
      print("Failed to start service: ${e.message}");
    }

    // Ajouter l'écoute de la méthode `serviceEnabled` envoyée par Kotlin
    platform.setMethodCallHandler((call) async {
      if (call.method == "serviceEnabled") {
        // Naviguer vers MainNavigationWrapper
        _navigateToMainNavigationWrapper();
      }
    });
  }

  void _navigateToMainNavigationWrapper() {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationWrapper()),
      );
    }
  }
}
