import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../services/esp32_service.dart';

class MusicControlWidget extends StatelessWidget {
  const MusicControlWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ESP32Service>(
      builder: (context, esp32Service, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Music Reactive Mode Toggle
              _buildSectionTitle('Music Reactive Mode'),
              _buildMusicModeToggle(esp32Service, context),
              
              const SizedBox(height: 24),
              
              // Audio Sensitivity
              _buildSectionTitle('Audio Sensitivity'),
              _buildSensitivityControl(esp32Service, context),
              
              const SizedBox(height: 24),
              
              // Reactive Effects
              _buildSectionTitle('Reactive Effects'),
              _buildReactiveEffects(esp32Service, context),
              
              const SizedBox(height: 24),
              
              // Audio Visualization Info
              _buildSectionTitle('Audio Setup'),
              _buildAudioInfo(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMusicModeToggle(ESP32Service esp32Service, BuildContext context) {
    final config = esp32Service.config;
    final isMusicMode = config.mode == 'music_reactive';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.music_note,
                color: isMusicMode ? Colors.green : Colors.grey,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Music Reactive',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isMusicMode ? Colors.green : Colors.grey,
                      ),
                    ),
                    Text(
                      isMusicMode ? 'LEDs respond to audio input' : 'Static pattern mode',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isMusicMode,
                onChanged: (value) {
                  esp32Service.setMode(value ? 'music_reactive' : 'rainbow');
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
          
          if (isMusicMode) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.mic, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Make sure your microphone is connected to the ESP32',
                      style: TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSensitivityControl(ESP32Service esp32Service, BuildContext context) {
    final config = esp32Service.config;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sensitivity: ${config.sensitivity}%'),
              const Text('0% - 100%'),
            ],
          ),
          const SizedBox(height: 8),
          SfSlider(
            value: config.sensitivity.toDouble(),
            min: 0,
            max: 100,
            interval: 25,
            showLabels: true,
            showTicks: true,
            onChanged: (value) => esp32Service.setSensitivity(value.round()),
            activeColor: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 8),
          const Text(
            'Higher sensitivity makes LEDs more responsive to quiet sounds',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildReactiveEffects(ESP32Service esp32Service, BuildContext context) {
    final config = esp32Service.config;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Base Brightness
          const Text('Base Brightness:'),
          SfSlider(
            value: config.brightness.toDouble(),
            min: 0,
            max: 255,
            onChanged: (value) => esp32Service.setBrightness(value.round()),
            activeColor: Theme.of(context).primaryColor,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${config.brightness}'),
              const Text('0 - 255'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Animation Speed
          const Text('Pattern Speed:'),
          SfSlider(
            value: config.speed.toDouble(),
            min: 0,
            max: 100,
            onChanged: (value) => esp32Service.setSpeed(value.round()),
            activeColor: Theme.of(context).primaryColor,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${config.speed}%'),
              const Text('0% - 100%'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quick Sensitivity Presets
          const Text('Quick Presets:'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => esp32Service.setSensitivity(25),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: config.sensitivity == 25 
                        ? Theme.of(context).primaryColor 
                        : Colors.transparent,
                  ),
                  child: const Text('Low'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => esp32Service.setSensitivity(50),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: config.sensitivity == 50 
                        ? Theme.of(context).primaryColor 
                        : Colors.transparent,
                  ),
                  child: const Text('Medium'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => esp32Service.setSensitivity(75),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: config.sensitivity == 75 
                        ? Theme.of(context).primaryColor 
                        : Colors.transparent,
                  ),
                  child: const Text('High'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Audio Setup Instructions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          const Text(
            '1. Connect a microphone module to GPIO 34 on your ESP32',
            style: TextStyle(fontSize: 14),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            '2. Recommended: MAX4466 microphone amplifier module',
            style: TextStyle(fontSize: 14),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            '3. Adjust sensitivity based on your environment',
            style: TextStyle(fontSize: 14),
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Text(
              'Note: Make sure the microphone is placed close to your audio source for best results.',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}