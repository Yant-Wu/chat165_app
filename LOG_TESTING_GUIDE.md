# 📊 Log 測試指南

## 🚀 如何查看 Log 輸出

### 方法 1: VS Code 內建終端機
```bash
cd /Users/yanwu/Desktop/實驗室/chat165_app
flutter run
```

### 方法 2: 使用 Android Studio 的 Logcat
1. 開啟 Android Studio
2. 連接手機或啟動模擬器
3. 點擊 Logcat 標籤
4. 過濾器設為 "flutter" 或 "Copilot"

### 方法 3: 使用 ADB 指令
```bash
adb logcat | grep flutter
```

## 📋 Log 輸出內容說明

### 🎯 App 啟動時的位置檢測
```
📍 開始自動偵測位置...
✅ 位置偵測成功: 台北市
🔑 Session ID: session_1722332400_abc123
🌍 位置已儲存到全域狀態，將在語音辨識時一併發送
```

### 🎤 語音識別對話框初始化
```
=== 🚀 RecordDialog 初始化 ===
📱 Session ID: session_1722332400_abc123
🌍 當前位置: 台北市
🔐 檢查麥克風權限狀態...
✅ 麥克風權限已授予
```

### 📹 開始錄音流程
```
=== 🎤 開始錄音流程 ===
🔐 檢查麥克風權限...
✅ 麥克風權限已取得
📁 錄音檔案將儲存至: /data/user/0/.../cache/audio.m4a
🔴 開始錄音...
🎯 UI 狀態更新: 錄音中
```

### 🔄 停止錄音並上傳
```
=== 🎤 停止錄音並開始上傳 ===
📁 錄音檔案路徑: /data/user/0/.../cache/audio.m4a
📊 音訊檔案大小: 45632 bytes
🔗 API 端點: http://203.145.202.91:8080/audio_analysis
📝 準備請求參數:
  - Session ID: session_1722332400_abc123
  - County: 台北市
  - Is Final: true
🚀 發送請求到後端...
📡 收到回應 - 狀態碼: 200
📄 回應內容: {"transcript":"您好，我是銀行客服...","is_scam":true,"confidence":0.85,"scamMessage":"疑似詐騙電話"}
```

### 📊 成功解析回應
```
🔍 解析 JSON 回應...
✅ JSON 解析成功:
  - transcript: 您好，我是銀行客服...
  - is_scam: true
  - confidence: 0.85
  - scamMessage: 疑似詐騙電話
🎯 UI 更新完成 - 詐騙風險: 是, 信心度: 85.0%
```

## 🛠️ 錯誤 Log 範例

### ❌ 權限錯誤
```
❌ 麥克風權限未授予
❌ 位置權限被拒絕
❌ 位置服務未開啟
```

### 📱 檔案錯誤
```
❌ 錯誤: 音訊檔案不存在
💥 錄音啟動失敗: PlatformException...
```

### 🌐 網路錯誤
```
📡 收到回應 - 狀態碼: 500
❌ JSON 解析失敗: FormatException...
💥 上傳過程發生錯誤: SocketException...
```

## 🎯 測試重點

1. **Session ID 一致性**: 確認整個流程中使用的是同一個 session ID
2. **位置資料**: 確認位置正確獲取並傳送到後端
3. **音訊檔案**: 確認音訊檔案大小不為 0
4. **API 回應**: 確認後端正確回應 JSON 格式
5. **錯誤處理**: 測試各種錯誤情況的處理

## 🔧 除錯技巧

- 如果 Session ID 不一致，檢查 GlobalState 單例模式
- 如果位置顯示「未取得」，檢查權限和網路連線
- 如果音訊檔案大小為 0，檢查麥克風權限
- 如果 API 錯誤，檢查網路連線和 VPN 設定
