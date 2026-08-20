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
        if (ttsManager.isSpeaking()) {
            ttsManager.stop()
        }
        speechRecognizerManager.setCallbacks(onResult, onError, onListeningChanged)
        speechRecognizerManager.startListening()
    }

    override fun stopListening() {
        speechRecognizerManager.stopListening()
    }

    override fun speak(text: String, onComplete: (() -> Unit)?) {
        ttsManager.speak(text, onComplete)
    }

    override fun stopSpeaking() {
        ttsManager.stop()
    }

    override fun isSpeaking(): Boolean = ttsManager.isSpeaking()

    override fun isListening(): Boolean = speechRecognizerManager.isListening()

    override fun setSpeechRate(rate: Float) {
        ttsManager.setSpeechRate(rate)
    }

    override fun setLanguage(language: String) {
        ttsManager.setLanguage(language)
    }

    override fun destroy() {
        speechRecognizerManager.destroy()
        ttsManager.destroy()
    }
}