import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rgb_config.dart';

class ESP32Service extends ChangeNotifier {
  WebSocketChannel? _channel;
  RGBConfig _config = RGBConfig();
  ConnectionStatus _connectionStatus = ConnectionStatus(
    isConnected: false,
    message: 'Not connected',
  );
  
  String _lastKnownIP = '';
  Timer? _reconnectTimer;
  bool _isReconnecting = false;

  RGBConfig get config => _config;
  ConnectionStatus get connectionStatus => _connectionStatus;
  bool get isConnected => _connectionStatus.isConnected;

  ESP32Service() {
    _loadLastKnownIP();
  }

  Future<void> _loadLastKnownIP() async {
    final prefs = await SharedPreferences.getInstance();
    _lastKnownIP = prefs.getString('last_esp32_ip') ?? '';
    if (_lastKnownIP.isNotEmpty) {
      connect(_lastKnownIP);
    }
  }

  Future<void> _saveLastKnownIP(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_esp32_ip', ip);
    _lastKnownIP = ip;
  }

  Future<void> connect(String ip) async {
    if (_isReconnecting) return;
    
    _updateConnectionStatus(false, 'Connecting to $ip...');
    
    try {
      _channel?.sink.close();
      
      final uri = Uri.parse('ws://$ip:81');
      _channel = WebSocketChannel.connect(uri);
      
      await _channel!.ready;
      
      _updateConnectionStatus(true, 'Connected to $ip', ip);
      await _saveLastKnownIP(ip);
      
      _listenToMessages();
      _requestCurrentConfig();
      
    } catch (e) {
      _updateConnectionStatus(false, 'Failed to connect: ${e.toString()}');
      _startReconnectTimer();
    }
  }

  void _listenToMessages() {
    _channel?.stream.listen(
      (message) {
        try {
          final data = json.decode(message);
          _handleMessage(data);
        } catch (e) {
          debugPrint('Error parsing message: $e');
        }
      },
      onError: (error) {
        _updateConnectionStatus(false, 'Connection error: $error');
        _startReconnectTimer();
      },
      onDone: () {
        _updateConnectionStatus(false, 'Connection closed');
        _startReconnectTimer();
      },
    );
  }

  void _handleMessage(Map<String, dynamic> data) {
    final type = data['type'];
    
    if (type == 'config') {
      _config = RGBConfig.fromJson(data);
      notifyListeners();
    } else if (type == 'status') {
      _config = _config.copyWith(
        enabled: data['enabled'],
        mode: data['mode'],
        brightness: data['brightness'],
      );
      notifyListeners();
    }
  }

  void _updateConnectionStatus(bool isConnected, String message, [String? ip]) {
    _connectionStatus = ConnectionStatus(
      isConnected: isConnected,
      message: message,
      ip: ip,
    );
    notifyListeners();
  }

  void _startReconnectTimer() {
    if (_isReconnecting || _lastKnownIP.isEmpty) return;
    
    _isReconnecting = true;
    _reconnectTimer?.cancel();
    
    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_connectionStatus.isConnected) {
        timer.cancel();
        _isReconnecting = false;
        return;
      }
      
      _updateConnectionStatus(false, 'Reconnecting to $_lastKnownIP...');
      connect(_lastKnownIP);
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _isReconnecting = false;
    _channel?.sink.close();
    _updateConnectionStatus(false, 'Disconnected');
  }

  // Control Methods
  void _sendCommand(Map<String, dynamic> command) {
    if (!_connectionStatus.isConnected) return;
    
    try {
      final message = json.encode(command);
      _channel?.sink.add(message);
    } catch (e) {
      debugPrint('Error sending command: $e');
    }
  }

  void setColor(int red, int green, int blue) {
    _config = _config.copyWith(red: red, green: green, blue: blue);
    _sendCommand({
      'action': 'set_color',
      'red': red,
      'green': green,
      'blue': blue,
    });
    notifyListeners();
  }

  void setBrightness(int brightness) {
    _config = _config.copyWith(brightness: brightness);
    _sendCommand({
      'action': 'set_brightness',
      'brightness': brightness,
    });
    notifyListeners();
  }

  void setSpeed(int speed) {
    _config = _config.copyWith(speed: speed);
    _sendCommand({
      'action': 'set_speed',
      'speed': speed,
    });
    notifyListeners();
  }

  void setSensitivity(int sensitivity) {
    _config = _config.copyWith(sensitivity: sensitivity);
    _sendCommand({
      'action': 'set_sensitivity',
      'sensitivity': sensitivity,
    });
    notifyListeners();
  }

  void setMode(String mode) {
    _config = _config.copyWith(mode: mode);
    _sendCommand({
      'action': 'set_mode',
      'mode': mode,
    });
    notifyListeners();
  }

  void setPatternStep(int step, int value) {
    if (step >= 0 && step < _config.patternSteps.length) {
      _config.patternSteps[step] = value;
      _sendCommand({
        'action': 'set_pattern_step',
        'step': step,
        'value': value,
      });
      notifyListeners();
    }
  }

  void setPatternSteps(List<int> steps) {
    _config = _config.copyWith(patternSteps: steps);
    _sendCommand({
      'action': 'set_pattern_steps',
      'steps': steps,
    });
    notifyListeners();
  }

  void togglePower() {
    _config = _config.copyWith(enabled: !_config.enabled);
    _sendCommand({
      'action': 'toggle_power',
    });
    notifyListeners();
  }

  void _requestCurrentConfig() {
    _sendCommand({
      'action': 'get_config',
    });
  }

  // Pattern Presets
  void setRainbowPattern() {
    final steps = List.generate(256, (index) => index);
    setPatternSteps(steps);
  }

  void setFirePattern() {
    final steps = <int>[];
    for (int i = 0; i < 256; i++) {
      // Fire pattern: red to yellow to red
      if (i < 85) {
        steps.add(i ~/ 85 * 60); // Red to orange
      } else if (i < 170) {
        steps.add(60 + (i - 85) ~/ 85 * 30); // Orange to yellow
      } else {
        steps.add(90 - (i - 170) ~/ 86 * 90); // Yellow back to red
      }
    }
    setPatternSteps(steps);
  }

  void setOceanPattern() {
    final steps = <int>[];
    for (int i = 0; i < 256; i++) {
      // Ocean pattern: blue variations
      steps.add(160 + (i ~/ 32) * 10);
    }
    setPatternSteps(steps);
  }

  void setSunsetPattern() {
    final steps = <int>[];
    for (int i = 0; i < 256; i++) {
      // Sunset pattern: purple to orange to yellow
      if (i < 128) {
        steps.add(280 - i ~/ 4); // Purple to orange
      } else {
        steps.add(240 - (i - 128) ~/ 4); // Orange to yellow
      }
    }
    setPatternSteps(steps);
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}