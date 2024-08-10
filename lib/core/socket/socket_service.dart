// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:wallet_cryptomask/config.dart';
import 'package:wallet_cryptomask/core/model/message.dart';
import 'package:wallet_cryptomask/ui/utils/ui_utils.dart';

class SocketEvent {
  static String update_user = "update_user";
  static String private_message = "private_message";
  static String user_get_chat = "user_get_chat";
}

class SocketService {
  Function(List<ChatMessage>)? updateMessages;
  String? token;
  io.Socket? _socket;
  StreamController<String>? messageController;
  int? forId;

  void connect() {
    _socket = io.io(
        baseUrl,
        io.OptionBuilder()
            .setExtraHeaders({'authorization': token})
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .build());

    if (!_socket!.connected) {
      _socket?.connect();
    }

    _socket?.onConnect((_) {
      _socket?.emit(SocketEvent.update_user);
      if (forId != null) {
        getChatsByForId(forId!);
      }
    });

    _socket?.on(SocketEvent.private_message, (data) {
      if (forId != null) {
        getChatsByForId(forId!);
      }
    });

    _socket?.on(SocketEvent.user_get_chat, (data) {
      List<ChatMessage> chats = [];
      for (dynamic chat in data) {
        final message = Message.fromJson(chat);
        chats.add(
          ChatMessage(
            text: message.message,
            medias: message.attachment != null
                ? [
                    ChatMedia(
                      url: message.attachment!.url,
                      fileName: message.attachment!.fileName,
                      type: MediaType.parse(message.attachment!.mediaType),
                    )
                  ]
                : null,
            status: MessageStatus.received,
            user: ChatUser(
                firstName: message.isAdminMessage
                    ? "Admin"
                    : showEllipse(message.user.address),
                id: message.isAdminMessage ? "admin" : message.user.address),
            createdAt: message.timestamp,
          ),
        );
      }
      updateMessages?.call([...chats]);
    });

    _socket?.onDisconnect((_) {});
  }

  void getChatsByForId(int forId) {
    this.forId = forId;
    _socket?.emit(SocketEvent.user_get_chat, forId);
  }

  void sendMessage(String message) {
    final messageTemplate = {
      "timestamp": DateTime.now().toString(),
      "message": message,
      "forId": forId,
    };
    _socket?.emit(SocketEvent.private_message, messageTemplate);
  }

  void sendMessageWithAttachment(String message, Media media) {
    final messageTemplate = {
      "timestamp": DateTime.now().toString(),
      "message": message,
      "attachment": media.toJson(),
      "forId": forId,
    };
    _socket?.emit(SocketEvent.private_message, messageTemplate);
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.close();
    messageController?.close();
  }
}
