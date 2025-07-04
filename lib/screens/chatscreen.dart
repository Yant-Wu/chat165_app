// 📦 需要的套件：record, http, path_provider
// pubspec.yaml 加入：
// dependencies:
//   record: ^5.0.0
//   http: ^0.13.0
//   path_provider: ^2.0.0

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class RecordDialog extends StatefulWidget {
  const RecordDialog({super.key});

  @override
  State<RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<RecordDialog> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String _status = '點擊下方開始錄音';
  String _responseInfo = '回傳資訊將顯示在此處';

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
      if (await _recorder.isRecording()) {
        setState(() {
          _status = '錄音已在進行中...';
        });
        return;
      }

      if (await _recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/audio.m4a';

        await _recorder.start(const RecordConfig(), path: path);

        setState(() {
          _isRecording = true;
          _status = '錄音中...';
        });
      } else {
        setState(() {
          _status = '無法取得錄音權限，請至設定開啟權限。';
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
        _status = '正在分析中...';
      });

      if (path == null || !File(path).existsSync()) {
        setState(() {
          _status = '未取得有效音訊檔案';
          _responseInfo = '未取得有效音訊檔案';
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
        final transcript = json['transcript'] ?? '無內容';
        final isScam = json['is_scam'] ?? false;
        final confidence = json['confidence'] ?? 0.0;
        final scamMessage = json['scamMessage'] ?? '無進一步分析結果';

        final resultText = '辨識內容：「$transcript」\n'
            '是否詐騙：${isScam ? '是 🚨' : '否 ✅'}\n'
            '信心：${(confidence * 100).toStringAsFixed(1)}%\n'
            '詐騙分析：$scamMessage\n';

        setState(() {
          _status = '分析完成';
          _responseInfo = resultText;
        });
      } catch (e) {
        setState(() {
          _responseInfo = '回傳格式錯誤：$body';
        });
      }
    } catch (e) {
      setState(() {
        _status = '上傳失敗：$e';
        _responseInfo = '上傳失敗：$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _status,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRecording ? null : _startRecording,
                  icon: const Icon(Icons.mic),
                  label: const Text('開始錄音'),
                ),
                ElevatedButton.icon(
                  onPressed: _isRecording ? _stopAndUpload : null,
                  icon: const Icon(Icons.upload),
                  label: const Text('停止並上傳'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _responseInfo,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


// ✅ 使用方式（在 ChatScreen 中）：
// 將電話按鈕替換為：
// IconButton(
//   icon: const Icon(Icons.phone_outlined),
//   onPressed: () {
//     showDialog(
//       context: context,
//       builder: (context) => const RecordDialog(),
//     );
//   },
//   tooltip: '語音錄音辨識',
// ),
//       builder: (context) => const RecordDialog(),
//     );
//   },
//   tooltip: '語音錄音辨識',
// ),
