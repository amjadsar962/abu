package com.abusrar.assistant.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.abusrar.assistant.ui.theme.AbuSrarColors

enum class MicState {
    IDLE, LISTENING, PROCESSING, ERROR
}

@Composable
fun MicButton(
    state: MicState,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val color = when (state) {
        MicState.IDLE -> AbuSrarColors.MicIdle
        MicState.LISTENING -> AbuSrarColors.MicListening
        MicState.PROCESSING -> AbuSrarColors.MicProcessing
        MicState.ERROR -> AbuSrarColors.MicError
    }

    val infiniteTransition = rememberInfiniteTransition(label = "mic_anim")

    val scale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = if (state == MicState.LISTENING) 1.12f else 1f,
        animationSpec = if (state == MicState.LISTENING) {
            infiniteRepeatable(
                animation = tween(800, easing = EaseInOutCubic),
                repeatMode = RepeatMode.Reverse
            )
        } else {
            snap()
        },
        label = "scale"
    )

    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = if (state == MicState.LISTENING) 0.6f else 0f,
        animationSpec = if (state == MicState.LISTENING) {
            infiniteRepeatable(
                animation = tween(800, easing = EaseInOutCubic),
                repeatMode = RepeatMode.Reverse
            )
        } else {
            snap()
        },
        label = "glow"
    )

    Box(
        modifier = modifier.size(120.dp),
        contentAlignment = Alignment.Center
    ) {
        // هالة خارجية متحركة
        if (state == MicState.LISTENING) {
            Box(
                modifier = Modifier
                    .size(130.dp)
                    .clip(CircleShape)
                    .background(color.copy(alpha = glowAlpha * 0.3f))
            )
        }

        // الحد الخارجي
        Box(
            modifier = Modifier
                .size(100.dp)
                .clip(CircleShape)
                .border(
                    width = 2.dp,
                    color = color.copy(alpha = 0.5f),
                    shape = CircleShape
                )
                .background(MaterialTheme.colorScheme.surface),
            contentAlignment = Alignment.Center
        ) {
            // الزر الداخلي
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .clip(CircleShape)
                    .background(color)
                    .then(if (state == MicState.LISTENING) Modifier.size((80 * scale).dp) else Modifier),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Mic,
                    contentDescription = "ميكروفون",
                    tint = MaterialTheme.colorScheme.onPrimary,
                    modifier = Modifier.size(36.dp)
                )
            }
        }

        // زر غير مرئي لالتقاط النقرات على المنطقة الكاملة
        Box(
            modifier = Modifier
                .size(120.dp)
                .clip(CircleShape)
                .then(
                    if (state != MicState.PROCESSING) {
                        Modifier.background(Color.Transparent)
                    } else {
                        Modifier
                    }
                )
        ) {
            Spacer(modifier = Modifier
                .matchParentSize()
                .clip(CircleShape)
                .background(Color.Transparent)
            )
        }
    }

    // نعالج النقر على الحاوية الخارجية
    Spacer(
        modifier = Modifier
            .size(120.dp)
            .clip(CircleShape)
            .then(
                if (state != MicState.PROCESSING) {
                    Modifier
                } else {
                    Modifier
                }
            )
    )
}

/**
 * نسخة بسيطة من MicButton مع معالجة النقر
 */
@Composable
fun MicButtonWithClick(
    state: MicState,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val color = when (state) {
        MicState.IDLE -> AbuSrarColors.MicIdle
        MicState.LISTENING -> AbuSrarColors.MicListening
        MicState.PROCESSING -> AbuSrarColors.MicProcessing
        MicState.ERROR -> AbuSrarColors.MicError
    }

    val infiniteTransition = rememberInfiniteTransition(label = "mic_click_anim")

    val pulseScale by infiniteTransition.animateFloat(
        initialValue = 1f,
        targetValue = if (state == MicState.LISTENING) 1.15f else 1f,
        animationSpec = if (state == MicState.LISTENING) {
            infiniteRepeatable(
                animation = tween(600, easing = EaseInOutCubic),
                repeatMode = RepeatMode.Reverse
            )
        } else {
            snap()
        },
        label = "pulse"
    )

    val glowAlpha by infiniteTransition.animateFloat(
        initialValue = 0.2f,
        targetValue = if (state == MicState.LISTENING) 0.5f else 0f,
        animationSpec = if (state == MicState.LISTENING) {
            infiniteRepeatable(
                animation = tween(600, easing = EaseInOutCubic),
                repeatMode = RepeatMode.Reverse
            )
        } else {
            snap()
        },
        label = "glow_alpha"
    )

    val canClick = state != MicState.PROCESSING

    Box(
        modifier = modifier
            .size(140.dp)
            .clip(CircleShape)
            .then(
                if (canClick) {
                    Modifier
                } else {
                    Modifier
                }
            ),
        contentAlignment = Alignment.Center
    ) {
        // هالة الإستماع
        if (state == MicState.LISTENING) {
            Box(
                modifier = Modifier
                    .size(140.dp)
                    .clip(CircleShape)
                    .background(color.copy(alpha = glowAlpha * 0.25f))
            )
        }

        // الحلقة الخارجية
        Box(
            modifier = Modifier
                .size(110.dp)
                .clip(CircleShape)
                .border(2.dp, color.copy(alpha = 0.4f), CircleShape)
                .background(MaterialTheme.colorScheme.surface),
            contentAlignment = Alignment.Center
        ) {
            // الزر الأساسي
            Box(
                modifier = Modifier
                    .size(
                        if (state == MicState.LISTENING) (84 * pulseScale).dp
                        else 84.dp
                    )
                    .clip(CircleShape)
                    .background(color),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Mic,
                    contentDescription = if (canClick) "اضغط للاستماع" else "جاري المعالجة",
                    tint = MaterialTheme.colorScheme.onPrimary,
                    modifier = Modifier.size(38.dp)
                )
            }
        }
    }
}