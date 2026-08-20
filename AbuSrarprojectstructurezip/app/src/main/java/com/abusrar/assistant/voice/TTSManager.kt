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
        AppLogger.debug("VOICE", "تم تغيير سرعة الصوت إلى: $currentSpeechRate")
    }

    fun speak(text: String, onComplete: (() -> Unit)? = null) {
        if (!isInitialized) {
            AppLogger.error("VOICE", "TTS غير مهيأ")
            onComplete?.invoke()
            return
        }

        stop()

        onSpeakCompleteCallback = onComplete

        tts?.setOnUtteranceProgressListener(object : android.speech.tts.UtteranceProgressListener() {
            override fun onStart(utteranceId: String?) {
                AppLogger.debug("VOICE", "بدء نطق: $text")
            }

            override fun onDone(utteranceId: String?) {
                AppLogger.debug("VOICE", "انتهى النطق")
                onSpeakCompleteCallback?.invoke()
                onSpeakCompleteCallback = null
            }

            override fun onError(utteranceId: String?) {
                AppLogger.error("VOICE", "خطأ في النطق")
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
        try {
            tts?.shutdown()
        } catch (e: Exception) {
            AppLogger.error("VOICE", "خطأ في إيقاف TTS", e)
        }
        tts = null
        isInitialized = false
    }
}