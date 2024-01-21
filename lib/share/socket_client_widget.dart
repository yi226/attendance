import 'package:attendance/share/socket.dart';
import 'package:attendance/style/style.dart';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
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
  BonsoirDiscovery? _discovery;
  final _servers = <String>[];

  @override
  void initState() {
    super.initState();
    _initMultiCastServiceAndNetworkInfo();
  }

  Future<void> _initMultiCastServiceAndNetworkInfo() async {
    final ipAddress = await _info.getWifiIP();
    setState(() {
      _ipAddress = ipAddress ?? 'Unknown';
    });
    _discovery = BonsoirDiscovery(type: '_attendance._tcp');
    await _discovery?.ready;
    _discovery!.eventStream!.listen((event) {
      // `eventStream` is not null as the discovery instance is "ready" !
      if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
        if (kDebugMode) {
          print('Service found : ${event.service?.toJson()}');
        }
        final name = event.service!.name.replaceAll('-', '.');
        if (name == _ipAddress) {
          return;
        }
        _servers.add(name);
        setState(() {});
      } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
        if (kDebugMode) {
          print('Service lost : ${event.service?.toJson()}');
        }
        final name = event.service!.name.replaceAll('-', '.');
        if (name == _ipAddress) {
          return;
        }
        _servers.remove(name);
        setState(() {});
      }
    });

    await _discovery?.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    _client.close();
    _discovery?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _client,
      builder: (context, child) {
        return SizedBox(
          height: 300,
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
              const SizedBox(height: 8),
              const StText.medium('附近设备: '),
              const SizedBox(height: 8),
              if (_servers.isNotEmpty)
                SizedBox(
                  height: 30,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var i = 0; i < _servers.length; i++)
                        ElevatedButton(
                          child: StText.normal(_servers[i]),
                          onPressed: () {
                            _controller.text = _servers[i];
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
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
