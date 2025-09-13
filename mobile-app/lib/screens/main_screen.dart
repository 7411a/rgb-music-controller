import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/esp32_service.dart';
import '../models/rgb_config.dart';
import '../widgets/connection_widget.dart';
import '../widgets/color_control_widget.dart';
import '../widgets/pattern_control_widget.dart';
import '../widgets/music_control_widget.dart';
import '../widgets/settings_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ControlMode _currentMode = ControlMode.color;

  @override
  Widget build(BuildContext context) {
    return Consumer<ESP32Service>(
      builder: (context, esp32Service, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('RGB Controller'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  esp32Service.config.enabled ? Icons.power : Icons.power_off,
                  color: esp32Service.config.enabled ? Colors.green : Colors.red,
                ),
                onPressed: esp32Service.togglePower,
              ),
            ],
          ),
          body: Column(
            children: [
              // Connection Status
              const ConnectionWidget(),
              
              // Mode Selector
              _buildModeSelector(),
              
              // Current Mode Content
              Expanded(
                child: _buildCurrentModeWidget(esp32Service),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigation(),
        );
      },
    );
  }

  Widget _buildModeSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildModeTab(ControlMode.color, Icons.palette, 'Color'),
          _buildModeTab(ControlMode.patterns, Icons.gradient, 'Patterns'),
          _buildModeTab(ControlMode.music, Icons.music_note, 'Music'),
          _buildModeTab(ControlMode.settings, Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildModeTab(ControlMode mode, IconData icon, String label) {
    final isSelected = _currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentModeWidget(ESP32Service esp32Service) {
    switch (_currentMode) {
      case ControlMode.color:
        return const ColorControlWidget();
      case ControlMode.patterns:
        return const PatternControlWidget();
      case ControlMode.music:
        return const MusicControlWidget();
      case ControlMode.settings:
        return const SettingsWidget();
    }
  }

  Widget _buildBottomNavigation() {
    return Consumer<ESP32Service>(
      builder: (context, esp32Service, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Connection Status Indicator
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: esp32Service.isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  esp32Service.connectionStatus.message,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Current Mode Indicator
              Text(
                'Mode: ${esp32Service.config.mode}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}