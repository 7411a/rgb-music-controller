# ESP32 RGB Music Controller - Firmware

## Hardware Requirements

- ESP32 Development Board
- WS2812B RGB LED Strip (up to 300 LEDs)
- Microphone module (MAX4466 or similar)
- 5V Power Supply (appropriate for LED count)
- Jumper wires and breadboard

## Pin Connections

| Component | ESP32 Pin | Notes |
|-----------|-----------|-------|
| LED Strip Data | GPIO 5 | Can be changed in platformio.ini |
| Microphone Analog Out | GPIO 34 | ADC1 pin |
| LED Strip 5V | VIN | External power recommended |
| LED Strip GND | GND | Common ground |

## Features

- **Music Reactive**: LEDs respond to audio input
- **200+ Adjustable Steps**: Custom pattern with 256 configurable steps
- **Multiple Modes**: Solid color, rainbow, custom pattern, music reactive
- **WiFi Connectivity**: WebSocket communication with mobile app
- **Real-time Control**: Brightness, speed, sensitivity, color adjustment
- **WiFiManager**: Easy WiFi setup without hardcoding credentials

## Installation

1. Install PlatformIO in VS Code
2. Open this folder in PlatformIO
3. Connect ESP32 via USB
4. Build and upload: `pio run --target upload`
5. Monitor serial output: `pio device monitor`

## WiFi Setup

1. On first boot, ESP32 creates AP "ESP32-RGB-Controller"
2. Connect to this network
3. Navigate to 192.168.4.1
4. Configure your WiFi credentials
5. ESP32 will restart and connect to your network

## API Commands

### WebSocket Commands (JSON)

```json
// Set RGB color
{"action": "set_color", "red": 255, "green": 0, "blue": 0}

// Set brightness (0-255)
{"action": "set_brightness", "brightness": 150}

// Set animation speed (0-100)
{"action": "set_speed", "speed": 75}

// Set audio sensitivity (0-100)
{"action": "set_sensitivity", "sensitivity": 60}

// Change mode
{"action": "set_mode", "mode": "music_reactive"}
// Modes: "solid", "rainbow", "custom_pattern", "music_reactive"

// Set single pattern step
{"action": "set_pattern_step", "step": 0, "value": 120}

// Set multiple pattern steps
{"action": "set_pattern_steps", "steps": [0, 10, 20, 30, ...]}

// Toggle power
{"action": "toggle_power"}

// Get current configuration
{"action": "get_config"}
```

## Configuration

Edit `platformio.ini` to customize:
- `LED_PIN`: Data pin for LED strip
- `NUM_LEDS`: Number of LEDs in your strip
- `MIC_PIN`: Analog pin for microphone

## Troubleshooting

1. **LEDs not working**: Check power supply and data pin connection
2. **No WiFi connection**: Reset WiFi settings and reconfigure
3. **No audio response**: Check microphone connection and sensitivity
4. **Compilation errors**: Ensure all libraries are installed via PlatformIO

## Performance Notes

- Update rate: 50Hz (20ms intervals)
- WebSocket port: 81
- Audio sampling: 40kHz
- Maximum LEDs tested: 300 (adjust based on power supply)