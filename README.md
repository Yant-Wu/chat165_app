# Chat165 防詐騙攔截系統

一個結合即時通話分析與 AI 辨識的防詐騙應用程式，提供 Android 和 iOS 雙平台支援。

## 功能特色

- 📞 即時通話詐騙分析與攔截
- 🛡️ 詐騙號碼資料庫比對
- 🤖 AI 語音模式識別
- 📊 詐騙統計儀表板
- 🔔 即時詐騙警示通知

## 技術架構

- **前端**: Flutter (Android/iOS 跨平台)
- **後端**: Node.js/Python
- **AI 模型**: 修改中
- **資料庫**: Firebase/Firestore

## 開發環境設置

### 必要條件

- Flutter SDK (>=3.0.0)
- Dart (>=2.17.0)
- Android Studio/Xcode (依平台需求)
- Git 版本控制

### 安裝步驟

1. 克隆倉庫：
   ```bash
   git clone https://github.com/Yant-Wu/chat165_app.git
   cd chat165_app
   ```
2. 獲取依賴項：
    ```bash
    flutter pub get
    ```

3. 運行應用程式：
    ```bash
    flutter run
    ```

### Git 協作規範
#### 分支策略
- main - 正式環境分支，只接受合併請求
- develop - 開發主分支，所有功能合併到此分支
- feature/xxx - 功能開發分支 (例: feature/call-blocking)
- bugfix/xxx - 錯誤修復分支
- hotfix/xxx - 緊急修復分支

#### 分支命名範例
類型	範例
功能開發	feature/call-analysis
錯誤修復	bugfix/block-crash
緊急修復	hotfix/api-connection
文件更新	docs/update-readme

### 提交訊息規範(Commit)
#### 常見類型：
- feat: 新功能
- fix: 錯誤修復
- docs: 文件更新
- style: 代碼格式調整
- refactor: 代碼重構
- test: 測試相關
- chore: 構建過程或輔助工具變更

### 常見命令備忘錄
- 查看與遠端不一樣的項目

    git status

- 創建新分支

    git checkout -b feature/your-feature

- 提交變更

    git add .

    git commit -m "feat(module): add new feature"

- 推送分支
    
    git push origin feature/your-feature

- 拉取最新變更
    
    git pull origin develop

- 合併分支

    git checkout develop

    git merge --no-ff feature/your-feature

