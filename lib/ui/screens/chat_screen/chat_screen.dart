// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:io';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:jazzicon/jazzicon.dart';
import 'package:provider/provider.dart';
import 'package:routerino/routerino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:wallet_cryptomask/core/remote/http.dart';
import 'package:wallet_cryptomask/core/remote/response-model/register_user.dart';
import 'package:wallet_cryptomask/core/socket/message_engine.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_button.dart';
import 'package:wallet_cryptomask/ui/shared/wallet_text.dart';
import 'package:wallet_cryptomask/ui/utils/spaces.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final user = Get.find<User>();

  ChatUser? me;

  List<ChatMessage> messages = <ChatMessage>[];

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      if (context.mounted) {
        showSendFileConfirmation(
          name: result.files.single.name,
          onSend: (message) async {
            if (user.token != null) {
              final media =
                  await uploadFile(user.token!, file, result.files.single.name);
              if (media != null && context.mounted) {
                await MessageEngine.getMessageEngine(context)
                    .sendMessageWithAttachment(message, media);
                context.pop();
              }
            }
          },
        );
      }
    }
  }

  showSendFileConfirmation(
      {required String name, required Function(String message) onSend}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const WalletText(
          localizeKey: 'confirmation',
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const WalletText(
              localizeKey: 'fileSendAdminDialog',
            ),
            addHeight(SpacingSize.m),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                  color: kPrimaryColor.withAlpha(70),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.attach_file),
                  addWidth(SpacingSize.s),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            addHeight(SpacingSize.m),
            Row(
              children: [
                Expanded(
                  child: WalletButton(
                    onPressed: () => context.pop(),
                    localizeKey: 'cancel',
                  ),
                ),
                addHeight(SpacingSize.l),
                Expanded(
                  child: WalletButton(
                    type: WalletButtonType.filled,
                    onPressed: () => onSend(""),
                    localizeKey: 'send',
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

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

  void onMediaPressHandler(ChatMedia media) {
    launchUrl(Uri.parse(media.url),
        mode: LaunchMode.externalApplication,
        webViewConfiguration: WebViewConfiguration(
            headers: {'Authorization': 'Bearer ${user.token}'}));
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
            addWidth(SpacingSize.m),
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
              messageOptions: MessageOptions(
                showTime: true,
                onTapMedia: onMediaPressHandler,
              ),
              inputOptions: InputOptions(
                alwaysShowSend: true,
                textCapitalization: TextCapitalization.sentences,
                sendButtonBuilder: (send) => Row(
                  children: [
                    IconButton(
                        onPressed: pickFile,
                        icon: const Icon(Icons.attach_file)),
                    IconButton(onPressed: send, icon: const Icon(Icons.send)),
                  ],
                ),
              ),
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
