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
import com.abusrar.assistant.voice.VoiceManager
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
    val lastResponse: String = "",
    val showSettingsButton: Boolean = true
)

class MainViewModel(application: Application) : AndroidViewModel(application) {

    private val voiceManager: VoiceManager = VoiceManagerImpl(application)
    private val commandParser = CommandParser()
    private val settingsManager = SettingsManager(application)
    private val providerManager = ProviderManager()

    private val toolRegistry = ToolRegistry()
    private lateinit var commandRouter: CommandRouter

    private val _uiState = MutableStateFlow(MainUiState())
    val uiState: StateFlow<MainUiState> = _uiState.asStateFlow()

    init {
        // تسجيل الأدوات
        toolRegistry.register(OpenAppTool(application))
        toolRegistry.register(HomeTool(application))
        toolRegistry.register(BackTool(application))
        toolRegistry.register(SettingsTool(application))
        toolRegistry.register(WebSearchTool(application))
        toolRegistry.register(CallTool(application))
        toolRegistry.register(SmsTool(application))

        // إنشاء موجه الأوامر
        commandRouter = CommandRouter(toolRegistry)

        // تسجيل AI Provider الافتراضي
        providerManager.registerProvider(RuleBasedProvider())
        providerManager.setActiveProvider("rule_based")

        // تهيئة Voice Manager
        voiceManager.initialize()
        voiceManager.setSpeechRate(settingsManager.speechRate)

        AppLogger.info("APP", "تم تهيئة MainViewModel")
    }

    fun onMicClicked() {
        val currentState = _uiState.value.micState
        when (currentState) {
            MicState.IDLE, MicState.ERROR -> startListening()
            MicState.LISTENING -> stopListening()
            MicState.PROCESSING -> { /* لا شيء */ }
        }
    }

    private fun startListening() {
        updateState(
            statusText = "أستمع إليك...",
            micState = MicState.LISTENING
        )

        voiceManager.startListening(
            onResult = { text ->
                handleSpeechResult(text)
            },
            onError = { error ->
                handleError(error)
            },
            onListeningChanged = { isListening ->
                if (!isListening && _uiState.value.micState == MicState.LISTENING) {
                    // انتهى الاستماع بدون نتيجة
                }
            }
        )
    }

    private fun stopListening() {
        voiceManager.stopListening()
        updateState(
            statusText = "جاهز للاستماع",
            micState = MicState.IDLE
        )
    }

    private fun handleSpeechResult(text: String) {
        updateState(
            micState = MicState.PROCESSING,
            statusText = "جاري التنفيذ...",
            lastCommand = text
        )

        AppLogger.command("النص المستلم: $text")

        val parseResult = commandParser.parse(text)

        if (parseResult.containsWakeWord) {
            // تم استدعاء أبو صرار
            if (parseResult.command is Command.WakeWord) {
                // فقط كلمة الاستيقاظ بدون أمر
                speakAndThen("تفضل سيدي.") {
                    updateState(
                        statusText = "أستمع إليك...",
                        micState = MicState.LISTENING
                    )
                    // استمع للأمر التالي بعد انتهاء الرد
                    viewModelScope.launch {
                        delay(500)
                        startListening()
                    }
                }
            } else {
                // كلمة الاستيقاظ + أمر
                speakAndThen("تفضل سيدي.") {
                    executeCommand(parseResult.command)
                }
            }
        } else {
            // أمر مباشر بدون كلمة استيقاظ
            executeCommand(parseResult.command)
        }
    }

    private fun executeCommand(command: Command) {
        viewModelScope.launch {
            val result = commandRouter.route(command)

            when (result) {
                is AppResult.Success -> {
                    val message = getSuccessMessage(command, result.data)
                    updateState(
                        lastResponse = message,
                        statusText = "تم التنفيذ.",
                        micState = MicState.IDLE
                    )
                    speak(message)
                }
                is AppResult.Error -> {
                    updateState(
                        lastResponse = result.message,
                        statusText = "تم التنفيذ.",
                        micState = MicState.ERROR
                    )
                    speak(result.message)
                }
                is AppResult.Loading -> {
                    // لا يحدث في التنفيذ المتزامن
                }
            }
        }
    }

    private fun getSuccessMessage(command: Command, data: String): String {
        return when (command) {
            is Command.OpenApp -> data
            is Command.GoHome -> "تم الرجوع للشاشة الرئيسية"
            is Command.GoBack -> data // سيكون رسالة خطأ في MVP
            is Command.OpenSettings -> "تم فتح الإعدادات"
            is Command.SearchWeb -> data
            is Command.MakeCall -> data
            is Command.SendSms -> data
            is Command.WakeWord -> "تفضل سيدي"
            is Command.Unknown -> data
        }
    }

    private fun speak(text: String) {
        if (settingsManager.isVoiceEnabled) {
            voiceManager.speak(text) {
                // بعد انتهاء النطق
            }
        }
    }

    private fun speakAndThen(text: String, onComplete: () -> Unit) {
        if (settingsManager.isVoiceEnabled) {
            voiceManager.speak(text) {
                onComplete()
            }
        } else {
            onComplete()
        }
    }

    private fun handleError(error: String) {
        updateState(
            statusText = error,
            micState = MicState.ERROR,
            lastResponse = error
        )

        viewModelScope.launch {
            delay(2000)
            if (_uiState.value.micState == MicState.ERROR) {
                updateState(
                    statusText = "جاهز للاستماع",
                    micState = MicState.IDLE
                )
            }
        }
    }

    private fun updateState(
        statusText: String? = null,
        micState: MicState? = null,
        lastCommand: String? = null,
        lastResponse: String? = null
    ) {
        _uiState.value = _uiState.value.copy(
            statusText = statusText ?: _uiState.value.statusText,
            micState = micState ?: _uiState.value.micState,
            lastCommand = lastCommand ?: _uiState.value.lastCommand,
            lastResponse = lastResponse ?: _uiState.value.lastResponse
        )
    }

    fun onSettingsClicked() {
        // يتم التعامل معه في MainActivity
    }

    override fun onCleared() {
        super.onCleared()
        voiceManager.destroy()
        AppLogger.info("APP", "تم تنظيف MainViewModel")
    }
}