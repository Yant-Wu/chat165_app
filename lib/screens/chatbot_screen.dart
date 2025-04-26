import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 初始化歡迎訊息
    _messages.add(ChatMessage(
      text: "您好！我是反詐騙助手，請問有什麼可以幫您？",
      isMe: false,
      time: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    // 添加用戶訊息
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isMe: true,
        time: DateTime.now(),
      ));
    });

    // 滾動到底部
    _scrollToBottom();

    // 模擬機器人回覆
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(ChatMessage(
          text: _getReply(message),
          isMe: false,
          time: DateTime.now(),
        ));
      });
      _scrollToBottom();
    });
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

  String _getReply(String message) {
    // 簡單回覆邏輯，實際應用中替換為API呼叫
    if (message.contains("詐騙")) {
      return "如果您懷疑遇到詐騙，請立即停止所有資金操作，並撥打反詐專線110諮詢。";
    } else if (message.contains("電話")) {
      return "可疑電話通常有以下特徵：\n1. 自稱公檢法要求轉賬\n2. 聲稱中獎需先交稅\n3. 索要驗證碼或密碼";
    }
    return "我已收到您的訊息，正在為您查詢相關資訊...";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('反詐騙諮詢'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1976D2), 
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEDEDED), // 微信聊天背景色
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isMe
                    ? const Color(0xFF95EC69) // 用戶訊息綠色
                    : Colors.white, // 機器人訊息白色
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(message.isMe ? 12 : 0),
                  bottomRight: Radius.circular(message.isMe ? 0 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.time),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
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
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
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
                      decoration: const InputDecoration(
                        hintText: '輸入訊息...',
                        border: InputBorder.none,
                      ),
                      maxLines: 5,
                      minLines: 1,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined,
                        color: Color(0xFF7D7D7D)),
                    onPressed: () {},
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
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}