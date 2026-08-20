package com.abusrar.assistant.commands

sealed class Command {
    data object WakeWord : Command()
    data class OpenApp(val appName: String) : Command()
    data object GoHome : Command()
    data object GoBack : Command()
    data object OpenSettings : Command()
    data class SearchWeb(val query: String) : Command()
    data class MakeCall(val target: String) : Command()
    data class SendSms(val target: String, val message: String) : Command()
    data class Unknown(val text: String) : Command()
}

data class ParseResult(
    val containsWakeWord: Boolean,
    val command: Command
)