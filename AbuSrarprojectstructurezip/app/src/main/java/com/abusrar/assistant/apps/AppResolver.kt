package com.abusrar.assistant.apps

import android.content.Context
import android.content.pm.PackageManager
import com.abusrar.assistant.core.AppLogger

class AppResolver(private val context: Context) {

    private val packageManager: PackageManager = context.packageManager

    companion object {
        // خريطة الأسماء العربية إلى أسماء الحزم الشائعة
        private val APP_NAME_MAP = mapOf(
            "واتساب" to "com.whatsapp",
            "واتساب بزنس" to "com.whatsapp.w4b",
            "يوتيوب" to "com.google.android.youtube",
            "يوتيوب كيدز" to "com.google.android.apps.youtube.kids",
            "يوتيوب ميوزك" to "com.google.android.apps.youtube.music",
            "فيسبوك" to "com.facebook.katana",
            "انستغرام" to "com.instagram.android",
            "انستقرام" to "com.instagram.android",
            "تويتر" to "com.twitter.android",
            "إكس" to "com.twitter.android",
            "اكس" to "com.twitter.android",
            "تيك توك" to "com.zhiliaoapp.musically",
            "تيكتوك" to "com.zhiliaoapp.musically",
            "سناب شات" to "com.snapchat.android",
            "سنابشات" to "com.snapchat.android",
            "تيليجرام" to "org.telegram.messenger",
            "تلجرام" to "org.telegram.messenger",
            "جوجل" to "com.google.android.googlequicksearchbox",
            "كروم" to "com.android.chrome",
            "متصفح كروم" to "com.android.chrome",
            "فايرفوكس" to "org.mozilla.firefox",
            "سافاري" to "com.apple.android.webkit",
            "فايبر" to "com.viber.voip",
            "لاين" to "jp.naver.line.android",
            "ساوند كلاود" to "com.soundcloud.android",
            "سبوتيفاي" to "com.spotify.music",
            "نيتفلكس" to "com.netflix.mediaclient",
            "شاهيد" to "net.shahid.android",
            "الاعدادات" to "com.android.settings",
            "الإعدادات" to "com.android.settings",
            "اعدادات" to "com.android.settings",
            "الكاميرا" to "com.android.camera",
            "الصور" to "com.google.android.apps.photos",
            "المعرض" to "com.google.android.apps.photos",
            "المعرض" to "com.google.android.apps.photos",
            "الهاتف" to "com.android.dialer",
            "الرسائل" to "com.google.android.apps.messaging",
            "البريد" to "com.google.android.gm",
            "جيميل" to "com.google.android.gm",
            "الساعة" to "com.android.deskclock",
            "ساعة" to "com.android.deskclock",
            "حاسبة" to "com.android.calculator2",
            "فيديو" to "com.google.android.videos",
            "خرائط" to "com.google.android.apps.maps",
            "خرائط جوجل" to "com.google.android.apps.maps",
            "جوجل مابس" to "com.google.android.apps.maps",
            "مابس" to "com.google.android.apps.maps",
            "بلاي ستور" to "com.android.vending",
            "متجر بلاي" to "com.android.vending",
            "متجر التطبيقات" to "com.android.vending",
            "واتسباد" to "com.whatsapp.w4b",
            "ديسكورد" to "com.discord",
            "سلاك" to "com.Slack",
            "زووم" to "us.zoom.videomeetings",
            "مايكروسوفت تيمز" to "com.microsoft.teams",
            "تيندر" to "com.tinder",
            "سنغس" to "com.smule.singandroid",
            "ريلز" to "com.instagram.android",
            "لينكد إن" to "com.linkedin.android",
            "بنترست" to "com.pinterest",
            "ريدت" to "com.reddit.frontpage",
            "واتس" to "com.whatsapp",
            "انستا" to "com.instagram.android",
            "تلgra" to "org.telegram.messenger",
        )
    }

    /**
     * يحلل اسم التطبيق العربي إلى اسم الحزمة
     * يبحث أولاً في الخريطة ثم في التطبيقات المثبتة
     */
    fun resolve(appName: String): ResolveResult {
        val normalized = normalizeForMatch(appName)
        AppLogger.debug("APPS", "حل اسم التطبيق: '$appName' → '$normalized'")

        // 1. بحث مباشر في الخريطة
        APP_NAME_MAP[normalized]?.let { packageName ->
            if (isPackageInstalled(packageName)) {
                AppLogger.debug("APPS", "تم العثور في الخريطة: $packageName")
                return ResolveResult.Found(packageName)
            }
        }

        // 2. بحث جزئي في الخريطة
        for ((name, packageName) in APP_NAME_MAP) {
            if (name.contains(normalized) || normalized.contains(name)) {
                if (isPackageInstalled(packageName)) {
                    AppLogger.debug("APPS", "تم العثور ببحث جزئي: $packageName")
                    return ResolveResult.Found(packageName)
                }
            }
        }

        // 3. بحث في التطبيقات المثبتة بالاسم المعروض
        val installedMatch = searchInstalledApps(normalized)
        if (installedMatch != null) {
            AppLogger.debug("APPS", "تم العثور في التطبيقات المثبتة: $installedMatch")
            return ResolveResult.Found(installedMatch)
        }

        AppLogger.warn("APPS", "لم يتم العثور على التطبيق: $appName")
        return ResolveResult.NotFound(appName)
    }

    private fun searchInstalledApps(appName: String): String? {
        return try {
            val intent = Intent(Intent.ACTION_MAIN, null).apply {
                addCategory(Intent.CATEGORY_LAUNCHER)
            }
            val resolveInfos = packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)

            for (resolveInfo in resolveInfos) {
                val label = resolveInfo.loadLabel(packageManager).toString()
                val normalizedLabel = normalizeForMatch(label)
                if (normalizedLabel == appName ||
                    normalizedLabel.contains(appName) ||
                    appName.contains(normalizedLabel)
                ) {
                    return resolveInfo.activityInfo.packageName
                }
            }
            null
        } catch (e: Exception) {
            AppLogger.error("APPS", "خطأ في البحث عن التطبيقات المثبتة", e)
            null
        }
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            packageManager.getPackageInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun normalizeForMatch(text: String): String {
        return text
            .replace("ة", "ه")
            .replace("أ", "ا")
            .replace("إ", "ا")
            .replace("آ", "ا")
            .replace("ى", "ي")
            .replace(Regex("\\s+"), "")
            .lowercase()
    }

    sealed class ResolveResult {
        data class Found(val packageName: String) : ResolveResult()
        data class NotFound(val appName: String) : ResolveResult()
    }
}