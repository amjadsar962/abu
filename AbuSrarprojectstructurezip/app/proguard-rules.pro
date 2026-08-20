# Abu Srar - ProGuard Rules
# Add specific rules here when minification is enabled

# Keep Kotlin metadata
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep Voice Manager classes for reflection if needed
-keep class com.abusrar.assistant.voice.** { *; }

# Keep AI provider classes for runtime loading
-keep class com.abusrar.assistant.ai.** { *; }