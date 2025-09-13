# RGB Controller Mobile App

A Flutter mobile application for controlling ESP32-based RGB LED strips with music reactive capabilities and 200+ adjustable pattern steps.

## Features

- 🎨 **Real-time Color Control**: RGB color picker with live preview
- 🌈 **Multiple Display Modes**: Solid color, rainbow, custom patterns, music reactive
- 🎵 **Music Reactive**: LEDs respond to audio input from microphone
- ⚡ **256 Pattern Steps**: Highly customizable patterns with individual step control
- 📱 **Mobile Interface**: Intuitive touch controls optimized for mobile
- 🔌 **WiFi Communication**: Real-time WebSocket connection to ESP32
- 🔄 **Auto-reconnection**: Automatic reconnection when connection is lost
- 🎛️ **Advanced Controls**: Brightness, speed, sensitivity adjustments

## Screenshots

[Add screenshots of your app here]

## Requirements

### For Development
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio / VS Code
- Android device or emulator

### For Use
- ESP32 with RGB LED controller firmware
- WiFi network (same network as ESP32)
- Android 6.0+ or iOS 12.0+

## Installation

### Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mobile-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Release

1. **Android APK**
   ```bash
   flutter build apk --release
   ```

2. **Android App Bundle**
   ```bash
   flutter build appbundle --release
   ```

3. **iOS (requires Xcode)**
   ```bash
   flutter build ios --release
   ```

## Usage

### Initial Setup

1. **Connect ESP32 to WiFi**
   - Power on your ESP32 RGB controller
   - Connect to "ESP32-RGB-Controller" WiFi network
   - Navigate to 192.168.4.1 and configure your WiFi

2. **Connect Mobile App**
   - Open the RGB Controller app
   - Tap the connection panel to expand
   - Enter your ESP32's IP address
   - Tap "Connect"

### Controls

#### Color Tab
- **Color Picker**: Select any color using the color wheel
- **Brightness**: Adjust overall brightness (0-255)
- **Display Mode**: Choose between solid, rainbow, custom pattern, or music reactive
- **Speed**: Control animation speed for animated modes
- **Quick Colors**: Preset color buttons for common colors

#### Patterns Tab
- **Pattern Presets**: Quick access to rainbow, fire, ocean, and sunset patterns
- **Custom Editor**: Edit individual pattern steps (0-255)
- **Pattern Preview**: Visual representation of your custom pattern
- **Step Controls**: Fine-tune individual pattern steps

#### Music Tab
- **Music Reactive Toggle**: Enable/disable audio responsiveness
- **Sensitivity**: Adjust how sensitive the LEDs are to audio (0-100%)
- **Base Brightness**: Set the minimum brightness level
- **Pattern Speed**: Control how fast the reactive pattern moves
- **Quick Presets**: Low, medium, high sensitivity presets

#### Settings Tab
- **Device Information**: Connection status, IP address, current mode
- **Connection Settings**: Manual disconnect, auto-reconnect status
- **LED Configuration**: Hardware setup information
- **App Information**: Version, features, and protocol details

## Communication Protocol

The app communicates with the ESP32 via WebSocket on port 81. Commands are sent as JSON messages:

### Example Commands

```json
// Set RGB color
{"action": "set_color", "red": 255, "green": 0, "blue": 0}

// Set brightness
{"action": "set_brightness", "brightness": 150}

// Set mode
{"action": "set_mode", "mode": "music_reactive"}

// Set pattern step
{"action": "set_pattern_step", "step": 0, "value": 120}

// Toggle power
{"action": "toggle_power"}
```

## Dependencies

- **flutter_colorpicker**: Advanced color picker widget
- **syncfusion_flutter_sliders**: Professional slider controls
- **web_socket_channel**: WebSocket communication
- **provider**: State management
- **shared_preferences**: Local data storage
- **permission_handler**: Device permissions

## Architecture

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── rgb_config.dart      # Data models
├── services/
│   └── esp32_service.dart   # ESP32 communication service
├── screens/
│   └── main_screen.dart     # Main app screen
└── widgets/
    ├── connection_widget.dart      # Connection controls
    ├── color_control_widget.dart   # Color picker and controls
    ├── pattern_control_widget.dart # Pattern editor
    ├── music_control_widget.dart   # Music reactive controls
    └── settings_widget.dart        # Settings and info
```

## Troubleshooting

### Connection Issues
- Ensure ESP32 and phone are on the same WiFi network
- Check that ESP32 is powered on and running the firmware
- Verify the IP address is correct
- Try restarting the ESP32 if connection fails

### Performance Issues
- Close other apps to free up memory
- Ensure stable WiFi connection
- Check ESP32 power supply is adequate for your LED strip

### Audio Not Working
- Verify microphone is connected to ESP32 GPIO 34
- Adjust sensitivity settings in the Music tab
- Check that music reactive mode is enabled
- Ensure microphone is close to audio source

## Development

### Adding New Features

1. **Add new commands**: Extend the ESP32Service class
2. **New UI components**: Create widgets in the widgets/ directory
3. **State management**: Use Provider pattern for shared state
4. **Testing**: Add unit tests for new functionality

### Code Style

- Follow Flutter/Dart style guidelines
- Use meaningful variable and function names
- Comment complex logic
- Keep widgets focused and reusable

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please:
1. Check the troubleshooting section
2. Review the ESP32 firmware documentation
3. Open an issue on GitHub