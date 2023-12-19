import 'package:attendance/share/socket.dart';
import 'package:attendance/style/__init__.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class SocketClientWidget extends StatefulWidget {
  const SocketClientWidget({super.key});

  @override
  State<SocketClientWidget> createState() => _SocketClientWidgetState();
}

class _SocketClientWidgetState extends State<SocketClientWidget> {
  final _controller = TextEditingController();
  final SocketClient _client = SocketClient();
  final _info = NetworkInfo();
  String _ipAddress = 'Unknown';

  @override
  void initState() {
    super.initState();
    _initNetworkInfo();
  }

  Future<void> _initNetworkInfo() async {
    final ipAddress = await _info.getWifiIP();
    setState(() {
      _ipAddress = ipAddress ?? 'Unknown';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _client,
      builder: (context, child) {
        return SizedBox(
          height: 240,
          width: 300,
          child: Column(
            children: [
              const StText.big('连接设备'),
              const Divider(),
              StText.medium('Your IP Address: $_ipAddress'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'IP地址',
                  hintText: '127.0.0.1',
                ),
              ),
              const SizedBox(height: 20),
              if (_client.inited && !_client.connected)
                const StText.medium('连接中...'),
              if (_client.inited && !_client.connected)
                const LinearProgressIndicator(),
              if (_client.inited && _client.connected)
                const StText.medium('连接成功，等待接收...'),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel')),
                  _client.inited
                      ? FilledButton(
                          onPressed: () {
                            _client.clear();
                          },
                          child: const Text('Disconnect'))
                      : FilledButton(
                          onPressed: () {
                            _client.connect(_controller.text, _ipAddress);
                          },
                          child: const Text('Connect')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
