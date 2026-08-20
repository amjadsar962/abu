package com.abusrar.assistant.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.abusrar.assistant.accessibility.AccessibilityController

class SettingsViewModel(private val settingsManager: SettingsManager) : ViewModel() {

    // الصوت
    val isVoiceEnabled: Boolean get() = settingsManager.isVoiceEnabled
    val speechRate: Float get() = settingsManager.speechRate
    val listeningLanguage: String get() = settingsManager.listeningLanguage

    // Wake Word
    val wakeWordMode: String get() = settingsManager.wakeWordMode

    // AI
    val aiProvider: String get() = settingsManager.aiProvider
    val apiUrl: String get() = settingsManager.apiUrl

    // التنقيح
    val isLogEnabled: Boolean get() = settingsManager.isLogEnabled

    fun setVoiceEnabled(enabled: Boolean) {
        settingsManager.isVoiceEnabled = enabled
    }

    fun setSpeechRate(rate: Float) {
        settingsManager.speechRate = rate
    }

    fun setListeningLanguage(language: String) {
        settingsManager.listeningLanguage = language
    }

    fun setWakeWordMode(mode: String) {
        settingsManager.wakeWordMode = mode
    }

    fun setAiProvider(provider: String) {
        settingsManager.aiProvider = provider
    }

    fun setApiUrl(url: String) {
        settingsManager.apiUrl = url
    }

    fun setApiKey(key: String) {
        // TODO: V2 - تخزين في Android Keystore بدلاً من SharedPreferences
        settingsManager.apiKey = key
    }

    fun setLogEnabled(enabled: Boolean) {
        settingsManager.isLogEnabled = enabled
    }

    fun isAccessibilityServiceRunning(): Boolean {
        return AccessibilityController.isServiceRunning()
    }

    @Suppress("UNCHECKED_CAST")
    class Factory(private val settingsManager: SettingsManager) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            return SettingsViewModel(settingsManager) as T
        }
    }
}