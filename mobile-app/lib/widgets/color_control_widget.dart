import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../services/esp32_service.dart';

class ColorControlWidget extends StatefulWidget {
  const ColorControlWidget({super.key});

  @override
  State<ColorControlWidget> createState() => _ColorControlWidgetState();
}

class _ColorControlWidgetState extends State<ColorControlWidget> {
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
              // Color Picker
              _buildSectionTitle('Color Selection'),
              _buildColorPicker(esp32Service),
              
              const SizedBox(height: 24),
              
              // Brightness Control
              _buildSectionTitle('Brightness'),
              _buildSlider(
                value: config.brightness.toDouble(),
                min: 0,
                max: 255,
                onChanged: (value) => esp32Service.setBrightness(value.round()),
                label: '${config.brightness}',
              ),
              
              const SizedBox(height: 24),
              
              // Mode Selection
              _buildSectionTitle('Display Mode'),
              _buildModeSelector(esp32Service),
              
              const SizedBox(height: 24),
              
              // Speed Control (for animated modes)
              if (config.mode != 'solid') ...[
                _buildSectionTitle('Animation Speed'),
                _buildSlider(
                  value: config.speed.toDouble(),
                  min: 0,
                  max: 100,
                  onChanged: (value) => esp32Service.setSpeed(value.round()),
                  label: '${config.speed}%',
                ),
                const SizedBox(height: 24),
              ],
              
              // Quick Color Presets
              _buildSectionTitle('Quick Colors'),
              _buildColorPresets(esp32Service),
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

  Widget _buildColorPicker(ESP32Service esp32Service) {
    final config = esp32Service.config;
    final currentColor = Color.fromARGB(255, config.red, config.green, config.blue);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Color Preview
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Center(
              child: Text(
                'RGB(${config.red}, ${config.green}, ${config.blue})',
                style: TextStyle(
                  color: currentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Color Wheel
          ColorPicker(
            pickerColor: currentColor,
            onColorChanged: (Color color) {
              esp32Service.setColor(color.red, color.green, color.blue);
            },
            colorPickerWidth: 300,
            pickerAreaHeightPercent: 0.7,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hueWheel,
            labelTypes: const [],
            pickerAreaBorderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required String label,
  }) {
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
              Text('Value: $label'),
              Text('${min.round()} - ${max.round()}'),
            ],
          ),
          SfSlider(
            value: value,
            min: min,
            max: max,
            onChanged: (dynamic value) => onChanged(value.toDouble()),
            activeColor: Theme.of(context).primaryColor,
            thumbIcon: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(ESP32Service esp32Service) {
    final modes = [
      {'value': 'solid', 'label': 'Solid Color', 'icon': Icons.circle},
      {'value': 'rainbow', 'label': 'Rainbow', 'icon': Icons.color_lens},
      {'value': 'custom_pattern', 'label': 'Custom Pattern', 'icon': Icons.gradient},
      {'value': 'music_reactive', 'label': 'Music Reactive', 'icon': Icons.music_note},
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
          childAspectRatio: 2.5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: modes.length,
        itemBuilder: (context, index) {
          final mode = modes[index];
          final isSelected = esp32Service.config.mode == mode['value'];
          
          return GestureDetector(
            onTap: () => esp32Service.setMode(mode['value'] as String),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.white24,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    mode['icon'] as IconData,
                    color: isSelected ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mode['label'] as String,
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
        },
      ),
    );
  }

  Widget _buildColorPresets(ESP32Service esp32Service) {
    final presets = [
      {'color': Colors.red, 'name': 'Red'},
      {'color': Colors.green, 'name': 'Green'},
      {'color': Colors.blue, 'name': 'Blue'},
      {'color': Colors.purple, 'name': 'Purple'},
      {'color': Colors.orange, 'name': 'Orange'},
      {'color': Colors.cyan, 'name': 'Cyan'},
      {'color': Colors.pink, 'name': 'Pink'},
      {'color': Colors.white, 'name': 'White'},
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
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: presets.length,
        itemBuilder: (context, index) {
          final preset = presets[index];
          final color = preset['color'] as Color;
          
          return GestureDetector(
            onTap: () => esp32Service.setColor(color.red, color.green, color.blue),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Center(
                child: Text(
                  preset['name'] as String,
                  style: TextStyle(
                    color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}