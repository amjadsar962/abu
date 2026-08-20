package com.abusrar.assistant.apps

import android.content.Context
import android.content.Intent
import android.net.Uri
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

/**
 * طبقة تحكم في WhatsApp
 *
 * المرحلة الأولى (MVP): فتح WhatsApp فقط
 * المرحلة المستقبلية:
 *   - البحث عن جهة اتصال
 *   - فتح محادثة محددة
 *   - إدخال نص وإرساله (عبر Accessibility Service)
 */
class WhatsAppController(private val context: Context) {

    companion object {
        const val PACKAGE_WHATSAPP = "com.whatsapp"
        const val PACKAGE_WHATSAPP_BUSINESS = "com.whatsapp.w4b"
    }

    /**
     * فتح WhatsApp — المرحلة الأولى
     */
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

    /**
     * فتح محادثة مع رقم محدد — مرحلة مستقبلية
     */
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

    // TODO: V4 - البحث عن جهة اتصال داخل واتساب (يحتاج Accessibility Service)
    // fun searchContact(name: String): AppResult<String>

    // TODO: V4 - كتابة رسالة وإرسالها (يحتاج Accessibility Service)
    // fun sendMessage(contact: String, message: String): AppResult<String>
}