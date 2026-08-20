package com.abusrar.assistant.voice

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import com.abusrar.assistant.core.AppLogger
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

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

            override fun onRmsChanged(rmsdB: Float) {
                // يمكن استخدامها لعرض مستوى الصوت مستقبلاً
            }

            override fun onBufferReceived(buffer: ByteArray?) {
                // غير مستخدم حالياً
            }

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

            override fun onPartialResults(partialResults: Bundle?) {
                // يمكن عرض النتائج الجزئية مستقبلاً
            }

            override fun onEvent(eventType: Int, params: Bundle?) {
                // غير مستخدم حالياً
            }
        }
    }

    fun startListening(language: String = "ar-SA") {
        if (isListening) {
            stopListening()
            return
        }

        if (speechRecognizer == null) {
            create()
        }

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
        try {
            speechRecognizer?.destroy()
        } catch (e: Exception) {
            AppLogger.error("VOICE", "خطأ في تدمير SpeechRecognizer", e)
        }
        speechRecognizer = null
    }

    fun isListening(): Boolean = isListening
}