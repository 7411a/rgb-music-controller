import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/esp32_service.dart';

class SettingsWidget extends StatelessWidget {
  const SettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ESP32Service>(
      builder: (context, esp32Service, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device Information
              _buildSectionTitle('Device Information'),
              _buildDeviceInfo(esp32Service, context),
              
              const SizedBox(height: 24),
              
              // Connection Settings
              _buildSectionTitle('Connection Settings'),
              _buildConnectionSettings(esp32Service, context),
              
              const SizedBox(height: 24),
              
              // LED Strip Settings
              _buildSectionTitle('LED Strip Configuration'),
              _buildLEDSettings(context),
              
              const SizedBox(height: 24),
              
              // App Information
              _buildSectionTitle('App Information'),
              _buildAppInfo(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDeviceInfo(ESP32Service esp32Service, BuildContext context) {
    final config = esp32Service.config;
    final connectionStatus = esp32Service.connectionStatus;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Status', 
            esp32Service.isConnected ? 'Connected' : 'Disconnected',
            esp32Service.isConnected ? Colors.green : Colors.red,
          ),
          
          if (connectionStatus.ip != null)
            _buildInfoRow('IP Address', connectionStatus.ip!, Colors.blue),
          
          _buildInfoRow('Current Mode', config.mode, Colors.purple),
          
          _buildInfoRow('Power State', 
            config.enabled ? 'On' : 'Off',
            config.enabled ? Colors.green : Colors.grey,
          ),
          
          _buildInfoRow('Brightness', '${config.brightness}/255', Colors.orange),
          
          _buildInfoRow('Pattern Steps', '${config.patternSteps.length}', Colors.cyan),
        ],
      ),
    );
  }

  Widget _buildConnectionSettings(ESP32Service esp32Service, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Auto-reconnect'),
              ),
              Switch(
                value: true, // Always enabled for now
                onChanged: null, // Disabled
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ElevatedButton(
            onPressed: esp32Service.isConnected 
                ? esp32Service.disconnect 
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Disconnect'),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'The app will automatically try to reconnect if the connection is lost.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLEDSettings(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'These settings are configured in the ESP32 firmware:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow('LED Type', 'WS2812B', Colors.blue),
          _buildInfoRow('Data Pin', 'GPIO 5', Colors.blue),
          _buildInfoRow('Max LEDs', '300', Colors.blue),
          _buildInfoRow('Update Rate', '50 Hz', Colors.blue),
          _buildInfoRow('Microphone Pin', 'GPIO 34', Colors.blue),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: const Text(
              'To change these settings, modify the platformio.ini file in the ESP32 firmware and re-upload.',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('App Version', '1.0.0', Colors.green),
          _buildInfoRow('Protocol', 'WebSocket', Colors.green),
          _buildInfoRow('Port', '81', Colors.green),
          _buildInfoRow('Framework', 'Flutter', Colors.green),
          
          const SizedBox(height: 16),
          
          const Text(
            'Features:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 8),
          
          _buildFeatureItem('✓ Real-time RGB color control'),
          _buildFeatureItem('✓ 256-step custom patterns'),
          _buildFeatureItem('✓ Music reactive mode'),
          _buildFeatureItem('✓ Multiple animation modes'),
          _buildFeatureItem('✓ WiFi connectivity'),
          _buildFeatureItem('✓ Auto-reconnection'),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: const Text(
              'This app controls ESP32-based RGB LED strips with real-time communication via WebSocket.',
              style: TextStyle(fontSize: 12, color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        feature,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}