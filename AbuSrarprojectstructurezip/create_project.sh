#!/bin/bash
set -e

echo "================================"
echo "  كتابة ملفات أبو صرار..."
echo "================================"

# === الجذر ===

cat > settings.gradle.kts << 'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "AbuSrar"
include(":app")
EOF

cat > build.gradle.kts << 'EOF'
plugins {
    id("com.android.application") version "8.2.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}
EOF

cat > gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
EOF

cat > gradle/wrapper/gradle-wrapper.properties << 'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

cat > .gitignore << 'EOF'
*.iml
.gradle
/local.properties
/.idea
.DS_Store
/build
/captures
.externalNativeBuild
.cxx
local.properties
/app/build
/app/release
*.apk
*.aab
*.keystore
!gradle-wrapper.jar
EOF

cat > app/proguard-rules.pro << 'EOF'
# Abu Srar - ProGuard Rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
EOF

echo "  ✅ ملفات الجذر"

# === App Build ===

cat > app/build.gradle.kts << 'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.abusrar.assistant"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.abusrar.assistant"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.8"
    }
}

dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2024.02.00")
    implementation(composeBom)

    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.activity:activity-compose:1.8.2")

    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")

    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.7.0")

    debugImplementation("androidx.compose.ui:ui-tooling")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}
EOF

echo "  ✅ app/build.gradle.kts"

# === AndroidManifest ===

cat > app/src/main/AndroidManifest.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.CALL_PHONE" tools:node="remove" />
    <uses-permission android:name="android.permission.SEND_SMS" tools:node="remove" />

    <application
        android:name=".AbuSrarApp"
        android:allowBackup="true"
        android:backupAgent="androidx.backup.BackupAgentHelper"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.AbuSrar"
        tools:targetApi="34">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <activity
            android:name=".settings.SettingsActivity"
            android:exported="false"
            android:label="@string/settings_title"
            android:parentActivityName=".MainActivity" />

        <service
            android:name=".accessibility.AbuSrarAccessibilityService"
            android:exported="false"
            android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
            android:enabled="false">
            <intent-filter>
                <action android:name="android.accessibilityservice.AccessibilityService" />
            </intent-filter>
            <meta-data
                android:name="android.accessibilityservice"
                android:resource="@xml/accessibility_service_config" />
        </service>

    </application>
</manifest>
EOF

echo "  ✅ AndroidManifest.xml"

# === Core ===

cat > app/src/main/java/com/abusrar/assistant/AbuSrarApp.kt << 'EOF'
package com.abusrar.assistant

import android.app.Application
import com.abusrar.assistant.core.AppLogger

class AbuSrarApp : Application() {

    override fun onCreate() {
        super.onCreate()
        AppLogger.init(this)
        AppLogger.info("APP", "أبو صرار — بدء التشغيل")
    }
}
EOF

cat > app/src/main/java/com/abusrar/assistant/core/AppLogger.kt << 'EOF'
package com.abusrar.assistant.core

import android.content.Context
import android.util.Log
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object AppLogger {

    private const val TAG_PREFIX = "AbuSrar"
    private var isEnabled = true

    fun init(context: Context) {
        isEnabled = true
    }

    private fun log(tag: String, level: String, message: String) {
        if (!isEnabled) return
        val timestamp = SimpleDateFormat("HH:mm:ss.SSS", Locale.US).format(Date())
        val fullTag = "$TAG_PREFIX[$tag]"
        val fullMessage = "[$timestamp] $message"
        when (level) {
            "ERROR" -> Log.e(fullTag, fullMessage)
            "WARN" -> Log.w(fullTag, fullMessage)
            "DEBUG" -> Log.d(fullTag, fullMessage)
            else -> Log.i(fullTag, fullMessage)
        }
    }

    fun info(tag: String, message: String) = log(tag, "INFO", message)
    fun error(tag: String, message: String, throwable: Throwable? = null) {
        log(tag, "ERROR", message + (throwable?.let { ": ${it.message}" } ?: ""))
        throwable?.printStackTrace()
    }
    fun warn(tag: String, message: String) = log(tag, "WARN", message)
    fun debug(tag: String, message: String) = log(tag, "DEBUG", message)
    fun voice(message: String) = info("VOICE", message)
    fun command(message: String) = info("COMMAND", message)
    fun tool(message: String) = info("TOOL", message)
    fun accessibility(message: String) = info("ACCESSIBILITY", message)
    fun ai(message: String) = info("AI", message)
}
EOF

cat > app/src/main/java/com/abusrar/assistant/core/AppResult.kt << 'EOF'
package com.abusrar.assistant.core

sealed class AppResult<out T> {
    data class Success<T>(val data: T) : AppResult<T>()
    data class Error(val message: String, val code: Int = -1) : AppResult<Nothing>()
    data object Loading : AppResult<Nothing>()
}

fun <T> AppResult<T>.isSuccess(): Boolean = this is AppResult.Success
fun <T> AppResult<T>.isError(): Boolean = this is AppResult.Error
fun <T> AppResult<T>.isLoading(): Boolean = this is AppResult.Loading
EOF

echo "  ✅ core/"

# === Voice ===

cat > app/src/main/java/com/abusrar/assistant/voice/SpeechRecognizerManager.kt << 'EOF'
package com.abusrar.assistant.voice

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import com.abusrar.assistant.core.AppLogger

class SpeechRecognizerManager(private val context: Context) {

    private var speechRecognizer: SpeechRecognizer? = null
    private var isListening = false

    fun create() {
        if (speechRecognizer != null) return
        try {
            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(context).apply {
                setRecognitionListener(createRecognitionListener())
            }
            AppLogger.voice("تم إنشاء SpeechRecognizer بنجاح")
        } catch (e: Exception) {
            AppLogger.error("VOICE", "فشل إنشاء SpeechRecognizer", e)
        }
    }

    private var onResultCallback: ((String) -> Unit)? = null
    private var onErrorCallback: ((String) -> Unit)? = null
    private var onListeningStateChanged: ((Boolean) -> Unit)? = null

    fun setCallbacks(
        onResult: (String) -> Unit,
        onError: (String) -> Unit,
        onListeningChanged: (Boolean) -> Unit
    ) {
        onResultCallback = onResult
        onErrorCallback = onError
        onListeningStateChanged = onListeningChanged
    }

    private fun createRecognitionListener(): RecognitionListener {
        return object : RecognitionListener {
            override fun onReadyForSpeech(params: Bundle?) {
                AppLogger.voice("جاهز للاستقبال")
            }

            override fun onBeginningOfSpeech() {
                AppLogger.voice("بدء الكلام")
                isListening = true
                onListeningStateChanged?.invoke(true)
            }

            override fun onRmsChanged(rmsdB: Float) {}

            override fun onBufferReceived(buffer: ByteArray?) {}

            override fun onEndOfSpeech() {
                AppLogger.voice("انتهى الكلام")
                isListening = false
                onListeningStateChanged?.invoke(false)
            }

            override fun onError(error: Int) {
                isListening = false
                onListeningStateChanged?.invoke(false)
                val errorMessage = when (error) {
                    SpeechRecognizer.ERROR_NO_MATCH -> "لم أتمكن من فهم ما قلته"
                    SpeechRecognizer.ERROR_AUDIO -> "مشكلة في الصوت"
                    SpeechRecognizer.ERROR_CLIENT -> "خطأ في العميل"
                    SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "صلاحية الميكروفون مرفوضة"
                    SpeechRecognizer.ERROR_NETWORK -> "مشكلة في الشبكة"
                    SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "انتهت مهلة الشبكة"
                    SpeechRecognizer.ERROR_SERVER -> "خطأ في الخادم"
                    SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "المعرف مشغول"
                    SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "لم أسمع شيئاً"
                    else -> "خطأ غير معروف: $error"
                }
                AppLogger.error("VOICE", errorMessage)
                onErrorCallback?.invoke(errorMessage)
            }

            override fun onResults(results: Bundle?) {
                val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                if (!matches.isNullOrEmpty()) {
                    val text = matches[0]
                    AppLogger.voice("النتيجة: $text")
                    onResultCallback?.invoke(text)
                } else {
                    onErrorCallback?.invoke("لم أتمكن من فهم ما قلته")
                }
            }

            override fun onPartialResults(partialResults: Bundle?) {}

            override fun onEvent(eventType: Int, params: Bundle?) {}
        }
    }

    fun startListening(language: String = "ar-SA") {
        if (isListening) {
            stopListening()
            return
        }
        if (speechRecognizer == null) create()
        if (speechRecognizer == null) {
            onErrorCallback?.invoke("التعرف على الكلام غير متاح على هذا الجهاز")
            return
        }
        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, language)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 3)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
        }
        try {
            speechRecognizer?.startListening(intent)
            AppLogger.voice("بدأ الاستماع — اللغة: $language")
        } catch (e: Exception) {
            AppLogger.error("VOICE", "فشل بدء الاستماع", e)
            onErrorCallback?.invoke("فشل بدء الاستماع")
        }
    }

    fun stopListening() {
        try {
            speechRecognizer?.stopListening()
            speechRecognizer?.cancel()
            isListening = false
            onListeningStateChanged?.invoke(false)
            AppLogger.voice("تم إيقاف الاستماع")
        } catch (e: Exception) {
            AppLogger.error("VOICE", "خطأ في إيقاف الاستماع", e)
        }
    }

    fun destroy() {
        stopListening()
        try { speechRecognizer?.destroy() } catch (_: Exception) {}
        speechRecognizer = null
    }

    fun isListening(): Boolean = isListening
}
EOF

cat > app/src/main/java/com/abusrar/assistant/voice/TTSManager.kt << 'EOF'
package com.abusrar.assistant.voice

import android.content.Context
import android.speech.tts.TextToSpeech
import com.abusrar.assistant.core.AppLogger
import java.util.Locale

class TTSManager(private val context: Context) : TextToSpeech.OnInitListener {

    private var tts: TextToSpeech? = null
    private var isInitialized = false
    private var isArabicAvailable = false
    private var currentSpeechRate = 1.0f
    private var onSpeakCompleteCallback: (() -> Unit)? = null

    fun create() {
        if (tts != null) return
        tts = TextToSpeech(context, this)
        AppLogger.voice("جاري تهيئة TTS...")
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            isInitialized = true
            isArabicAvailable = setArabicLanguage()
            AppLogger.voice(
                if (isArabicAvailable) "TTS جاهز — العربية متاحة"
                else "TTS جاهز — العربية غير متاحة، سيتم استخدام اللغة الافتراضية"
            )
        } else {
            AppLogger.error("VOICE", "فشل تهيئة TTS: $status")
        }
    }

    private fun setArabicLanguage(): Boolean {
        val result = tts?.setLanguage(Locale("ar")) ?: TextToSpeech.LANG_MISSING_DATA
        return result >= TextToSpeech.LANG_AVAILABLE
    }

    fun setLanguage(language: String): Boolean {
        if (!isInitialized) return false
        val locale = Locale(language)
        val result = tts?.setLanguage(locale) ?: TextToSpeech.LANG_MISSING_DATA
        return result >= TextToSpeech.LANG_AVAILABLE
    }

    fun setSpeechRate(rate: Float) {
        currentSpeechRate = rate.coerceIn(0.5f, 2.0f)
        tts?.setSpeechRate(currentSpeechRate)
    }

    fun speak(text: String, onComplete: (() -> Unit)? = null) {
        if (!isInitialized) {
            onComplete?.invoke()
            return
        }
        stop()
        onSpeakCompleteCallback = onComplete
        tts?.setOnUtteranceProgressListener(object : android.speech.tts.UtteranceProgressListener() {
            override fun onStart(utteranceId: String?) {}
            override fun onDone(utteranceId: String?) {
                onSpeakCompleteCallback?.invoke()
                onSpeakCompleteCallback = null
            }
            override fun onError(utteranceId: String?) {
                onSpeakCompleteCallback?.invoke()
                onSpeakCompleteCallback = null
            }
        })
        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "abusrar_utterance")
    }

    fun stop() {
        tts?.stop()
        onSpeakCompleteCallback = null
    }

    fun isSpeaking(): Boolean = tts?.isSpeaking == true
    fun isArabicSupported(): Boolean = isArabicAvailable

    fun destroy() {
        stop()
        try { tts?.shutdown() } catch (_: Exception) {}
        tts = null
        isInitialized = false
    }
}
EOF

cat > app/src/main/java/com/abusrar/assistant/voice/VoiceManager.kt << 'EOF'
package com.abusrar.assistant.voice

import android.content.Context

interface VoiceManager {
    fun startListening(
        onResult: (String) -> Unit,
        onError: (String) -> Unit,
        onListeningChanged: (Boolean) -> Unit
    )
    fun stopListening()
    fun speak(text: String, onComplete: (() -> Unit)? = null)
    fun stopSpeaking()
    fun isSpeaking(): Boolean
    fun isListening(): Boolean
    fun setSpeechRate(rate: Float)
    fun setLanguage(language: String)
    fun initialize()
    fun destroy()
}

class VoiceManagerImpl(context: Context) : VoiceManager {

    private val speechRecognizerManager = SpeechRecognizerManager(context)
    private val ttsManager = TTSManager(context)

    override fun initialize() {
        speechRecognizerManager.create()
        ttsManager.create()
    }

    override fun startListening(
        onResult: (String) -> Unit,
        onError: (String) -> Unit,
        onListeningChanged: (Boolean) -> Unit
    ) {
        if (ttsManager.isSpeaking()) ttsManager.stop()
        speechRecognizerManager.setCallbacks(onResult, onError, onListeningChanged)
        speechRecognizerManager.startListening()
    }

    override fun stopListening() = speechRecognizerManager.stopListening()
    override fun speak(text: String, onComplete: (() -> Unit)?) = ttsManager.speak(text, onComplete)
    override fun stopSpeaking() = ttsManager.stop()
    override fun isSpeaking(): Boolean = ttsManager.isSpeaking()
    override fun isListening(): Boolean = speechRecognizerManager.isListening()
    override fun setSpeechRate(rate: Float) = ttsManager.setSpeechRate(rate)
    override fun setLanguage(language: String) = ttsManager.setLanguage(language)

    override fun destroy() {
        speechRecognizerManager.destroy()
        ttsManager.destroy()
    }
}
EOF

echo "  ✅ voice/"

# === Commands ===

cat > app/src/main/java/com/abusrar/assistant/commands/Command.kt << 'EOF'
package com.abusrar.assistant.commands

sealed class Command {
    data object WakeWord : Command()
    data class OpenApp(val appName: String) : Command()
    data object GoHome : Command()
    data object GoBack : Command()
    data object OpenSettings : Command()
    data class SearchWeb(val query: String) : Command()
    data class MakeCall(val target: String) : Command()
    data class SendSms(val target: String, val message: String) : Command()
    data class Unknown(val text: String) : Command()
}

data class ParseResult(
    val containsWakeWord: Boolean,
    val command: Command
)
EOF

cat > app/src/main/java/com/abusrar/assistant/commands/CommandParser.kt << 'EOF'
package com.abusrar.assistant.commands

import com.abusrar.assistant.core.AppLogger

class CommandParser {

    companion object {
        private const val WAKE_WORD = "ابو صرار"
        private const val WAKE_WORD_ALT = "أبو صرار"
        private const val WAKE_WORD_FULL = "ابوصرار"
        private const val WAKE_WORD_FULL_ALT = "أبوصرار"
    }

    fun parse(input: String): ParseResult {
        val normalized = normalizeArabic(input)
        AppLogger.command("النص المحوّل: '$normalized'")

        val containsWakeWord = checkWakeWord(normalized)
        val textWithoutWakeWord = if (containsWakeWord) removeWakeWord(normalized) else normalized
        val trimmed = textWithoutWakeWord.trim()

        val command = if (trimmed.isEmpty()) {
            Command.WakeWord
        } else {
            parseCommand(trimmed)
        }

        return ParseResult(containsWakeWord, command)
    }

    private fun checkWakeWord(text: String): Boolean {
        return text.contains(WAKE_WORD) ||
                text.contains(WAKE_WORD_ALT) ||
                text.contains(WAKE_WORD_FULL) ||
                text.contains(WAKE_WORD_FULL_ALT)
    }

    private fun removeWakeWord(text: String): String {
        var result = text
        result = result.replace(WAKE_WORD_ALT, " ")
        result = result.replace(WAKE_WORD, " ")
        result = result.replace(WAKE_WORD_FULL_ALT, " ")
        result = result.replace(WAKE_WORD_FULL, " ")
        return result
    }

    private fun parseCommand(text: String): Command {
        return when {
            text.startsWith("افتح الاعدادات") || text.startsWith("افتح الإعدادات") ->
                Command.OpenSettings

            text.startsWith("افتح") ->
                Command.OpenApp(extractAppName(text.removePrefix("افتح").trim()))

            text.contains("الرئيسية") || text.contains("الشاشة الرئيسية") || text == "رئيسي" ->
                Command.GoHome

            text == "ارجع" || text == "رجوع" || text == "خلف" || text == "للخلف" ->
                Command.GoBack

            text.startsWith("ابحث عن") || text.startsWith("ابحث في") ->
                Command.SearchWeb(extractSearchQuery(text))

            text.startsWith("اتصل ب") || text.startsWith("اتصل على") ->
                Command.MakeCall(extractCallTarget(text))

            text.startsWith("ارسل رسالة") || text.startsWith("أرسل رسالة") ->
                parseSmsCommand(text)

            else -> Command.Unknown(text)
        }
    }

    private fun parseSmsCommand(text: String): Command.SendSms {
        val withoutPrefix = text
            .replace("ارسل رسالة", "")
            .replace("أرسل رسالة", "")
            .trim()

        val target = extractUntilKeyword(withoutPrefix, listOf("واقول", "وقل", "نص", "مضمون"))
        val message = if (withoutPrefix.length > target.length) {
            withoutPrefix.removePrefix(target).trim()
                .removePrefix("واقول").removePrefix("وقل")
                .removePrefix("نص").removePrefix("مضمون")
                .trim()
        } else {
            ""
        }
        return Command.SendSms(target.trim(), message)
    }

    private fun extractAppName(text: String): String = text.trim()

    private fun extractSearchQuery(text: String): String =
        text.replace("ابحث عن", "").replace("ابحث في", "").trim()

    private fun extractCallTarget(text: String): String =
        text.replace("اتصل ب", "").replace("اتصل على", "").trim()

    private fun extractUntilKeyword(text: String, keywords: List<String>): String {
        for (keyword in keywords) {
            val index = text.indexOf(keyword)
            if (index > 0) return text.substring(0, index)
        }
        return text
    }

    private fun normalizeArabic(text: String): String {
        return text
            .replace(Regex("[\\u0610-\\u061A\\u064B-\\u065F\\u0670]"), "")
            .replace('أ', 'ا').replace('إ', 'ا').replace('آ', 'ا')
            .replace('ة', 'ه').replace('ى', 'ي')
            .replace(Regex("\\s+"), " ")
            .trim()
    }
}
EOF

cat > app/src/main/java/com/abusrar/assistant/commands/CommandRouter.kt << 'EOF'
package com.abusrar.assistant.commands

import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult
import com.abusrar.assistant.tools.ToolRegistry

class CommandRouter(private val toolRegistry: ToolRegistry) {

    fun route(command: Command): AppResult<String> {
        AppLogger.command("توجيه الأمر: ${command::class.simpleName}")

        val tool = toolRegistry.findTool(command)
        if (tool != null) {
            AppLogger.command("الأداة المختارة: ${tool.name}")
            return tool.execute(command)
        }

        return when (command) {
            is Command.WakeWord -> AppResult.Success("wake_word")
            is Command.Unknown -> AppResult.Error("ما فهمت الأمر: ${command.text}")
            else -> AppResult.Error("لا يوجد أداة مناسبة لهذا الأمر")
        }
    }
}
EOF

echo "  ✅ commands/"

# === Tools ===

cat > app/src/main/java/com/abusrar/assistant/tools/Tool.kt << 'EOF'
package com.abusrar.assistant.tools

import com.abusrar.assistant.commands.Command
import com.abusrar.assistant.core.AppResult
import com.abusrar.assistant.core.AppLogger

interface Tool {
    val name: String
    val description: String
    fun canHandle(command: Command): Boolean
    fun execute(command: Command): AppResult<String>
}

class ToolRegistry {

    private val tools = mutableListOf<Tool>()

    fun register(tool: Tool) {
        tools.add(tool)
        AppLogger.tool("تم تسجيل الأداة: ${tool.name}")
    }

    fun unregister(toolName: String) {
        tools.removeAll { it.name == toolName }
    }

    fun findTool(command: Command): Tool? {
        return tools.find { it.canHandle(command) }
    }

    fun getAllTools(): List<Tool> = tools.toList()
}
EOF

cat > app/src/main/java/com/abusrar/assistant/tools/ToolExecutor.kt << 'EOF'
package com.abusrar.assistant.tools

import com.abusrar.assistant.commands.Command
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

class ToolExecutor(private val toolRegistry: ToolRegistry) {

    fun execute(command: Command): AppResult<String> {
        val tool = toolRegistry.findTool(command)
        return if (tool != null) {
            AppLogger.tool("تنفيذ الأداة: ${tool.name}")
            try {
                tool.execute(command)
            } catch (e: Exception) {
                AppLogger.error("TOOL", "خطأ في تنفيذ ${tool.name}", e)
                AppResult.Error("ما قدرت أنفذ الأمر: ${e.message}")
            }
        } else {
            AppLogger.warn("TOOL", "لا توجد أداة مناسبة للأمر")
            AppResult.Error("ما لقيت أداة مناسبة لهذا الأمر")
        }
    }
}
EOF

cat > app/src/main/java/com/abusrar/assistant/tools/OpenAppTool.kt << 'EOF'
package com.abusrar.assistant.tools

import android.content.Context
import com.abusrar.assistant.apps.AppLauncher
import com.abusrar.assistant.commands.Command
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

class OpenAppTool(private val context: Context) : Tool {

    private val appLauncher = AppLauncher(context)

    override val name: String = "open_app"
    override val description: String = "فتح تطبيق مثبت على الجهاز"

    override fun canHandle(command: Command): Boolean = command is Command.OpenApp

    override fun execute(command: Command): AppResult<String> {
        if (command !is Command.OpenApp) {
            return AppResult.Error("أمر غير صحيح لهذه الأداة")
        }
        AppLogger.tool("محاولة فتح: ${command.appName}")
        return appLauncher.launch(command.appName)
    }
}
EOF

cat > app/src/main/java/com/abusrar/assistant/tools/NavigationTools.kt << 'EOF'
package com.abusrar.assistant.tools

import android.content.Context
import android.content.Intent
import com.abusrar.assistant.commands.Command
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

class HomeTool(private val context: Context) : Tool {

    override val name: String = "go_home"
    override val description: String = "الرجوع للشاشة الرئيسية"

    override fun canHandle(command: Command): Boolean = command is Command.GoHome

    override fun execute(command: Command): AppResult<String> {
        return try {
            val intent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            AppLogger.tool("تم الرجوع للشاشة الرئيسية")
            AppResult.Success("تم الرجوع للشاشة الرئيسية")
        } catch (e: Exception) {
            AppLogger.error("TOOL", "فشل الرجوع للرئيسية", e)
            AppResult.Error("ما قدرت أرجع للشاشة الرئيسية")
        }
    }
}

class BackTool(private val context: Context) : Tool {

    override val name: String = "go_back"
    override val description: String = "الرجوع للخلف"

    override fun canHandle(command: Command): Boolean = command is Command.GoBack

    override fun execute(command: Command): AppResult<String> {
        AppLogger.warn("TOOL", "أمر الرجوع يتطلب Accessibility Service للعمل بشكل كامل")
        return AppResult.Error("أمر الرجوع يحتاج تفعيل خدمة إمكانية الوصول")
    }
}

class SettingsTool(private val context: Context) : Tool {

    override val name: String = "open_settings"
    override val description: String = "فتح إعدادات النظام"

    override fun canHandle(command: Command): Boolean = command is Command.OpenSettings

    override fun execute(command: Command): AppResult<String> {
        return try {
            val intent = Intent(android.provider.Settings.ACTION_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            AppLogger.tool("تم فتح الإعدادات")
            AppResult.Success("تم فتح الإعدادات")
        } catch (e: Exception) {
            AppLogger.error("TOOL", "فشل فتح الإعدادات", e)
            AppResult.Error("ما قدرت أفتح الإعدادات")
        }
    }
}
EOF

cat > app/src/main/java/com/abusrar/assistant/tools/WebSearchTool.kt << 'EOF'
package com.abusrar.assistant.tools

import android.content.Context
import android.content.Intent
import android.net.Uri
import com.abusrar.assistant.commands.Command
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

class WebSearchTool(private val context: Context) : Tool {

    override val name: String = "web_search"
    override val description: String = "البحث في الويب"

    override fun canHandle(command: Command): Boolean = command is Command.SearchWeb

    override fun execute(command: Command): AppResult<String> {
        if (command !is Command.SearchWeb) return AppResult.Error("أمر غير صحيح")

        val query = command.query
        if (query.isBlank()) return AppResult.Error("ما قلت لي أبحث عن أيش")

        return try {
            val encodedQuery = Uri.encode(query)
            val uri = Uri.parse("https://www.google.com/search?q=$encodedQuery")
            val intent = Intent(Intent.ACTION_VIEW, uri).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            AppLogger.tool("تم البحث عن: $query")
            AppResult.Success("تم فتح البحث عن: $query")
        } catch (e: Exception) {
            AppLogger.error("TOOL", "فشل فتح البحث", e)
            AppResult.Error("ما قدرت أفتح البحث")
        }
    }
}
EOF

cat > app/src/main/java/com/abusrar/assistant/tools/CommunicationTools.kt << 'EOF'
package com.abusrar.assistant.tools

import android.content.Context
import android.content.Intent
import android.net.Uri
import com.abusrar.assistant.commands.Command
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

class CallTool(private val context: Context) : Tool {

    override val name: String = "make_call"
    override val description: String = "إجراء مكالمة هاتفية"

    override fun canHandle(command: Command): Boolean = command is Command.MakeCall

    override fun execute(command: Command): AppResult<String> {
        if (command !is Command.MakeCall) return AppResult.Error("أمر غير صحيح")

        val target = command.target.trim()
        if (target.isBlank()) return AppResult.Error("ما قلت لي اتصل بمن")

        val phoneNumber = target.filter { it.isDigit() || it == '+' }

        return if (phoneNumber.length >= 8) {
            try {
                val intent = Intent(Intent.ACTION_CALL, Uri.parse("tel:$phoneNumber")).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(intent)
                AppLogger.tool("تم الاتصال بـ: $phoneNumber")
                AppResult.Success("جاري الاتصال بـ $target")
            } catch (e: SecurityException) {
                AppLogger.error("TOOL", "صلاحية الاتصال مرفوضة", e)
                AppResult.Error("ما عندي صلاحية إجراء مكالمات. فعّلها من الإعدادات")
            } catch (e: Exception) {
                AppResult.Error("ما قدرت أتصل")
            }
        } else {
            AppResult.Error("البحث عن اسم جهة اتصال يكون متاح في تحديث لاحق. قل الرقم مباشرة")
        }
    }
}

class SmsTool(private val context: Context) : Tool {

    override val name: String = "send_sms"
    override val description: String = "إرسال رسالة SMS"

    override fun canHandle(command: Command): Boolean = command is Command.SendSms

    override fun execute(command: Command): AppResult<String> {
        if (command !is Command.SendSms) return AppResult.Error("أمر غير صحيح")

        val target = command.target.trim()
        val message = command.message.trim()

        if (target.isBlank()) return AppResult.Error("ما قلت لي أرسل لمن")

        return try {
            val phoneNumber = target.filter { it.isDigit() || it == '+' }
            if (phoneNumber.length < 8) return AppResult.Error("الرجاء إعطاء رقم هاتف صحيح")

            val uri = Uri.parse("smsto:$phoneNumber")
            val intent = Intent(Intent.ACTION_SENDTO, uri).apply {
                putExtra("sms_body", message)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            AppLogger.tool("تم فتح الرسائل لـ: $phoneNumber")
            AppResult.Success("تم فتح الرسائل. الرسالة جاهزة للإرسال")
        } catch (e: Exception) {
            AppResult.Error("ما قدرت أفتح الرسائل")
        }
    }
}
EOF

echo "  ✅ tools/"

# === Apps ===

cat > app/src/main/java/com/abusrar/assistant/apps/AppResolver.kt << 'EOF'
package com.abusrar.assistant.apps

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import com.abusrar.assistant.core.AppLogger

class AppResolver(private val context: Context) {

    private val packageManager: PackageManager = context.packageManager

    companion object {
        private val APP_NAME_MAP = mapOf(
            "واتساب" to "com.whatsapp",
            "واتساب بزنس" to "com.whatsapp.w4b",
            "يوتيوب" to "com.google.android.youtube",
            "يوتيوب كيدز" to "com.google.android.apps.youtube.kids",
            "يوتيوب ميوزك" to "com.google.android.apps.youtube.music",
            "فيسبوك" to "com.facebook.katana",
            "انستغرام" to "com.instagram.android",
            "انستقرام" to "com.instagram.android",
            "تويتر" to "com.twitter.android",
            "إكس" to "com.twitter.android",
            "اكس" to "com.twitter.android",
            "تيك توك" to "com.zhiliaoapp.musically",
            "تيكتوك" to "com.zhiliaoapp.musically",
            "سناب شات" to "com.snapchat.android",
            "سنابشات" to "com.snapchat.android",
            "تيليجرام" to "org.telegram.messenger",
            "تلجرام" to "org.telegram.messenger",
            "جوجل" to "com.google.android.googlequicksearchbox",
            "كروم" to "com.android.chrome",
            "متصفح كروم" to "com.android.chrome",
            "فايرفوكس" to "org.mozilla.firefox",
            "فايبر" to "com.viber.voip",
            "لاين" to "jp.naver.line.android",
            "ساوند كلاود" to "com.soundcloud.android",
            "سبوتيفاي" to "com.spotify.music",
            "نيتفلكس" to "com.netflix.mediaclient",
            "شاهيد" to "net.shahid.android",
            "الاعدادات" to "com.android.settings",
            "الإعدادات" to "com.android.settings",
            "اعدادات" to "com.android.settings",
            "الكاميرا" to "com.android.camera",
            "الصور" to "com.google.android.apps.photos",
            "المعرض" to "com.google.android.apps.photos",
            "الهاتف" to "com.android.dialer",
            "الرسائل" to "com.google.android.apps.messaging",
            "البريد" to "com.google.android.gm",
            "جيميل" to "com.google.android.gm",
            "الساعة" to "com.android.deskclock",
            "ساعة" to "com.android.deskclock",
            "حاسبة" to "com.android.calculator2",
            "فيديو" to "com.google.android.videos",
            "خرائط" to "com.google.android.apps.maps",
            "خرائط جوجل" to "com.google.android.apps.maps",
            "جوجل مابس" to "com.google.android.apps.maps",
            "مابس" to "com.google.android.apps.maps",
            "بلاي ستور" to "com.android.vending",
            "متجر بلاي" to "com.android.vending",
            "متجر التطبيقات" to "com.android.vending",
            "واتسباد" to "com.whatsapp.w4b",
            "ديسكورد" to "com.discord",
            "سلاك" to "com.Slack",
            "زووم" to "us.zoom.videomeetings",
            "مايكروسوفت تيمز" to "com.microsoft.teams",
            "لينكد إن" to "com.linkedin.android",
            "بنترست" to "com.pinterest",
            "ريدت" to "com.reddit.frontpage",
            "واتس" to "com.whatsapp",
            "انستا" to "com.instagram.android",
        )
    }

    fun resolve(appName: String): ResolveResult {
        val normalized = normalizeForMatch(appName)
        AppLogger.debug("APPS", "حل اسم التطبيق: '$appName' → '$normalized'")

        APP_NAME_MAP[normalized]?.let { packageName ->
            if (isPackageInstalled(packageName)) {
                AppLogger.debug("APPS", "تم العثور في الخريطة: $packageName")
                return ResolveResult.Found(packageName)
            }
        }

        for ((name, packageName) in APP_NAME_MAP) {
            if (name.contains(normalized) || normalized.contains(name)) {
                if (isPackageInstalled(packageName)) {
                    AppLogger.debug("APPS", "تم العثور ببحث جزئي: $packageName")
                    return ResolveResult.Found(packageName)
                }
            }
        }

        val installedMatch = searchInstalledApps(normalized)
        if (installedMatch != null) {
            AppLogger.debug("APPS", "تم العثور في التطبيقات المثبتة: $installedMatch")
            return ResolveResult.Found(installedMatch)
        }

        AppLogger.warn("APPS", "لم يتم العثور على التطبيق: $appName")
        return ResolveResult.NotFound(appName)
    }

    private fun searchInstalledApps(appName: String): String? {
        return try {
            val intent = Intent(Intent.ACTION_MAIN, null).apply {
                addCategory(Intent.CATEGORY_LAUNCHER)
            }
            val resolveInfos = packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
            for (resolveInfo in resolveInfos) {
                val label = resolveInfo.loadLabel(packageManager).toString()
                val normalizedLabel = normalizeForMatch(label)
                if (normalizedLabel == appName ||
                    normalizedLabel.contains(appName) ||
                    appName.contains(normalizedLabel)
                ) {
                    return resolveInfo.activityInfo.packageName
                }
            }
            null
        } catch (e: Exception) {
            AppLogger.error("APPS", "خطأ في البحث عن التطبيقات المثبتة", e)
            null
        }
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun normalizeForMatch(text: String): String {
        return text
            .replace("ة", "ه").replace("أ", "ا").replace("إ", "ا")
            .replace("آ", "ا").replace("ى", "ي")
            .replace(Regex("\\s+"), "").lowercase()
    }

    sealed class ResolveResult {
        data class Found(val packageName: String) : ResolveResult()
        data class NotFound(val appName: String) : ResolveResult()
    }
}
EOF

cat > app/src/main/java/com/abusrar/assistant/apps/AppLauncher.kt << 'EOF'
package com.abusrar.assistant.apps

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

class AppLauncher(private val context: Context) {

    private val appResolver = AppResolver(context)
    private val packageManager: PackageManager = context.packageManager

    fun launch(appName: String): AppResult<String> {
        if (appName.isBlank()) return AppResult.Error("ما قلت لي أفتح أيش")

        return when (val result = appResolver.resolve(appName)) {
            is AppResolver.ResolveResult.Found -> launchPackage(result.packageName, appName)
            is AppResolver.ResolveResult.NotFound -> {
                val message = "ما لقيت $appName على الجهاز"
                AppLogger.warn("APPS", message)
                AppResult.Error(message)
            }
        }
    }

    private fun launchPackage(packageName: String, displayName: String): AppResult<String> {
        return try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
                val message = "تم فتح $displayName"
                AppLogger.info("APPS", message)
                AppResult.Success(message)
            } else {
                AppResult.Error("التطبيق موجود لكن ما قدرت أفتحه")
            }
        } catch (e: Exception) {
            AppLogger.error("APPS", "فشل فتح $packageName", e)
            AppResult.Error("حصل خطأ وأنا أحاول أفتح $displayName")
        }
    }

    fun getInstalledApps(): List<AppInfo> {
        val apps = mutableListOf<AppInfo>()
        try {
            val intent = Intent(Intent.ACTION_MAIN, null).apply {
                addCategory(Intent.CATEGORY_LAUNCHER)
            }
            val resolveInfos = packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
            for (info in resolveInfos) {
                apps.add(AppInfo(name = info.loadLabel(packageManager).toString(), packageName = info.activityInfo.packageName))
            }
            apps.sortBy { it.name.lowercase() }
        } catch (e: Exception) {
            AppLogger.error("APPS", "خطأ في جلب التطبيقات", e)
        }
        return apps
    }

    data class AppInfo(val name: String, val packageName: String)
}
EOF

cat > app/src/main/java/com/abusrar/assistant/apps/WhatsAppController.kt << 'EOF'
package com.abusrar.assistant.apps

import android.content.Context
import android.content.Intent
import android.net.Uri
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

class WhatsAppController(private val context: Context) {

    companion object {
        const val PACKAGE_WHATSAPP = "com.whatsapp"
    }

    fun openWhatsApp(): AppResult<String> {
        return try {
            val intent = context.packageManager.getLaunchIntentForPackage(PACKAGE_WHATSAPP)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
                AppLogger.info("WHATSAPP", "تم فتح واتساب")
                AppResult.Success("تم فتح واتساب")
            } else {
                AppResult.Error("ما لقيت واتساب على الجهاز")
            }
        } catch (e: Exception) {
            AppLogger.error("WHATSAPP", "فشل فتح واتساب", e)
            AppResult.Error("ما قدرت أفتح واتساب")
        }
    }

    fun openChatWith(phoneNumber: String): AppResult<String> {
        return try {
            val uri = Uri.parse("https://wa.me/$phoneNumber")
            val intent = Intent(Intent.ACTION_VIEW, uri).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            AppResult.Success("تم فتح محادثة واتساب")
        } catch (e: Exception) {
            AppResult.Error("ما قدرت أفتح المحادثة")
        }
    }

    // TODO: V4 - البحث عن جهة اتصال داخل واتساب
    // TODO: V4 - كتابة رسالة وإرسالها
}
EOF

echo "  ✅ apps/"

# === Accessibility ===

cat > app/src/main/java/com/abusrar/assistant/accessibility/AbuSrarAccessibilityService.kt << 'EOF'
package com.abusrar.assistant.accessibility

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import com.abusrar.assistant.core.AppLogger

class AbuSrarAccessibilityService : AccessibilityService() {

    override fun onServiceConnected() {
        super.onServiceConnected()
        AppLogger.accessibility("تم تشغيل خدمة إمكانية الوصول")
        AccessibilityController.setServiceInstance(this)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // TODO: V3 - معالجة الأحداث لأتمتة التطبيقات
    }

    override fun onInterrupt() {
        AppLogger.warn("ACCESSIBILITY", "تم مقاطعة الخدمة")
    }

    override fun onDestroy() {
        super.onDestroy()
        AccessibilityController.clearServiceInstance()
        AppLogger.accessibility("تم إيقاف خدمة إمكانية الوصول")
    }
}
EOF

cat > app/src/main/java/com/abusrar/assistant/accessibility/AccessibilityController.kt << 'EOF'
package com.abusrar.assistant.accessibility

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.provider.Settings
import com.abusrar.assistant.core.AppLogger

object AccessibilityController {

    private var serviceInstance: AccessibilityService? = null

    fun setServiceInstance(service: AccessibilityService) {
        serviceInstance = service
    }

    fun clearServiceInstance() {
        serviceInstance = null
    }

    fun isServiceRunning(): Boolean = serviceInstance != null

    fun openAccessibilitySettings(context: Context) {
        try {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            AppLogger.accessibility("تم فتح إعدادات إمكانية الوصول")
        } catch (e: Exception) {
            AppLogger.error("ACCESSIBILITY", "فشل فتح إعدادات إمكانية الوصول", e)
        }
    }

    // TODO: V3 - clickByText, typeInField, performBack, performHome, scrollDown
}
EOF

echo "  ✅ accessibility/"

# === AI ===

cat > app/src/main/java/com/abusrar/assistant/ai/AIProvider.kt << 'EOF'
package com.abusrar.assistant.ai

interface AIProvider {
    val name: String
    val isAvailable: Boolean
    val capabilities: ModelCapabilities
    suspend fun chat(request: AIRequest): AIResponse
    fun initialize(config: Map<String, String>)
    fun shutdown()
}

interface ChatProvider : AIProvider {
    suspend fun sendMessage(message: String, context: List<ChatMessage> = emptyList()): AIResponse
    fun clearHistory()
}

data class ChatMessage(
    val role: MessageRole,
    val content: String,
    val timestamp: Long = System.currentTimeMillis()
)

enum class MessageRole { SYSTEM, USER, ASSISTANT }

data class AIRequest(
    val prompt: String,
    val systemPrompt: String? = null,
    val temperature: Float = 0.7f,
    val maxTokens: Int = 1000,
    val metadata: Map<String, String> = emptyMap()
)

data class AIResponse(
    val text: String,
    val isSuccess: Boolean,
    val errorMessage: String? = null,
    val metadata: Map<String, String> = emptyMap(),
    val usage: TokenUsage? = null
)

data class TokenUsage(
    val promptTokens: Int,
    val completionTokens: Int,
    val totalTokens: Int
)

data class ModelCapabilities(
    val supportsChat: Boolean = false,
    val supportsVision: Boolean = false,
    val supportsFunctionCalling: Boolean = false,
    val supportsStreaming: Boolean = false,
    val maxContextTokens: Int = 0,
    val isOffline: Boolean = false,
    val supportsArabic: Boolean = false
)
EOF

cat > app/src/main/java/com/abusrar/assistant/ai/ProviderManager.kt << 'EOF'
package com.abusrar.assistant.ai

import com.abusrar.assistant.core.AppLogger

class ProviderManager {

    private val providers = mutableMapOf<String, AIProvider>()
    private var activeProviderName: String? = null

    fun registerProvider(provider: AIProvider) {
        providers[provider.name] = provider
        AppLogger.ai("تم تسجيل AI Provider: ${provider.name}")
    }

    fun unregisterProvider(name: String) {
        providers.remove(name)?.shutdown()
        if (activeProviderName == name) activeProviderName = null
    }

    fun setActiveProvider(name: String): Boolean {
        val provider = providers[name]
        return if (provider != null && provider.isAvailable) {
            activeProviderName = name
            AppLogger.ai("تم تفعيل AI Provider: $name")
            true
        } else {
            AppLogger.warn("AI", "Provider غير متاح: $name")
            false
        }
    }

    fun getActiveProvider(): AIProvider? = activeProviderName?.let { providers[it] }
    fun getProvider(name: String): AIProvider? = providers[name]
    fun getAvailableProviders(): List<AIProvider> = providers.values.filter { it.isAvailable }
    fun getAllProviders(): List<AIProvider> = providers.values.toList()

    suspend fun chat(request: AIRequest): AIResponse {
        val provider = getActiveProvider()
        return if (provider != null) {
            try {
                provider.chat(request)
            } catch (e: Exception) {
                AppLogger.error("AI", "خطأ من ${provider.name}", e)
                AIResponse(text = "", isSuccess = false, errorMessage = "خطأ في ${provider.name}: ${e.message}")
            }
        } else {
            AIResponse(text = "", isSuccess = false, errorMessage = "لا يوجد مزود ذكاء اصطناعي مفعل")
        }
    }
}
EOF

cat > app/src/main/java/com/abusrar/assistant/ai/RuleBasedProvider.kt << 'EOF'
package com.abusrar.assistant.ai

import com.abusrar.assistant.core.AppLogger

class RuleBasedProvider : AIProvider {

    override val name: String = "rule_based"
    override val isAvailable: Boolean = true
    override val capabilities: ModelCapabilities = ModelCapabilities(
        supportsChat = true, isOffline = true, supportsArabic = true
    )

    private val responses = mapOf(
        Regex("(مرحبا|السلام عليكم|هاي|هلا|أهلا)") to "أهلاً وسهلاً سيدي.",
        Regex("(كيف حالك|شلونك|عامل إيه|كيفك)") to "الحمد لله بخير، كيف أقدر أساعدك؟",
        Regex("(شكرا|شكراً|مشكور|يعطيك العافية)") to "العفو سيدي، بالخدمة.",
        Regex("(من أنت|مين أنت|إنت مين|شو اسمك)") to "أنا أبو صرار، مساعدك الصوتي.",
        Regex("(ماذا تستطيع|ايش تسوي|شو بتقدر تعمل)") to "أقدر أفتح التطبيقات، أبحث في الويب، وأتصل وأرسل رسائل.",
    )

    override suspend fun chat(request: AIRequest): AIResponse {
        val input = request.prompt.trim()
        AppLogger.ai("RuleBased معالجة: $input")
        for ((pattern, response) in responses) {
            if (pattern.containsMatchIn(input)) {
                return AIResponse(text = response, isSuccess = true)
            }
        }
        return AIResponse(
            text = "ما فهمت قصدك سيدي. جرب تقول مثلاً افتح واتساب أو ابحث عن شي.",
            isSuccess = true
        )
    }

    override fun initialize(config: Map<String, String>) {}
    override fun shutdown() {}
}
EOF

echo "  ✅ ai/"

# === Permissions ===

cat > app/src/main/java/com/abusrar/assistant/permissions/PermissionManager.kt << 'EOF'
package com.abusrar.assistant.permissions

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat

class PermissionManager(private val context: Context) {

    enum class Permission(
        val manifestPermission: String,
        val titleAr: String,
        val descriptionAr: String,
        val isRequired: Boolean,
        val minSdk: Int = 0
    ) {
        MICROPHONE(Manifest.permission.RECORD_AUDIO, "الميكروفون", "لاستقبال صوتك وتحويله إلى أوامر نصية", true),
        NOTIFICATION(Manifest.permission.POST_NOTIFICATIONS, "الإشعارات", "لإرسال إشعارات عند الحاجة", false, Build.VERSION_CODES.TIRAMISU),
        CALL_PHONE(Manifest.permission.CALL_PHONE, "الاتصال الهاتفي", "لإجراء مكالمات هاتفية عند طلبك", false),
        SEND_SMS(Manifest.permission.SEND_SMS, "إرسال الرسائل", "لإرسال رسائل SMS عند طلبك", false),
        CONTACTS(Manifest.permission.READ_CONTACTS, "جهات الاتصال", "للبحث عن أسماء جهات الاتصال", false)
    }

    fun isPermissionGranted(permission: Permission): Boolean {
        if (Build.VERSION.SDK_INT < permission.minSdk) return true
        return ContextCompat.checkSelfPermission(context, permission.manifestPermission) == PackageManager.PERMISSION_GRANTED
    }

    fun getRequiredPermissions(): List<Permission> = Permission.entries.filter { it.isRequired && Build.VERSION.SDK_INT >= it.minSdk }
    fun getOptionalPermissions(): List<Permission> = Permission.entries.filter { !it.isRequired && Build.VERSION.SDK_INT >= it.minSdk }
    fun getMissingPermissions(): List<Permission> = Permission.entries.filter { !isPermissionGranted(it) && Build.VERSION.SDK_INT >= it.minSdk }
    fun getMissingRequiredPermissions(): List<Permission> = getRequiredPermissions().filter { !isPermissionGranted(it) }
    fun hasAllRequiredPermissions(): Boolean = getMissingRequiredPermissions().isEmpty()

    fun getPermissionArray(permissions: List<Permission>): Array<String> {
        return permissions.filter { Build.VERSION.SDK_INT >= it.minSdk }.map { it.manifestPermission }.toTypedArray()
    }
}
EOF

echo "  ✅ permissions/"

# === Settings ===

cat > app/src/main/java/com/abusrar/assistant/settings/SettingsManager.kt << 'EOF'
package com.abusrar.assistant.settings

import android.content.Context
import android.content.SharedPreferences

class SettingsManager(context: Context) {

    private val prefs: SharedPreferences = context.getSharedPreferences("abusrar_settings", Context.MODE_PRIVATE)

    companion object {
        private const val KEY_VOICE_ENABLED = "voice_enabled"
        private const val KEY_SPEECH_RATE = "speech_rate"
        private const val KEY_LISTENING_LANGUAGE = "listening_language"
        private const val KEY_WAKE_WORD_MODE = "wake_word_mode"
        private const val KEY_AI_PROVIDER = "ai_provider"
        private const val KEY_API_KEY = "api_key"
        private const val KEY_API_URL = "api_url"
        private const val KEY_LOG_ENABLED = "log_enabled"
    }

    var isVoiceEnabled: Boolean
        get() = prefs.getBoolean(KEY_VOICE_ENABLED, true)
        set(value) = prefs.edit().putBoolean(KEY_VOICE_ENABLED, value).apply()

    var speechRate: Float
        get() = prefs.getFloat(KEY_SPEECH_RATE, 1.0f)
        set(value) = prefs.edit().putFloat(KEY_SPEECH_RATE, value.coerceIn(0.5f, 2.0f)).apply()

    var listeningLanguage: String
        get() = prefs.getString(KEY_LISTENING_LANGUAGE, "ar-SA") ?: "ar-SA"
        set(value) = prefs.edit().putString(KEY_LISTENING_LANGUAGE, value).apply()

    var wakeWordMode: String
        get() = prefs.getString(KEY_WAKE_WORD_MODE, "button") ?: "button"
        set(value) = prefs.edit().putString(KEY_WAKE_WORD_MODE, value).apply()

    var aiProvider: String
        get() = prefs.getString(KEY_AI_PROVIDER, "rule_based") ?: "rule_based"
        set(value) = prefs.edit().putString(KEY_AI_PROVIDER, value).apply()

    var apiKey: String
        get() = prefs.getString(KEY_API_KEY, "") ?: ""
        set(value) = prefs.edit().putString(KEY_API_KEY, value).apply()

    var apiUrl: String
        get() = prefs.getString(KEY_API_URL, "") ?: ""
        set(value) = prefs.edit().putString(KEY_API_URL, value).apply()

    var isLogEnabled: Boolean
        get() = prefs.getBoolean(KEY_LOG_ENABLED, true)
        set(value) = prefs.edit().putBoolean(KEY_LOG_ENABLED, value).apply()

    fun clearAll() = prefs.edit().clear().apply()
}
EOF

cat > app/src/main/java/com/abusrar/assistant/settings/SettingsViewModel.kt << 'EOF'
package com.abusrar.assistant.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.abusrar.assistant.accessibility.AccessibilityController

class SettingsViewModel(private val settingsManager: SettingsManager) : ViewModel() {

    val isVoiceEnabled: Boolean get() = settingsManager.isVoiceEnabled
    val speechRate: Float get() = settingsManager.speechRate
    val listeningLanguage: String get() = settingsManager.listeningLanguage
    val wakeWordMode: String get() = settingsManager.wakeWordMode
    val aiProvider: String get() = settingsManager.aiProvider
    val apiUrl: String get() = settingsManager.apiUrl
    val apiKey: String get() = settingsManager.apiKey
    val isLogEnabled: Boolean get() = settingsManager.isLogEnabled

    fun setVoiceEnabled(enabled: Boolean) { settingsManager.isVoiceEnabled = enabled }
    fun setSpeechRate(rate: Float) { settingsManager.speechRate = rate }
    fun setListeningLanguage(language: String) { settingsManager.listeningLanguage = language }
    fun setWakeWordMode(mode: String) { settingsManager.wakeWordMode = mode }
    fun setAiProvider(provider: String) { settingsManager.aiProvider = provider }
    fun setApiUrl(url: String) { settingsManager.apiUrl = url }
    fun setApiKey(key: String) { settingsManager.apiKey = key }
    fun setLogEnabled(enabled: Boolean) { settingsManager.isLogEnabled = enabled }
    fun isAccessibilityServiceRunning(): Boolean = AccessibilityController.isServiceRunning()

    @Suppress("UNCHECKED_CAST")
    class Factory(private val settingsManager: SettingsManager) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T = SettingsViewModel(settingsManager) as T
    }
}
EOF

cat > app/src/main/java/com/abusrar/assistant/settings/SettingsActivity.kt << 'EOF'
package com.abusrar.assistant.settings

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.abusrar.assistant.accessibility.AccessibilityController
import com.abusrar.assistant.ui.theme.AbuSrarTheme

class SettingsActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val viewModel = SettingsViewModel(SettingsManager(this))
        setContent {
            AbuSrarTheme {
                SettingsScreen(viewModel = viewModel, onBack = { finish() })
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SettingsScreen(viewModel: SettingsViewModel, onBack: () -> Unit) {
    val context = LocalContext.current
    var speechRate by remember { mutableFloatStateOf(viewModel.speechRate) }
    var voiceEnabled by remember { mutableStateOf(viewModel.isVoiceEnabled) }
    var logEnabled by remember { mutableStateOf(viewModel.isLogEnabled) }
    var selectedLanguage by remember { mutableStateOf(viewModel.listeningLanguage) }
    var selectedWakeMode by remember { mutableStateOf(viewModel.wakeWordMode) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("الإعدادات") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "رجوع")
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // الصوت
            Text("الصوت", style = MaterialTheme.typography.titleMedium, color = MaterialTheme.colorScheme.primary)

            Card(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text("الرد الصوتي")
                        Text("تشغيل أو إيقاف صوت المساعد", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                    Switch(checked = voiceEnabled, onCheckedChange = { voiceEnabled = it; viewModel.setVoiceEnabled(it) })
                }
            }

            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("سرعة الصوت: ${"%.1f".format(speechRate)}")
                    Slider(value = speechRate, onValueChange = { speechRate = it; viewModel.setSpeechRate(it) }, valueRange = 0.5f..2.0f, steps = 5)
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("بطيء", style = MaterialTheme.typography.labelSmall)
                        Text("سريع", style = MaterialTheme.typography.labelSmall)
                    }
                }
            }

            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("لغة الاستماع")
                    Spacer(modifier = Modifier.height(8.dp))
                    listOf("ar-SA" to "العربية (السعودية)", "ar-AE" to "العربية (الإمارات)", "ar-EG" to "العربية (مصر)", "en-US" to "الإنجليزية (أمريكا)").forEach { (code, label) ->
                        Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), verticalAlignment = Alignment.CenterVertically) {
                            RadioButton(selected = selectedLanguage == code, onClick = { selectedLanguage = code; viewModel.setListeningLanguage(code) })
                            Text(label, modifier = Modifier.padding(start = 8.dp))
                        }
                    }
                }
            }

            HorizontalDivider()

            // كلمة الاستيقاظ
            Text("كلمة الاستيقاظ", style = MaterialTheme.typography.titleMedium, color = MaterialTheme.colorScheme.primary)

            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("وضع الاستماع")
                    Spacer(modifier = Modifier.height(8.dp))
                    listOf("button" to "زر الاستماع (المبدئي)", "continuous" to "استماع مستمر (قريباً)").forEach { (mode, label) ->
                        Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), verticalAlignment = Alignment.CenterVertically) {
                            RadioButton(
                                selected = selectedWakeMode == mode,
                                onClick = { if (mode != "continuous") { selectedWakeMode = mode; viewModel.setWakeWordMode(mode) } },
                                enabled = mode != "continuous"
                            )
                            Text(
                                label,
                                modifier = Modifier.padding(start = 8.dp),
                                color = if (mode == "continuous") MaterialTheme.colorScheme.onSurfaceVariant else MaterialTheme.colorScheme.onSurface
                            )
                        }
                    }
                }
            }

            HorizontalDivider()

            // إمكانية الوصول
            Text("إمكانية الوصول", style = MaterialTheme.typography.titleMedium, color = MaterialTheme.colorScheme.primary)

            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text("خدمة إمكانية الوصول")
                            Text(
                                if (viewModel.isAccessibilityServiceRunning()) "مفعّلة" else "معطّلة",
                                style = MaterialTheme.typography.bodySmall,
                                color = if (viewModel.isAccessibilityServiceRunning()) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.error
                            )
                        }
                        Button(onClick = { AccessibilityController.openAccessibilitySettings(context) }) { Text("فتح الإعدادات") }
                    }
                    Spacer(modifier = Modifier.height(8.dp))
                    Text("مطلوبة للتحكم داخل التطبيقات (مرحلة مستقبلية)", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }

            HorizontalDivider()

            // أخرى
            Text("أخرى", style = MaterialTheme.typography.titleMedium, color = MaterialTheme.colorScheme.primary)

            Card(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text("سجل التشغيل")
                        Text("تسجيل الأحداث لتصحيح الأخطاء", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                    Switch(checked = logEnabled, onCheckedChange = { logEnabled = it; viewModel.setLogEnabled(it) })
                }
            }

            HorizontalDivider()

            // حول
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text("أبو صرار", style = MaterialTheme.typography.titleMedium)
                    Text("الإصدار 1.0.0", style = MaterialTheme.typography.bodySmall)
                    Text("مساعد صوتي شخصي لنظام Android", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }

            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}
EOF

echo "  ✅ settings/"

# === UI Theme ===

cat > app/src/main/java/com/abusrar/assistant/ui/theme/Color.kt << 'EOF'
package com.abusrar.assistant.ui.theme

import androidx.compose.ui.graphics.Color

val AbuSrarBlue = Color(0xFF58A6FF)
val AbuSrarBlueDark = Color(0xFF1A3A5C)
val AbuSrarTeal = Color(0xFF39D2C0)
val AbuSrarTealDark = Color(0xFF1A3A38)
val AbuSrarPurple = Color(0xFFBC8CFF)

val DarkBackground = Color(0xFF0D1117)
val SurfaceDark = Color(0xFF161B22)
val SurfaceElevated = Color(0xFF1C2128)

val TextPrimary = Color(0xFFE6EDF3)
val TextSecondary = Color(0xFF8B949E)
val TextTertiary = Color(0xFF484F58)

val MicActive = Color(0xFF3FB950)
val ProcessingOrange = Color(0xFFD29922)
val ErrorRed = Color(0xFFF85149)
val ErrorRedDark = Color(0xFF5C1A1A)
val LightRed = Color(0xFFFFA198)
val SuccessGreen = Color(0xFF3FB950)

val OutlineColor = Color(0xFF30363D)
val OutlineVariantColor = Color(0xFF21262D)

val White = Color(0xFFFFFFFF)
val LightBlue = Color(0xFFA5D6FF)
val LightTeal = Color(0xFFA5F2E8)
EOF

cat > app/src/main/java/com/abusrar/assistant/ui/theme/Type.kt << 'EOF'
package com.abusrar.assistant.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

val Typography = Typography(
    displayLarge = TextStyle(fontFamily = FontFamily.Default, fontWeight = FontWeight.Bold, fontSize = 40.sp, lineHeight = 48.sp, letterSpacing = 0.sp),
    displayMedium = TextStyle(fontFamily = FontFamily.Default, fontWeight = FontWeight.Bold, fontSize = 32.sp, lineHeight = 40.sp, letterSpacing = 0.sp),
    headlineMedium = TextStyle(fontFamily = FontFamily.Default, fontWeight = FontWeight.SemiBold, fontSize = 24.sp, lineHeight = 32.sp, letterSpacing = 0.sp),
    titleMedium = TextStyle(fontFamily = FontFamily.Default, fontWeight = FontWeight.SemiBold, fontSize = 18.sp, lineHeight = 24.sp, letterSpacing = 0.sp),
    bodyLarge = TextStyle(fontFamily = FontFamily.Default, fontWeight = FontWeight.Normal, fontSize = 16.sp, lineHeight = 24.sp, letterSpacing = 0.5.sp),
    bodyMedium = TextStyle(fontFamily = FontFamily.Default, fontWeight = FontWeight.Normal, fontSize = 14.sp, lineHeight = 20.sp, letterSpacing = 0.25.sp),
    bodySmall = TextStyle(fontFamily = FontFamily.Default, fontWeight = FontWeight.Normal, fontSize = 12.sp, lineHeight = 16.sp, letterSpacing = 0.4.sp),
    labelSmall = TextStyle(fontFamily = FontFamily.Default, fontWeight = FontWeight.Medium, fontSize = 11.sp, lineHeight = 16.sp, letterSpacing = 0.5.sp)
)
EOF

cat > app/src/main/java/com/abusrar/assistant/ui/theme/Theme.kt << 'EOF'
package com.abusrar.assistant.ui.theme

import android.app.Activity
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val DarkColorScheme = darkColorScheme(
    primary = AbuSrarBlue,
    onPrimary = White,
    primaryContainer = AbuSrarBlueDark,
    onPrimaryContainer = LightBlue,
    secondary = AbuSrarTeal,
    onSecondary = White,
    secondaryContainer = AbuSrarTealDark,
    onSecondaryContainer = LightTeal,
    tertiary = AbuSrarPurple,
    onTertiary = White,
    background = DarkBackground,
    onBackground = TextPrimary,
    surface = SurfaceDark,
    onSurface = TextPrimary,
    onSurfaceVariant = TextSecondary,
    error = ErrorRed,
    onError = White,
    errorContainer = ErrorRedDark,
    onErrorContainer = LightRed,
    outline = OutlineColor,
    outlineVariant = OutlineVariantColor
)

@Composable
fun AbuSrarTheme(darkTheme: Boolean = true, dynamicColor: Boolean = false, content: @Composable () -> Unit) {
    val colorScheme = DarkColorScheme
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.background.toArgb()
            window.navigationBarColor = colorScheme.surface.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
            WindowCompat.getInsetsController(window, view).isAppearanceLightNavigationBars = false
        }
    }
    MaterialTheme(colorScheme = colorScheme, typography = Typography, content = content)
}

object AbuSrarColors {
    val Primary = AbuSrarBlue
    val Background = DarkBackground
    val Surface = SurfaceDark
    val TextPrimary = TextPrimary
    val TextSecondary = TextSecondary
    val TextTertiary = TextTertiary
    val Error = ErrorRed
    val Success = SuccessGreen
    val MicIdle = AbuSrarBlue
    val MicListening = MicActive
    val MicProcessing = ProcessingOrange
    val MicError = ErrorRed
}
EOF

echo "  ✅ ui/theme/"

# === UI Components ===

cat > app/src/main/java/com/abusrar/assistant/ui/components/MicButton.kt << 'EOF'
package com.abusrar.assistant.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.abusrar.assistant.ui.theme.AbuSrarColors

enum class MicState { IDLE, LISTENING, PROCESSING, ERROR }

@Composable
fun MicButtonWithClick(state: MicState, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val color = when (state) {
        MicState.IDLE -> AbuSrarColors.MicIdle
        MicState.LISTENING -> AbuSrarColors.MicListening
        MicState.PROCESSING -> AbuSrarColors.MicProcessing
        MicState.ERROR -> AbuSrarColors.MicError
    }

    val infiniteTransition = rememberInfiniteTransition(label = "mic_anim")

    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = if (state == MicState.LISTENING) 1.15f else 1f,
        animationSpec = if (state == MicState.LISTENING) {
            infiniteRepeatable(tween(600, easing = EaseInOutCubic), RepeatMode.Reverse)
        } else { snap() },
        label = "pulse"
    )

    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.2f,
        targetValue = if (state == MicState.LISTENING) 0.5f else 0f,
        animationSpec = if (state == MicState.LISTENING) {
            infiniteRepeatable(tween(600, easing = EaseInOutCubic), RepeatMode.Reverse)
        } else { snap() },
        label = "glow"
    )

    Box(modifier = modifier.size(140.dp), contentAlignment = Alignment.Center) {
        if (state == MicState.LISTENING) {
            Box(
                modifier = Modifier.size(140.dp).clip(CircleShape)
                    .background(color.copy(alpha = glowAlpha * 0.25f))
            )
        }

        Box(
            modifier = Modifier.size(110.dp).clip(CircleShape)
                .border(2.dp, color.copy(alpha = 0.4f), CircleShape)
                .background(MaterialTheme.colorScheme.surface),
            contentAlignment = Alignment.Center
        ) {
            Box(
                modifier = Modifier.size(if (state == MicState.LISTENING) (84 * pulseScale).dp else 84.dp)
                    .clip(CircleShape).background(color),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Mic,
                    contentDescription = if (state != MicState.PROCESSING) "اضغط للاستماع" else "جاري المعالجة",
                    tint = MaterialTheme.colorScheme.onPrimary,
                    modifier = Modifier.size(38.dp)
                )
            }
        }
    }
}
EOF

echo "  ✅ ui/components/"

# === UI Main ===

cat > app/src/main/java/com/abusrar/assistant/ui/main/MainViewModel.kt << 'EOF'
package com.abusrar.assistant.ui.main

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.abusrar.assistant.ai.ProviderManager
import com.abusrar.assistant.ai.RuleBasedProvider
import com.abusrar.assistant.commands.Command
import com.abusrar.assistant.commands.CommandParser
import com.abusrar.assistant.commands.CommandRouter
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult
import com.abusrar.assistant.settings.SettingsManager
import com.abusrar.assistant.tools.*
import com.abusrar.assistant.ui.components.MicState
import com.abusrar.assistant.voice.VoiceManagerImpl
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class MainUiState(
    val statusText: String = "جاهز للاستماع",
    val micState: MicState = MicState.IDLE,
    val lastCommand: String = "",
    val lastResponse: String = ""
)

class MainViewModel(application: Application) : AndroidViewModel(application) {

    private val voiceManager = VoiceManagerImpl(application)
    private val commandParser = CommandParser()
    private val settingsManager = SettingsManager(application)
    private val providerManager = ProviderManager()
    private val toolRegistry = ToolRegistry()
    private lateinit var commandRouter: CommandRouter

    private val _uiState = MutableStateFlow(MainUiState())
    val uiState: StateFlow<MainUiState> = _uiState.asStateFlow()

    init {
        toolRegistry.register(OpenAppTool(application))
        toolRegistry.register(HomeTool(application))
        toolRegistry.register(BackTool(application))
        toolRegistry.register(SettingsTool(application))
        toolRegistry.register(WebSearchTool(application))
        toolRegistry.register(CallTool(application))
        toolRegistry.register(SmsTool(application))

        commandRouter = CommandRouter(toolRegistry)

        providerManager.registerProvider(RuleBasedProvider())
        providerManager.setActiveProvider("rule_based")

        voiceManager.initialize()
        voiceManager.setSpeechRate(settingsManager.speechRate)

        AppLogger.info("APP", "تم تهيئة MainViewModel")
    }

    fun onMicClicked() {
        when (_uiState.value.micState) {
            MicState.IDLE, MicState.ERROR -> startListening()
            MicState.LISTENING -> stopListening()
            MicState.PROCESSING -> {}
        }
    }

    private fun startListening() {
        updateState(statusText = "أستمع إليك...", micState = MicState.LISTENING)
        voiceManager.startListening(
            onResult = { handleSpeechResult(it) },
            onError = { handleError(it) },
            onListeningChanged = {}
        )
    }

    fun stopListening() {
        voiceManager.stopListening()
        updateState(statusText = "جاهز للاستماع", micState = MicState.IDLE)
    }

    private fun handleSpeechResult(text: String) {
        updateState(micState = MicState.PROCESSING, statusText = "جاري التنفيذ...", lastCommand = text)
        AppLogger.command("النص المستلم: $text")

        val parseResult = commandParser.parse(text)

        if (parseResult.containsWakeWord) {
            if (parseResult.command is Command.WakeWord) {
                speakAndThen("تفضل سيدي.") {
                    updateState(statusText = "أستمع إليك...", micState = MicState.LISTENING)
                    viewModelScope.launch { delay(500); startListening() }
                }
            } else {
                speakAndThen("تفضل سيدي.") { executeCommand(parseResult.command) }
            }
        } else {
            executeCommand(parseResult.command)
        }
    }

    private fun executeCommand(command: Command) {
        viewModelScope.launch {
            val result = commandRouter.route(command)
            when (result) {
                is AppResult.Success -> {
                    val message = getSuccessMessage(command, result.data)
                    updateState(lastResponse = message, statusText = "تم التنفيذ.", micState = MicState.IDLE)
                    speak(message)
                }
                is AppResult.Error -> {
                    updateState(lastResponse = result.message, statusText = "تم التنفيذ.", micState = MicState.ERROR)
                    speak(result.message)
                }
                is AppResult.Loading -> {}
            }
        }
    }

    private fun getSuccessMessage(command: Command, data: String): String = when (command) {
        is Command.OpenApp -> data
        is Command.GoHome -> "تم الرجوع للشاشة الرئيسية"
        is Command.GoBack -> data
        is Command.OpenSettings -> "تم فتح الإعدادات"
        is Command.SearchWeb -> data
        is Command.MakeCall -> data
        is Command.SendSms -> data
        is Command.WakeWord -> "تفضل سيدي"
        is Command.Unknown -> data
    }

    private fun speak(text: String) {
        if (settingsManager.isVoiceEnabled) voiceManager.speak(text) {}
    }

    private fun speakAndThen(text: String, onComplete: () -> Unit) {
        if (settingsManager.isVoiceEnabled) {
            voiceManager.speak(text) { onComplete() }
        } else {
            onComplete()
        }
    }

    private fun handleError(error: String) {
        updateState(statusText = error, micState = MicState.ERROR, lastResponse = error)
        viewModelScope.launch {
            delay(2000)
            if (_uiState.value.micState == MicState.ERROR) {
                updateState(statusText = "جاهز للاستماع", micState = MicState.IDLE)
            }
        }
    }

    private fun updateState(statusText: String? = null, micState: MicState? = null, lastCommand: String? = null, lastResponse: String? = null) {
        _uiState.value = _uiState.value.copy(
            statusText = statusText ?: _uiState.value.statusText,
            micState = micState ?: _uiState.value.micState,
            lastCommand = lastCommand ?: _uiState.value.lastCommand,
            lastResponse = lastResponse ?: _uiState.value.lastResponse
        )
    }

    override fun onCleared() {
        super.onCleared()
        voiceManager.destroy()
    }
}
EOF

cat > app/src/main/java/com/abusrar/assistant/ui/main/MainScreen.kt << 'EOF'
package com.abusrar.assistant.ui.main

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.abusrar.assistant.ui.components.MicButtonWithClick
import com.abusrar.assistant.ui.components.MicState
import com.abusrar.assistant.ui.theme.AbuSrarColors
import com.abusrar.assistant.ui.theme.SurfaceElevated

@Composable
fun MainScreen(uiState: MainUiState, onMicClicked: () -> Unit, onSettingsClicked: () -> Unit, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier.fillMaxSize().background(AbuSrarColors.Background).padding(16.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            TopSection(onSettingsClicked = onSettingsClicked)
            Spacer(modifier = Modifier.weight(1f))
            MiddleSection(statusText = uiState.statusText, lastCommand = uiState.lastCommand, lastResponse = uiState.lastResponse)
            Spacer(modifier = Modifier.weight(1f))
            BottomSection(micState = uiState.micState, onMicClicked = onMicClicked)
            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@Composable
private fun TopSection(onSettingsClicked: () -> Unit) {
    Row(modifier = Modifier.fillMaxWidth().padding(top = 16.dp), horizontalArrangement = Arrangement.End) {
        IconButton(onClick = onSettingsClicked) {
            Icon(Icons.Default.Settings, contentDescription = "الإعدادات", tint = AbuSrarColors.TextSecondary)
        }
    }
}

@Composable
private fun MiddleSection(statusText: String, lastCommand: String, lastResponse: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp), modifier = Modifier.padding(horizontal = 24.dp)) {
        Text(text = "أبو صرار", style = MaterialTheme.typography.displayMedium, color = AbuSrarColors.TextPrimary, textAlign = TextAlign.Center)

        Text(
            text = statusText,
            style = MaterialTheme.typography.bodyLarge,
            color = when {
                statusText.contains("أستمع") -> AbuSrarColors.MicListening
                statusText.contains("جاري") -> AbuSrarColors.MicProcessing
                statusText.contains("تم") -> AbuSrarColors.Success
                statusText.contains("ما") || statusText.contains("فشل") || statusText.contains("خطأ") -> AbuSrarColors.Error
                else -> AbuSrarColors.TextSecondary
            },
            textAlign = TextAlign.Center
        )

        if (lastCommand.isNotEmpty()) {
            Card(modifier = Modifier.fillMaxWidth().padding(top = 8.dp), colors = CardDefaults.cardColors(containerColor = SurfaceElevated)) {
                Column(modifier = Modifier.fillMaxWidth().padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(text = "🎤 $lastCommand", style = MaterialTheme.typography.bodyMedium, color = AbuSrarColors.TextSecondary)
                    if (lastResponse.isNotEmpty()) {
                        Text(text = "🤖 $lastResponse", style = MaterialTheme.typography.bodyMedium, color = AbuSrarColors.TextPrimary)
                    }
                }
            }
        }
    }
}

@Composable
private fun BottomSection(micState: MicState, onMicClicked: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Box(
            modifier = Modifier.clip(MaterialTheme.shapes.extraLarge)
                .clickable(interactionSource = remember { MutableInteractionSource() }, indication = null, onClick = onMicClicked)
                .padding(8.dp)
        ) {
            MicButtonWithClick(state = micState, onClick = onMicClicked)
        }
        Text(
            text = when (micState) {
                MicState.IDLE -> "اضغط للاستماع"
                MicState.LISTENING -> "جاري الاستماع..."
                MicState.PROCESSING -> "جاري التنفيذ..."
                MicState.ERROR -> "اضغط للمحاولة مرة أخرى"
            },
            style = MaterialTheme.typography.bodySmall,
            color = AbuSrarColors.TextTertiary
        )
    }
}
EOF

echo "  ✅ ui/main/"

# === MainActivity ===

cat > app/src/main/java/com/abusrar/assistant/MainActivity.kt << 'EOF'
package com.abusrar.assistant

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.*
import com.abusrar.assistant.permissions.PermissionManager
import com.abusrar.assistant.settings.SettingsActivity
import com.abusrar.assistant.ui.main.MainScreen
import com.abusrar.assistant.ui.main.MainViewModel
import com.abusrar.assistant.ui.theme.AbuSrarTheme

class MainActivity : ComponentActivity() {

    private lateinit var viewModel: MainViewModel
    private lateinit var permissionManager: PermissionManager

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        if (permissions.entries.all { it.value }) {
            com.abusrar.assistant.core.AppLogger.info("PERMISSION", "تم منح جميع الأذونات")
        } else {
            com.abusrar.assistant.core.AppLogger.warn("PERMISSION", "بعض الأذونات مرفوضة")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        permissionManager = PermissionManager(this)
        viewModel = MainViewModel(application)

        requestRequiredPermissions()

        setContent {
            AbuSrarTheme {
                val uiState by viewModel.uiState.collectAsState()
                MainScreen(
                    uiState = uiState,
                    onMicClicked = { viewModel.onMicClicked() },
                    onSettingsClicked = { openSettings() }
                )
            }
        }
    }

    private fun requestRequiredPermissions() {
        val missingPermissions = permissionManager.getMissingRequiredPermissions()
        if (missingPermissions.isNotEmpty()) {
            permissionLauncher.launch(permissionManager.getPermissionArray(missingPermissions))
        }
    }

    private fun openSettings() {
        viewModel.stopListening()
        startActivity(Intent(this, SettingsActivity::class.java))
    }
}
EOF

echo "  ✅ MainActivity.kt"

# === Resources ===

cat > app/src/main/res/values/strings.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">أبو صرار</string>
    <string name="settings_title">الإعدادات</string>
    <string name="accessibility_service_description">يسمح لأبو صرار بالتحكم في واجهة المستخدم لتنفيذ الأوامر الصوتية داخل التطبيقات. لن يتم جمع أي بيانات شخصية.</string>
</resources>
EOF

cat > app/src/main/res/values-ar/strings.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">أبو صرار</string>
    <string name="settings_title">الإعدادات</string>
    <string name="accessibility_service_description">يسمح لأبو صرار بالتحكم في واجهة المستخدم لتنفيذ الأوامر الصوتية داخل التطبيقات.</string>
</resources>
EOF

cat > app/src/main/res/values/colors.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#0D1117</color>
</resources>
EOF

cat > app/src/main/res/values/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.AbuSrar" parent="android:Theme.Material.NoActionBar">
        <item name="android:statusBarColor">@android:color/transparent</item>
        <item name="android:navigationBarColor">@android:color/transparent</item>
        <item name="android:windowBackground">#0D1117</item>
    </style>
</resources>
EOF

cat > app/src/main/res/drawable/ic_launcher_foreground.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#58A6FF"
        android:pathData="M54,54m-40,0a40,40 0,1 1,80 0a40,40 0,1 1,-80 0" />
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M54,30c-4.4,0 -8,3.6 -8,8v16c0,4.4 3.6,8 8,8s8,-3.6 8,-8V38C62,33.6 58.4,30 54,30z" />
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M44,54c0,5.5 4.5,10 10,10s10,-4.5 10,-10h-4c0,3.3 -2.7,6 -6,6s-6,-2.7 -6,-6H44z" />
    <path
        android:fillColor="#FFFFFF"
        android:pathData="M54,68c-4.4,0 -8,-3.6 -8,-8h-4c0,5.8 4.4,10.6 10,11.4V78h4v-6.6c5.6,-0.8 10,-5.6 10,-11.4h-4C62,64.4 58.4,68 54,68z" />
</vector>
EOF

cat > app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

cat > app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
EOF

cat > app/src/main/res/xml/accessibility_service_config.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowStateChanged|typeWindowContentChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:accessibilityFlags="flagDefault|flagReportViewIds|flagRetrieveInteractiveWindows"
    android:canRetrieveWindowContent="true"
    android:notificationTimeout="100"
    android:description="@string/accessibility_service_description" />
EOF

cat > app/src/main/res/xml/backup_rules.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <exclude domain="sharedpref" path="abusrar_settings.xml" />
</full-backup-content>
EOF

echo "  ✅ resources/"

echo ""
echo "========================================"
echo "  ✅ تم كتابة جميع ملفات المشروع!"
echo "========================================"
echo ""
echo "عدد الملفات التي تم إنشاؤها:"
find . -type f -not -path './.git/*' -not -name 'create_project.sh' -not -name 'setup.sh' | wc -l
echo ""
echo "الخطوة التالية:"
echo "  1. انسخ مجلد المشروع إلى جهازك"
echo "  2. افتحه بـ Android Studio"
echo "  3. انتظر Gradle Sync"
echo "  4. شغّل التطبيق على جهاز أو محاكي"
