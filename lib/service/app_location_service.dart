import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'global_state.dart';

class AppLocationService {
  static final GlobalState _globalState = GlobalState();
  
  // 在 app 啟動時自動偵測位置
  static Future<void> initializeLocationOnAppStart() async {
    try {
      debugPrint('📍 開始自動偵測位置...');
      debugPrint('🔍 使用 GlobalState 實例: ${_globalState.hashCode}');
      
      // 檢查位置權限
      PermissionStatus permission = await Permission.location.status;
      if (permission.isDenied) {
        debugPrint('🔐 請求位置權限...');
        permission = await Permission.location.request();
      }
      
      if (permission.isPermanentlyDenied || permission.isDenied) {
        debugPrint('❌ 位置權限被拒絕');
        return;
      }
      
      // 檢查位置服務是否開啟
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ 位置服務未開啟');
        return;
      }
      
      // 獲取當前位置
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      
      // 反向地理編碼
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String county = place.administrativeArea ?? '未知縣市';
        
        // 儲存到全域狀態（不發送到後端）
        _globalState.setLocationData(county);
        
        debugPrint('✅ 位置偵測成功: $county');
        debugPrint('🔑 Session ID: ${_globalState.sessionId}');
        debugPrint('🌍 位置已儲存到全域狀態，將在語音辨識時一併發送');
        debugPrint('🔍 儲存後 GlobalState 實例: ${_globalState.hashCode}');
        debugPrint('📊 hasLocationData: ${_globalState.hasLocationData}');
      }
      
    } catch (e) {
      debugPrint('❌ 位置偵測失敗: $e');
    }
  }
  
  // 獲取當前位置資訊
  static String? getCurrentCounty() {
    return _globalState.currentCounty;
  }
  
  // 獲取統一的 session ID
  static String getSessionId() {
    return _globalState.sessionId;
  }
  
  // 檢查是否有位置資料
  static bool hasLocationData() {
    return _globalState.hasLocationData;
  }
}
