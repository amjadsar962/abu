package com.abusrar.assistant

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.*
import androidx.core.content.ContextCompat
import com.abusrar.assistant.permissions.PermissionManager
import com.abusrar.assistant.settings.SettingsActivity
import com.abusrar.assistant.ui.main.MainScreen
import com.abusrar.assistant.ui.main.MainViewModel
import com.abusrar.assistant.ui.theme.AbuSrarTheme

class MainActivity : ComponentActivity() {

    private lateinit var viewModel: MainViewModel
    private lateinit var permissionManager: PermissionManager

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val allGranted = permissions.entries.all { it.value }
        if (allGranted) {
            com.abusrar.assistant.core.AppLogger.info("PERMISSION", "تم منح جميع الأذونات")
        } else {
            com.abusrar.assistant.core.AppLogger.warn("PERMISSION", "بعض الأذونات مرفوضة")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        permissionManager = PermissionManager(this)
        viewModel = MainViewModel(application)

        requestRequiredPermissions()

        setContent {
            AbuSrarTheme {
                val uiState by viewModel.uiState.collectAsState()

                MainScreen(
                    uiState = uiState,
                    onMicClicked = { viewModel.onMicClicked() },
                    onSettingsClicked = { openSettings() }
                )
            }
        }
    }

    private fun requestRequiredPermissions() {
        val missingPermissions = permissionManager.getMissingRequiredPermissions()
        if (missingPermissions.isNotEmpty()) {
            val permissionsArray = permissionManager.getPermissionArray(missingPermissions)
            permissionLauncher.launch(permissionsArray)
        }
    }

    private fun openSettings() {
        viewModel.stopListening()
        val intent = Intent(this, SettingsActivity::class.java)
        startActivity(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        // ViewModel يتم تنظيفه تلقائياً via onCleared
    }
}