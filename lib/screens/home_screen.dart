import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _voiceEnabled = false; // 主開關狀態
  String _lastResult = '';
  DateTime? _lastBackTap;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  void _toggleVoiceEnabled(bool value) {
    setState(() {
      _voiceEnabled = value;
      if (!value) {
        _stopListening(); // 關閉主開關時停止語音辨識
      }
    });
  }

  void _handleBackTap() {
    if (!_voiceEnabled) return; // 只有主開關開啟時響應

    final now = DateTime.now();
    if (_lastBackTap != null && now.difference(_lastBackTap!) < Duration(milliseconds: 500)) {
      _toggleListening(); // 雙擊背面切換語音狀態
      _lastBackTap = null;
    } else {
      _lastBackTap = now;
    }
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _startListening();
      } else {
        _stopListening();
      }
    });
  }

  Future<void> _startListening() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;

    if (!_isListening) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() => _lastResult = result.recognizedWords);
          }
        },
        listenFor: Duration(seconds: 30),
      );
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('國家反詐中心'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 功能按鈕區 (保持不變)
              Container(
                color: const Color(0xFF1976D2),
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFunctionButton('我要舉報', Icons.report, Colors.red),
                    _buildFunctionButton('來電預警', Icons.phone, Colors.orange),
                    _buildFunctionButton('身份核實', Icons.verified_user, Colors.green),
                  ],
                ),
              ),
              
              // 風險自查區 (修改部分)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '風險自查',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // 新增語音辨識開關
                          ListTile(
                            leading: const Icon(Icons.mic, color: Colors.blue),
                            title: const Text('語音風險檢測'),
                            subtitle: const Text('敲擊背面兩下啟動語音辨識'),
                            trailing: Switch(
                              value: _voiceEnabled,
                              onChanged: _toggleVoiceEnabled,
                            ),
                            onTap: () => _toggleVoiceEnabled(!_voiceEnabled),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.android, color: Colors.blue),
                            title: const Text('APP自檢'),
                            subtitle: const Text('手機自測可疑APP'),
                            onTap: () {},
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.search, color: Colors.blue),
                            title: const Text('風險查詢'),
                            subtitle: const Text('支付社交賬號核驗'),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    // 新增語音狀態顯示
                    if (_voiceEnabled) ...[
                      const SizedBox(height: 12),
                      Card(
                        color: _isListening ? Colors.blue[50] : null,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.mic,
                                    color: _isListening ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isListening ? '正在聆聽中...' : '待機中 (敲擊背面兩下開始)',
                                    style: TextStyle(
                                      color: _isListening ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (_lastResult.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('上次結果: $_lastResult'),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // 最新案例區 (保持不變)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '最新案例',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildNewsCard(
                      '為逃生竟肯跳樓？被抓後險遭活埋！男子親送緬北恐怖遺...',
                      '國家反詐中心',
                      '2021-08-03',
                    ),
                    const SizedBox(height: 12),
                    _buildNewsCard(
                      '八旬老太執意轉賬40萬元 民警、銀行聯手上演現場"反詐"...',
                      '國家反詐中心',
                      '2021-08-03',
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('查看更多案例 >'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 保持原有的 _buildFunctionButton 和 _buildNewsCard 方法不變
  Widget _buildFunctionButton(String text, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(icon, size: 30, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(String title, String source, String date) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    source,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}