import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../services/esp32_service.dart';

class PatternControlWidget extends StatefulWidget {
  const PatternControlWidget({super.key});

  @override
  State<PatternControlWidget> createState() => _PatternControlWidgetState();
}

class _PatternControlWidgetState extends State<PatternControlWidget> {
  int _selectedStep = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer<ESP32Service>(
      builder: (context, esp32Service, child) {
        final config = esp32Service.config;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pattern Presets
              _buildSectionTitle('Pattern Presets'),
              _buildPatternPresets(esp32Service),
              
              const SizedBox(height: 24),
              
              // Step Editor
              _buildSectionTitle('Custom Pattern Editor (256 Steps)'),
              _buildStepEditor(esp32Service),
              
              const SizedBox(height: 24),
              
              // Pattern Visualization
              _buildSectionTitle('Pattern Preview'),
              _buildPatternVisualization(config.patternSteps),
              
              const SizedBox(height: 24),
              
              // Pattern Controls
              _buildSectionTitle('Pattern Controls'),
              _buildPatternControls(esp32Service),
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

  Widget _buildPatternPresets(ESP32Service esp32Service) {
    final presets = [
      {
        'name': 'Rainbow',
        'icon': Icons.color_lens,
        'action': () => esp32Service.setRainbowPattern(),
      },
      {
        'name': 'Fire',
        'icon': Icons.local_fire_department,
        'action': () => esp32Service.setFirePattern(),
      },
      {
        'name': 'Ocean',
        'icon': Icons.waves,
        'action': () => esp32Service.setOceanPattern(),
      },
      {
        'name': 'Sunset',
        'icon': Icons.wb_twilight,
        'action': () => esp32Service.setSunsetPattern(),
      },
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: presets.length,
        itemBuilder: (context, index) {
          final preset = presets[index];
          
          return ElevatedButton(
            onPressed: preset['action'] as VoidCallback,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              foregroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(preset['icon'] as IconData, size: 24),
                const SizedBox(height: 4),
                Text(
                  preset['name'] as String,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepEditor(ESP32Service esp32Service) {
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
          // Step Selector
          Row(
            children: [
              const Text('Step:'),
              const SizedBox(width: 8),
              Expanded(
                child: SfSlider(
                  value: _selectedStep.toDouble(),
                  min: 0,
                  max: 255,
                  interval: 32,
                  showLabels: true,
                  showTicks: true,
                  onChanged: (value) {
                    setState(() {
                      _selectedStep = value.round();
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Value Editor
          Row(
            children: [
              Text('Value: ${config.patternSteps[_selectedStep]}'),
              const Spacer(),
              Text('Hue: ${(config.patternSteps[_selectedStep] * 360 / 255).round()}°'),
            ],
          ),
          
          SfSlider(
            value: config.patternSteps[_selectedStep].toDouble(),
            min: 0,
            max: 255,
            onChanged: (value) {
              esp32Service.setPatternStep(_selectedStep, value.round());
            },
            activeColor: HSVColor.fromAHSV(
              1.0,
              config.patternSteps[_selectedStep] * 360 / 255,
              1.0,
              1.0,
            ).toColor(),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Set all steps to current value
                    final currentValue = config.patternSteps[_selectedStep];
                    final newSteps = List.filled(256, currentValue);
                    esp32Service.setPatternSteps(newSteps);
                  },
                  child: const Text('Fill All'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Generate gradient from step 0 to 255
                    final steps = List.generate(256, (index) => index);
                    esp32Service.setPatternSteps(steps);
                  },
                  child: const Text('Gradient'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternVisualization(List<int> steps) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pattern Colors (256 steps):'),
          const SizedBox(height: 8),
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: steps.take(128).map((step) { // Show first 128 steps
                  return Expanded(
                    child: Container(
                      color: HSVColor.fromAHSV(
                        1.0,
                        step * 360 / 255,
                        1.0,
                        1.0,
                      ).toColor(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Showing first 128 of 256 steps',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternControls(ESP32Service esp32Service) {
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
          // Speed Control
          const Text('Animation Speed:'),
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
          
          // Pattern Mode Switch
          Row(
            children: [
              const Text('Use Custom Pattern:'),
              const Spacer(),
              Switch(
                value: config.mode == 'custom_pattern',
                onChanged: (value) {
                  esp32Service.setMode(value ? 'custom_pattern' : 'rainbow');
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}