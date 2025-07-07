// 📦 需要的套件：record, http, path_provider, percent_indicator
// pubspec.yaml 加入：
// dependencies:
//   record: ^5.0.0
//   http: ^0.13.0
//   path_provider: ^2.0.0
//   percent_indicator: ^4.2.3

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';

class RecordDialog extends StatefulWidget {
  const RecordDialog({super.key});

  @override
  State<RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<RecordDialog> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String _status = '點擊開始辨識';
  double _confidence = 0.0;
  bool _isScam = false;
  String _transcript = '';
  String _scamMessage = '';
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    if (!await _recorder.hasPermission()) {
      setState(() => _status = '尚未取得麥克風權限，請至設定開啟。');
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/audio.m4a';

        await _recorder.start(const RecordConfig(), path: path);

        setState(() {
          _isRecording = true;
          _status = '錄音中';
        });
      } else {
        setState(() {
          _status = '無法取得錄音權限';
        });
      }
    } catch (e) {
      setState(() {
        _status = '錄音失敗：$e';
      });
    }
  }

  Future<void> _stopAndUpload() async {
    try {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _status = '分析中';
      });

      if (path == null || !File(path).existsSync()) {
        setState(() {
          _status = '未取得有效音訊檔案';
        });
        return;
      }

      final file = File(path);
      final uri = Uri.parse('http://203.145.202.91:8080/audio_analysis');
      final request = http.MultipartRequest('POST', uri)
        ..fields['session_id'] = 'mobile_session_001'
        ..fields['is_final'] = 'true'
        ..files.add(await http.MultipartFile.fromPath('audio_file', file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (!mounted) return;

      try {
        final json = jsonDecode(body);
        setState(() {
          _transcript = json['transcript'] ?? '';
          _isScam = json['is_scam'] ?? false;
          _confidence = (json['confidence'] ?? 0.0) * 100;
          _scamMessage = json['scamMessage'] ?? '';
          _status = '分析完成';
        });
      } catch (e) {
        setState(() {
          _status = '回傳格式錯誤：$body';
        });
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('上傳失敗'),
            content: const Text('請檢查網路以及VPN連線'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('確定'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView( // 包裹 Column，啟用滾動功能
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8), // 調整狀態欄與圓形百分比指示器的間距
              CircularPercentIndicator(
                radius: 80,
                lineWidth: 12,
                percent: (_confidence.clamp(0, 100)) / 100,
                animation: true,
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: Colors.grey.shade300,
                progressColor: _isScam ? Colors.redAccent : const Color.fromARGB(255, 37, 231, 19),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_confidence.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isScam ? 'SCAM RISK' : 'TOTAL TFX',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isScam ? Colors.redAccent : Colors.grey,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _status, // 顯示狀態欄內容
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isRecording ? null : _startRecording,
                    icon: const Icon(Icons.mic),
                    label: const Text('開始辨識'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isRecording ? _stopAndUpload : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('結束辨識'),
                  ),
                ],
              ),
              const Divider(height: 24),
              TextButton(
                onPressed: () => setState(() => _showDetails = !_showDetails),
                child: Text(_showDetails ? '隱藏詳細資料' : 'V 更多詳細資料'),
              ),
              if (_showDetails) ...[
                const Divider(height: 24),
                /*
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('辨識結果：', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 4 * 20.0, // 預設高度為 4 行文字大小
                  ),
                  child: Container(
                    width: double.infinity, // 左右對齊，填滿父容器
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), // 增加左右間隔
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _transcript.isEmpty ? '尚無內容' : _transcript,
                      textAlign: TextAlign.left, // 文字靠左對齊
                      maxLines: null, // 允許文字行數不限
                      overflow: TextOverflow.visible, // 文字超出時顯示完整內容
                      style: const TextStyle(fontSize: 16), // 設定文字大小
                    ),
                  ),
                ),
                */
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('分析結果：', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 4 * 20.0, // 預設高度為 4 行文字大小
                  ),
                  child: Container(
                    width: double.infinity, // 左右對齊，填滿父容器
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), // 增加左右間隔
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _scamMessage.isEmpty ? '尚無內容' : _scamMessage,
                      textAlign: TextAlign.left, // 文字靠左對齊
                      maxLines: null, // 允許文字行數不限
                      overflow: TextOverflow.visible, // 文字超出時顯示完整內容
                      style: const TextStyle(fontSize: 16), // 設定文字大小
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}