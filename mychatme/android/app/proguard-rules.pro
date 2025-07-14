# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Agora RTC Engine
-keep class io.agora.**{*;}

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Kotlin Metadata
-dontwarn kotlin.Metadata
-keep class kotlin.Metadata { *; }

# R8 compatibility
-dontwarn kotlinx.metadata.**
-keep class kotlinx.metadata.** { *; }
