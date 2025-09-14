import 'package:flutter/material.dart';

// Pattern Step class for managing individual pattern steps
class PatternStep {
  Color color;
  int duration; // Duration in milliseconds
  double brightness;
  String effect;
  
  PatternStep({
    this.color = Colors.white,
    this.duration = 500,
    this.brightness = 1.0,
    this.effect = 'solid',
  });
  
  PatternStep copyWith({
    Color? color,
    int? duration,
    double? brightness,
    String? effect,
  }) {
    return PatternStep(
      color: color ?? this.color,
      duration: duration ?? this.duration,
      brightness: brightness ?? this.brightness,
      effect: effect ?? this.effect,
    );
  }
}

void main() {
  runApp(const RGBControllerApp());
}

class RGBControllerApp extends StatelessWidget {
  const RGBControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ຕົວຄວບຄຸມ RGB',
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
  
  // Pattern Steps Management
  List<PatternStep> _patternSteps = [];
  int _selectedStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializePatternSteps();
  }
  
  void _initializePatternSteps() {
    // Initialize with 256 steps (default rainbow pattern)
    _patternSteps = List.generate(256, (index) {
      final hue = (index / 256.0) * 360.0;
      return PatternStep(
        color: HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor(),
        duration: 100,
        brightness: 1.0,
        effect: 'solid',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ຕົວຄວບຄຸມ RGB'),
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
            
            // Mode-specific settings
            _buildModeSettings(),
            
            const SizedBox(height: 20),
            
            // Pattern Editor (show only when in pattern mode)
            if (_currentMode == 'pattern')
              _buildPatternEditor(),
            
            if (_currentMode == 'pattern')
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
                Text('ບໍ່ໄດ້ເຊື່ອມຕໍ່ກັບ ESP32', 
                     style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('ໃສ່ທີ່ຢູ່ IP ຂອງ ESP32 ເພື່ອເຊື່ອມຕໍ່:'),
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
                      const SnackBar(content: Text('ຄຸນສົມບັດການເຊື່ອມຕໍ່ກຳລັງມາ!')),
                    );
                  },
                  child: const Text('ເຊື່ອມຕໍ່'),
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
            const Text('ຕົວຢ່າງສີ', 
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
                  'RGB(${_selectedColor.red}, ${_selectedColor.green}, ${_selectedColor.blue})\nຄວາມສະຫວ່າງ: ${_brightness.round()}',
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
            const Text('ການຄວບຄຸມສີ', 
                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Quick Colors
            const Text('ສີດ່ວນ:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildColorButton(Colors.red, 'ແດງ'),
                _buildColorButton(Colors.green, 'ເຂືອ'),
                _buildColorButton(Colors.blue, 'ຟ້າ'),
                _buildColorButton(Colors.purple, 'ມ່ວງ'),
                _buildColorButton(Colors.orange, 'ສົ້ມ'),
                _buildColorButton(Colors.cyan, 'ຟ້າອ່ອນ'),
                _buildColorButton(Colors.pink, 'ບົວ'),
                _buildColorButton(Colors.white, 'ຂາວ'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Brightness Control
            const Text('ຄວາມສະຫວ່າງ:'),
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
    final modes = [
      {
        'key': 'solid',
        'title': 'ສີພື້ນຖານ',
        'description': 'ສີດຽວທົ່ວທຸກ LED',
        'icon': Icons.circle,
        'color': Colors.blue,
      },
      {
        'key': 'rainbow',
        'title': 'ສຽງຟ້າຮ້ອງ',
        'description': 'ລາຍການສີເຄື່ອນໄຫວ',
        'icon': Icons.color_lens,
        'color': Colors.purple,
      },
      {
        'key': 'music',
        'title': 'ຕອບສະໜອງດົນຕີ',
        'description': 'LED ຕອບສະໜອງກັບສຽງ',
        'icon': Icons.music_note,
        'color': Colors.green,
      },
      {
        'key': 'pattern',
        'title': 'ແບບຮູບແບບກຳນົດເອງ',
        'description': '256 ຂັ້ນຕອນປັບໄດ້',
        'icon': Icons.gradient,
        'color': Colors.orange,
      },
      {
        'key': 'strobe',
        'title': 'ແສງກະພິບ',
        'description': 'ຜົນກະທົບກະພິບໄວ',
        'icon': Icons.flash_on,
        'color': Colors.red,
      },
      {
        'key': 'fade',
        'title': 'ເປີ່ຍນສີນຸ່ມນວນ',
        'description': 'ການປ່ຽນສີແບບລື່ນ',
        'icon': Icons.gradient,
        'color': Colors.cyan,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.display_settings, color: Colors.purple),
                const SizedBox(width: 8),
                const Text('ໂໝດການສະແດງຜົນ', 
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('ປັດຈຸບັນ: ${_getModeDisplayName(_currentMode)}',
                     style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Mode List
            Column(
              children: modes.map((mode) => _buildModeListItem(mode)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeListItem(Map<String, dynamic> mode) {
    final isSelected = _currentMode == mode['key'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _currentMode = mode['key'] as String;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ເລືອກແລ້ວ: ${mode['title']}'),
              duration: const Duration(seconds: 1),
              backgroundColor: mode['color'] as Color,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? (mode['color'] as Color).withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? (mode['color'] as Color)
                  : Colors.white24,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Icon with colored background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (mode['color'] as Color).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  mode['icon'] as IconData,
                  color: mode['color'] as Color,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode['title'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? mode['color'] as Color : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode['description'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Selection indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: mode['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune, color: Colors.purple),
                const SizedBox(width: 8),
                Text('${_getModeDisplayName(_currentMode)} Settings',
                     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Mode-specific controls
            _buildModeSpecificControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSpecificControls() {
    switch (_currentMode) {
      case 'solid':
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ໃຊ້ສີທີ່ເລືອກໄວ້ຂ້າງເທິງ'),
            Text('• ສາມາດປັບຄວາມສະຫວ່າງໄດ້'),
            Text('• ເໝາະສຳລັບແສງແວດລ້ອມ'),
          ],
        );
        
      case 'rainbow':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ຄວາມໄວໃນການເຄື່ອນໄຫວ:'),
            Slider(
              value: 50.0,
              min: 1,
              max: 100,
              divisions: 99,
              label: '50%',
              onChanged: (value) {
                // TODO: Implement speed control
              },
            ),
            const Text('• ໝູນວຽນຜ່ານທຸກສີ'),
            const Text('• ສາມາດປັບຄວາມໄວໄດ້'),
          ],
        );
        
      case 'music':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ຄວາມອ່ອນໄຫວ:'),
            Slider(
              value: 75.0,
              min: 0,
              max: 100,
              divisions: 100,
              label: '75%',
              onChanged: (value) {
                // TODO: Implement sensitivity control
              },
            ),
            const Text('• ຕ້ອງການການເຊື່ອມຕໍ່ໄມໂຄຣໂຟນ'),
            const Text('• ຕອບສະໜອງກັບການປ້ອນສຽງ'),
            const Text('• ປັບຄວາມອ່ອນໄຫວສຳລັບສະພາບແວດລ້ອມທີ່ແຕກຕ່າງກັນ'),
          ],
        );
        
      case 'pattern':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ຕົວແກ້ໄຂແບບຮູບແບບກຳລັງມາ!')),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('ແກ້ໄຂແບບຮູບແບບ'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ແບບຮູບແບບທີ່ກຳນົດໄວ້ລ່ວງໜ້າກຳລັງມາ!')),
                      );
                    },
                    icon: const Icon(Icons.library_books),
                    label: const Text('ຕົວຢ່າງ'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('• 256 ຂັ້ນຕອນແຕ່ລະຂັ້ນ'),
            const Text('• ສີກຳນົດເອງສຳລັບແຕ່ລະ LED'),
            const Text('• ບັນທຶກ ແລະ ໂຫຼດແບບຮູບແບບ'),
          ],
        );
        
      case 'strobe':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ອັດຕາການກະພິບ:'),
            Slider(
              value: 10.0,
              min: 1,
              max: 50,
              divisions: 49,
              label: '10 Hz',
              onChanged: (value) {
                // TODO: Implement flash rate control
              },
            ),
            const Text('• ຜົນກະທົບການກະພິບໄວ'),
            const Text('• ສາມາດປັບອັດຕາການກະພິບໄດ້'),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ເຕືອນ: ອາດຈະກໍ່ໃຫ້ເກີດພະຍາດລົມບ້າໝູເນື່ອງຈາກແສງ',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        
      case 'fade':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ຄວາມໄວການຈືນ:'),
            Slider(
              value: 30.0,
              min: 1,
              max: 100,
              divisions: 99,
              label: '30%',
              onChanged: (value) {
                // TODO: Implement fade speed control
              },
            ),
            const Text('• ການປ່ຽນສີແບບລື່ນ'),
            const Text('• ໝູນວຽນລະຫວ່າງສີທີ່ເລືອກ'),
            const Text('• ສາມາດປັບຄວາມໄວການປ່ຽນໄດ້'),
          ],
        );
        
      default:
        return const Text('ເລືອກໂໝດເພື່ອເບິ່ງການຕັ້ງຄ່າ');
    }
  }

  Widget _buildPatternEditor() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('ຕົວແກ້ໄຂແບບຮູບແບບ', 
                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${_patternSteps.length} ຂັ້ນຕອນ',
                     style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Pattern Steps Overview
            _buildPatternStepsOverview(),
            
            const SizedBox(height: 16),
            
            // Selected Step Editor
            _buildSelectedStepEditor(),
            
            const SizedBox(height: 16),
            
            // Pattern Controls
            _buildPatternControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternStepsOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('ຂັ້ນຕອນແບບຮູບແບບ:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('ເລືອກແລ້ວ: ${_selectedStepIndex + 1}',
                 style: const TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 8),
        
        // Visual pattern preview
        Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _patternSteps.length,
            itemBuilder: (context, index) {
              final step = _patternSteps[index];
              final isSelected = index == _selectedStepIndex;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStepIndex = index;
                  });
                },
                child: Container(
                  width: 40,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: step.color.withOpacity(step.brightness),
                    borderRadius: BorderRadius.circular(6),
                    border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ] : null,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getContrastColor(step.color),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedStepEditor() {
    if (_selectedStepIndex >= _patternSteps.length) return const SizedBox();
    
    final selectedStep = _patternSteps[_selectedStepIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ແກ້ໄຂຂັ້ນຕອນ ${_selectedStepIndex + 1}', 
             style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        
        // Color picker for selected step
        Row(
          children: [
            const Text('ສີ:'),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showColorPickerForStep(_selectedStepIndex),
              child: Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: selectedStep.color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'RGB(${selectedStep.color.red}, ${selectedStep.color.green}, ${selectedStep.color.blue})',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Duration slider
        Text('ໄລຍະເວລາ: ${selectedStep.duration}ms'),
        Slider(
          value: selectedStep.duration.toDouble(),
          min: 50,
          max: 2000,
          divisions: 39,
          label: '${selectedStep.duration}ms',
          onChanged: (value) {
            setState(() {
              _patternSteps[_selectedStepIndex] = selectedStep.copyWith(
                duration: value.round(),
              );
            });
          },
        ),
        
        const SizedBox(height: 12),
        
        // Brightness slider
        Text('ຄວາມສະຫວ່າງ: ${(selectedStep.brightness * 100).round()}%'),
        Slider(
          value: selectedStep.brightness,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          label: '${(selectedStep.brightness * 100).round()}%',
          onChanged: (value) {
            setState(() {
              _patternSteps[_selectedStepIndex] = selectedStep.copyWith(
                brightness: value,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildPatternControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ການຄວບຄຸມແບບຮູບແບບ:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: _generateRainbowPattern,
              icon: const Icon(Icons.gradient, size: 16),
              label: const Text('ສີຟ້າຮ້ອງ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.withOpacity(0.3),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _generateRandomPattern,
              icon: const Icon(Icons.shuffle, size: 16),
              label: const Text('ສຸ່ມ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.3),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _clearPattern,
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('ລ້າງ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.3),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _sendPatternToESP32,
              icon: const Icon(Icons.send, size: 16),
              label: const Text('ສົ່ງໄປ ESP32'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper function to get contrasting color for text
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Pattern generation functions
  void _generateRainbowPattern() {
    setState(() {
      _patternSteps = List.generate(256, (index) {
        final hue = (index / 256.0) * 360.0;
        return PatternStep(
          color: HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor(),
          duration: 100,
          brightness: 1.0,
          effect: 'solid',
        );
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ສ້າງແບບຮູບແບບສີຟ້າຮ້ອງແລ້ວ!')),
    );
  }

  void _generateRandomPattern() {
    setState(() {
      _patternSteps = List.generate(256, (index) {
        return PatternStep(
          color: Color.fromRGBO(
            (index * 123) % 256,
            (index * 456) % 256,
            (index * 789) % 256,
            1.0,
          ),
          duration: 50 + (index % 200),
          brightness: 0.5 + (index % 50) / 100.0,
          effect: 'solid',
        );
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ສ້າງແບບຮູບແບບສຸ່ມແລ້ວ!')),
    );
  }

  void _clearPattern() {
    setState(() {
      _patternSteps = List.generate(256, (index) {
        return PatternStep(
          color: Colors.black,
          duration: 100,
          brightness: 0.0,
          effect: 'solid',
        );
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ລ້າງແບບຮູບແບບແລ້ວ!')),
    );
  }

  void _showColorPickerForStep(int stepIndex) {
    // TODO: Implement color picker dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ຕົວເລືອກສີສຳລັບຂັ້ນຕອນ ${stepIndex + 1} - ກຳລັງມາ!')),
    );
  }

  void _sendPatternToESP32() {
    // TODO: Implement WebSocket communication
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ສົ່ງແບບຮູບແບບໄປ ESP32 ແລ້ວ! (ການເຊື່ອມຕໍ່ WebSocket ກຳລັງມາ)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getModeDisplayName(String mode) {
    switch (mode) {
      case 'solid': return 'ສີພື້ນຖານ';
      case 'rainbow': return 'ສິຟ້າຮ້ອງ';
      case 'music': return 'ຕອບສະໜອງດົນຕີ';
      case 'pattern': return 'ແບບຮູບແບບກຳນົດເອງ';
      case 'strobe': return 'ແສງກະພິບ';
      case 'fade': return 'ເປີ່ຍນສີນຸ່ມນວນ';
      default: return 'ບໍ່ຮູ້ຈັກ';
    }
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
                Text('ເລີ່ມຕົ້ນໃຊ້ງານ', 
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            const Text('1. ອັບໂຫລດເຟີມແວໄປທີ່ ESP32 ຂອງທ່ານ'),
            const Text('2. ເຊື່ອມຕໍ່ ESP32 ກັບ WiFi ໂດຍໃຊ້ "ESP32-RGB-Controller" AP'),
            const Text('3. ໃສ່ທີ່ຢູ່ IP ຂອງ ESP32 ຂ້າງເທິງ ແລະ ເຊື່ອມຕໍ່'),
            const Text('4. ເລີ່ມຄວບຄຸມ RGB LED ຂອງທ່ານ!'),
            const SizedBox(height: 12),
            const Text('ຄຸນສົມບັດ:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('• 256 ຂັ້ນຕອນແບບຮູບແບບທີ່ປັບໄດ້'),
            const Text('• ໂໝດຕອບສະໜອງດົນຕີ'),
            const Text('• ການຄວບຄຸມສີແບບທັນທີ'),
            const Text('• ໂໝດການສະແດງຜົນຫຼາຍແບບ'),
          ],
        ),
      ),
    );
  }
}