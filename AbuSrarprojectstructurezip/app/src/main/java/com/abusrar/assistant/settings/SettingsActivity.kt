package com.abusrar.assistant.settings

import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import com.abusrar.assistant.accessibility.AccessibilityController
import com.abusrar.assistant.ui.theme.AbuSrarTheme

class SettingsActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val settingsManager = SettingsManager(this)
        val viewModel = SettingsViewModel(settingsManager)

        setContent {
            AbuSrarTheme {
                SettingsScreen(
                    viewModel = viewModel,
                    onBack = { finish() }
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SettingsScreen(
    viewModel: SettingsViewModel,
    onBack: () -> Unit
) {
    val context = LocalContext.current
    var speechRate by remember { mutableFloatStateOf(viewModel.speechRate) }
    var voiceEnabled by remember { mutableStateOf(viewModel.isVoiceEnabled) }
    var logEnabled by remember { mutableStateOf(viewModel.isLogEnabled) }
    var selectedLanguage by remember { mutableStateOf(viewModel.listeningLanguage) }
    var selectedWakeMode by remember { mutableStateOf(viewModel.wakeWordMode) }
    var isAccessibilityRunning by remember { mutableStateOf(viewModel.isAccessibilityServiceRunning()) }
    var showApiKeyDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("الإعدادات") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "رجوع")
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // === قسم الصوت ===
            Text(
                text = "الصوت",
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.primary
            )

            // تفعيل الرد الصوتي
            Card(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text("الرد الصوتي")
                        Text(
                            "تشغيل أو إيقاف صوت المساعد",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    Switch(
                        checked = voiceEnabled,
                        onCheckedChange = {
                            voiceEnabled = it
                            viewModel.setVoiceEnabled(it)
                        }
                    )
                }
            }

            // سرعة الصوت
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("سرعة الصوت: ${"%.1f".format(speechRate)}")
                    Slider(
                        value = speechRate,
                        onValueChange = {
                            speechRate = it
                            viewModel.setSpeechRate(it)
                        },
                        valueRange = 0.5f..2.0f,
                        steps = 5
                    )
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text("بطيء", style = MaterialTheme.typography.labelSmall)
                        Text("سريع", style = MaterialTheme.typography.labelSmall)
                    }
                }
            }

            // لغة الاستماع
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("لغة الاستماع")
                    Spacer(modifier = Modifier.height(8.dp))
                    val languages = listOf(
                        "ar-SA" to "العربية (السعودية)",
                        "ar-AE" to "العربية (الإمارات)",
                        "ar-EG" to "العربية (مصر)",
                        "en-US" to "الإنجليزية (أمريكا)"
                    )
                    languages.forEach { (code, label) ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            RadioButton(
                                selected = selectedLanguage == code,
                                onClick = {
                                    selectedLanguage = code
                                    viewModel.setListeningLanguage(code)
                                }
                            )
                            Text(label, modifier = Modifier.padding(start = 8.dp))
                        }
                    }
                }
            }

            HorizontalDivider()

            // === قسم Wake Word ===
            Text(
                text = "كلمة الاستيقاظ",
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.primary
            )

            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("وضع الاستماع")
                    Spacer(modifier = Modifier.height(8.dp))
                    listOf(
                        "button" to "زر الاستماع (المبدئي)",
                        "continuous" to "استماع مستمر (قريباً)"
                    ).forEach { (mode, label) ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            RadioButton(
                                selected = selectedWakeMode == mode,
                                onClick = {
                                    if (mode == "continuous") {
                                        // لا يمكن تفعيله بعد
                                    } else {
                                        selectedWakeMode = mode
                                        viewModel.setWakeWordMode(mode)
                                    }
                                },
                                enabled = mode != "continuous"
                            )
                            Text(
                                label,
                                modifier = Modifier.padding(start = 8.dp),
                                color = if (mode == "continuous")
                                    MaterialTheme.colorScheme.onSurfaceVariant
                                else
                                    MaterialTheme.colorScheme.onSurface
                            )
                        }
                    }
                }
            }

            HorizontalDivider()

            // === قسم AI ===
            Text(
                text = "الذكاء الاصطناعي",
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.primary
            )

            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("المزود الحالي: ${viewModel.aiProvider}")
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        "في النسخة الأولى، يعتمد أبو صرار على قواعد محددة بدون الحاجة لـ API.",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedButton(
                        onClick = { showApiKeyDialog = true },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("إعدادات API (متقدم)")
                    }
                }
            }

            HorizontalDivider()

            // === قسم إمكانية الوصول ===
            Text(
                text = "إمكانية الوصول",
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.primary
            )

            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text("خدمة إمكانية الوصول")
                            Text(
                                if (isAccessibilityRunning) "مفعّلة" else "معطّلة",
                                style = MaterialTheme.typography.bodySmall,
                                color = if (isAccessibilityRunning)
                                    MaterialTheme.colorScheme.primary
                                else
                                    MaterialTheme.colorScheme.error
                            )
                        }
                        Button(
                            onClick = {
                                AccessibilityController.openAccessibilitySettings(context)
                            }
                        ) {
                            Text("فتح الإعدادات")
                        }
                    }
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        "مطلوبة للتحكم داخل التطبيقات (مرحلة مستقبلية)",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            HorizontalDivider()

            // === قسم التنقيح ===
            Text(
                text = "أخرى",
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.primary
            )

            Card(modifier = Modifier.fillMaxWidth()) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text("سجل التشغيل")
                        Text(
                            "تسجيل الأحداث لتصحيح الأخطاء",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                    Switch(
                        checked = logEnabled,
                        onCheckedChange = {
                            logEnabled = it
                            viewModel.setLogEnabled(it)
                        }
                    )
                }
            }

            // === حول ===
            HorizontalDivider()
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text("أبو صرار", style = MaterialTheme.typography.titleMedium)
                    Text("الإصدار 1.0.0", style = MaterialTheme.typography.bodySmall)
                    Text(
                        "مساعد صوتي شخصي لنظام Android",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            Spacer(modifier = Modifier.height(32.dp))
        }
    }

    if (showApiKeyDialog) {
        AlertDialog(
            onDismissRequest = { showApiKeyDialog = false },
            title = { Text("إعدادات API") },
            text = {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(
                        "تحذير: لا يُنصح بتخزين مفاتيح API في النسخة الأولى. سيتم دعم التخزين الآمن لاحقاً.",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.error
                    )
                    OutlinedTextField(
                        value = viewModel.apiUrl,
                        onValueChange = { viewModel.setApiUrl(it) },
                        label = { Text("رابط API") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    OutlinedTextField(
                        value = viewModel.apiKey,
                        onValueChange = { viewModel.setApiKey(it) },
                        label = { Text("مفتاح API") },
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            },
            confirmButton = {
                TextButton(onClick = { showApiKeyDialog = false }) {
                    Text("حفظ")
                }
            },
            dismissButton = {
                TextButton(onClick = { showApiKeyDialog = false }) {
                    Text("إلغاء")
                }
            }
        )
    }
}