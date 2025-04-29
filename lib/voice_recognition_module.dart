import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vibration/vibration.dart';

class VoiceRecognitionModule {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final Function(String)? onResult;
  final Function()? onStart;
  final Function()? onStop;
  final Function(String)? onError;

  bool _isInitialized = false;
  bool _isListening = false;

  VoiceRecognitionModule({
    this.onResult,
    this.onStart,
    this.onStop,
    this.onError,
  });

  Future<void> initialize() async {
    _isInitialized = await _speech.initialize(
      onStatus: (status) => _handleStatus(status),
      onError: (error) => onError?.call(error.errorMsg),
    );
    if (!_isInitialized) {
      onError?.call('無法初始化語音辨識');
    }
  }

  Future<bool> toggleListening() async {
    if (!_isInitialized) return false;
    
    if (_isListening) {
      await stopListening();
      return false;
    } else {
      return await startListening();
    }
  }

  Future<bool> startListening() async {
    if (!_isInitialized || _isListening) return false;

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      onError?.call('麥克風權限被拒絕');
      return false;
    }

    final success = await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult?.call(result.recognizedWords);
        }
      },
      listenFor: Duration(seconds: 30),
      cancelOnError: true,
    );

    if (success) {
      _isListening = true;
      onStart?.call();
      Vibration.vibrate(duration: 50);
    }
    return success;
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      onStop?.call();
    }
  }

  void _handleStatus(String status) {
    if (status == 'done') {
      stopListening();
    }
  }

  void dispose() {
    _speech.stop();
  }

  bool get isListening => _isListening;
  bool get isAvailable => _isInitialized;
}