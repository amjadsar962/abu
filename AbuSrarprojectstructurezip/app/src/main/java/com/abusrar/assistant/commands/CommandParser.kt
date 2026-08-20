package com.abusrar.assistant.commands

import com.abusrar.assistant.core.AppLogger

class CommandParser {

    companion object {
        private const val WAKE_WORD = "ابو صرار"
        private const val WAKE_WORD_ALT = "أبو صرار"
        private const val WAKE_WORD_FULL = "ابوصرار"
        private const val WAKE_WORD_FULL_ALT = "أبوصرار"
    }

    fun parse(input: String): ParseResult {
        val normalized = normalizeArabic(input)
        AppLogger.command("الم输入 المحولة: '$normalized'")

        val containsWakeWord = checkWakeWord(normalized)
        val textWithoutWakeWord = if (containsWakeWord) removeWakeWord(normalized) else normalized

        val trimmed = textWithoutWakeWord.trim()

        val command = if (trimmed.isEmpty()) {
            Command.WakeWord
        } else {
            parseCommand(trimmed)
        }

        return ParseResult(containsWakeWord, command)
    }

    private fun checkWakeWord(text: String): Boolean {
        return text.contains(WAKE_WORD) ||
                text.contains(WAKE_WORD_ALT) ||
                text.contains(WAKE_WORD_FULL) ||
                text.contains(WAKE_WORD_FULL_ALT)
    }

    private fun removeWakeWord(text: String): String {
        var result = text
        result = result.replace(WAKE_WORD_ALT, " ")
        result = result.replace(WAKE_WORD, " ")
        result = result.replace(WAKE_WORD_FULL_ALT, " ")
        result = result.replace(WAKE_WORD_FULL, " ")
        return result
    }

    private fun parseCommand(text: String): Command {
        return when {
            text.startsWith("افتح الاعدادات") || text.startsWith("افتح الإعدادات") ->
                Command.OpenSettings

            text.startsWith("افتح") ->
                Command.OpenApp(extractAppName(text.removePrefix("افتح").trim()))

            text.contains("الرئيسية") || text.contains("الشاشة الرئيسية") || text == "رئيسي" ->
                Command.GoHome

            text == "ارجع" || text == "رجوع" || text == "خلف" || text == "للخلف" ->
                Command.GoBack

            text.startsWith("ابحث عن") || text.startsWith("ابحث في") ->
                Command.SearchWeb(extractSearchQuery(text))

            text.startsWith("اتصل ب") || text.startsWith("اتصل على") ->
                Command.MakeCall(extractCallTarget(text))

            text.startsWith("ارسل رسالة") || text.startsWith("أرسل رسالة") ->
                parseSmsCommand(text)

            else -> Command.Unknown(text)
        }
    }

    private fun parseSmsCommand(text: String): Command.SendSms {
        // "ارسل رسالة لاحمد مرحبا كيفك"
        val withoutPrefix = text
            .replace("ارسل رسالة", "")
            .replace("أرسل رسالة", "")
            .trim()

        val target = extractUntilKeyword(withoutPrefix, listOf("واقول", "وقل", "نص", "مضمون"))
        val message = if (withoutPrefix.length > target.length) {
            withoutPrefix.removePrefix(target).trim()
                .removePrefix("واقول")
                .removePrefix("وقل")
                .removePrefix("نص")
                .removePrefix("مضمون")
                .trim()
        } else {
            ""
        }

        return Command.SendSms(target.trim(), message)
    }

    private fun extractAppName(text: String): String {
        return text.trim()
    }

    private fun extractSearchQuery(text: String): String {
        return text
            .replace("ابحث عن", "")
            .replace("ابحث في", "")
            .trim()
    }

    private fun extractCallTarget(text: String): String {
        return text
            .replace("اتصل ب", "")
            .replace("اتصل على", "")
            .trim()
    }

    private fun extractUntilKeyword(text: String, keywords: List<String>): String {
        for (keyword in keywords) {
            val index = text.indexOf(keyword)
            if (index > 0) {
                return text.substring(0, index)
            }
        }
        return text
    }

    private fun normalizeArabic(text: String): String {
        return text
            .replace(Regex("[\\u0610-\\u061A\\u064B-\\u065F\\u0670]"), "")
            .replace('أ', 'ا')
            .replace('إ', 'ا')
            .replace('آ', 'ا')
            .replace('ة', 'ه')
            .replace('ى', 'ي')
            .replace(Regex("\\s+"), " ")
            .trim()
    }
}