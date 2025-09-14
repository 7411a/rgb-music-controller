// ESP32 RGB Music Controller with WiFi AP Configuration
// Compatible with ESP32 only

#include <WiFi.h>
#include <WebServer.h>
#include <Preferences.h>
#include <WebSocketsServer.h>
#include <ArduinoJson.h>
#include <FastLED.h>
#include <WiFiManager.h>

// RGB LED Configuration
#define LED_PIN 5
#define NUM_LEDS 300  // Adjust based on your LED strip
#define LED_TYPE WS2812B
#define COLOR_ORDER GRB

// Audio Input Configuration
#define MIC_PIN 34
#define NOISE_FLOOR 100
#define SAMPLES 64

// Communication
WebSocketsServer webSocket = WebSocketsServer(81);
WebServer configServer(80);  // Web server for AP configuration
Preferences preferences;

// LED Array
CRGB leds[NUM_LEDS];

// Audio Analysis Variables
double vReal[SAMPLES];
double vImag[SAMPLES];
unsigned int sampling_period_us;
unsigned long microseconds;

// RGB Control Variables
struct RGBPattern {
  uint8_t red = 255;
  uint8_t green = 255;
  uint8_t blue = 255;
  uint8_t brightness = 100;
  uint8_t speed = 50;
  uint8_t sensitivity = 50;
  String mode = "music_reactive";
  bool enabled = true;
};

RGBPattern currentPattern;
uint8_t patternSteps[256]; // 200+ adjustable steps
bool musicReactive = true;
unsigned long lastUpdate = 0;
const unsigned long updateInterval = 20; // 50Hz update rate

// WiFi Configuration
String apSSID = "RGB-Controller-Setup";
String apPassword = "12345678";
bool isAPMode = false;
bool configComplete = false;

void setup() {
  Serial.begin(115200);
  
  // Initialize preferences for storing WiFi config
  preferences.begin("wifi-config", false);
  
  // Load AP configuration from memory
  loadAPConfig();
  
  // Initialize LED strip
  FastLED.addLeds<LED_TYPE, LED_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);
  FastLED.setBrightness(currentPattern.brightness);
  
  // Initialize WiFi
  setupWiFi();
  
  // Initialize WebSocket server
  webSocket.begin();
  webSocket.onEvent(webSocketEvent);
  
  // Initialize audio input
  pinMode(MIC_PIN, INPUT);
  sampling_period_us = round(1000000 * (1.0 / 40000)); // 40kHz sampling
  
  // Initialize pattern steps (default rainbow pattern)
  initializeDefaultPattern();
  
  // Load saved preset if available
  int savedPreset = preferences.getInt("current_preset", 0);
  loadPatternPreset(savedPreset);
  
  Serial.println("ESP32 RGB Music Controller Ready!");
  Serial.println("Loaded " + String(savedPreset == 0 ? "Rainbow" : "Preset " + String(savedPreset)) + " pattern");
  if (isAPMode) {
    Serial.println("Access Point Mode - Configure WiFi at: http://192.168.4.1");
    Serial.println("AP Name: " + apSSID);
    Serial.println("AP Password: " + apPassword);
    
    // Show startup color test in AP mode
    startupColorTest();
  } else {
    Serial.print("Station Mode - IP Address: ");
    Serial.println(WiFi.localIP());
    
    // Show brief startup color test
    startupColorTest();
  }
}

void loop() {
  webSocket.loop();
  
  if (isAPMode) {
    configServer.handleClient();  // Handle AP configuration web server
  }
  
  if (millis() - lastUpdate > updateInterval) {
    if (musicReactive && !isAPMode) {
      processAudioInput();
    }
    updateLEDs();
    lastUpdate = millis();
  }
}

void setupWiFi() {
  // Check if we should start in AP mode (first time setup or reset)
  String savedSSID = preferences.getString("wifi_ssid", "");
  String savedPassword = preferences.getString("wifi_pass", "");
  
  if (savedSSID.length() == 0) {
    // No WiFi configured, start AP mode
    startAPMode();
  } else {
    // Try to connect to saved WiFi
    WiFi.begin(savedSSID.c_str(), savedPassword.c_str());
    
    int attempts = 0;
    while (WiFi.status() != WL_CONNECTED && attempts < 20) {
      delay(500);
      Serial.print(".");
      attempts++;
    }
    
    if (WiFi.status() == WL_CONNECTED) {
      Serial.println();
      Serial.println("WiFi connected successfully");
      isAPMode = false;
    } else {
      Serial.println();
      Serial.println("Failed to connect to saved WiFi, starting AP mode");
      startAPMode();
    }
  }
}

void startAPMode() {
  isAPMode = true;
  
  // Start Access Point
  WiFi.softAP(apSSID.c_str(), apPassword.c_str());
  Serial.println("Access Point started");
  Serial.println("SSID: " + apSSID);
  Serial.println("Password: " + apPassword);
  Serial.println("IP: 192.168.4.1");
  
  // Setup web server for configuration
  setupConfigServer();
  
  // Show AP mode on LEDs (orange pulsing)
  showAPMode();
}

void setupConfigServer() {
  // Main configuration page
  configServer.on("/", HTTP_GET, []() {
    String html = getConfigHTML();
    configServer.send(200, "text/html", html);
  });
  
  // Handle WiFi configuration
  configServer.on("/config", HTTP_POST, []() {
    if (configServer.hasArg("wifi_ssid") && configServer.hasArg("wifi_pass") && 
        configServer.hasArg("ap_ssid") && configServer.hasArg("ap_pass")) {
      
      String wifiSSID = configServer.arg("wifi_ssid");
      String wifiPass = configServer.arg("wifi_pass");
      String newAPSSID = configServer.arg("ap_ssid");
      String newAPPass = configServer.arg("ap_pass");
      
      // Save WiFi configuration
      preferences.putString("wifi_ssid", wifiSSID);
      preferences.putString("wifi_pass", wifiPass);
      
      // Save AP configuration
      apSSID = newAPSSID;
      apPassword = newAPPass;
      saveAPConfig();
      
      String response = "<html><body><h1>Configuration Saved!</h1>";
      response += "<p>WiFi SSID: " + wifiSSID + "</p>";
      response += "<p>AP Name: " + newAPSSID + "</p>";
      response += "<p>Device will restart in 3 seconds...</p>";
      response += "<script>setTimeout(function(){alert('Restarting...');}, 3000);</script>";
      response += "</body></html>";
      
      configServer.send(200, "text/html", response);
      
      delay(3000);
      ESP.restart();
    } else {
      configServer.send(400, "text/plain", "Missing parameters");
    }
  });
  
  // Reset configuration
  configServer.on("/reset", HTTP_GET, []() {
    preferences.clear();
    String response = "<html><body><h1>Configuration Reset!</h1>";
    response += "<p>Device will restart in 2 seconds...</p>";
    response += "</body></html>";
    configServer.send(200, "text/html", response);
    delay(2000);
    ESP.restart();
  });
  
  configServer.begin();
}

void loadAPConfig() {
  apSSID = preferences.getString("ap_ssid", "RGB-Controller-Setup");
  apPassword = preferences.getString("ap_pass", "12345678");
}

void saveAPConfig() {
  preferences.putString("ap_ssid", apSSID);
  preferences.putString("ap_pass", apPassword);
}

void showAPMode() {
  // Orange pulsing animation for AP mode
  for (int i = 0; i < NUM_LEDS; i++) {
    leds[i] = CRGB::Orange;
  }
  FastLED.show();
}

String getConfigHTML() {
  String html = R"rawliteral(
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RGB Controller Setup</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 500px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        h1 {
            text-align: center;
            color: #333;
            margin-bottom: 30px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #555;
        }
        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 16px;
            box-sizing: border-box;
            transition: border-color 0.3s;
        }
        input[type="text"]:focus, input[type="password"]:focus {
            outline: none;
            border-color: #667eea;
        }
        .btn {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
            margin: 10px 0;
            transition: transform 0.2s;
        }
        .btn:hover {
            transform: translateY(-2px);
        }
        .btn-reset {
            background: linear-gradient(45deg, #ff6b6b, #ee5a52);
        }
        .help-text {
            font-size: 12px;
            color: #777;
            margin-top: 5px;
        }
        .section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
        .section-title {
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 15px;
            color: #333;
        }
        .status {
            text-align: center;
            background: #e3f2fd;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            color: #1976d2;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎵 RGB Music Controller</h1>
        
        <div class="status">
            <strong>Setup Mode Active</strong><br>
            Configure your WiFi and controller settings
        </div>

        <form action="/config" method="POST">
            <div class="section">
                <div class="section-title">📶 WiFi Connection</div>
                <div class="form-group">
                    <label for="wifi_ssid">WiFi Network Name (SSID):</label>
                    <input type="text" id="wifi_ssid" name="wifi_ssid" required>
                    <div class="help-text">Enter your home WiFi network name</div>
                </div>
                <div class="form-group">
                    <label for="wifi_pass">WiFi Password:</label>
                    <input type="password" id="wifi_pass" name="wifi_pass" required>
                    <div class="help-text">Enter your WiFi password</div>
                </div>
            </div>

            <div class="section">
                <div class="section-title">🎛️ Controller Settings</div>
                <div class="form-group">
                    <label for="ap_ssid">Controller Name:</label>
                    <input type="text" id="ap_ssid" name="ap_ssid" value=")rawliteral" + apSSID + R"rawliteral(" required>
                    <div class="help-text">Name for your RGB controller (for future setup)</div>
                </div>
                <div class="form-group">
                    <label for="ap_pass">Setup Password:</label>
                    <input type="password" id="ap_pass" name="ap_pass" value=")rawliteral" + apPassword + R"rawliteral(" required>
                    <div class="help-text">Password for configuration access (min 8 characters)</div>
                </div>
            </div>

            <button type="submit" class="btn">💾 Save Configuration</button>
        </form>

        <button onclick="if(confirm('This will reset all settings. Continue?')) window.location.href='/reset'" class="btn btn-reset">
            🔄 Reset All Settings
        </button>

        <div style="text-align: center; margin-top: 30px; color: #777; font-size: 14px;">
            IP Address: 192.168.4.1<br>
            Device will restart after configuration
        </div>
    </div>

    <script>
        // Form validation
        document.querySelector('form').addEventListener('submit', function(e) {
            const apPass = document.getElementById('ap_pass').value;
            if (apPass.length < 8) {
                e.preventDefault();
                alert('Setup password must be at least 8 characters long');
                return false;
            }
        });
    </script>
</body>
</html>
)rawliteral";
  
  return html;
}



void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  switch(type) {
    case WStype_DISCONNECTED:
      Serial.printf("Client [%u] disconnected\n", num);
      break;
      
    case WStype_CONNECTED: {
      IPAddress ip = webSocket.remoteIP(num);
      Serial.printf("Client [%u] connected from %d.%d.%d.%d\n", num, ip[0], ip[1], ip[2], ip[3]);
      
      // Send current configuration to newly connected client
      sendCurrentConfig(num);
      break;
    }
    
    case WStype_TEXT:
      Serial.printf("Received: %s\n", payload);
      handleCommand((char*)payload);
      break;
      
    default:
      break;
  }
}

void handleCommand(String command) {
  DynamicJsonDocument doc(1024);
  deserializeJson(doc, command);
  
  String action = doc["action"];
  
  if (action == "set_color") {
    currentPattern.red = doc["red"];
    currentPattern.green = doc["green"];
    currentPattern.blue = doc["blue"];
  }
  else if (action == "set_brightness") {
    currentPattern.brightness = doc["brightness"];
    FastLED.setBrightness(currentPattern.brightness);
  }
  else if (action == "set_speed") {
    currentPattern.speed = doc["speed"];
  }
  else if (action == "set_sensitivity") {
    currentPattern.sensitivity = doc["sensitivity"];
  }
  else if (action == "set_mode") {
    currentPattern.mode = doc["mode"].as<String>();
    musicReactive = (currentPattern.mode == "music_reactive");
    
    // Special handling for demo mode
    if (currentPattern.mode == "all_colors_demo") {
      showAllColorsDemo();
      FastLED.show();
    }
  }
  else if (action == "set_pattern_step") {
    int step = doc["step"];
    uint8_t value = doc["value"];
    if (step >= 0 && step < 256) {
      patternSteps[step] = value;
    }
  }
  else if (action == "set_pattern_steps") {
    JsonArray steps = doc["steps"];
    for (int i = 0; i < steps.size() && i < 256; i++) {
      patternSteps[i] = steps[i];
    }
  }
  else if (action == "toggle_power") {
    currentPattern.enabled = !currentPattern.enabled;
  }
  else if (action == "get_config") {
    sendCurrentConfig();
  }
  else if (action == "test_colors") {
    startupColorTest();
  }
  else if (action == "show_color_palette") {
    showAllColorsDemo();
    FastLED.show();
  }
  else if (action == "cycle_hue") {
    // Cycle through all hues quickly
    for (int hue = 0; hue < 256; hue += 5) {
      fill_solid(leds, NUM_LEDS, CHSV(hue, 255, currentPattern.brightness));
      FastLED.show();
      delay(50);
    }
  }
  else if (action == "load_preset") {
    int presetNumber = doc["preset"];
    loadPatternPreset(presetNumber);
    Serial.println("Loaded pattern preset: " + String(presetNumber));
  }
  else if (action == "get_presets") {
    sendPresetList();
  }
  
  // Broadcast update to all connected clients
  broadcastStatus();
}

void sendCurrentConfig(uint8_t clientNum = 255) {
  DynamicJsonDocument doc(2048);
  doc["type"] = "config";
  doc["red"] = currentPattern.red;
  doc["green"] = currentPattern.green;
  doc["blue"] = currentPattern.blue;
  doc["brightness"] = currentPattern.brightness;
  doc["speed"] = currentPattern.speed;
  doc["sensitivity"] = currentPattern.sensitivity;
  doc["mode"] = currentPattern.mode;
  doc["enabled"] = currentPattern.enabled;
  doc["ip"] = WiFi.localIP().toString();
  doc["current_preset"] = preferences.getInt("current_preset", 0);
  
  // Add pattern steps
  JsonArray steps = doc.createNestedArray("pattern_steps");
  for (int i = 0; i < 256; i++) {
    steps.add(patternSteps[i]);
  }
  
  String message;
  serializeJson(doc, message);
  
  if (clientNum == 255) {
    webSocket.broadcastTXT(message);
  } else {
    webSocket.sendTXT(clientNum, message);
  }
}

void broadcastStatus() {
  DynamicJsonDocument doc(1024);
  doc["type"] = "status";
  doc["enabled"] = currentPattern.enabled;
  doc["mode"] = currentPattern.mode;
  doc["brightness"] = currentPattern.brightness;
  
  String message;
  serializeJson(doc, message);
  webSocket.broadcastTXT(message);
}

void sendPresetList(uint8_t clientNum = 255) {
  DynamicJsonDocument doc(2048);
  doc["type"] = "presets";
  
  JsonArray presets = doc.createNestedArray("preset_list");
  
  // Add preset information
  JsonObject preset0 = presets.createNestedObject();
  preset0["id"] = 0;
  preset0["name"] = "Rainbow";
  preset0["name_th"] = "รุ้ง";
  preset0["description"] = "Full spectrum rainbow gradient";
  preset0["description_th"] = "สีรุ้งเต็มสเปกตรัม";
  
  JsonObject preset1 = presets.createNestedObject();
  preset1["id"] = 1;
  preset1["name"] = "Fire";
  preset1["name_th"] = "ไฟ";
  preset1["description"] = "Warm fire colors";
  preset1["description_th"] = "สีไฟอุ่นๆ";
  
  JsonObject preset2 = presets.createNestedObject();
  preset2["id"] = 2;
  preset2["name"] = "Ocean";
  preset2["name_th"] = "คลื่นทะเล";
  preset2["description"] = "Cool ocean waves";
  preset2["description_th"] = "คลื่นทะเลเย็นสบาย";
  
  JsonObject preset3 = presets.createNestedObject();
  preset3["id"] = 3;
  preset3["name"] = "Sunset";
  preset3["name_th"] = "แสงยามเย็น";
  preset3["description"] = "Warm sunset colors";
  preset3["description_th"] = "สีแสงตะวันตก";
  
  JsonObject preset4 = presets.createNestedObject();
  preset4["id"] = 4;
  preset4["name"] = "Forest";
  preset4["name_th"] = "ป่าเขียว";
  preset4["description"] = "Natural green variations";
  preset4["description_th"] = "เขียวธรรมชาติ";
  
  JsonObject preset5 = presets.createNestedObject();
  preset5["id"] = 5;
  preset5["name"] = "Purple Storm";
  preset5["name_th"] = "พายุม่วง";
  preset5["description"] = "Purple with lightning flashes";
  preset5["description_th"] = "ม่วงพร้อมแสงฟ้าแลบ";
  
  JsonObject preset6 = presets.createNestedObject();
  preset6["id"] = 6;
  preset6["name"] = "Candy";
  preset6["name_th"] = "ลูกกวาด";
  preset6["description"] = "Bright candy colors";
  preset6["description_th"] = "สีลูกกวาดสดใส";
  
  JsonObject preset7 = presets.createNestedObject();
  preset7["id"] = 7;
  preset7["name"] = "Chrome";
  preset7["name_th"] = "โลหะเงา";
  preset7["description"] = "Metallic silver chrome";
  preset7["description_th"] = "โลหะเงาสีเงิน";
  
  JsonObject preset8 = presets.createNestedObject();
  preset8["id"] = 8;
  preset8["name"] = "Neon Club";
  preset8["name_th"] = "นีออนดิสโก้";
  preset8["description"] = "Bright neon disco colors";
  preset8["description_th"] = "สีนีออนดิสโก้สดใส";
  
  JsonObject preset9 = presets.createNestedObject();
  preset9["id"] = 9;
  preset9["name"] = "Warm White";
  preset9["name_th"] = "ขาวอุ่น";
  preset9["description"] = "Warm white gradient";
  preset9["description_th"] = "ไล่เฉดขาวอุ่น";
  
  String message;
  serializeJson(doc, message);
  
  if (clientNum == 255) {
    webSocket.broadcastTXT(message);
  } else {
    webSocket.sendTXT(clientNum, message);
  }
}

void processAudioInput() {
  // Sample audio
  for (int i = 0; i < SAMPLES; i++) {
    microseconds = micros();
    vReal[i] = analogRead(MIC_PIN);
    vImag[i] = 0;
    while (micros() < (microseconds + sampling_period_us)) {
      // Wait for next sample
    }
  }
  
  // Simple peak detection for music reactivity
  double peak = 0;
  for (int i = 0; i < SAMPLES; i++) {
    if (vReal[i] > peak) {
      peak = vReal[i];
    }
  }
  
  // Adjust brightness based on audio level
  if (peak > NOISE_FLOOR) {
    uint8_t audioBrightness = map(peak, NOISE_FLOOR, 4095, 50, 255);
    audioBrightness = constrain(audioBrightness, 50, currentPattern.brightness);
    FastLED.setBrightness(audioBrightness * currentPattern.sensitivity / 100);
  }
}

void updateLEDs() {
  if (!currentPattern.enabled) {
    FastLED.clear();
    FastLED.show();
    return;
  }
  
  if (currentPattern.mode == "solid") {
    fill_solid(leds, NUM_LEDS, CRGB(currentPattern.red, currentPattern.green, currentPattern.blue));
  }
  else if (currentPattern.mode == "rainbow") {
    fill_rainbow(leds, NUM_LEDS, millis() / (101 - currentPattern.speed), 7);
  }
  else if (currentPattern.mode == "custom_pattern") {
    updateCustomPattern();
  }
  else if (currentPattern.mode == "music_reactive") {
    updateMusicReactivePattern();
  }
  else if (currentPattern.mode == "color_cycle") {
    updateColorCycle();
  }
  else if (currentPattern.mode == "rainbow_wave") {
    updateRainbowWave();
  }
  else if (currentPattern.mode == "color_chase") {
    updateColorChase();
  }
  else if (currentPattern.mode == "spectrum_analyzer") {
    updateSpectrumAnalyzer();
  }
  else if (currentPattern.mode == "all_colors_demo") {
    showAllColorsDemo();
  }
  else if (currentPattern.mode == "full_spectrum") {
    showFullSpectrumCycle();
    return; // ฟังก์ชันนี้มี FastLED.show() ในตัวแล้ว
  }
  else if (currentPattern.mode == "color_flash") {
    flashAllColors();
    return; // ฟังก์ชันนี้มี FastLED.show() ในตัวแล้ว
  }
  
  FastLED.show();
}

void updateCustomPattern() {
  static uint8_t patternIndex = 0;
  
  for (int i = 0; i < NUM_LEDS; i++) {
    uint8_t stepIndex = (patternIndex + i) % 256;
    uint8_t hue = patternSteps[stepIndex];
    leds[i] = CHSV(hue, 255, currentPattern.brightness);
  }
  
  patternIndex += currentPattern.speed / 10;
}

void updateMusicReactivePattern() {
  static uint8_t hue = 0;
  
  // Create reactive pattern based on current audio level
  for (int i = 0; i < NUM_LEDS; i++) {
    uint8_t stepIndex = (hue + i * 2) % 256;
    uint8_t brightness = patternSteps[stepIndex] * currentPattern.brightness / 255;
    leds[i] = CHSV(stepIndex, 255, brightness);
  }
  
  hue += currentPattern.speed / 5;
}

void initializeDefaultPattern() {
  // Initialize with a rainbow pattern across 256 steps
  for (int i = 0; i < 256; i++) {
    patternSteps[i] = i;
  }
}

// Pattern Presets for 256 steps
void loadPatternPreset(int presetNumber) {
  // Save current preset selection
  preferences.putInt("current_preset", presetNumber);
  
  switch(presetNumber) {
    case 0:
      loadRainbowPreset();
      break;
    case 1:
      loadFirePreset();
      break;
    case 2:
      loadOceanPreset();
      break;
    case 3:
      loadSunsetPreset();
      break;
    case 4:
      loadForestPreset();
      break;
    case 5:
      loadPurpleStormPreset();
      break;
    case 6:
      loadCandyPreset();
      break;
    case 7:
      loadMetalPreset();
      break;
    case 8:
      loadNeonPreset();
      break;
    case 9:
      loadWarmWhitePreset();
      break;
    default:
      loadRainbowPreset();
      break;
  }
}

// Preset 0: Rainbow Gradient (รุ้ง)
void loadRainbowPreset() {
  for (int i = 0; i < 256; i++) {
    patternSteps[i] = i; // Full HSV spectrum
  }
  Serial.println("Loaded Rainbow Preset");
}

// Preset 1: Fire Effect (ไฟ)
void loadFirePreset() {
  for (int i = 0; i < 256; i++) {
    // Red to Orange to Yellow range (HSV 0-60) with flickering effect
    float angle = i * 4.0 * PI / 256.0;
    float intensity = (sin(angle) + sin(angle * 3) + sin(angle * 7)) / 3.0;
    int hue = map((intensity + 1.0) * 127.5, 0, 255, 0, 45); // Red to Orange
    patternSteps[i] = constrain(hue, 0, 45);
  }
  Serial.println("Loaded Fire Preset");
}

// Preset 2: Ocean Waves (คลื่นทะเล)
void loadOceanPreset() {
  for (int i = 0; i < 256; i++) {
    // Blue to Cyan range (HSV 160-200) with multiple wave layers
    float wave1 = sin(i * 2.0 * PI / 64.0);
    float wave2 = sin(i * 2.0 * PI / 32.0) * 0.5;
    float wave3 = sin(i * 2.0 * PI / 16.0) * 0.25;
    float combined = (wave1 + wave2 + wave3) * 15;
    int baseHue = 180; // Base blue
    patternSteps[i] = constrain(baseHue + combined, 160, 200);
  }
  Serial.println("Loaded Ocean Preset");
}

// Preset 3: Sunset Colors (สีแสงยามเย็น)
void loadSunsetPreset() {
  for (int i = 0; i < 128; i++) {
    // Orange to Red gradient
    patternSteps[i] = map(i, 0, 127, 15, 0); // Orange to Red
  }
  for (int i = 128; i < 256; i++) {
    // Purple to Pink gradient
    patternSteps[i] = map(i, 128, 255, 200, 240); // Purple to Pink
  }
  Serial.println("Loaded Sunset Preset");
}

// Preset 4: Forest Green (ป่าเขียว)
void loadForestPreset() {
  for (int i = 0; i < 256; i++) {
    // Green variations (HSV 60-120) with organic patterns
    float rustling = sin(i * 3.0 * PI / 256.0) * 0.3;
    float growth = sin(i * 0.5 * PI / 256.0) * 0.7;
    int baseGreen = 85; // Pure green
    int variation = (rustling + growth) * 20;
    patternSteps[i] = constrain(baseGreen + variation, 60, 120);
  }
  Serial.println("Loaded Forest Preset");
}

// Preset 5: Purple Storm (พายุม่วง)
void loadPurpleStormPreset() {
  for (int i = 0; i < 256; i++) {
    // Purple to Magenta range with realistic lightning effect
    if ((i % 64 < 2) || (i % 128 < 1)) {
      patternSteps[i] = 0; // White/Blue flash for lightning
    } else if (i % 32 < 4) {
      patternSteps[i] = 170; // Blue for storm clouds
    } else {
      // Purple storm base
      float storm = sin(i * 2.0 * PI / 128.0) * 0.5;
      int baseHue = 220; // Deep purple
      patternSteps[i] = constrain(baseHue + storm * 30, 200, 255);
    }
  }
  Serial.println("Loaded Purple Storm Preset");
}

// Preset 6: Candy Colors (สีลูกกวาด)
void loadCandyPreset() {
  // Bright saturated colors
  uint8_t candyColors[] = {0, 30, 60, 85, 120, 150, 180, 210, 240}; // Red, Orange, Yellow, Green, etc.
  int numColors = sizeof(candyColors) / sizeof(candyColors[0]);
  
  for (int i = 0; i < 256; i++) {
    int colorIndex = (i * numColors) / 256;
    patternSteps[i] = candyColors[colorIndex];
  }
  Serial.println("Loaded Candy Preset");
}

// Preset 7: Metallic Chrome (โลหะเงา)
void loadMetalPreset() {
  for (int i = 0; i < 256; i++) {
    // Silver/White with blue tints
    if (i % 16 < 8) {
      patternSteps[i] = 0; // White
    } else {
      patternSteps[i] = 200; // Cool blue
    }
  }
  Serial.println("Loaded Metal Preset");
}

// Preset 8: Neon Club (นีออนดิสโก้)
void loadNeonPreset() {
  // Bright neon colors
  uint8_t neonColors[] = {0, 45, 85, 120, 160, 200, 240}; // Neon Red, Yellow, Green, Cyan, Blue, Purple, Pink
  int numColors = sizeof(neonColors) / sizeof(neonColors[0]);
  
  for (int i = 0; i < 256; i++) {
    // Sharp transitions between neon colors
    int segment = i / (256 / numColors);
    patternSteps[i] = neonColors[segment % numColors];
  }
  Serial.println("Loaded Neon Preset");
}

// Preset 9: Warm White Gradient (ขาวอุ่น)
void loadWarmWhitePreset() {
  for (int i = 0; i < 256; i++) {
    // Warm white range (HSV 20-40 with low saturation)
    patternSteps[i] = map(i, 0, 255, 20, 40); // Warm yellow-orange tints
  }
  Serial.println("Loaded Warm White Preset");
}

void updateColorCycle() {
  // Cycle through all colors in HSV spectrum
  static uint8_t globalHue = 0;
  
  for (int i = 0; i < NUM_LEDS; i++) {
    leds[i] = CHSV(globalHue, 255, currentPattern.brightness);
  }
  
  globalHue += currentPattern.speed / 10;
}

void updateRainbowWave() {
  // Rainbow wave effect - different colors flowing across strip
  static uint8_t startHue = 0;
  
  for (int i = 0; i < NUM_LEDS; i++) {
    uint8_t hue = startHue + (i * 256 / NUM_LEDS);
    leds[i] = CHSV(hue, 255, currentPattern.brightness);
  }
  
  startHue += currentPattern.speed / 5;
}

void updateColorChase() {
  // Color chase effect - bands of different colors moving
  static uint8_t position = 0;
  static uint8_t colorIndex = 0;
  
  // Clear all LEDs first
  FastLED.clear();
  
  // Define color palette
  CRGB colors[] = {
    CRGB::Red, CRGB::Orange, CRGB::Yellow, CRGB::Green,
    CRGB::Blue, CRGB::Indigo, CRGB::Violet, CRGB::Pink,
    CRGB::Cyan, CRGB::Magenta, CRGB::Lime, CRGB::White
  };
  
  int numColors = sizeof(colors) / sizeof(colors[0]);
  int bandWidth = 10; // Width of each color band
  
  for (int i = 0; i < numColors; i++) {
    int startPos = (position + i * bandWidth) % NUM_LEDS;
    
    for (int j = 0; j < bandWidth && (startPos + j) < NUM_LEDS; j++) {
      int ledIndex = (startPos + j) % NUM_LEDS;
      leds[ledIndex] = colors[(colorIndex + i) % numColors];
      leds[ledIndex].fadeToBlackBy(256 - currentPattern.brightness);
    }
  }
  
  position += currentPattern.speed / 8;
  if (position >= NUM_LEDS) {
    position = 0;
    colorIndex = (colorIndex + 1) % numColors;
  }
}

void showAllColorsDemo() {
  // Demo function to show all primary and secondary colors
  CRGB demoColors[] = {
    CRGB::Red,        // แดง
    CRGB::Orange,     // ส้ม  
    CRGB::Yellow,     // เหลือง
    CRGB::Green,      // เขียว
    CRGB::Blue,       // น้ำเงิน
    CRGB::Indigo,     // คราม
    CRGB::Violet,     // ม่วง
    CRGB::Pink,       // ชมพู
    CRGB::Cyan,       // ฟ้า
    CRGB::Magenta,    // แมเจนตา
    CRGB::Lime,       // เขียวมะนาว
    CRGB::White,      // ขาว
    CRGB::Maroon,     // แดงเข้ม
    CRGB::Navy,       // น้ำเงินเข้ม
    CRGB::Olive,      // เขียวมะกอก
    CRGB::Purple,     // ม่วงเข้ม
    CRGB::Teal,       // เขียวน้ำทะเล
    CRGB::Silver,     // เงิน
    CRGB::Gold,       // ทอง
    CRGB::Crimson     // แดงเลือด
  };
  
  int numColors = sizeof(demoColors) / sizeof(demoColors[0]);
  int ledsPerColor = NUM_LEDS / numColors;
  
  for (int colorIdx = 0; colorIdx < numColors; colorIdx++) {
    int startLed = colorIdx * ledsPerColor;
    int endLed = min(startLed + ledsPerColor, NUM_LEDS);
    
    for (int i = startLed; i < endLed; i++) {
      leds[i] = demoColors[colorIdx];
      leds[i].fadeToBlackBy(256 - currentPattern.brightness);
    }
  }
}

void updateSpectrumAnalyzer() {
  // Spectrum analyzer effect - shows different frequencies as different colors
  static uint8_t bassHue = 0;      // Red-Orange for bass (0-60)
  static uint8_t midHue = 85;      // Green for mid (60-170) 
  static uint8_t trebleHue = 170;  // Blue-Purple for treble (170-255)
  
  // Simple frequency separation simulation
  int bassSection = NUM_LEDS / 3;
  int midSection = NUM_LEDS / 3;
  int trebleSection = NUM_LEDS - bassSection - midSection;
  
  // Bass section (Low frequencies - Red/Orange)
  for (int i = 0; i < bassSection; i++) {
    uint8_t brightness = random(50, currentPattern.brightness);
    leds[i] = CHSV(bassHue + random(30), 255, brightness);
  }
  
  // Mid section (Mid frequencies - Green/Yellow)
  for (int i = bassSection; i < bassSection + midSection; i++) {
    uint8_t brightness = random(50, currentPattern.brightness);
    leds[i] = CHSV(midHue + random(30), 255, brightness);
  }
  
  // Treble section (High frequencies - Blue/Purple)
  for (int i = bassSection + midSection; i < NUM_LEDS; i++) {
    uint8_t brightness = random(50, currentPattern.brightness);
    leds[i] = CHSV(trebleHue + random(30), 255, brightness);
  }
  
  // Slowly change hues for variety
  bassHue += currentPattern.speed / 20;
  midHue += currentPattern.speed / 25;
  trebleHue += currentPattern.speed / 30;
}

void startupColorTest() {
  // Show all primary colors briefly to test LED functionality
  Serial.println("Starting color test...");
  
  // Test primary colors
  CRGB testColors[] = {
    CRGB::Red,     // แดง
    CRGB::Green,   // เขียว  
    CRGB::Blue,    // น้ำเงิน
    CRGB::Yellow,  // เหลือง
    CRGB::Cyan,    // ฟ้า
    CRGB::Magenta, // แมเจนตา
    CRGB::White    // ขาว
  };
  
  int numTestColors = sizeof(testColors) / sizeof(testColors[0]);
  
  for (int colorIdx = 0; colorIdx < numTestColors; colorIdx++) {
    // Fill all LEDs with current test color
    for (int i = 0; i < NUM_LEDS; i++) {
      leds[i] = testColors[colorIdx];
      leds[i].fadeToBlackBy(256 - 150); // Medium brightness for test
    }
    
    FastLED.show();
    delay(300); // Show each color for 300ms
    
    Serial.print("Testing color: ");
    if (colorIdx == 0) Serial.println("Red");
    else if (colorIdx == 1) Serial.println("Green");
    else if (colorIdx == 2) Serial.println("Blue");
    else if (colorIdx == 3) Serial.println("Yellow");
    else if (colorIdx == 4) Serial.println("Cyan");
    else if (colorIdx == 5) Serial.println("Magenta");
    else if (colorIdx == 6) Serial.println("White");
  }
  
  // Clear LEDs after test
  FastLED.clear();
  FastLED.show();
  delay(500);
  
  Serial.println("Color test completed!");
}

void showFullSpectrumCycle() {
  // Show complete HSV spectrum as a slow cycle
  static unsigned long lastSpectrumUpdate = 0;
  static uint8_t spectrumHue = 0;
  
  if (millis() - lastSpectrumUpdate > 50) { // Update every 50ms
    for (int i = 0; i < NUM_LEDS; i++) {
      // Create rainbow across the strip
      uint8_t pixelHue = spectrumHue + (i * 256 / NUM_LEDS);
      leds[i] = CHSV(pixelHue, 255, currentPattern.brightness);
    }
    
    FastLED.show();
    spectrumHue += currentPattern.speed / 10;
    lastSpectrumUpdate = millis();
  }
}

void flashAllColors() {
  // Flash through all major colors quickly for demonstration
  CRGB flashColors[] = {
    CRGB::Red, CRGB::Orange, CRGB::Yellow, CRGB::Chartreuse,
    CRGB::Green, CRGB::SpringGreen, CRGB::Cyan, CRGB::Azure,
    CRGB::Blue, CRGB::Violet, CRGB::Magenta, CRGB::Rose,
    CRGB::Pink, CRGB::DeepPink, CRGB::OrangeRed, CRGB::Crimson,
    CRGB::Indigo, CRGB::Purple, CRGB::DarkViolet, CRGB::BlueViolet,
    CRGB::MediumSlateBlue, CRGB::LimeGreen, CRGB::ForestGreen, CRGB::SeaGreen,
    CRGB::Aqua, CRGB::LightBlue, CRGB::SkyBlue, CRGB::Gold,
    CRGB::Goldenrod, CRGB::DarkOrange, CRGB::Coral, CRGB::Salmon
  };
  
  int numFlashColors = sizeof(flashColors) / sizeof(flashColors[0]);
  
  for (int i = 0; i < numFlashColors; i++) {
    fill_solid(leds, NUM_LEDS, flashColors[i]);
    leds->fadeToBlackBy(256 - currentPattern.brightness);
    FastLED.show();
    delay(100); // Flash each color for 100ms
  }
}