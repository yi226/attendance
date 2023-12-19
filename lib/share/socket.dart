import 'package:attendance/config/data.dart';
import 'package:flutter/foundation.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:socket_io/socket_io.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketServer extends ChangeNotifier {
  late Server server;

  bool get hasReceived => _connected.values.any((e) => e['received']);
  bool get hasReceivedAll => _connected.values.every((e) => e['received']);
  int get receivedCount => _connected.values.where((e) => e['received']).length;

  final Map _connected = {};
  Map get connected => _connected;
  add(String name, dynamic client) {
    _connected[name] = {'client': client, 'received': false};
    notifyListeners();
  }

  remove(dynamic value) {
    _connected.removeWhere((key, v) => v['client'] == value);
    notifyListeners();
  }

  send(String value) {
    server.emit('data', value);
  }

  close() {
    server.close();
  }

  SocketServer() {
    server = Server();
    server.on('connection', (client) {
      client.on('connect_msg', (data) {
        add(data, client);
      });
      client.on('disconnect', (_) {
        remove(client);
      });
      client.on('received', (data) {
        _connected[data]['received'] = true;
        notifyListeners();
      });
    });
    server.listen(3000);
  }
}

class SocketClient extends ChangeNotifier {
  io.Socket? socket;

  bool _inited = false;
  bool get inited => _inited;
  set inited(bool value) {
    _inited = value;
    notifyListeners();
  }

  bool _connected = false;
  bool get connected => _connected;
  set connected(bool value) {
    _connected = value;
    notifyListeners();
  }

  String _content = '';
  String get content => _content;
  set content(String value) {
    _content = value;
    notifyListeners();
  }

  close() {
    socket?.dispose();
  }

  init() {
    socket?.dispose();
    _inited = true;
    _connected = false;
    _content = '';
    notifyListeners();
  }

  clear() {
    socket?.dispose();
    _inited = false;
    _connected = false;
    _content = '';
    notifyListeners();
  }

  connect(String ip, String name) {
    init();
    if (kDebugMode) {
      print('http://$ip:3000');
    }
    socket = io.io('http://$ip:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket?.onConnect((_) {
      connected = true;
      socket?.emit('connect_msg', name);
    });
    socket?.onDisconnect((_) {
      connected = false;
      if (kDebugMode) {
        print('disconnect');
      }
    });

    socket?.on('data', (data) async {
      if (kDebugMode) {
        print(data);
      }
      socket?.emit('received', name);
      final sheets = data.split('\n');
      final success = await Data().importSheets(sheets);
      if (success.isNotEmpty) {
        MyDialog.alert(
            'Imported sheets from $ip\n names: ${success.join(', ')}');
      }
    });
  }
}
