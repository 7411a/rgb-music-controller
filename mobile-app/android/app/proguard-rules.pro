# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# WebSocket related
-keep class org.java_websocket.** { *; }
-keep class java.net.** { *; }

# Color picker and UI components
-keep class com.syncfusion.** { *; }

# Permission handler
-keep class com.baseflow.permissionhandler.** { *; }

# Keep all annotations
-keepattributes *Annotation*

# Keep line numbers for stack traces
-keepattributes SourceFile,LineNumberTable

# ESP32 RGB Controller App specific
-keep class com.rgbcontroller.esp32.app.** { *; }