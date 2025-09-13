# ESP32 RGB Music Controller

A complete RGB LED strip controller system with music reactive capabilities and 200+ adjustable pattern steps. The system consists of ESP32 firmware and a Flutter mobile app for real-time control.

## 🌟 Features

- **🎵 Music Reactive**: LEDs respond to audio input in real-time
- **🎨 RGB Control**: Full color spectrum control with color picker
- **⚡ 256 Pattern Steps**: Highly customizable patterns with individual step control
- **📱 Mobile App**: Flutter-based mobile controller with intuitive interface
- **🔌 WiFi Communication**: Real-time WebSocket communication
- **🌈 Multiple Modes**: Solid color, rainbow, custom patterns, music reactive
- **🔄 Auto-reconnect**: Automatic reconnection and recovery
- **⚙️ Easy Setup**: WiFiManager for simple WiFi configuration

## 📁 Project Structure

```
RGB/
├── esp32-firmware/           # ESP32 Arduino firmware
│   ├── rgb_music_controller.ino
│   ├── platformio.ini
│   └── README.md
├── mobile-app/              # Flutter mobile controller
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md
└── README.md               # This file
```

## 🛠️ Hardware Requirements

### ESP32 Setup
- ESP32 Development Board
- WS2812B RGB LED Strip (up to 300 LEDs)
- MAX4466 Microphone Module (for music reactive mode)
- 5V Power Supply (appropriate for LED count)
- Jumper wires and breadboard

### Pin Connections
| Component | ESP32 Pin | Notes |
|-----------|-----------|-------|
| LED Strip Data | GPIO 5 | Configurable in platformio.ini |
| Microphone Analog Out | GPIO 34 | ADC1 pin |
| LED Strip 5V | VIN | External power recommended |
| LED Strip GND | GND | Common ground |

## 🚀 Quick Start

### 1. ESP32 Firmware Setup

1. **Install PlatformIO** in VS Code
2. **Open ESP32 firmware folder** in PlatformIO
3. **Connect ESP32** via USB
4. **Build and upload**:
   ```bash
   pio run --target upload
   ```
5. **Monitor serial output**:
   ```bash
   pio device monitor
   ```

### 2. WiFi Configuration

1. On first boot, ESP32 creates AP "ESP32-RGB-Controller"
2. Connect to this network from your phone
3. Navigate to 192.168.4.1
4. Configure your WiFi credentials
5. ESP32 will restart and connect to your network

### 3. Mobile App Setup

1. **Install Flutter SDK** (3.0.0+)
2. **Open mobile app folder**:
   ```bash
   cd mobile-app
   flutter pub get
   ```
3. **Run the app**:
   ```bash
   flutter run
   ```
4. **Connect to ESP32** using its IP address

## 📱 Mobile App Usage

### Connection
1. Tap the connection panel to expand
2. Enter your ESP32's IP address (shown in serial monitor)
3. Tap "Connect"

### Control Modes

#### 🎨 Color Tab
- **Color Picker**: Select any RGB color
- **Brightness**: 0-255 brightness control
- **Display Modes**: Solid, rainbow, custom pattern, music reactive
- **Quick Colors**: Preset color buttons

#### 🌈 Patterns Tab
- **Pattern Presets**: Rainbow, fire, ocean, sunset
- **Custom Editor**: Edit individual pattern steps (0-255)
- **Pattern Preview**: Visual representation
- **Advanced Controls**: Speed and pattern mode

#### 🎵 Music Tab
- **Music Reactive Toggle**: Enable/disable audio response
- **Sensitivity**: 0-100% audio sensitivity
- **Reactive Controls**: Base brightness and speed
- **Quick Presets**: Low, medium, high sensitivity

#### ⚙️ Settings Tab
- **Device Info**: Connection status, IP, current mode
- **LED Configuration**: Hardware setup information
- **App Information**: Version and features

## 🔧 Configuration

### ESP32 Firmware
Edit `platformio.ini` to customize:
```ini
build_flags = 
    -D LED_PIN=5          # LED data pin
    -D NUM_LEDS=300       # Number of LEDs
    -D MIC_PIN=34         # Microphone pin
```

### Mobile App
Dependencies in `pubspec.yaml`:
- `flutter_colorpicker`: Color picker widget
- `syncfusion_flutter_sliders`: Professional sliders
- `web_socket_channel`: WebSocket communication
- `provider`: State management

## 📡 Communication Protocol

### WebSocket Commands (JSON)
```json
// Set RGB color
{"action": "set_color", "red": 255, "green": 0, "blue": 0}

// Set brightness (0-255)
{"action": "set_brightness", "brightness": 150}

// Set mode
{"action": "set_mode", "mode": "music_reactive"}

// Set pattern step
{"action": "set_pattern_step", "step": 0, "value": 120}

// Set multiple steps
{"action": "set_pattern_steps", "steps": [0, 10, 20, ...]}

// Toggle power
{"action": "toggle_power"}
```

### Response Messages
```json
// Configuration update
{
  "type": "config",
  "red": 255, "green": 0, "blue": 0,
  "brightness": 150,
  "mode": "music_reactive",
  "pattern_steps": [0, 1, 2, ...]
}

// Status update
{
  "type": "status",
  "enabled": true,
  "mode": "music_reactive"
}
```

## 🎛️ Advanced Features

### Custom Patterns
- **256 Steps**: Each step represents a hue value (0-255)
- **Individual Control**: Edit each step independently
- **Pattern Presets**: Built-in rainbow, fire, ocean, sunset patterns
- **Real-time Preview**: See pattern changes instantly

### Music Reactive Mode
- **40kHz Sampling**: High-quality audio analysis
- **Peak Detection**: Responds to audio volume peaks
- **Sensitivity Control**: 0-100% adjustable sensitivity
- **Dynamic Brightness**: LEDs brightness follows audio level

### Performance
- **50Hz Update Rate**: Smooth LED animations
- **WebSocket**: Low-latency communication
- **Auto-reconnect**: Handles connection drops gracefully

## 🐛 Troubleshooting

### Connection Issues
- Ensure ESP32 and phone are on same WiFi network
- Check ESP32 power supply is adequate
- Verify IP address is correct
- Try restarting ESP32

### LED Issues
- Check data pin connection (GPIO 5)
- Verify power supply voltage and current
- Ensure LED strip is WS2812B compatible
- Check ground connections

### Audio Issues
- Verify microphone connection to GPIO 34
- Check microphone module power (3.3V)
- Adjust sensitivity in mobile app
- Ensure microphone is close to audio source

### Mobile App Issues
- Update Flutter to latest version
- Clear app cache and restart
- Check WiFi connection stability
- Verify ESP32 is responding (ping IP)

## 🔮 Future Enhancements

- **Bluetooth Support**: Alternative communication method
- **Sound Visualization**: FFT-based frequency analysis
- **Multi-zone Control**: Control multiple LED strips
- **Schedule/Timer**: Automated lighting schedules
- **Cloud Sync**: Save patterns to cloud storage
- **Voice Control**: Integration with voice assistants

## 📚 Development

### ESP32 Development
- **Arduino IDE**: Alternative to PlatformIO
- **Libraries**: FastLED, ArduinoJson, WebSockets, WiFiManager
- **Debugging**: Serial monitor for troubleshooting

### Flutter Development
- **State Management**: Provider pattern
- **Architecture**: Widget-based UI with service layer
- **Testing**: Unit tests for services and widgets

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 🆘 Support

For support:
1. Check troubleshooting section
2. Review individual README files in each folder
3. Open an issue on GitHub
4. Join our community discussions

## 🙏 Acknowledgments

- FastLED library for efficient LED control
- Flutter team for excellent mobile framework
- ESP32 community for hardware support
- Open source contributors

---

**Happy Lighting! 🌈✨**