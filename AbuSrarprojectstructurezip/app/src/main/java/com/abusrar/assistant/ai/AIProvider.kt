package com.abusrar.assistant.ai

/**
 * واجهة مقدّم الذكاء الاصطناعي
 * كل provider جديد (OpenRouter, Local Model, إلخ) يطبّق هذه الواجهة
 */
interface AIProvider {
    val name: String
    val isAvailable: Boolean
    val capabilities: ModelCapabilities

    suspend fun chat(request: AIRequest): AIResponse
    fun initialize(config: Map<String, String>)
    fun shutdown()
}

/**
 * واجهة مقدّم المحادثة — تمدّد AIProvider بإمكانيات المحادثة
 */
interface ChatProvider : AIProvider {
    suspend fun sendMessage(message: String, context: List<ChatMessage> = emptyList()): AIResponse
    fun clearHistory()
}

/**
 * رسالة محادثة
 */
data class ChatMessage(
    val role: MessageRole,
    val content: String,
    val timestamp: Long = System.currentTimeMillis()
)

enum class MessageRole {
    SYSTEM, USER, ASSISTANT
}

/**
 * طلب AI عام
 */
data class AIRequest(
    val prompt: String,
    val systemPrompt: String? = null,
    val temperature: Float = 0.7f,
    val maxTokens: Int = 1000,
    val metadata: Map<String, String> = emptyMap()
)

/**
 * استجابة AI عامة
 */
data class AIResponse(
    val text: String,
    val isSuccess: Boolean,
    val errorMessage: String? = null,
    val metadata: Map<String, String> = emptyMap(),
    val usage: TokenUsage? = null
)

/**
 * استخدام التوكنات
 */
data class TokenUsage(
    val promptTokens: Int,
    val completionTokens: Int,
    val totalTokens: Int
)

/**
 * قدرات النموذج
 */
data class ModelCapabilities(
    val supportsChat: Boolean = false,
    val supportsVision: Boolean = false,
    val supportsFunctionCalling: Boolean = false,
    val supportsStreaming: Boolean = false,
    val maxContextTokens: Int = 0,
    val isOffline: Boolean = false,
    val supportsArabic: Boolean = false
)