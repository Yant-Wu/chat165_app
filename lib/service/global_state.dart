import 'dart:math';

class GlobalState {
  static final GlobalState _instance = GlobalState._internal();
  factory GlobalState() => _instance;
  GlobalState._internal();

  // 全域變數
  String? _sessionId;
  String? _currentCounty;
  DateTime? _locationTimestamp;

  // Getter 方法
  String get sessionId {
    _sessionId ??= _generateSessionId();
    return _sessionId!;
  }

  String? get currentCounty => _currentCounty;
  DateTime? get locationTimestamp => _locationTimestamp;

  // Setter 方法
  void setLocationData(String county) {
    _currentCounty = county;
    _locationTimestamp = DateTime.now();
  }

  void resetSession() {
    _sessionId = _generateSessionId();
    _currentCounty = null;
    _locationTimestamp = null;
  }

  // 生成唯一的 session_id
  String _generateSessionId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = random.nextInt(9999).toString().padLeft(4, '0');
    return 'session_${timestamp}_$randomSuffix';
  }

  // 檢查是否有位置資料
  bool get hasLocationData => _currentCounty != null;

  // 獲取完整的位置資料 Map
  Map<String, dynamic> getLocationDataMap() {
    return {
      'session_id': sessionId,
      'county': _currentCounty ?? '',
    };
  }
}
