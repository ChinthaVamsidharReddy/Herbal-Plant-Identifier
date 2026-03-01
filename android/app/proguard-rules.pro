# TensorFlow Lite keep rules
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# GPU delegate
-keep class org.tensorflow.lite.gpu.** { *; }

# Native methods
-keepclasseswithmembernames class * {
    native <methods>;
}