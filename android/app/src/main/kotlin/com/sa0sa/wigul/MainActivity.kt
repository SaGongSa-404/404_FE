package com.sa0sa.wigul

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val shareMethodChannel = "wigul/share_intent"
    private val shareEventChannel = "wigul/share_intent/events"
    private var pendingSharedText: String? = null
    private var shareEventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        pendingSharedText = ShareIntentExtractor.extract(intent)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            shareMethodChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialSharedText" -> {
                    result.success(pendingSharedText)
                    pendingSharedText = null
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            shareEventChannel,
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    shareEventSink = events
                    pendingSharedText?.let {
                        events?.success(it)
                        pendingSharedText = null
                    }
                }

                override fun onCancel(arguments: Any?) {
                    shareEventSink = null
                }
            },
        )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)

        val sharedText = ShareIntentExtractor.extract(intent) ?: return
        val eventSink = shareEventSink
        if (eventSink == null) {
            pendingSharedText = sharedText
        } else {
            eventSink.success(sharedText)
        }
    }

    override fun shouldDestroyEngineWithHost(): Boolean = true
}
