import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'dart:math'; // <--- 新增：匯入 dart:math 以使用 Random

class SpeechService with ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final StreamController<String> _textStream = StreamController<String>.broadcast();
  final StreamController<String> _serverResponseStream = StreamController<String>.broadcast();
  
  String _currentText = '';
  bool _isListening = false;
  Timer? _timeoutTimer;
  String _permissionError = '';
  bool _hasPermission = false;
  String? _currentSessionId; // <--- 新增：用於儲存當前的 Session ID
  // 新增：服務狀態
  String _serviceStatus = '閒置中';
  // 新增：API配置
  //final String _apiBaseUrl = 'https://c2fe-2001-b400-e2c2-de8b-bd43-1ebb-17b-9bcc.ngrok-free.app';
  //final String _apiEndpoint = '/process_text';

  final String _apiBaseUrl = 'http://203.145.202.91:8080'; // 確保沒有不可見字元並加上 http:// (或 https://)
  final String _apiEndpoint = '/chat_analysis';

  // 新增：請求計數器
  int _requestCount = 0;

  // 暴露文本流供UI層監聽
  Stream<String> get textStream => _textStream.stream;
  Stream<String> get serverResponseStream => _serverResponseStream.stream;

  bool get isListening => _isListening;
  String get currentText => _currentText;
  String get permissionError => _permissionError;
  bool get hasPermission => _hasPermission;
  // 新增：服務狀態
  String get serviceStatus => _serviceStatus;
  // 新增：請求計數器
  int get requestCount => _requestCount;

  // 新增：產生新的 Session ID 的輔助方法
  String _generateNewSessionId() {
    return '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(99999)}';
  }

  // 初始化語音辨識與權限
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

  // 開始聆聽
  void startListening() async {
    if (!_isListening && _hasPermission) {
      _updateStatus('正在聆聽...');
      _currentSessionId = _generateNewSessionId(); // <--- 新增：開始聆聽時產生新的 Session ID
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
      _updateStatus('權限不足');
    }
  }

  // 停止聆聽
  void stopListening() {
    if (_isListening) {
      _updateStatus('已停止聆聽');
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
      // <--- 修改點：傳遞 _currentSessionId (使用 ! 因為此時它必不為空)
      _sendToServer(_currentText, val.finalResult, _currentSessionId!); 
      _resetTimeoutTimer();
    }
  }

  // 處理狀態變更
  void _handleStatus(String status) {
    print('語音狀態: $status');
    _updateStatus(status);
    
    if (status == 'notListening' && _isListening) {
      // 意外停止，自動重啟
      _textStream.add('語音辨識短暫中斷，正在重啟...');
      _updateStatus('重新連接中');
      _restartListening();
    }
  }

  void _handleError(dynamic error) {
    // 直接將錯誤對象轉換為字符串，避免類型判斷
    final errorMessage = error.toString();
    
    // 過濾無意義的錯誤（如空字符串）
    if (errorMessage.isNotEmpty && !errorMessage.contains('NoSuchMethodError')) {
      _textStream.add("語音辨識錯誤：$errorMessage");
      _updateStatus('發生錯誤');
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
  // <--- 修改點：增加 sessionId 參數
  Future<void> _sendToServer(String text, bool isFinal, String sessionId) async { 
    _updateStatus('正在發送數據...');
    _textStream.add('正在發送到伺服器...');
    print('--- [SpeechService] _sendToServer ---');
    print('原始文本: "$text", 是否最終: $isFinal, Session ID: $sessionId');
    
    String? fullUrl;

    try {
      // 構建符合新後端 API 的請求體
      final requestBody = {
        "data": text,
        "is_final": isFinal, 
        "session_id": sessionId,
      };
      
      fullUrl = '$_apiBaseUrl$_apiEndpoint';
      print('準備發送請求到 URL: $fullUrl');
      print('請求 Body: ${jsonEncode(requestBody)}');
      
      final url = Uri.parse(fullUrl);

      print('開始 http.post...');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'X-App-Version': '1.0.0', // 根據新的後端 API，這些自訂標頭可能不再需要
          // 'X-Request-ID': 'req-${DateTime.now().millisecondsSinceEpoch}'
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 40));
      print('http.post 完成, 狀態碼: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('伺服器原始回應 Body: ${response.body}');
        final responseData = json.decode(response.body);
        
        // 直接從根部讀取 is_scam
        final isScam = responseData['is_scam'] as bool?;

        if (isScam != null) {
          print('--- [SpeechService] Received is_scam: $isScam ---');
          _serverResponseStream.add('詐騙偵測結果: $isScam');
          // 您可以根據 isScam 的值來決定更詳細的訊息
          // if (isScam) {
          //   _serverResponseStream.add('警告：偵測到可能的詐騙內容！');
          // } else {
          //   _serverResponseStream.add('內容分析完成，未偵測到詐騙。');
          // }
        } else {
          print('--- [SpeechService] "is_scam" field not found or is not a boolean in response: ${response.body} ---');
          _serverResponseStream.add('無法解析詐騙偵測結果');
        }
        
        _requestCount++;
        _updateStatus('處理完成');
      } else {
        print('伺服器錯誤回應 Body: ${response.body}'); // 新增日誌，查看錯誤時的 body
        _serverResponseStream.add(_parseError(response.statusCode));
        _updateStatus('HTTP錯誤');
      }
      _textStream.add('伺服器回覆已接收');
    } on TimeoutException {
      _serverResponseStream.add('請求超時，請檢查網絡或重試');
      _updateStatus('請求超時');
      print('--- [SpeechService] 請求超時 ---'); // 新增日誌
      if (fullUrl != null) print('URL: $fullUrl'); // 在超時時也印出 URL
    } on http.ClientException catch (e) {
      _serverResponseStream.add('客戶端網絡錯誤：$e');
      _updateStatus('網絡錯誤');
      print('--- [SpeechService] ClientException ---'); // 新增日誌
      print('錯誤訊息: $e'); // 新增日誌
      if (fullUrl != null) print('URL: $fullUrl'); // 在錯誤時也印出 URL
    } on FormatException catch (e, s) { // 新增堆疊追蹤
      _serverResponseStream.add('伺服器返回數據格式錯誤');
      _updateStatus('數據格式錯誤');
      print('--- [SpeechService] FormatException ---'); // 新增日誌
      print('錯誤訊息: $e'); // 新增日誌
      print('堆疊追蹤: $s'); // 新增日誌
      // 如果可能，也印出 response.body，但要注意此時 response 可能不存在或 body 不是字串
    } catch (e, s) { // 新增堆疊追蹤
      _serverResponseStream.add('未知錯誤：$e');
      _updateStatus('未知錯誤');
      print('--- [SpeechService] 未知錯誤 ---'); // 新增日誌
      print('錯誤訊息: $e'); // 新增日誌
      print('堆疊追蹤: $s'); // 新增日誌
      if (fullUrl != null) print('URL: $fullUrl');
    }
    print('--- [SpeechService] _sendToServer 結束 ---'); // 新增日誌
  }

  // 解析HTTP錯誤
  String _parseError(int statusCode) {
    return {
      400: '請求格式錯誤',
      401: '未授權訪問',
      403: '拒絕訪問',
      404: '伺服器路徑不存在',
      408: '請求超時',
      500: '伺服器內部錯誤',
      502: '錯誤閘道',
      503: '服務暫不可用',
      504: '閘道超時',
    }[statusCode] ?? '未知錯誤 (代碼: $statusCode)';
  }

  // 超時重啟機制
  void _resetTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(minutes: 3), () {
      if (_isListening) {
        _textStream.add('長時間無語音輸入，自動重啟聆聽...');
        _updateStatus('重啟聆聽');
        _restartListening();
      }
    });
  }

  // 手動發送文本（用於文字輸入）
  void sendText(String text) {
    if (text.isNotEmpty) {
      // <--- 修改點：決定 sessionId 並傳遞給 _sendToServer
      String sessionIdToSend = _currentSessionId ?? _generateNewSessionId();
      _sendToServer(text, true, sessionIdToSend); 
    }
  }

  // 更新服務狀態
  void _updateStatus(String status) {
    _serviceStatus = status;
    notifyListeners(); // 通知UI更新
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