import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:jazzicon/jazzicon.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/core/remote/response-model/register_user.dart';
import 'package:wallet_cryptomask/core/socket/message_engine.dart';
import 'package:wallet_cryptomask/core/socket/socket_service.dart';
import 'package:wallet_cryptomask/utils.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final user = Get.find<User>();

  ChatUser? me;

  List<ChatMessage> messages = <ChatMessage>[];

  @override
  void initState() {
    super.initState();

    setState(() {
      me = ChatUser(
        id: user.address,
        firstName: showEllipse(user.address),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: 'avatar',
              child: Jazzicon.getIconWidget(
                  Jazzicon.getJazziconData(30, address: "Admin")),
            ),
            const SizedBox(
              width: 20,
            ),
            const Expanded(
              child: Text(
                "Admin",
                maxLines: 2,
                // overflow: TextOverflow.clip,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      body: me != null
          ? DashChat(
              inputOptions: const InputOptions(
                  textCapitalization: TextCapitalization.sentences),
              messageListOptions: const MessageListOptions(),
              currentUser: me!,
              onSend: (ChatMessage message) {
                final token = user.token;
                if (token != null) {
                  MessageEngine.getMessageEngine(context)
                      .sendMessage(message.text);
                }
              },
              messages: Provider.of<MessageEngine>(context).messages,
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
