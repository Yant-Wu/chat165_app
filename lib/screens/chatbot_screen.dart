import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/speech_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late SpeechService _speechService;

  @override
  void initState() {
    super.initState();
    _speechService = context.read<SpeechService>();
    _speechService.initSpeech();

    // 初始化歡迎訊息
    _addMessage(
      text: "您好！我是反詐騙助手，請問有什麼可以幫您？",
      isMe: false,
      isFinal: true,
    );

    // 監聽語音辨識結果
    _speechService.textStream.listen((text) {
      if (text.startsWith('正在聆聽')) {
        _addMessage(text: text, isMe: true, isFinal: false);
      } else if (text.startsWith('語音辨識錯誤') || text.startsWith('網路錯誤')) {
        _addMessage(text: text, isMe: false, isFinal: true);
      } else if (text.isNotEmpty && !text.startsWith('正在發送') && !text.startsWith('伺服器回覆')) {
        // 更新最後一條消息（語音即時預覽）
        _updateLastMessage(text: text, isFinal: false);
      }
    });

    // 監聽伺服器回覆
    _speechService.serverResponseStream.listen((response) {
      _addMessage(text: response, isMe: false, isFinal: true);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage({required String text, required bool isMe, required bool isFinal}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isMe: isMe,
        isFinal: isFinal,
        time: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _updateLastMessage({required String text, required bool isFinal}) {
    if (_messages.isNotEmpty && !_messages.last.isFinal) {
      setState(() {
        _messages.removeLast();
        _messages.add(ChatMessage(
          text: text,
          isMe: true,
          isFinal: isFinal,
          time: DateTime.now(),
        ));
      });
      _scrollToBottom();
    } else {
      _addMessage(text: text, isMe: true, isFinal: isFinal);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _addMessage(text: text, isMe: true, isFinal: true);
      _messageController.clear();
      _speechService.sendText(text);
    }
  }

  void _makePhoneCall() async {
    final url = Uri.parse('tel:110');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('無法撥打電話'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('反詐騙諮詢'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: _makePhoneCall,
            tooltip: '撥打反詐專線110',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFFEDEDED),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildMessage(_messages[index]),
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isFinal = message.isFinal;
    final textColor = message.isMe 
      ? isFinal ? Colors.black : Colors.grey
      : Colors.black;
    final backgroundColor = message.isMe 
      ? isFinal ? const Color(0xFF95EC69) : const Color(0xFFD3D3D3)
      : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: message.isMe ? Radius.circular(0) : Radius.circular(12),
                  bottomRight: message.isMe ? Radius.circular(12) : Radius.circular(0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.time),
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF7D7D7D)),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(hintText: '輸入訊息...', border: InputBorder.none),
                      maxLines: 5,
                      minLines: 1,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  StreamBuilder<bool>(
                    stream: Stream.periodic(const Duration(milliseconds: 300), (_) => _speechService.isListening),
                    builder: (context, snapshot) {
                      final isListening = snapshot.data ?? false;
                      return IconButton(
                        icon: Icon(
                          isListening ? Icons.mic_off : Icons.mic,
                          color: isListening ? Colors.red : Colors.blue,
                        ),
                        onPressed: isListening ? _speechService.stopListening : _speechService.startListening,
                        tooltip: isListening ? '停止語音輸入' : '開始語音輸入',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF1976D2)),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final bool isFinal;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.isFinal,
    required this.time,
  });
}