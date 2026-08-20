package com.abusrar.assistant.ui.main

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.abusrar.assistant.ui.components.MicButtonWithClick
import com.abusrar.assistant.ui.components.MicState
import com.abusrar.assistant.ui.theme.AbuSrarColors
import com.abusrar.assistant.ui.theme.SurfaceElevated

@Composable
fun MainScreen(
    uiState: MainUiState,
    onMicClicked: () -> Unit,
    onSettingsClicked: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .fillMaxSize()
            .background(AbuSrarColors.Background)
            .padding(16.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // الجزء العلوي
            TopSection(onSettingsClicked = onSettingsClicked)

            Spacer(modifier = Modifier.weight(1f))

            // الجزء الأوسط — العنوان والحالة
            MiddleSection(
                statusText = uiState.statusText,
                lastCommand = uiState.lastCommand,
                lastResponse = uiState.lastResponse
            )

            Spacer(modifier = Modifier.weight(1f))

            // الجزء السفلي — زر الميكروفون
            BottomSection(
                micState = uiState.micState,
                onMicClicked = onMicClicked
            )

            Spacer(modifier = Modifier.height(32.dp))
        }
    }
}

@Composable
private fun TopSection(onSettingsClicked: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 16.dp),
        horizontalArrangement = Arrangement.End
    ) {
        IconButton(onClick = onSettingsClicked) {
            Icon(
                imageVector = Icons.Default.Settings,
                contentDescription = "الإعدادات",
                tint = AbuSrarColors.TextSecondary
            )
        }
    }
}

@Composable
private fun MiddleSection(
    statusText: String,
    lastCommand: String,
    lastResponse: String
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp),
        modifier = Modifier.padding(horizontal = 24.dp)
    ) {
        // اسم التطبيق
        Text(
            text = "أبو صرار",
            style = MaterialTheme.typography.displayMedium,
            color = AbuSrarColors.TextPrimary,
            textAlign = TextAlign.Center
        )

        // حالة المساعد
        Text(
            text = statusText,
            style = MaterialTheme.typography.bodyLarge,
            color = when {
                statusText.contains("أستمع") -> AbuSrarColors.MicListening
                statusText.contains("جاري") -> AbuSrarColors.MicProcessing
                statusText.contains("تم") -> AbuSrarColors.Success
                statusText.contains("ما") || statusText.contains("فشل") || statusText.contains("خطأ") -> AbuSrarColors.Error
                else -> AbuSrarColors.TextSecondary
            },
            textAlign = TextAlign.Center
        )

        // آخر أمر (إذا وجد)
        if (lastCommand.isNotEmpty()) {
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 8.dp),
                colors = CardDefaults.cardColors(
                    containerColor = SurfaceElevated
                )
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    if (lastCommand.isNotEmpty()) {
                        Text(
                            text = "🎤 $lastCommand",
                            style = MaterialTheme.typography.bodyMedium,
                            color = AbuSrarColors.TextSecondary
                        )
                    }
                    if (lastResponse.isNotEmpty()) {
                        Text(
                            text = "🤖 $lastResponse",
                            style = MaterialTheme.typography.bodyMedium,
                            color = AbuSrarColors.TextPrimary
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun BottomSection(
    micState: MicState,
    onMicClicked: () -> Unit
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Box(
            modifier = Modifier
                .clip(MaterialTheme.shapes.extraLarge)
                .clickable(
                    interactionSource = remember { MutableInteractionSource() },
                    indication = null,
                    onClick = onMicClicked
                )
                .padding(8.dp)
        ) {
            MicButtonWithClick(
                state = micState,
                onClick = onMicClicked
            )
        }

        Text(
            text = when (micState) {
                MicState.IDLE -> "اضغط للاستماع"
                MicState.LISTENING -> "جاري الاستماع..."
                MicState.PROCESSING -> "جاري التنفيذ..."
                MicState.ERROR -> "اضغط للمحاولة مرة أخرى"
            },
            style = MaterialTheme.typography.bodySmall,
            color = AbuSrarColors.TextTertiary
        )
    }
}