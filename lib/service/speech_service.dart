import 'package:speech_to_text/speech_recognition_result.dart' as stt_result_source;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_error.dart' as stt_error_specific;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'dart:math';

class SpeechService with ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final StreamController<String> _textStream = StreamController<String>.broadcast();
  final StreamController<String> _serverResponseStream = StreamController<String>.broadcast();

  String _currentText = '';
  bool _isListening = false;
  Timer? _timeoutTimer;
  String _permissionError = '';
  bool _hasPermission = false;
  String? _currentSessionId;
  String _serviceStatus = '閒置中';
  bool _userRequestedStop = false; // 新增：追蹤是否由使用者主動停止

  final String _apiBaseUrl = 'http://203.145.202.91:8080';
  final String _apiEndpoint = '/chat_analysis';
  int _requestCount = 0;

  Stream<String> get textStream => _textStream.stream;
  Stream<String> get serverResponseStream => _serverResponseStream.stream;
  bool get isListening => _isListening;
  String get currentText => _currentText;
  String get permissionError => _permissionError;
  bool get hasPermission => _hasPermission;
  String get serviceStatus => _serviceStatus;
  int get requestCount => _requestCount;

  String _generateNewSessionId() {
    return '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(99999)}';
  }

  Future<void> initSpeech() async {
    _updateStatus('正在初始化語音辨識...');
    final status = await Permission.microphone.status;
    _hasPermission = status.isGranted || status.isLimited;

    if (!_hasPermission) {
      final result = await Permission.microphone.request();
      _hasPermission = result.isGranted;
      if (!_hasPermission) {
        _permissionError = '請授予麥克風權限';
        _textStream.add(_permissionError);
        _updateStatus('權限被拒絕');
        return;
      }
    }

    _currentSessionId = _generateNewSessionId();
    print('初始化完成，Session ID: $_currentSessionId');

    final available = await _speech.initialize(
      onStatus: _handleStatus,
      onError: _handleError,
    );

    if (!available) {
      _textStream.add("語音辨識初始化失敗，請檢查裝置支援與權限");
      _updateStatus('初始化失敗');
    } else {
      _textStream.add("語音辨識準備就緒，請開始說話");
      _updateStatus('準備就緒');
    }
  }

  void startListening() async {
    if (!_isListening && _hasPermission) {
      _userRequestedStop = false; // 重置標誌
      _updateStatus('正在聆聽...');
      await _speech.listen(
        onResult: _handleResult,
        localeId: 'zh-TW',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 10),
      );
      _isListening = true;
      _currentText = '正在聆聽...';
      _textStream.add(_currentText);
      _resetTimeoutTimer();
    } else if (!_hasPermission) {
      _textStream.add(_permissionError);
      _updateStatus('權限不足');
    }
  }

  void stopListening() {
    if (_isListening) {
      _userRequestedStop = true; // 標記為使用者主動停止
      _updateStatus('已停止聆聽');
      _speech.stop();
      _isListening = false;
      _timeoutTimer?.cancel();
      
      // 只有在有文本內容時才發送
      if (_currentText.isNotEmpty && _currentText != '正在聆聽...' && _currentText != '聆聽已停止') {
        _sendToServer(_currentText, true, _currentSessionId!);
      } else {
        _textStream.add('聆聽已停止');
      }
    }
  }

  void _handleResult(stt_result_source.SpeechRecognitionResult val) {
    _currentText = val.recognizedWords;
    _textStream.add(_currentText);

    // 只有在finalResult且是使用者主動停止時才視為最終結果
    if (val.finalResult && _currentText.isNotEmpty) {
      _sendToServer(_currentText, _userRequestedStop, _currentSessionId!);
      _resetTimeoutTimer();
    }
  }

  void _handleStatus(String status) {
    print('語音狀態: $status');
    _updateStatus(status);

    if (status == 'notListening' && _isListening) {
      _textStream.add('語音辨識短暫中斷，正在重啟...');
      _updateStatus('重新啟動語音');
      _restartListening();
    }
  }

  void _handleError(stt_error_specific.SpeechRecognitionError error) {
    final errorMessage = error.errorMsg;
    final permanent = error.permanent;
    print('語音辨識錯誤：$errorMessage, permanent: $permanent');

    if (!permanent) {
      _textStream.add("語音辨識錯誤：$errorMessage（將自動重啟）");
      _updateStatus('錯誤自動重啟中');
      _restartListening();
    } else {
      _textStream.add("語音辨識發生永久錯誤：$errorMessage");
      _updateStatus('永久錯誤');
      _isListening = false;
    }

    _resetTimeoutTimer();
  }

  void _restartListening() {
    if (_isListening || _speech.isAvailable) {
      print('重啟語音辨識，保留Session ID: $_currentSessionId');
      stopListening();
      _userRequestedStop = false; // 重啟時重置標誌
      Future.delayed(const Duration(milliseconds: 500), () {
        startListening();
      });
    }
  }

  Future<void> sendText(String text, {bool isFinal = true}) async {
    if (_currentSessionId == null) {
      _currentSessionId = _generateNewSessionId();
      print('警告：sendText()被呼叫但session ID為空，已重新生成: $_currentSessionId');
    }
    await _sendToServer(text, isFinal, _currentSessionId!);
  }

  Future<void> _sendToServer(String text, bool isFinal, String sessionId) async {
    _updateStatus('正在發送數據...');
    _textStream.add('正在發送到伺服器...');
    print('--- [SpeechService] _sendToServer ---');
    print('原始文本: "$text", 是否最終: $isFinal, Session ID: $sessionId');

    String? fullUrl;

    try {
      final requestBody = {
        "data": text,
        "is_final": isFinal,
        "session_id": sessionId,
      };

      fullUrl = '$_apiBaseUrl$_apiEndpoint';
      final url = Uri.parse(fullUrl);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 40));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final isScam = responseData['is_scam'] as bool?;

        if (isScam != null) {
          _serverResponseStream.add('詐騙偵測結果: $isScam');
        } else {
          _serverResponseStream.add('無法解析詐騙偵測結果');
        }

        _requestCount++;
        _updateStatus('處理完成');
      } else {
        _serverResponseStream.add(_parseError(response.statusCode));
        _updateStatus('HTTP錯誤');
      }

      _textStream.add('伺服器回覆已接收');
    } on TimeoutException {
      _serverResponseStream.add('請求超時，請檢查網絡或重試');
      _updateStatus('請求超時');
    } on http.ClientException catch (e) {
      _serverResponseStream.add('客戶端網絡錯誤：$e');
      _updateStatus('網絡錯誤');
    } catch (e) {
      _serverResponseStream.add('其他錯誤：${e.toString()}');
      _updateStatus('錯誤');
    }
  }

  void _resetTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (_isListening) {
        _textStream.add('超過時間未說話，自動停止聆聽');
        stopListening();
      }
    });
  }

  void _updateStatus(String status) {
    _serviceStatus = status;
    notifyListeners();
  }

  String _parseError(int statusCode) {
    switch (statusCode) {
      case 400:
        return '請求格式錯誤 (400)';
      case 401:
        return '未授權的請求 (401)';
      case 403:
        return '禁止訪問 (403)';
      case 404:
        return '資源未找到 (404)';
      case 500:
        return '伺服器內部錯誤 (500)';
      default:
        return '未知錯誤 ($statusCode)';
    }
  }

  @override
  void dispose() {
    _textStream.close();
    _serverResponseStream.close();
    _timeoutTimer?.cancel();
    super.dispose();
  }
}