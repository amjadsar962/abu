.PHONY: check sync clean

check:
		./gradlew compileDebugKotlin --no-daemon 2>&1 || echo ""
		@echo ""
		@echo "=== ملخص التحقق ==="
		@echo "إذا ظهرت أخطاء compilation، أصلحها قبل نقل المشروع لـ Android Studio"
		@echo "أخطاء Gradle wrapper طبيعية في Replit — لا تقلق منها"

sync:
		./gradlew --no-daemon tasks --all 2>&1 | head -20 || echo "Gradle sync - تحقق من الملفات يدوياً"

clean:
		rm -rf app/build .gradle build