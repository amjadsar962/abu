package com.abusrar.assistant.commands

import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult
import com.abusrar.assistant.tools.Tool
import com.abusrar.assistant.tools.ToolRegistry

class CommandRouter(private val toolRegistry: ToolRegistry) {

    fun route(command: Command): AppResult<String> {
        AppLogger.command("توجيه الأمر: ${command::class.simpleName}")

        val tool = toolRegistry.findTool(command)
        if (tool != null) {
            AppLogger.command("الأداة المختارة: ${tool.name}")
            return tool.execute(command)
        }

        return when (command) {
            is Command.WakeWord -> AppResult.Success("wake_word")
            is Command.Unknown -> AppResult.Error("ما فهمت الأمر: ${command.text}")
            else -> AppResult.Error("لا يوجد أداة مناسبة لهذا الأمر")
        }
    }
}