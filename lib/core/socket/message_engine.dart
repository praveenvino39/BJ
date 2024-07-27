import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_cryptomask/core/model/message.dart';
import 'package:wallet_cryptomask/core/socket/socket_service.dart';

class MessageEngine extends ChangeNotifier {
  final SocketService _socketService = SocketService();

  List<ChatMessage> messages;

  MessageEngine({required this.messages}) {
    _socketService.updateMessages = updateMessages;
  }

  setToken(String token) {
    _socketService.token = token;
  }

  updateMessages(List<ChatMessage> messages) {
    this.messages = messages;
    notifyListeners();
  }

  connect() {
    _socketService.connect();
  }

  sendMessage(String message) {
    _socketService.sendMessage(message);
  }

  sendMessageWithAttachment(String message, Media attachment) {
    _socketService.sendMessageWithAttachment(message, attachment);
  }

  getChatFor(int id) {
    _socketService.getChatsByForId(id);
  }

  static MessageEngine getMessageEngine(BuildContext context,
      {bool listen = false}) {
    return Provider.of<MessageEngine>(context, listen: listen);
  }

  SocketService get socketService => _socketService;
}
