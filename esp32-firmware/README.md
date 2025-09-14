# ESP32 RGB Music Controller - Firmware

## Overview
This firmware provides music-reactive RGB LED strip control with 256 adjustable pattern steps and easy WiFi configuration through a web interface.

## Features
- **Music Reactive**: LEDs respond to audio input via microphone
- **256 Pattern Steps**: Fully customizable pattern sequences  
- **WiFi Configuration**: Easy setup through Access Point mode
- **WebSocket Control**: Real-time communication with mobile app
- **Multiple Modes**: Solid color, rainbow, custom patterns, music reactive
- **Auto-reconnect**: Automatic WiFi connection recovery

## Hardware Requirements
- ESP32 Development Board
- WS2812B RGB LED Strip (up to 300 LEDs)
- MAX4466 Microphone Module
- 5V Power Supply (adequate for LED strip)

## Wiring Diagram
```
ESP32 Pin -> Component
GPIO 5    -> WS2812B Data In
GPIO 34   -> MAX4466 Out (Audio)
VIN/5V    -> LED Strip Power +
GND       -> LED Strip Ground & Microphone Ground
3.3V      -> MAX4466 VCC
```

## WiFi Setup Process

### First Time Setup
1. Flash firmware to ESP32
2. Device will create WiFi Access Point: `RGB-Controller-Setup`
3. Default password: `12345678`
4. Connect to this network and go to: `192.168.4.1`
5. Enter your home WiFi credentials
6. Set custom controller name and setup password
7. Save configuration - device will restart and connect to your WiFi

### Reconfigure WiFi
- Hold reset button during power-on to clear WiFi settings
- Or connect to AP and use "Reset All Settings" button
- Device will return to setup mode

### Configuration Web Interface
The setup page includes:
- **WiFi Settings**: Home network name and password
- **Controller Settings**: Custom device name and setup password  
- **Reset Option**: Clear all saved configurations
- **Responsive Design**: Works on mobile devices

## Pin Connections

| Component | ESP32 Pin | Notes |
|-----------|-----------|-------|
| LED Strip Data | GPIO 5 | Can be changed in platformio.ini |
| Microphone Analog Out | GPIO 34 | ADC1 pin |
| LED Strip 5V | VIN | External power recommended |
| LED Strip GND | GND | Common ground |

## Features

- **Music Reactive**: LEDs respond to audio input
- **256 Adjustable Steps**: Custom pattern with 256 configurable steps
- **Multiple Modes**: 11 different lighting modes including color demonstrations
- **WiFi Connectivity**: WebSocket communication with mobile app
- **Real-time Control**: Brightness, speed, sensitivity, color adjustment
- **WiFi Configuration**: Easy setup through web interface
- **Color Testing**: Automatic startup color test to verify LED functionality

## Available LED Modes

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

## LED Status Indicators

- **Color Test Sequence**: Red → Green → Blue → Yellow → Cyan → Magenta → White (at startup)
- **Orange Pulsing**: Access Point mode (WiFi setup required)
- **Connected Mode**: Normal operation with selected lighting mode

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