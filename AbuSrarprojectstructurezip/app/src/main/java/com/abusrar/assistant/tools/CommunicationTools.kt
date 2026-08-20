package com.abusrar.assistant.tools

import android.content.Context
import android.content.Intent
import android.net.Uri
import com.abusrar.assistant.commands.Command
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

class CallTool(private val context: Context) : Tool {

    override val name: String = "make_call"
    override val description: String = "إجراء مكالمة هاتفية"

    override fun canHandle(command: Command): Boolean = command is Command.MakeCall

    override fun execute(command: Command): AppResult<String> {
        if (command !is Command.MakeCall) {
            return AppResult.Error("أمر غير صحيح")
        }

        val target = command.target.trim()
        if (target.isBlank()) {
            return AppResult.Error("ما قلت لي اتصل بمن")
        }

        // التحقق مما إذا كان الهدف رقم هاتف
        val phoneNumber = target.filter { it.isDigit() || it == '+' }

        return if (phoneNumber.length >= 8) {
            try {
                val intent = Intent(Intent.ACTION_CALL, Uri.parse("tel:$phoneNumber")).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                context.startActivity(intent)
                AppLogger.tool("تم الاتصال بـ: $phoneNumber")
                AppResult.Success("جاري الاتصال بـ $target")
            } catch (e: SecurityException) {
                AppLogger.error("TOOL", "صلاحية الاتصال مرفوضة", e)
                AppResult.Error("ما عندي صلاحية إجراء مكالمات. تقدر تعطيني الصلاحية من الإعدادات")
            } catch (e: Exception) {
                AppLogger.error("TOOL", "فشل الاتصال", e)
                AppResult.Error("ما قدرت أتصل")
            }
        } else {
            // اسم جهة اتصال - يحتاج قراءة جهات الاتصال (مستقبلاً)
            AppLogger.warn("TOOL", "البحث عن جهة اتصال بالاسم غير مدعوم بعد")
            AppResult.Error("البحث عن اسم جهة اتصال يكون متاح في تحديث لاحق. قل الرقم مباشرة")
        }
    }
}

class SmsTool(private val context: Context) : Tool {

    override val name: String = "send_sms"
    override val description: String = "إرسال رسالة SMS"

    override fun canHandle(command: Command): Boolean = command is Command.SendSms

    override fun execute(command: Command): AppResult<String> {
        if (command !is Command.SendSms) {
            return AppResult.Error("أمر غير صحيح")
        }

        val target = command.target.trim()
        val message = command.message.trim()

        if (target.isBlank()) {
            return AppResult.Error("ما قلت لي أرسل لمن")
        }

        // في MVP: نفتح تطبيق الرسائل مع الرقم والرسالة
        // إرسال الرسالة تلقائياً يحتاج صلاحية SEND_SMS وتأكيد المستخدم
        return try {
            val phoneNumber = target.filter { it.isDigit() || it == '+' }
            if (phoneNumber.length < 8) {
                return AppResult.Error("الرجاء إعطاء رقم هاتف صحيح")
            }

            val uri = Uri.parse("smsto:$phoneNumber")
            val intent = Intent(Intent.ACTION_SENDTO, uri).apply {
                putExtra("sms_body", message)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            AppLogger.tool("تم فتح الرسائل لـ: $phoneNumber")
            AppResult.Success("تم فتح الرسائل. الرسالة جاهزة للإرسال")
        } catch (e: Exception) {
            AppLogger.error("TOOL", "فشل فتح الرسائل", e)
            AppResult.Error("ما قدرت أفتح الرسائل")
        }
    }
}