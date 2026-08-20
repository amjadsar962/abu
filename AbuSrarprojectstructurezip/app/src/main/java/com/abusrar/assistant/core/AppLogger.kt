package com.abusrar.assistant.core

import android.content.Context
import android.util.Log
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object AppLogger {

    private const val TAG_PREFIX = "AbuSrar"
    private var isEnabled = true

    fun init(context: Context) {
        // يمكن إضافة إعدادات من SharedPreferences لاحقاً
        isEnabled = true
    }

    private fun log(tag: String, level: String, message: String) {
        if (!isEnabled) return
        val timestamp = SimpleDateFormat("HH:mm:ss.SSS", Locale.US).format(Date())
        val fullTag = "$TAG_PREFIX[$tag]"
        val fullMessage = "[$timestamp] $message"

        when (level) {
            "ERROR" -> Log.e(fullTag, fullMessage)
            "WARN" -> Log.w(fullTag, fullMessage)
            "DEBUG" -> Log.d(fullTag, fullMessage)
            else -> Log.i(fullTag, fullMessage)
        }
    }

    fun info(tag: String, message: String) {
        log(tag, "INFO", message)
    }

    fun error(tag: String, message: String, throwable: Throwable? = null) {
        log(tag, "ERROR", message + (throwable?.let { ": ${it.message}" } ?: ""))
        throwable?.printStackTrace()
    }

    fun warn(tag: String, message: String) {
        log(tag, "WARN", message)
    }

    fun debug(tag: String, message: String) {
        log(tag, "DEBUG", message)
    }

    fun voice(message: String) = info("VOICE", message)
    fun command(message: String) = info("COMMAND", message)
    fun tool(message: String) = info("TOOL", message)
    fun accessibility(message: String) = info("ACCESSIBILITY", message)
    fun ai(message: String) = info("AI", message)
}