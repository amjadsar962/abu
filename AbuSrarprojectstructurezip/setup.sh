#!/bin/bash
set -e

echo "================================"
echo "  أبو صرار — إعداد المشروع"
echo "================================"
echo ""

# إنشاء المجلدات
DIRS=(
    "app/src/main/java/com/abusrar/assistant/core"
    "app/src/main/java/com/abusrar/assistant/voice"
    "app/src/main/java/com/abusrar/assistant/commands"
    "app/src/main/java/com/abusrar/assistant/tools"
    "app/src/main/java/com/abusrar/assistant/apps"
    "app/src/main/java/com/abusrar/assistant/accessibility"
    "app/src/main/java/com/abusrar/assistant/ai"
    "app/src/main/java/com/abusrar/assistant/permissions"
    "app/src/main/java/com/abusrar/assistant/settings"
    "app/src/main/java/com/abusrar/assistant/ui/theme"
    "app/src/main/java/com/abusrar/assistant/ui/main"
    "app/src/main/java/com/abusrar/assistant/ui/components"
    "app/src/main/res/drawable"
    "app/src/main/res/mipmap-anydpi-v26"
    "app/src/main/res/values"
    "app/src/main/res/values-ar"
    "app/src/main/res/xml"
    "gradle/wrapper"
)

echo "📁 إنشاء المجلدات..."
for dir in "${DIRS[@]}"; do
    mkdir -p "$dir"
done
echo "   ✅ تم إنشاء ${#DIRS[@]} مجلد"

echo ""
echo "✅ المشروع جاهز للنسخ إليه الملفات"
echo ""
echo "الخطوة التالية:"
echo "  1. انسخ كل ملف من الرد السابق لمساره الصحيح"
echo "  2. افتح المشروع في Android Studio"
echo "  3. شغّل: ./gradlew assembleDebug"