package com.abusrar.assistant.tools

import android.content.Context
import android.content.Intent
import com.abusrar.assistant.commands.Command
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

class HomeTool(private val context: Context) : Tool {

    override val name: String = "go_home"
    override val description: String = "الرجوع للشاشة الرئيسية"

    override fun canHandle(command: Command): Boolean = command is Command.GoHome

    override fun execute(command: Command): AppResult<String> {
        return try {
            val intent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            AppLogger.tool("تم الرجوع للشاشة الرئيسية")
            AppResult.Success("تم الرجوع للشاشة الرئيسية")
        } catch (e: Exception) {
            AppLogger.error("TOOL", "فشل الرجوع للرئيسية", e)
            AppResult.Error("ما قدرت أرجع للشاشة الرئيسية")
        }
    }
}

class BackTool(private val context: Context) : Tool {

    override val name: String = "go_back"
    override val description: String = "الرجوع للخلف"

    override fun canHandle(command: Command): Boolean = command is Command.GoBack

    override fun execute(command: Command): AppResult<String> {
        return try {
            // إرسال حدث الضغط على زر الرجوع
            val intent = Intent(Intent.ACTION_BACK).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            // لا يمكن إرسال ACTION_BACK مباشرة
            // نستخدم طريقة بديلة عبر إرسال broadcast
            // لكن الطريقة الأكثر موثوقية هي استخدام Runtime
            // في MVP سنستخدم إرسال keyevent عبر shell (يتطلب rooted أو خاصية معينة)
            // البديل الآمن: نخبر المستخدم أن نضغط زر الرجوع
            AppLogger.warn("TOOL", "أمر الرجوع يتطلب Accessibility Service للعمل بشكل كامل")
            AppResult.Error("أمر الرجوع يحتاج تفعيل خدمة إمكانية الوصول")
        } catch (e: Exception) {
            AppResult.Error("ما قدرت أرجع للخلف")
        }
    }
}

class SettingsTool(private val context: Context) : Tool {

    override val name: String = "open_settings"
    override val description: String = "فتح إعدادات النظام"

    override fun canHandle(command: Command): Boolean = command is Command.OpenSettings

    override fun execute(command: Command): AppResult<String> {
        return try {
            val intent = Intent(android.provider.Settings.ACTION_SETTINGS).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            AppLogger.tool("تم فتح الإعدادات")
            AppResult.Success("تم فتح الإعدادات")
        } catch (e: Exception) {
            AppLogger.error("TOOL", "فشل فتح الإعدادات", e)
            AppResult.Error("ما قدرت أفتح الإعدادات")
        }
    }
}