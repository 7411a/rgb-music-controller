import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/esp32_service.dart';

class ConnectionWidget extends StatefulWidget {
  const ConnectionWidget({super.key});

  @override
  State<ConnectionWidget> createState() => _ConnectionWidgetState();
}

class _ConnectionWidgetState extends State<ConnectionWidget> {
  final TextEditingController _ipController = TextEditingController();
  bool _showConnectionForm = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ESP32Service>(
      builder: (context, esp32Service, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: esp32Service.isConnected ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    esp32Service.isConnected ? Icons.wifi : Icons.wifi_off,
                    color: esp32Service.isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      esp32Service.connectionStatus.message,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_showConnectionForm ? Icons.expand_less : Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        _showConnectionForm = !_showConnectionForm;
                      });
                    },
                  ),
                ],
              ),
              if (_showConnectionForm) ...[
                const SizedBox(height: 16),
                const Text(
                  'ESP32 IP Address:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ipController,
                        decoration: const InputDecoration(
                          hintText: '192.168.1.100',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_ipController.text.isNotEmpty) {
                          esp32Service.connect(_ipController.text);
                          setState(() {
                            _showConnectionForm = false;
                          });
                        }
                      },
                      child: const Text('Connect'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Make sure your ESP32 is powered on and connected to the same WiFi network.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }
}