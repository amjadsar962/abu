package com.abusrar.assistant.tools

import android.content.Context
import com.abusrar.assistant.apps.AppLauncher
import com.abusrar.assistant.commands.Command
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

class OpenAppTool(private val context: Context) : Tool {

    private val appLauncher = AppLauncher(context)

    override val name: String = "open_app"
    override val description: String = "فتح تطبيق مثبت على الجهاز"

    override fun canHandle(command: Command): Boolean {
        return command is Command.OpenApp
    }

    override fun execute(command: Command): AppResult<String> {
        if (command !is Command.OpenApp) {
            return AppResult.Error("أمر غير صحيح لهذه الأداة")
        }

        AppLogger.tool("محاولة فتح: ${command.appName}")
        return appLauncher.launch(command.appName)
    }
}