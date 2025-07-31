# 位置 API 端點實作指南

## 概述
您的 Flutter 應用需要一個 `/location` 端點來接收位置資料。以下是實作建議：

## 需要的端點
- **URL**: `http://203.145.202.91:8080/location`
- **方法**: POST
- **Content-Type**: application/json

## 請求格式
簡化版本，只發送縣市資料：
```json
{
  "session_id": "session_1722150000000_1234",
  "county": "台北市",
  "timestamp": "2025-01-01T12:00:00.000Z"
}
```

## 回應格式
### 成功 (200/201)
```json
{
  "status": "success",
  "message": "位置資料已成功接收",
  "data": {
    "id": "生成的ID",
    "received_at": "2025-01-01T12:00:00.000Z"
  }
}
```

### 錯誤 (400)
```json
{
  "error": "Missing required field: latitude"
}
```

## Python Flask 實作範例
```python
from flask import Flask, request, jsonify
from datetime import datetime
import sqlite3

app = Flask(__name__)

@app.route('/location', methods=['POST'])
def receive_location():
    try:
        data = request.get_json()
        
        # 驗證必要欄位（簡化版本）
        required_fields = ['session_id', 'county']
        for field in required_fields:
            if field not in data:
                return jsonify({'error': f'Missing required field: {field}'}), 400
        
        # 儲存到資料庫
        conn = sqlite3.connect('locations.db')
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO user_locations 
            (session_id, county, timestamp, received_at)
            VALUES (?, ?, ?, ?)
        ''', (
            data.get('session_id'),
            data.get('county'),
            data.get('timestamp'),
            datetime.now().isoformat()
        ))
        
        location_id = cursor.lastrowid
        conn.commit()
        conn.close()
        
        return jsonify({
            'status': 'success',
            'message': '位置資料已成功接收',
            'data': {
                'id': location_id,
                'received_at': datetime.now().isoformat()
            }
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
```

## 資料庫表格結構 (SQLite)
簡化版本，只儲存縣市資料：
```sql
CREATE TABLE user_locations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    county TEXT NOT NULL,
    timestamp TEXT,
    received_at TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## Node.js Express 實作範例
```javascript
const express = require('express');
const sqlite3 = require('sqlite3').verbose();
const app = express();

app.use(express.json());

app.post('/location', (req, res) => {
    const { latitude, longitude, country, city, district, fullAddress, timestamp } = req.body;
    
    if (!latitude || !longitude) {
        return res.status(400).json({ error: 'Missing required fields: latitude, longitude' });
    }
    
    const db = new sqlite3.Database('locations.db');
    
    db.run(`
        INSERT INTO user_locations 
        (latitude, longitude, country, city, district, full_address, timestamp, received_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    `, [latitude, longitude, country, city, district, fullAddress, timestamp, new Date().toISOString()],
    function(err) {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        
        res.json({
            status: 'success',
            message: '位置資料已成功接收',
            data: {
                id: this.lastID,
                received_at: new Date().toISOString()
            }
        });
    });
    
    db.close();
});
```

## 部署到現有服務器
將上述程式碼添加到您現有的後端應用中，確保：
1. 端點路徑為 `/location`
2. 接受 POST 請求
3. 處理 JSON 格式的請求體
4. 返回適當的 HTTP 狀態碼

## 測試端點
使用 curl 測試簡化版本：
```bash
curl -X POST http://203.145.202.91:8080/location \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "session_1722150000000_1234",
    "county": "台北市",
    "timestamp": "2025-01-01T12:00:00.000Z"
  }'
```

應該返回：
```json
{
  "status": "success",
  "message": "位置資料已成功接收",
  "data": {
    "id": 1,
    "received_at": "2025-01-01T12:00:00.000Z"
  }
}
```
