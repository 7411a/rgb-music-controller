# ESP32 RGB Music Controller Project

This workspace contains a complete RGB LED strip controller system with music reactive capabilities and 200+ adjustable pattern steps.

## Project Structure

- **esp32-firmware/**: Arduino/C++ firmware for ESP32 microcontroller
  - WebSocket server for real-time communication
  - FastLED library for RGB control
  - Audio input processing for music reactive mode
  - WiFiManager for easy WiFi setup
  - 256-step custom pattern support

- **mobile-app/**: Flutter mobile application for control
  - Real-time RGB color picker
  - Pattern editor with 256 individual steps
  - Music reactive controls and sensitivity adjustment
  - WiFi/WebSocket communication with ESP32
  - Auto-reconnection and device management

## Key Features

- **Real-time Control**: WebSocket communication for instant response
- **Music Reactive**: LEDs respond to audio input via microphone
- **Custom Patterns**: 256 individually adjustable pattern steps
- **Multiple Modes**: Solid color, rainbow, custom patterns, music reactive
- **Mobile Interface**: Intuitive Flutter app with touch controls
- **WiFi Setup**: Easy WiFi configuration via captive portal
- **Auto-reconnect**: Automatic connection recovery

## Hardware Requirements

- ESP32 Development Board
- WS2812B RGB LED Strip (up to 300 LEDs)
- MAX4466 Microphone Module (for music reactive mode)
- 5V Power Supply
- Mobile device (Android/iOS)

## Development Guidelines

### ESP32 Firmware (Arduino/C++)
- Use PlatformIO for development and dependencies
- Follow Arduino coding standards
- Optimize for real-time performance (50Hz update rate)
- Use FastLED library for LED control
- Implement WebSocket server for communication

### Flutter Mobile App
- Use Provider for state management
- Follow Flutter/Dart style guidelines
- Implement responsive UI for different screen sizes
- Use WebSocket for real-time communication
- Handle connection states gracefully

### Communication Protocol
- WebSocket on port 81
- JSON message format
- Commands: set_color, set_brightness, set_mode, set_pattern_step, etc.
- Real-time status updates and configuration sync

## Testing Considerations

- Test with different LED strip lengths
- Verify audio responsiveness with various music genres
- Test WiFi reconnection scenarios
- Validate pattern editor with complex custom patterns
- Performance testing with high update rates

## Documentation Standards

- Maintain comprehensive README files
- Document API/protocol changes
- Include wiring diagrams and setup instructions
- Provide troubleshooting guides
- Keep code comments up to date