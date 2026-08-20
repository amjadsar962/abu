package com.abusrar.assistant.tools

import com.abusrar.assistant.commands.Command
import com.abusrar.assistant.core.AppResult

interface Tool {
    val name: String
    val description: String
    fun canHandle(command: Command): Boolean
    fun execute(command: Command): AppResult<String>
}

data class ToolResult(
    val success: Boolean,
    val message: String
)

class ToolRegistry {

    private val tools = mutableListOf<Tool>()

    fun register(tool: Tool) {
        tools.add(tool)
        AppLogger.tool("تم تسجيل الأداة: ${tool.name}")
    }

    fun unregister(toolName: String) {
        tools.removeAll { it.name == toolName }
    }

    fun findTool(command: Command): Tool? {
        return tools.find { it.canHandle(command) }
    }

    fun getAllTools(): List<Tool> = tools.toList()
}