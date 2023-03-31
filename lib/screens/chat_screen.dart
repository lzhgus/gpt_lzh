import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_lzh/providers/chats_providers.dart';
import '../widgets/chat_item.dart';
import '../widgets/my_app_bar.dart';
import '../widgets/text_and_voice_field.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({Key? key}) : super(key: key);
  final GlobalKey _listViewKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBar(),
        body: Column(
          children: [
            Expanded(child: Consumer(builder: (context, ref, child) {
              final chats = ref.watch(chatProvider);
              return ListView.builder(
                key: _listViewKey,
                controller: _scrollController,
                itemCount: chats.length,
                itemBuilder: (context, index) => ChatItem(
                    text: chats[index].message, isMe: chats[index].isMe),
              );
            })),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: TextAndVoiceField(onNewChatItem: scrollToBottom),
            ),
            const SizedBox(height: 10),
          ],
        ));
  }

  void scrollToBottom() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }
}
