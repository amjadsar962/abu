أبو صرار — Abu Srar
مساعد صوتي شخصي يعمل على نظام Android. يتحدث باللغة العربية ويتحكم في جهازك بأوامر صوتية بسيطة.

فكرة المشروع
أبو صرار هو مساعد صوتي يتيح لك التحكم في هاتف Android باللغة العربية. قل "أبو صرار" ثم أعطِه أمراً مثل "افتح واتساب" فينفذه لك.

Architecture
المشروع مبني على MVVM + Clean Architecture مع فصل واضح بين الطبقات:

com.abusrar.assistant/
├── core/ — أساسيات: Logger، Result types
├── voice/ — طبقة الصوت: Speech Recognition، TTS، VoiceManager
├── commands/ — معالجة الأوامر: Parser، Router
├── tools/ — الأدوات: OpenApp، Home، Back، Search، إلخ
├── apps/ — إدارة التطبيقات: Resolver، Launcher، WhatsAppController
├── accessibility/ — خدمة إمكانية الوصول (بنية مستقبلية)
├── ai/ — طبقة الذكاء الاصطناعي (abstraction + RuleBased)
├── permissions/ — إدارة الأذونات
├── settings/ — الإعدادات
└── ui/ — واجهة المستخدم (Jetpack Compose)

### تدفق البيانات
صوت المستخدم
→ SpeechRecognizerManager (تحويل لنص)
→ CommandParser (تحليل النص)
→ CommandRouter (توجيه للأداة المناسبة)
→ Tool.execute() (تنفيذ الأمر)
→ TTSManager (رد صوتي)

text


## كيفية البناء

### المتطلبات
- Android Studio Hedgehog أو أحدث
- Gradle 8.5+
- JDK 17

### الخطوات

1. استنساخ المشروع
2. فتحه في Android Studio
3. انتظار مزامنة Gradle
4. ربط جهاز Android أو تشغيل Emulator
5. تشغيل التطبيق

```bash
# أو من سطر الأوامر
./gradlew assembleDebug
./gradlew installDebug
الأذونات
مطلوبة (V1)
الصلاحية
السبب
RECORD_AUDIO	لسماع صوت المستخدم وتحويله لنص
INTERNET	للبحث في الويب (مستقبلاً للـ AI)
POST_NOTIFICATIONS	(Android 13+) للإشعارات

اختيارية (تُطلب عند الحاجة)
الصلاحية
السبب
CALL_PHONE	لإجراء مكالمات
SEND_SMS	لإرسال رسائل SMS
READ_CONTACTS	للبحث عن أسماء جهات الاتصال

Accessibility Service
خدمة إمكانية الوصول معطّلة افتراضياً ولا تُطلب إلا عندما يحتاجها المستخدم.

الغرض المستقبلي: التحكم داخل التطبيقات (النقر، إدخال نص، التمرير).

التفعيل: الإعدادات → إمكانية الوصول → تفعيل "أبو صرار"

ملاحظة مهمة: الخدمة حالياً تحتوي على بنية أساسية فقط ولا تنفذ أي أتمتة.

الأوامر المدعومة (V1)
الأمر
المثال
الوظيفة
كلمة الاستيقاظ	"أبو صرار"	يرد "تفضل سيدي" ويستمع
فتح تطبيق	"افتح واتساب"	يفتح التطبيق المطلوب
فتح الإعدادات	"افتح الإعدادات"	يفتح إعدادات النظام
الشاشة الرئيسية	"الرئيسية"	يرجع للشاشة الرئيسية
البحث في الويب	"ابحث عن الطقس"	يفتح بحث Google
إجراء مكالمة	"اتصل بـ 0512345678"	يفتح تطبيق الهاتف
إرسال رسالة	"ارسل رسالة لـ 0512345678"	يفتح تطبيق الرسائل

التطبيقات المدعومة بالاسم العربي
واتساب، يوتيوب، فيسبوك، انستغرام، تويتر/إكس، تيك توك، سناب شات، تيليجرام، كروم، جوجل، سبوتيفاي، نيتفلكس، خرائط جوجل، جيميل، والكثير غيرها.

إذا لم يكن التطبيق في القائمة، يبحث تلقائياً في التطبيقات المثبتة بالاسم.

كيفية إضافة Tool جديدة
كيفية إضافة Tool جديدة
أنشئ ملف في tools/:
class MyNewTool(private val context: Context) : Tool {
    override val name = "my_tool"
    override val description = "وصف الأداة"

    override fun canHandle(command: Command): Boolean {
        return command is Command.MyNewCommand
    }

    override fun execute(command: Command): AppResult<String> {
        // تنفيذ الأمر
        return AppResult.Success("تم التنفيذ")
    }
}
أضف Command جديدة في commands/Command.kt
سجّل الأداة في MainViewModel.init:
toolRegistry.register(MyNewTool(application))
أضف نمط التعرف في CommandParser.parseCommand()
كيفية إضافة AI Provider
أنشئ صنف يطبّق AIProvider أو ChatProvider:
class MyAIProvider : AIProvider {
    override val name = "my_ai"
    override val isAvailable = true
    override val capabilities = ModelCapabilities(
        supportsChat = true,
        supportsArabic = true
    )

    override suspend fun chat(request: AIRequest): AIResponse {
        // اتصل بالـ API
        return AIResponse(text = "الرد", isSuccess = true)
    }

    override fun initialize(config: Map<String, String>) {}
    override fun shutdown() {}
}
}
providerManager.registerProvider(MyAIProvider())
providerManager.setActiveProvider("my_ai")
المشاكل المعروكة
التعرف على الكلام: يعتمد على محرك Google المثبت على الجهاز. بعض الأجهزة قد لا تدعم العربية بشكل جيد.
Wake Word: في V1 يعمل بالكلمات المفتاحية داخل النص المعروف، وليس استماعاً مستمراً.
أمر الرجوع: يحتاج Accessibility Service للعمل. حالياً يُرجع رسالة خطأ.
أسماء التطبيقات: القائمة لا تغطي كل التطبيقات، لكن البحث في التطبيقات المثبتة يعمل كبديل.
المكالمات والرسائل: تتطلب صلاحيات إضافية ومطابقة أرقام الهاتف فقط (بدون أسماء جهات الاتصال).
الأمان
لا تُخزن مفاتيح API في الكود المصدري
الإعدادات الحساسة مشمولة من النسخ الاحتياطي
لا تُجمع بيانات شخصية
لا تُنفذ أوامر خطرة تلقائياً
Accessibility Service معطّلة افتراضياً
Roadmap
الإصدار
الميزة
الحالة
V1	صوت + TTS + فتح التطبيقات	✅ حالياً
V2	Wake Word حقيقي (Porcupine أو مشابه)	🔜 قريباً
V3	Accessibility Automation	🔜 مخطط
V4	WhatsApp Automation	🔜 مخطط
V5	AI Agent (مع Function Calling)	🔜 مخطط
V6	ذاكرة المحادثات	🔜 مخطط
V7	أدوات شخصية مخصصة	🔜 مخطط
V8	AI محلي (لا يحتاج إنترنت)	🔜 مخطط
V9	أتمتة Android متقدمة	🔜 مخطط

الترخيص
هذا المشروع لأغراض تعليمية وتطويرية.

text


---

## ملخص هيكل الملفات النهائي

AbuSrar/
├── .gitignore
├── README.md
├── build.gradle.kts
├── settings.gradle.kts
├── gradle.properties
├── gradle/
│ └── wrapper/
│ └── gradle-wrapper.properties
└── app/
├── build.gradle.kts
├── proguard-rules.pro
└── src/
└── main/
├── AndroidManifest.xml
├── java/com/abusrar/assistant/
│ ├── AbuSrarApp.kt
│ ├── MainActivity.kt
│ ├── core/
│ │ ├── AppLogger.kt
│ │ └── AppResult.kt
│ ├── voice/
│ │ ├── VoiceManager.kt
│ │ ├── VoiceManagerImpl.kt (داخل VoiceManager.kt)
│ │ ├── SpeechRecognizerManager.kt
│ │ └── TTSManager.kt
│ ├── commands/
│ │ ├── Command.kt
│ │ ├── CommandParser.kt
│ │ └── CommandRouter.kt
│ ├── tools/
│ │ ├── Tool.kt
│ │ ├── ToolExecutor.kt
│ │ ├── OpenAppTool.kt
│ │ ├── NavigationTools.kt
│ │ ├── WebSearchTool.kt
│ │ └── CommunicationTools.kt
│ ├── apps/
│ │ ├── AppLauncher.kt
│ │ ├── AppResolver.kt
│ │ └── WhatsAppController.kt
│ ├── accessibility/
│ │ ├── AbuSrarAccessibilityService.kt
│ │ └── AccessibilityController.kt
│ ├── ai/
│ │ ├── AIProvider.kt
│ │ ├── ProviderManager.kt
│ │ └── RuleBasedProvider.kt
│ ├── permissions/
│ │ └── PermissionManager.kt
│ ├── settings/
│ │ ├── SettingsManager.kt
│ │ ├── SettingsViewModel.kt
│ │ └── SettingsActivity.kt
│ └── ui/
│ ├── theme/
│ │ ├── Theme.kt
│ │ ├── Color.kt
│ │ └── Type.kt
│ ├── main/
│ │ ├── MainScreen.kt
│ │ └── MainViewModel.kt
│ └── components/
│ └── MicButton.kt
└── res/
├── drawable/
│ └── ic_launcher_foreground.xml
├── mipmap-anydpi-v26/
│ ├── ic_launcher.xml
│ └── ic_launcher_round.xml
├── values/
│ ├── strings.xml
│ ├── colors.xml
│ └── themes.xml
├── values-ar/
│ └── strings.xml
└── xml/
├── accessibility_service_config.xml
└── backup_rules.xml

---

## ملاحظات مهمة للبناء

**لتشغيل المشروع على Android Studio:**

1. أنشئ مجلد `AbuSrar` وأنسخ كل الملفات حسب المسارات المحددة
2. افتح المجلد بـ Android Studio (File → Open)
3. انتظر انتهاء Gradle Sync
4. شغّل `gradlew assembleDebug` أو اضغط Run

**ملاحظة عن `VoiceManagerImpl`:** هو مكتوب داخل ملف `VoiceManager.kt` (بعد الـ interface مباشرة). لا أنشئ ملف منفصل له.

**ملاحظة عن `local.properties`:** لا تنشئ هذا الملف يدوياً — Android Studio ينشئه تلقائياً عند فتح المشروع ويضع فيه مسار SDK.

**ملاحظة عن Gradle Wrapper:** الملفات `gradlew` و `gradlew.bat` و `gradle-wrapper.jar` لا يمكن إنشاؤها كنص. شغّل من Android Studio: `Tools → Gradle → Create Gradle Wrapper` أو شغّل المشروع وسيُنشأ تلقائياً.

**السيناريو الأول القابل للعمل:**
1. افتح التطبيق ← ترى "أبو صرار" مع زر ميكروفون أزرق
2. اضغط الزر ← يتحول لأخضر نابض ويعرض "أستمع إليك..."
3. قل "أبو صرار" ← يرد صوتياً "تفضل سيدي" ويستمع تلقائياً
4. قل "افتح واتساب" ← يفتح WhatsApp ويعرض "تم فتح واتساب"
5. عد للتطبيق ← قل "افتح يوتيوب" ← يفتح YouTube
6. قل "افتح الإعدادات" ← يفتح Settings