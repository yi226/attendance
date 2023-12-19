import 'package:attendance/config/data.dart';
import 'package:attendance/share/socket.dart';
import 'package:attendance/style/__init__.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class SocketWidget extends StatefulWidget {
  final List<String> names;
  const SocketWidget({super.key, required this.names});

  @override
  State<SocketWidget> createState() => _SocketWidgetState();
}

class _SocketWidgetState extends State<SocketWidget> {
  final _info = NetworkInfo();
  final _server = SocketServer();
  String _ipAddress = 'Unknown';

  @override
  void initState() {
    super.initState();
    _initNetworkInfo();
  }

  @override
  void dispose() {
    _server.close();
    super.dispose();
  }

  Future<void> _initNetworkInfo() async {
    final ipAddress = await _info.getWifiIP();
    setState(() {
      _ipAddress = ipAddress ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: _server,
        builder: (context, child) {
          final keys = _server.connected.keys.toList();
          return SizedBox(
            height: 240,
            width: 300,
            child: Column(
              children: [
                const StText.big('附近设备'),
                const Divider(),
                StText.medium('Your IP Address: $_ipAddress'),
                const SizedBox(height: 10),
                if (_server.connected.isEmpty) ...[
                  const StText.medium('等待连接...'),
                  const SizedBox(height: 20),
                  const LinearProgressIndicator(),
                ],
                if (_server.connected.isNotEmpty) ...[
                  StText.medium('已连接: ${_server.connected.length}台设备'),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: keys.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.phone_android),
                          title: StText.medium(keys[index]),
                          trailing: Icon(_server.connected[keys[index]]
                                  ['received']
                              ? Icons.check
                              : Icons.close),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Expanded(
                    child: StText.medium('发送表名: ${widget.names.join(', ')}')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel')),
                    if (_server.connected.isNotEmpty && !_server.hasReceived)
                      FilledButton(
                          onPressed: () {
                            _server.send(
                                Data().exportSheets(widget.names).join('\n'));
                          },
                          child: const Text('Send')),
                    if (_server.hasReceived)
                      FilledButton(
                        onPressed: null,
                        child: Text('Received: ${_server.receivedCount}'),
                      ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
