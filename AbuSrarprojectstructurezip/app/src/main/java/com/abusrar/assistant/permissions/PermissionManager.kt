package com.abusrar.assistant.permissions

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.content.ContextCompat

/**
 * مدير الأذونات
 * يتحقق من الأذونات ويوفر معلومات عنها
 */
class PermissionManager(private val context: Context) {

    enum class Permission(
        val manifestPermission: String,
        val titleAr: String,
        val descriptionAr: String,
        val isRequired: Boolean,
        val minSdk: Int = 0
    ) {
        MICROPHONE(
            Manifest.permission.RECORD_AUDIO,
            "الميكروفون",
            "لاستقبال صوتك وتحويله إلى أوامر نصية",
            true
        ),
        NOTIFICATION(
            Manifest.permission.POST_NOTIFICATIONS,
            "الإشعارات",
            "لإرسال إشعارات عند الحاجة",
            false,
            Build.VERSION_CODES.TIRAMISU
        ),
        CALL_PHONE(
            Manifest.permission.CALL_PHONE,
            "الاتصال الهاتفي",
            "لإجراء مكالمات هاتفية عند طلبك",
            false
        ),
        SEND_SMS(
            Manifest.permission.SEND_SMS,
            "إرسال الرسائل",
            "لإرسال رسائل SMS عند طلبك",
            false
        ),
        CONTACTS(
            Manifest.permission.READ_CONTACTS,
            "جهات الاتصال",
            "للبحث عن أسماء جهات الاتصال عند الاتصال أو إرسال الرسائل",
            false
        )
    }

    fun isPermissionGranted(permission: Permission): Boolean {
        if (Build.VERSION.SDK_INT < permission.minSdk) {
            return true // الصلاحية غير موجودة في هذا الإصدار
        }
        return ContextCompat.checkSelfPermission(
            context,
            permission.manifestPermission
        ) == PackageManager.PERMISSION_GRANTED
    }

    fun getRequiredPermissions(): List<Permission> {
        return Permission.entries.filter { it.isRequired && Build.VERSION.SDK_INT >= it.minSdk }
    }

    fun getOptionalPermissions(): List<Permission> {
        return Permission.entries.filter { !it.isRequired && Build.VERSION.SDK_INT >= it.minSdk }
    }

    fun getMissingPermissions(): List<Permission> {
        return Permission.entries.filter { !isPermissionGranted(it) && Build.VERSION.SDK_INT >= it.minSdk }
    }

    fun getMissingRequiredPermissions(): List<Permission> {
        return getRequiredPermissions().filter { !isPermissionGranted(it) }
    }

    fun hasAllRequiredPermissions(): Boolean {
        return getMissingRequiredPermissions().isEmpty()
    }

    fun getPermissionArray(permissions: List<Permission>): Array<String> {
        return permissions
            .filter { Build.VERSION.SDK_INT >= it.minSdk }
            .map { it.manifestPermission }
            .toTypedArray()
    }
}