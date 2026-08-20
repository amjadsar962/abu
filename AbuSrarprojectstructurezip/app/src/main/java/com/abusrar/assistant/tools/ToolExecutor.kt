package com.abusrar.assistant.tools

import com.abusrar.assistant.commands.Command
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

class ToolExecutor(private val toolRegistry: ToolRegistry) {

    fun execute(command: Command): AppResult<String> {
        val tool = toolRegistry.findTool(command)
        return if (tool != null) {
            AppLogger.tool("تنفيذ الأداة: ${tool.name}")
            try {
                tool.execute(command)
            } catch (e: Exception) {
                AppLogger.error("TOOL", "خطأ في تنفيذ ${tool.name}", e)
                AppResult.Error("ما قدرت أنفذ الأمر: ${e.message}")
            }
        } else {
            AppLogger.warn("TOOL", "لا توجد أداة مناسبة للأمر")
            AppResult.Error("ما لقيت أداة مناسبة لهذا الأمر")
        }
    }
}