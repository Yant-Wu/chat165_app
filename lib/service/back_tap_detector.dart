import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class BackTapDetector {
  final VoidCallback onDoubleTap;
  DateTime? _lastBackTap;
  bool _isEnabled = true;

  BackTapDetector({required this.onDoubleTap});

  void initialize() {
    SystemChannels.platform.setMethodCallHandler((call) {
      if (call.method == 'backPressed') {
        _handleBackTap();
        return Future.value(false); // 阻止默認返回行為
      }
      return Future.value(true);
    });
  }

  void _handleBackTap() {
    if (!_isEnabled) return;

    final now = DateTime.now();
    if (_lastBackTap != null && now.difference(_lastBackTap!) < Duration(milliseconds: 500)) {
      _isEnabled = false;
      Vibration.vibrate(duration: 50);
      onDoubleTap();
      _lastBackTap = null;
      Future.delayed(Duration(milliseconds: 500), () => _isEnabled = true);
    } else {
      _lastBackTap = now;
    }
  }

  void dispose() {
    SystemChannels.platform.setMethodCallHandler(null);
  }
}