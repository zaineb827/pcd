import 'package:flutter/services.dart';

class StressService {
  static const _channel = MethodChannel('com.example.ey/stress_channel');
  static Function(int)? _onStressDetected;

  static void init({Function(int)? onStressDetected}) {
    _onStressDetected = onStressDetected;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'stressDetected') {
        final int stressValue = call.arguments;
        if (_onStressDetected != null) {
          _onStressDetected!(stressValue);
        }
      }
    });
  }
}
