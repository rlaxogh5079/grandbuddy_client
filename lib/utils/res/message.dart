import 'package:web_socket_channel/web_socket_channel.dart';

class ChatSocket {
  final String matchUuid;
  final String senderUuid;
  final String receiverUuid;
  late WebSocketChannel channel;

  Function(String)? onMessageReceived;

  ChatSocket({
    required this.matchUuid,
    required this.senderUuid,
    required this.receiverUuid,
  }) {
    final url =
        'ws://3.27.71.121:8000/ws/chat/$matchUuid/$senderUuid/$receiverUuid';
    channel = WebSocketChannel.connect(Uri.parse(url));
    channel.stream.listen((data) {
      onMessageReceived?.call(data);
    });
  }

  void send(String message) {
    channel.sink.add(message);
  }

  void close() {
    channel.sink.close();
  }
}
