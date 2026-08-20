package com.abusrar.assistant

import android.app.Application
import com.abusrar.assistant.core.AppLogger

class AbuSrarApp : Application() {

    override fun onCreate() {
        super.onCreate()
        AppLogger.init(this)
        AppLogger.info("APP", "أبو صرار — بدء التشغيل")
    }
}