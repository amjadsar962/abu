package com.abusrar.assistant.apps

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import com.abusrar.assistant.core.AppLogger
import com.abusrar.assistant.core.AppResult

class AppLauncher(private val context: Context) {

    private val appResolver = AppResolver(context)
    private val packageManager: PackageManager = context.packageManager

    fun launch(appName: String): AppResult<String> {
        if (appName.isBlank()) {
            return AppResult.Error("ما قلت لي أفتح أيش")
        }

        return when (val result = appResolver.resolve(appName)) {
            is AppResolver.ResolveResult.Found -> launchPackage(result.packageName, appName)
            is AppResolver.ResolveResult.NotFound -> {
                val message = "ما لقيت $appName على الجهاز"
                AppLogger.warn("APPS", message)
                AppResult.Error(message)
            }
        }
    }

    private fun launchPackage(packageName: String, displayName: String): AppResult<String> {
        return try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(intent)
                val message = "تم فتح $displayName"
                AppLogger.info("APPS", message)
                AppResult.Success(message)
            } else {
                // التطبيق موجود لكن لا يوجد activity رئيسية
                AppResult.Error("التطبيق موجود لكن ما قدرت أفتحه")
            }
        } catch (e: Exception) {
            AppLogger.error("APPS", "فشل فتح $packageName", e)
            AppResult.Error("حصل خطأ وأنا أحاول أفتح $displayName")
        }
    }

    fun getInstalledApps(): List<AppInfo> {
        val apps = mutableListOf<AppInfo>()
        try {
            val intent = Intent(Intent.ACTION_MAIN, null).apply {
                addCategory(Intent.CATEGORY_LAUNCHER)
            }
            val resolveInfos = packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
            for (info in resolveInfos) {
                apps.add(
                    AppInfo(
                        name = info.loadLabel(packageManager).toString(),
                        packageName = info.activityInfo.packageName
                    )
                )
            }
            apps.sortBy { it.name.lowercase() }
        } catch (e: Exception) {
            AppLogger.error("APPS", "خطأ في جلب التطبيقات", e)
        }
        return apps
    }

    data class AppInfo(
        val name: String,
        val packageName: String
    )
}