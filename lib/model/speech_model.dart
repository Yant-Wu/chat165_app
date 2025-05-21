import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class SpeechState extends Equatable {
  final bool isListening;
  final String text;
  final String serverResponse;
  final bool hasPermission;
  final String permissionError;
  final DateTime? lastRecognitionTime;
  final List<String> recognizedTexts;
  final String finalResult;

  const SpeechState({
    this.isListening = false,
    this.text = '',
    this.serverResponse = '',
    this.hasPermission = false,
    this.permissionError = '',
    this.lastRecognitionTime,
    this.recognizedTexts = const [],
    this.finalResult = '',
  });

  SpeechState copyWith({
    bool? isListening,
    String? text,
    String? serverResponse,
    bool? hasPermission,
    String? permissionError,
    DateTime? lastRecognitionTime,
    List<String>? recognizedTexts,
    String? finalResult,
  }) {
    return SpeechState(
      isListening: isListening ?? this.isListening,
      text: text ?? this.text,
      serverResponse: serverResponse ?? this.serverResponse,
      hasPermission: hasPermission ?? this.hasPermission,
      permissionError: permissionError ?? this.permissionError,
      lastRecognitionTime: lastRecognitionTime ?? this.lastRecognitionTime,
      recognizedTexts: recognizedTexts ?? this.recognizedTexts,
      finalResult: finalResult ?? this.finalResult,
    );
  }

  @override
  List<Object?> get props => [
    isListening,
    text,
    serverResponse,
    hasPermission,
    permissionError,
    lastRecognitionTime,
    recognizedTexts,
    finalResult,
  ];
}