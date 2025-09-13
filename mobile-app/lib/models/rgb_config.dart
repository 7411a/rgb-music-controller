class RGBConfig {
  int red;
  int green;
  int blue;
  int brightness;
  int speed;
  int sensitivity;
  String mode;
  bool enabled;
  String ip;
  List<int> patternSteps;

  RGBConfig({
    this.red = 255,
    this.green = 255,
    this.blue = 255,
    this.brightness = 100,
    this.speed = 50,
    this.sensitivity = 50,
    this.mode = 'music_reactive',
    this.enabled = true,
    this.ip = '',
    List<int>? patternSteps,
  }) : patternSteps = patternSteps ?? List.generate(256, (index) => index);

  factory RGBConfig.fromJson(Map<String, dynamic> json) {
    return RGBConfig(
      red: json['red'] ?? 255,
      green: json['green'] ?? 255,
      blue: json['blue'] ?? 255,
      brightness: json['brightness'] ?? 100,
      speed: json['speed'] ?? 50,
      sensitivity: json['sensitivity'] ?? 50,
      mode: json['mode'] ?? 'music_reactive',
      enabled: json['enabled'] ?? true,
      ip: json['ip'] ?? '',
      patternSteps: json['pattern_steps'] != null 
          ? List<int>.from(json['pattern_steps'])
          : List.generate(256, (index) => index),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'red': red,
      'green': green,
      'blue': blue,
      'brightness': brightness,
      'speed': speed,
      'sensitivity': sensitivity,
      'mode': mode,
      'enabled': enabled,
      'ip': ip,
      'pattern_steps': patternSteps,
    };
  }

  RGBConfig copyWith({
    int? red,
    int? green,
    int? blue,
    int? brightness,
    int? speed,
    int? sensitivity,
    String? mode,
    bool? enabled,
    String? ip,
    List<int>? patternSteps,
  }) {
    return RGBConfig(
      red: red ?? this.red,
      green: green ?? this.green,
      blue: blue ?? this.blue,
      brightness: brightness ?? this.brightness,
      speed: speed ?? this.speed,
      sensitivity: sensitivity ?? this.sensitivity,
      mode: mode ?? this.mode,
      enabled: enabled ?? this.enabled,
      ip: ip ?? this.ip,
      patternSteps: patternSteps ?? List<int>.from(this.patternSteps),
    );
  }
}

class ConnectionStatus {
  final bool isConnected;
  final String message;
  final String? ip;

  ConnectionStatus({
    required this.isConnected,
    required this.message,
    this.ip,
  });
}

enum ControlMode {
  color,
  patterns,
  music,
  settings,
}