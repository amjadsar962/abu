package com.abusrar.assistant.tools

import android.content.Context
import android.content.Intent
import android.net.Uri
import com.abusrar.assistant.commands.Command
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

class WebSearchTool(private val context: Context) : Tool {

    override val name: String = "web_search"
    override val description: String = "البحث في الويب"

    override fun canHandle(command: Command): Boolean = command is Command.SearchWeb

    override fun execute(command: Command): AppResult<String> {
        if (command !is Command.SearchWeb) {
            return AppResult.Error("أمر غير صحيح")
        }

        return try {
            val query = command.query
            if (query.isBlank()) {
                return AppResult.Error("ما قلت لي أبحث عن أيش")
            }

            val encodedQuery = Uri.encode(query)
            val uri = Uri.parse("https://www.google.com/search?q=$encodedQuery")
            val intent = Intent(Intent.ACTION_VIEW, uri).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            AppLogger.tool("تم البحث عن: $query")
            AppResult.Success("تم فتح البحث عن: $query")
        } catch (e: Exception) {
            AppLogger.error("TOOL", "فشل فتح البحث", e)
            AppResult.Error("ما قدرت أفتح البحث")
        }
    }
}