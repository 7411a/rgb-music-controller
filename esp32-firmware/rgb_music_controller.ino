#include <WiFi.h>
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

void setup() {
  Serial.begin(115200);
  
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
  
  Serial.println("ESP32 RGB Music Controller Ready!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  webSocket.loop();
  
  if (millis() - lastUpdate > updateInterval) {
    if (musicReactive) {
      processAudioInput();
    }
    updateLEDs();
    lastUpdate = millis();
  }
}

void setupWiFi() {
  WiFiManager wm;
  
  // Reset settings for testing (comment out for production)
  // wm.resetSettings();
  
  wm.setAPCallback(configModeCallback);
  
  if (!wm.autoConnect("ESP32-RGB-Controller")) {
    Serial.println("Failed to connect to WiFi");
    ESP.restart();
  }
  
  Serial.println("WiFi connected successfully");
}

void configModeCallback(WiFiManager *myWiFiManager) {
  Serial.println("Entered WiFi config mode");
  Serial.println("Connect to: ESP32-RGB-Controller");
  Serial.println("Go to: 192.168.4.1");
  
  // Show WiFi config mode on LEDs (blue pulsing)
  for (int i = 0; i < NUM_LEDS; i++) {
    leds[i] = CRGB::Blue;
  }
  FastLED.show();
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