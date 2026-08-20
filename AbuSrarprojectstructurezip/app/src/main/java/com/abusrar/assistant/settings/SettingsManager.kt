package com.abusrar.assistant.settings

import android.content.Context
import android.content.SharedPreferences

class SettingsManager(context: Context) {

    private val prefs: SharedPreferences =
        context.getSharedPreferences("abusrar_settings", Context.MODE_PRIVATE)

    companion object {
        private const val KEY_VOICE_ENABLED = "voice_enabled"
        private const val KEY_SPEECH_RATE = "speech_rate"
        private const val KEY_LISTENING_LANGUAGE = "listening_language"
        private const val KEY_WAKE_WORD_MODE = "wake_word_mode"
        private const val KEY_AI_PROVIDER = "ai_provider"
        private const val KEY_API_KEY = "api_key" // سيتم تخزينه في Keystore مستقبلاً
        private const val KEY_API_URL = "api_url"
        private const val KEY_LOG_ENABLED = "log_enabled"
    }

    // === الصوت ===

    var isVoiceEnabled: Boolean
        get() = prefs.getBoolean(KEY_VOICE_ENABLED, true)
        set(value) = prefs.edit().putBoolean(KEY_VOICE_ENABLED, value).apply()

    var speechRate: Float
        get() = prefs.getFloat(KEY_SPEECH_RATE, 1.0f)
        set(value) = prefs.edit().putFloat(KEY_SPEECH_RATE, value.coerceIn(0.5f, 2.0f)).apply()

    var listeningLanguage: String
        get() = prefs.getString(KEY_LISTENING_LANGUAGE, "ar-SA") ?: "ar-SA"
        set(value) = prefs.edit().putString(KEY_LISTENING_LANGUAGE, value).apply()

    // === Wake Word ===

    /**
     * وضع Wake Word:
     * - "button": زر الاستماع فقط (المبدئي)
     * - "continuous": استماع مستمر (مستقبلي)
     */
    var wakeWordMode: String
        get() = prefs.getString(KEY_WAKE_WORD_MODE, "button") ?: "button"
        set(value) = prefs.edit().putString(KEY_WAKE_WORD_MODE, value).apply()

    // === AI ===

    var aiProvider: String
        get() = prefs.getString(KEY_AI_PROVIDER, "rule_based") ?: "rule_based"
        set(value) = prefs.edit().putString(KEY_AI_PROVIDER, value).apply()

    var apiKey: String
        get() = prefs.getString(KEY_API_KEY, "") ?: ""
        set(value) = prefs.edit().putString(KEY_API_KEY, value).apply()

    var apiUrl: String
        get() = prefs.getString(KEY_API_URL, "") ?: ""
        set(value) = prefs.edit().putString(KEY_API_URL, value).apply()

    // === التنقيح ===

    var isLogEnabled: Boolean
        get() = prefs.getBoolean(KEY_LOG_ENABLED, true)
        set(value) = prefs.edit().putBoolean(KEY_LOG_ENABLED, value).apply()

    /**
     * مسح جميع الإعدادات
     */
    fun clearAll() {
        prefs.edit().clear().apply()
    }
}