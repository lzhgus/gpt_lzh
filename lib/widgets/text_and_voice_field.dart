import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_lzh/models/chat_model.dart';
import 'package:gpt_lzh/services/ai_handler.dart';
import 'package:gpt_lzh/services/voice_handler.dart';
import 'package:gpt_lzh/widgets/toggle_button.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../providers/chats_providers.dart';
import '../providers/tts_provider.dart';

enum InputMode {
  text,
  voice,
}

class TextAndVoiceField extends ConsumerStatefulWidget {
  final Function() onNewChatItem;
  TextAndVoiceField({required this.onNewChatItem, Key? key}) : super(key: key);

  @override
  ConsumerState<TextAndVoiceField> createState() => _TextAndVoiceFieldState();
}

class _TextAndVoiceFieldState extends ConsumerState<TextAndVoiceField> {
  InputMode _inputMode = InputMode.voice;
  final _messageController = TextEditingController();
  final AIHandler _openAI = AIHandler();
  final VoiceHandler voiceHandler = VoiceHandler();
  final FlutterTts _flutterTts = FlutterTts();
  var _isReplying = false;
  var _isListening = false;

  @override
  void initState() {
    voiceHandler.initSpeech();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _openAI.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            onChanged: (value) {
              value.isNotEmpty
                  ? setInputMode(InputMode.text)
                  : setInputMode(InputMode.voice);
            },
            cursorColor: Theme.of(context).colorScheme.onPrimary,
            decoration: InputDecoration(
              hintText: 'Type a message',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimary),
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 06),
        ToggleButton(
          isListening: _isListening,
          inputMode: _inputMode,
          isReplying: _isReplying,
          sendTextMessage: () {
            final message = _messageController.text;
            _messageController.clear();
            sendTextMessage(message);
          },
          sendVoiceMessage: sendVoiceMessage,
        ),
      ],
    );
  }

  void setInputMode(InputMode inputMode) {
    setState(() {
      _inputMode = inputMode;
    });
  }

  void sendTextMessage(String message) async {
    setReplying(true);
    addToList(message, true, DateTime.now().toString());
    addToList('Taping..', false, 'typing');
    setInputMode(InputMode.voice);
    final aiResponse = await _openAI.getResponse(message);

    removeTyping();
    addToList(aiResponse, false, DateTime.now().toString());

    final enableTts = ref.read(enableTtsProvider);
    if (enableTts) {
      _flutterTts.speak(aiResponse);
    }

    widget.onNewChatItem?.call();
    setReplying(false);
  }

  void setReplying(bool isReplying) {
    setState(() {
      _isReplying = isReplying;
    });
  }

  void removeTyping() {
    final chats = ref.read(chatProvider.notifier);
    chats.removeTyping();
  }

  void addToList(String message, bool isMe, String id) {
    final chats = ref.read(chatProvider.notifier);
    chats.add(ChatModel(id: id, message: message, isMe: isMe));
  }

  void sendVoiceMessage() async {
    if (voiceHandler.speechToText.isListening) {
      await voiceHandler.stopListening();
      setListening(false);
    } else {
      setListening(true);
      final result = await voiceHandler.startListening();
      setListening(false);
      sendTextMessage(result);
    }
  }

  void setListening(bool isListening) {
    setState(() {
      _isListening = isListening;
    });
  }
}
