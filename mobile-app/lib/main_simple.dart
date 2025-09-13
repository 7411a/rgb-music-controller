import 'package:flutter/material.dart';

void main() {
  runApp(const RGBControllerApp());
}

class RGBControllerApp extends StatelessWidget {
  const RGBControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RGB Controller',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        cardColor: const Color(0xFF2D2D2D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color _selectedColor = Colors.purple;
  double _brightness = 128.0;
  String _currentMode = 'solid';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RGB Controller'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status
            _buildConnectionCard(),
            
            const SizedBox(height: 20),
            
            // Color Preview
            _buildColorPreview(),
            
            const SizedBox(height: 20),
            
            // Color Controls
            _buildColorControls(),
            
            const SizedBox(height: 20),
            
            // Mode Selection
            _buildModeSelection(),
            
            const SizedBox(height: 20),
            
            // Instructions
            _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.red),
                SizedBox(width: 8),
                Text('Not Connected to ESP32', 
                     style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Enter your ESP32 IP address to connect:'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '192.168.1.100',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement connection
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Connection feature coming soon!')),
                    );
                  },
                  child: const Text('Connect'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Color Preview', 
                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: _selectedColor.withOpacity(_brightness / 255),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Text(
                  'RGB(${_selectedColor.red}, ${_selectedColor.green}, ${_selectedColor.blue})\nBrightness: ${_brightness.round()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _selectedColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Color Controls', 
                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Quick Colors
            const Text('Quick Colors:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildColorButton(Colors.red, 'Red'),
                _buildColorButton(Colors.green, 'Green'),
                _buildColorButton(Colors.blue, 'Blue'),
                _buildColorButton(Colors.purple, 'Purple'),
                _buildColorButton(Colors.orange, 'Orange'),
                _buildColorButton(Colors.cyan, 'Cyan'),
                _buildColorButton(Colors.pink, 'Pink'),
                _buildColorButton(Colors.white, 'White'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Brightness Control
            const Text('Brightness:'),
            Slider(
              value: _brightness,
              min: 0,
              max: 255,
              divisions: 255,
              label: _brightness.round().toString(),
              onChanged: (value) {
                setState(() {
                  _brightness = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color, String name) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _selectedColor == color ? Colors.white : Colors.white24,
            width: _selectedColor == color ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Display Mode', 
                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildModeButton('solid', 'Solid Color', Icons.circle),
                _buildModeButton('rainbow', 'Rainbow', Icons.color_lens),
                _buildModeButton('music', 'Music Reactive', Icons.music_note),
                _buildModeButton('pattern', 'Custom Pattern', Icons.gradient),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String mode, String label, IconData icon) {
    final isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, 
                 color: isSelected ? Colors.white : Colors.grey,
                 size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text('Getting Started', 
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            const Text('1. Upload the firmware to your ESP32'),
            const Text('2. Connect ESP32 to WiFi using "ESP32-RGB-Controller" AP'),
            const Text('3. Enter the ESP32 IP address above and connect'),
            const Text('4. Start controlling your RGB LEDs!'),
            const SizedBox(height: 12),
            const Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• 256 adjustable pattern steps'),
            const Text('• Music reactive mode'),
            const Text('• Real-time color control'),
            const Text('• Multiple display modes'),
          ],
        ),
      ),
    );
  }
}