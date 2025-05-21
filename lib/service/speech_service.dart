import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';

class SpeechService with ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final StreamController<String> _textStream = StreamController<String>.broadcast();
  final StreamController<String> _serverResponseStream = StreamController<String>.broadcast();
  
  String _currentText = '';
  bool _isListening = false;
  Timer? _timeoutTimer;
  String _permissionError = '';
  bool _hasPermission = false;

  // 暴露文本流供UI層監聽
  Stream<String> get textStream => _textStream.stream;
  Stream<String> get serverResponseStream => _serverResponseStream.stream;

  bool get isListening => _isListening;
  String get currentText => _currentText;
  String get permissionError => _permissionError;
  bool get hasPermission => _hasPermission;

  // 初始化語音辨識與權限
  Future<void> initSpeech() async {
    final status = await Permission.microphone.status;
    _hasPermission = status.isGranted || status.isLimited;

    if (!_hasPermission) {
      final result = await Permission.microphone.request();
      _hasPermission = result.isGranted;
      
      if (!_hasPermission) {
        _permissionError = '請授予麥克風權限';
        _textStream.add(_permissionError);
        return;
      }
    }

    final available = await _speech.initialize(
      onStatus: _handleStatus,
      onError: _handleError,
    );

    if (!available) {
      _textStream.add("語音辨識初始化失敗，請檢查裝置支援與權限");
    } else {
      _textStream.add("語音辨識準備就緒，請開始說話");
    }
  }

  // 開始聆聽
  void startListening() async {
    if (!_isListening && _hasPermission) {
      await _speech.listen(
        onResult: _handleResult,
        localeId: 'zh-TW',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        pauseFor: const Duration(seconds: 10), // 延長暫停檢測時間
      );
      
      _isListening = true;
      _currentText = '正在聆聽...';
      _textStream.add(_currentText);
      _resetTimeoutTimer();
    } else if (!_hasPermission) {
      _textStream.add(_permissionError);
    }
  }

  // 停止聆聽
  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
      _timeoutTimer?.cancel();
      _currentText = '聆聽已停止';
      _textStream.add(_currentText);
    }
  }

  // 處理辨識結果
  void _handleResult(stt.SpeechRecognitionResult val) {
    _currentText = val.recognizedWords;
    
    // 即時更新UI（中間結果）
    _textStream.add(_currentText);
    
    if (val.finalResult && _currentText.isNotEmpty) {
      _sendToServer(_currentText);
      _resetTimeoutTimer();
    }
  }

  // 處理狀態變更
  void _handleStatus(String status) {
    print('語音狀態: $status');
    
    if (status == 'notListening' && _isListening) {
      // 意外停止，自動重啟
      _textStream.add('語音辨識短暫中斷，正在重啟...');
      _restartListening();
    }
  }

  void _handleError(dynamic error) {
    // 直接將錯誤對象轉換為字符串，避免類型判斷
    final errorMessage = error.toString();
    
    // 過濾無意義的錯誤（如空字符串）
    if (errorMessage.isNotEmpty && !errorMessage.contains('NoSuchMethodError')) {
      _textStream.add("語音辨識錯誤：$errorMessage");
    }
    
    _isListening = false;
    _resetTimeoutTimer();
  }

  // 重新啟動聆聽
  void _restartListening() {
    if (_isListening) {
      stopListening();
      startListening();
    }
  }

  // 發送數據到後台
  Future<void> _sendToServer(String text) async {
    _textStream.add('正在發送到伺服器...');
    
    try {
      final url = Uri.parse('https://c250-2001-b400-e2c2-aaa8-e0c8-5a6-4ade-56fd.ngrok-free.app/process_text'); // 替換為實際URL
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final reply = responseData['reply'] ?? '伺服器處理成功';
        _serverResponseStream.add(reply);
        _textStream.add('伺服器回覆已接收');
      } else {
        _serverResponseStream.add(_parseError(response.statusCode));
      }
    } catch (e) {
      _serverResponseStream.add('網路錯誤：$e');
    }
  }

  // 解析HTTP錯誤
  String _parseError(int statusCode) {
    return {
      400: '請求格式錯誤',
      401: '未授權訪問',
      403: '拒絕訪問',
      404: '伺服器路徑不存在',
      500: '伺服器內部錯誤',
      503: '服務暫不可用',
    }[statusCode] ?? '未知錯誤 (代碼: $statusCode)';
  }

  // 超時重啟機制
  void _resetTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(minutes: 3), () {
      if (_isListening) {
        _textStream.add('長時間無語音輸入，自動重啟聆聽...');
        _restartListening();
      }
    });
  }

  // 手動發送文本（用於文字輸入）
  void sendText(String text) {
    if (text.isNotEmpty) {
      _sendToServer(text);
    }
  }

  // 釋放資源
  @override
  void dispose() {
    _textStream.close();
    _serverResponseStream.close();
    _speech.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }
}