package com.abusrar.assistant.ai

import com.abusrar.assistant.core.AppLogger

/**
 * مدير مزودّي الذكاء الاصطناعي
 * يدير تسجيل وتفعيل وتبديل الـ providers
 */
class ProviderManager {

    private val providers = mutableMapOf<String, AIProvider>()
    private var activeProviderName: String? = null

    fun registerProvider(provider: AIProvider) {
        providers[provider.name] = provider
        AppLogger.ai("تم تسجيل AI Provider: ${provider.name}")
    }

    fun unregisterProvider(name: String) {
        providers.remove(name)?.shutdown()
        if (activeProviderName == name) {
            activeProviderName = null
        }
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

    fun getActiveProvider(): AIProvider? {
        return activeProviderName?.let { providers[it] }
    }

    fun getProvider(name: String): AIProvider? = providers[name]

    fun getAvailableProviders(): List<AIProvider> {
        return providers.values.filter { it.isAvailable }
    }

    fun getAllProviders(): List<AIProvider> = providers.values.toList()

    /**
     * إرسال طلب للـ provider النشط
     * إذا لم يكن هناك provider نشط، يُرجع استجابة خطأ
     */
    suspend fun chat(request: AIRequest): AIResponse {
        val provider = getActiveProvider()
        return if (provider != null) {
            try {
                provider.chat(request)
            } catch (e: Exception) {
                AppLogger.error("AI", "خطأ من ${provider.name}", e)
                AIResponse(
                    text = "",
                    isSuccess = false,
                    errorMessage = "خطأ في ${provider.name}: ${e.message}"
                )
            }
        } else {
            AIResponse(
                text = "",
                isSuccess = false,
                errorMessage = "لا يوجد مزود ذكاء اصطناعي مفعل"
            )
        }
    }
}