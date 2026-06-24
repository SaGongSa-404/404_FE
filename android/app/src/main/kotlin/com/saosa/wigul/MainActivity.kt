package com.saosa.wigul

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

        pendingSharedText = extractSharedText(intent)

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

        val sharedText = extractSharedText(intent) ?: return
        val eventSink = shareEventSink
        if (eventSink == null) {
            pendingSharedText = sharedText
        } else {
            eventSink.success(sharedText)
        }
    }

    override fun shouldDestroyEngineWithHost(): Boolean = true

    private fun extractSharedText(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_SEND) return null
        val type = intent.type ?: return null
        if (!type.startsWith("text/")) return null

        val text = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()?.trim()
        if (!text.isNullOrEmpty()) return text

        val subject = intent.getCharSequenceExtra(Intent.EXTRA_SUBJECT)?.toString()?.trim()
        return subject?.takeIf { it.isNotEmpty() }
    }
}
