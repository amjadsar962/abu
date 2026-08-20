package com.abusrar.assistant.ai

import com.abusrar.assistant.core.AppLogger

/**
 * مزود ذكاء اصطناعي قائم على القواعد
 * لا يحتاج API Key — يعمل بدون إنترنت للأوامر الأساسية
 *
 * هذا الـ provider لا يُستخدم مباشرة في Command Engine
 * بل هو fallback للمحادثات العامة عندما لا يتطابق أي أمر
 */
class RuleBasedProvider : AIProvider {

    override val name: String = "rule_based"
    override val isAvailable: Boolean = true
    override val capabilities: ModelCapabilities = ModelCapabilities(
        supportsChat = true,
        supportsVision = false,
        supportsFunctionCalling = false,
        supportsStreaming = false,
        maxContextTokens = 0,
        isOffline = true,
        supportsArabic = true
    )

    private val responses = mapOf(
        Regex("(مرحبا|السلام عليكم|هاي|هلا|أهلا)") to "أهلاً وسهلاً سيدي.",
        Regex("(كيف حالك|شلونك|عامل إيه|كيفك)") to "الحمد لله بخير، كيف أقدر أساعدك؟",
        Regex("(شكرا|شكراً|مشكور|يعطيك العافية)") to "العفو سيدي، بالخدمة.",
        Regex("(من أنت|مين أنت|إنت مين|شو اسمك)") to "أنا أبو صرار، مساعدك الصوتي.",
        Regex("(ماذا تستطيع|ايش تسوي|شو بتقدر تعمل)") to "أقدر أفتح التطبيقات، أبحث في الويب، وأتصل وأرسل رسائل. مع الوقت رح أتعلم أشياء أكثر.",
        Regex("(الوقت|كم الساعة|ساعة كم)") to "ما عندي وصول للساعة حالياً، لكن بقدر أساعدك بأشياء ثانية.",
    )

    override suspend fun chat(request: AIRequest): AIResponse {
        val input = request.prompt.trim()
        AppLogger.ai("RuleBased معالجة: $input")

        for ((pattern, response) in responses) {
            if (pattern.containsMatchIn(input)) {
                return AIResponse(
                    text = response,
                    isSuccess = true
                )
            }
        }

        return AIResponse(
            text = "ما فهمت قصدك سيدي. جرب تقول مثلاً افتح واتساب أو ابحث عن شي.",
            isSuccess = true
        )
    }

    override fun initialize(config: Map<String, String>) {
        AppLogger.ai("RuleBased Provider لا يحتاج تهيئة")
    }

    override fun shutdown() {
        // لا شيء لتنظيفه
    }
}