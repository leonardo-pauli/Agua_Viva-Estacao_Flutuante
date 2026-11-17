# Preserva classes e assinaturas de métodos (incluindo parâmetros Continuation)
# chamadas via JNI pelo shared_preferences_android e package:jni no build release.
-keep,includedescriptorclasses class io.flutter.plugins.sharedpreferences.** { *; }
-keep,includedescriptorclasses class com.github.dart_lang.jni.** { *; }
-keep,includedescriptorclasses class kotlin.coroutines.** { *; }
-keep,includedescriptorclasses interface kotlin.coroutines.** { *; }
-keep,includedescriptorclasses @androidx.annotation.Keep class * { *; }

# Preserva classes do Flutter e do aplicativo
-keep class io.flutter.** { *; }
-keep class com.example.bioglow_receptor.** { *; }
