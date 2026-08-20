package com.abusrar.assistant.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val DarkColorScheme = darkColorScheme(
    primary = AbuSrarBlue,
    onPrimary = White,
    primaryContainer = AbuSrarBlueDark,
    onPrimaryContainer = LightBlue,
    secondary = AbuSrarTeal,
    onSecondary = White,
    secondaryContainer = AbuSrarTealDark,
    onSecondaryContainer = LightTeal,
    tertiary = AbuSrarPurple,
    onTertiary = White,
    background = DarkBackground,
    onBackground = TextPrimary,
    surface = SurfaceDark,
    onSurface = TextPrimary,
    onSurfaceVariant = TextSecondary,
    error = ErrorRed,
    onError = White,
    errorContainer = ErrorRedDark,
    onErrorContainer = LightRed,
    outline = OutlineColor,
    outlineVariant = OutlineVariantColor
)

@Composable
fun AbuSrarTheme(
    darkTheme: Boolean = true,
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = DarkColorScheme

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.background.toArgb()
            window.navigationBarColor = colorScheme.surface.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
            WindowCompat.getInsetsController(window, view).isAppearanceLightNavigationBars = false
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}

// ألوان أبو صرار
object AbuSrarColors {
    val Primary = AbuSrarBlue
    val Background = DarkBackground
    val Surface = SurfaceDark
    val TextPrimary = TextPrimary
    val TextSecondary = TextSecondary
    val Error = ErrorRed
    val Success = SuccessGreen
    val MicIdle = AbuSrarBlue
    val MicListening = MicActive
    val MicProcessing = ProcessingOrange
    val MicError = ErrorRed
}