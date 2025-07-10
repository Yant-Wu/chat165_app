# Chat165 防詐騙攔截系統

一個結合即時通話分析與 AI 辨識的防詐騙應用程式，提供 Android 和 iOS 雙平台支援。

![GitHub last commit](https://img.shields.io/github/last-commit/Yant-Wu/chat165_app)
![last monday](https://img.shields.io/badge/last%20commit-last%20monday-blue)
![dart](https://img.shields.io/badge/dart-50.3%25-blue)
![languages](https://img.shields.io/badge/languages-9-blue)

*Built with the tools and technologies:*

![Markdown](https://img.shields.io/badge/Markdown-000000?logo=markdown&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-CF142B?logo=yaml&logoColor=white)

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

#### Coding 循環
建立分支 →開發功能（add → commit） →拉取 develop → merge/rebase →發送 PR →Code Review →合併到 develop/main →刪除本地與遠端分支

#### 查看本地分支
git branch

#### 開啟新分支
git checkout -b branch_name

#### 合併分支
1. 完成 feature/login 開發並 commit。
2. 確保 feature 分支與 develop 同步
3. 切回 develop
    * git checkout develop
4. 合併
    * git merge feature/login
5. 如有衝突需要解決一下
6. 測試無誤推送
    * git push origin develop
7. 刪除已合併的feature分支
    * git branch -d feature/login
    * git push origin --delete feature/login