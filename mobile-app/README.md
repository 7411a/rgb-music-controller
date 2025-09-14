# B2SRGB Controller Mobile App

A Flutter mobile application for controlling ESP32 WROOM-32D based RGB LED strips with music reactive capabilities and 256 adjustable pattern steps.

## Features

- 🎨 **Real-time Color Control**: RGB color picker with live preview
- 🌈 **Multiple Display Modes**: 11 different lighting modes including solid color, rainbow, custom patterns, music reactive
- 🎵 **Music Reactive**: LEDs respond to audio input from microphone
- ⚡ **256 Pattern Steps**: Highly customizable patterns with individual step control
- 📱 **Mobile Interface**: Intuitive touch controls optimized for mobile (Thai language)
- 🔌 **WiFi Communication**: Real-time WebSocket connection to ESP32 WROOM-32D
- 🔄 **Auto-reconnection**: Automatic reconnection when connection is lost
- 🎛️ **Advanced Controls**: Brightness, speed, sensitivity adjustments
- 🎨 **10 Pattern Presets**: Pre-configured beautiful patterns (Fire, Ocean, Sunset, etc.)

## Screenshots

[Add screenshots of your app here]

## Requirements

### Hardware
- ESP32 WROOM-32D Development Board
- WS2812B RGB LED Strip (up to 300 LEDs)
- MAX4466 Microphone Module (for music reactive mode)
- 5V Power Supply

### For Development
- Flutter SDK 3.0.0 or higher
- Dart 3.0.0 or higher
- Android Studio / VS Code
- Android device or emulator

### For Use
- ESP32 WROOM-32D with RGB LED controller firmware
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

1. **Connect ESP32 WROOM-32D to WiFi**
   - Power on your ESP32 WROOM-32D RGB controller
   - Connect to "RGB-Controller-Setup" WiFi network (password: 12345678)
   - Navigate to http://192.168.4.1 and configure your WiFi

2. **Connect Mobile App**
   - Open the B2SRGB Controller app
   - Tap the connection panel to expand
   - Enter your ESP32's IP address
   - Tap "Connect"

### Controls

#### Color Tab (สี)
- **Color Picker**: Select any color using the color wheel
- **Brightness**: Adjust overall brightness (0-255)
- **Display Mode**: Choose between 11 different modes including solid, rainbow, custom pattern, or music reactive
- **Speed**: Control animation speed for animated modes
- **Quick Colors**: Preset color buttons for common colors

#### Patterns Tab (รูปแบบ)
- **Pattern Presets**: 10 beautiful presets (Rainbow, Fire, Ocean, Sunset, Forest, Purple Storm, Candy, Chrome, Neon Club, Warm White)
- **Custom Editor**: Edit individual pattern steps (0-255)
- **Pattern Preview**: Visual representation of your custom pattern
- **Step Controls**: Fine-tune individual pattern steps

#### Music Tab (เสียงเพลง)
- **Music Reactive Toggle**: Enable/disable audio responsiveness
- **Sensitivity**: Adjust how sensitive the LEDs are to audio (0-100%)
- **Base Brightness**: Set the minimum brightness level
- **Pattern Speed**: Control how fast the reactive pattern moves
- **Quick Presets**: Low, medium, high sensitivity presets

#### Settings Tab (การตั้งค่า)
- **Device Information**: Connection status, IP address, current mode
- **Connection Settings**: Manual disconnect, auto-reconnect status
- **LED Configuration**: Hardware setup information for ESP32 WROOM-32D
- **App Information**: Version, features, and protocol details

## Communication Protocol

The app communicates with the ESP32 WROOM-32D via WebSocket on port 81. Commands are sent as JSON messages:

### Example Commands

```json
// Set RGB color
{"action": "set_color", "red": 255, "green": 0, "blue": 0}

// Set brightness
{"action": "set_brightness", "brightness": 150}

// Set mode (11 available modes)
{"action": "set_mode", "mode": "music_reactive"}

// Load pattern preset (0-9)
{"action": "load_preset", "preset": 1}

// Set pattern step
{"action": "set_pattern_step", "step": 0, "value": 120}

// Toggle power
{"action": "toggle_power"}

// Get preset list
{"action": "get_presets"}
```

## 11 Available LED Modes

1. **solid** - Single solid color
2. **rainbow** - Classic rainbow wave effect  
3. **custom_pattern** - User-defined 256-step pattern
4. **music_reactive** - Audio-responsive lighting
5. **color_cycle** - Cycle through all HSV colors smoothly
6. **rainbow_wave** - Rainbow wave flowing across LED strip
7. **color_chase** - Colored bands chasing across LEDs
8. **spectrum_analyzer** - Frequency-based color zones (bass/mid/treble)
9. **all_colors_demo** - Display all 20 predefined colors simultaneously  
10. **full_spectrum** - Complete HSV spectrum cycle with customizable speed
11. **color_flash** - Flash through 32 different colors rapidly

## 10 Pattern Presets

0. **Rainbow (รุ้ง)** - Full spectrum rainbow gradient
1. **Fire (ไฟ)** - Warm fire colors with flickering effect
2. **Ocean (คลื่นทะเล)** - Cool ocean waves
3. **Sunset (แสงยามเย็น)** - Warm sunset colors
4. **Forest (ป่าเขียว)** - Natural green variations
5. **Purple Storm (พายุม่วง)** - Purple with lightning flashes
6. **Candy (ลูกกวาด)** - Bright candy colors
7. **Chrome (โลหะเงา)** - Metallic silver chrome
8. **Neon Club (นีออนดิสโก้)** - Bright neon disco colors
9. **Warm White (ขาวอุ่น)** - Warm white gradient

## Hardware Compatibility

### ESP32 WROOM-32D Pin Configuration
```
ESP32 WROOM-32D Pin -> Component
GPIO 5              -> WS2812B Data In
GPIO 34             -> MAX4466 Audio Out
VIN (5V)            -> LED Strip Power +
GND                 -> LED Strip GND + Microphone GND
3.3V                -> MAX4466 VCC
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