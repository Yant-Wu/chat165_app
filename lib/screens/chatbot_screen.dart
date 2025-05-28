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

    _addMessage(
      text: "您好！我是反詐騙助手，請問有什麼可以幫您？",
      isMe: false,
      isFinal: true,
    );

    _speechService.textStream.listen((text) {
      if (text.startsWith('正在聆聽')) {
        _addMessage(text: text, isMe: true, isFinal: false);
      } else if (text.startsWith('語音辨識錯誤') || text.startsWith('網路錯誤')) {
        _addMessage(text: text, isMe: false, isFinal: true);
      } else if (text.isNotEmpty && !text.startsWith('正在發送') && !text.startsWith('伺服器回覆')) {
        _updateLastMessage(text: text, isFinal: false);
      }
    });

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('反詐騙諮詢'),
        centerTitle: false,
        backgroundColor: Colors.grey[50],
        elevation: 0.5,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.blue.shade700),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: _makePhoneCall,
            tooltip: '撥打反詐專線110',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[100],
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
    final isMe = message.isMe;
    final isFinal = message.isFinal;

    final Color myMessageColor = Colors.blue.shade600;
    final Color otherMessageColor = Colors.grey.shade200;
    final Color myTextColor = Colors.white;
    final Color otherTextColor = Colors.black87;
    final Color interimTextColor = Colors.grey.shade700;

    final textColor = isMe ? (isFinal ? myTextColor : interimTextColor) : otherTextColor;
    final backgroundColor = isMe ? (isFinal ? myMessageColor : Colors.grey.shade300) : otherMessageColor;

    final BorderRadius messageBorderRadius = BorderRadius.circular(18);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: messageBorderRadius,
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(fontSize: 16.5, color: textColor, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatTime(message.time),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 11,
                    ),
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
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[300]!, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: '輸入訊息...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          maxLines: 5,
                          minLines: 1,
                          style: const TextStyle(fontSize: 16),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    StreamBuilder<bool>(
                      stream: Stream.periodic(const Duration(milliseconds: 300), (_) => _speechService.isListening),
                      builder: (context, snapshot) {
                        final isListening = snapshot.data ?? false;
                        return IconButton(
                          icon: Icon(
                            isListening ? Icons.mic_off_outlined : Icons.mic_none_outlined,
                            color: isListening ? Colors.red.shade600 : Colors.blue.shade700,
                            size: 26,
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
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send_rounded, color: Colors.blue.shade700, size: 26),
              onPressed: _sendMessage,
              tooltip: '送出訊息',
            ),
          ],
        ),
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
