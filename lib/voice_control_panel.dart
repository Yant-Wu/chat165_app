import 'package:flutter/material.dart';
import 'voice_recognition_module.dart';

class VoiceControlPanel extends StatefulWidget {
  final Function(String)? onCommandRecognized;
  final Color? activeColor;
  final Color? inactiveColor;

  const VoiceControlPanel({
    super.key,
    this.onCommandRecognized,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
  });

  @override
  State<VoiceControlPanel> createState() => _VoiceControlPanelState();
}

class _VoiceControlPanelState extends State<VoiceControlPanel> {
  late final VoiceRecognitionModule _voiceModule;
  bool _voiceEnabled = false;
  String _lastResult = '';

  @override
  void initState() {
    super.initState();
    _voiceModule = VoiceRecognitionModule(
      onResult: _handleVoiceResult,
      onStart: () => setState(() {}),
      onStop: () => setState(() {}),
      onError: (error) => _showError(error),
    );
    _voiceModule.initialize();
  }

  void _handleVoiceResult(String text) {
    setState(() => _lastResult = text);
    widget.onCommandRecognized?.call(text);
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
    setState(() => _voiceEnabled = false);
  }

  @override
  void dispose() {
    _voiceModule.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('語音風險檢測'),
          subtitle: const Text('敲擊背面兩下啟動'),
          value: _voiceEnabled,
          onChanged: (value) => setState(() {
            _voiceEnabled = value;
            if (!value) _voiceModule.stopListening();
          }),
          secondary: Icon(
            Icons.mic,
            color: _voiceEnabled ? widget.activeColor : widget.inactiveColor,
          ),
        ),
        if (_voiceEnabled) ...[
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(
              _voiceModule.isListening ? Icons.mic : Icons.mic_off,
              color: _voiceModule.isListening 
                  ? widget.activeColor 
                  : widget.inactiveColor,
            ),
            title: Text(_voiceModule.isListening 
                ? '正在聆聽中...' 
                : '待機中 (敲擊背面兩下開始)'),
            subtitle: _lastResult.isNotEmpty
                ? Text('上次結果: $_lastResult')
                : null,
            onTap: () => _voiceModule.toggleListening(),
          ),
        ],
      ],
    );
  }
}