package com.saosa.wigul

import android.content.ClipData
import android.content.Intent
import android.net.Uri
import android.os.Build

/**
 * 외부 앱 공유 시트·딥링크에서 위시리스트로 가져올 URL을 추출합니다.
 *
 * 지원 대상 쇼핑 앱: 무신사, 에이블리, 지그재그, 29CM, 올리브영,
 * 네이버쇼핑, 당근마켓, 번개장터
 */
object ShareIntentExtractor {
    private val HTTP_URL_PATTERN =
        Regex("""https?://[^\s<>"\]]+""", RegexOption.IGNORE_CASE)

    fun extract(intent: Intent?): String? {
        if (intent == null) return null

        return when (intent.action) {
            Intent.ACTION_SEND -> extractFromSendIntent(intent)
            Intent.ACTION_VIEW -> extractFromViewIntent(intent)
            else -> null
        }
    }

    private fun extractFromViewIntent(intent: Intent): String? {
        val data = intent.data ?: return null
        if (!isSupportedShoppingUri(data)) return null
        return data.toString().trim().takeIf { it.isNotEmpty() }
    }

    private fun extractFromSendIntent(intent: Intent): String? {
        extractFromExtraText(intent)?.let { return it }
        extractFromHtmlText(intent)?.let { return it }
        extractFromSubject(intent)?.let { return it }
        extractFromStream(intent)?.let { return it }
        extractFromClipData(intent.clipData)?.let { return it }

        val data = intent.data
        if (data != null) {
            val dataUrl = data.toString().trim()
            if (dataUrl.isNotEmpty()) {
                extractFirstHttpUrl(dataUrl)?.let { return it }
            }
        }

        return null
    }

    private fun extractFromExtraText(intent: Intent): String? {
        val text = intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()?.trim()
        return text?.takeIf { it.isNotEmpty() }
    }

    private fun extractFromHtmlText(intent: Intent): String? {
        val html = intent.getStringExtra(Intent.EXTRA_HTML_TEXT)?.trim()
        return html?.takeIf { it.isNotEmpty() }
    }

    private fun extractFromSubject(intent: Intent): String? {
        val subject = intent.getCharSequenceExtra(Intent.EXTRA_SUBJECT)?.toString()?.trim()
        return subject?.takeIf { it.isNotEmpty() }
    }

    private fun extractFromStream(intent: Intent): String? {
        val streamUri = intent.getStreamUri() ?: return null
        val uriText = streamUri.toString().trim()
        if (uriText.isEmpty()) return null

        return when (streamUri.scheme?.lowercase()) {
            "http", "https" -> extractFirstHttpUrl(uriText)
            else -> null
        }
    }

    private fun extractFromClipData(clipData: ClipData?): String? {
        if (clipData == null) return null

        for (index in 0 until clipData.itemCount) {
            val item = clipData.getItemAt(index)

            val text = item.text?.toString()?.trim()
            if (!text.isNullOrEmpty()) return text

            val uri = item.uri
            if (uri != null && isSupportedShoppingUri(uri)) {
                return uri.toString().trim().takeIf { it.isNotEmpty() }
            }
        }

        return null
    }

    private fun extractFirstHttpUrl(raw: String): String? {
        val direct = normalizeHttpUrl(raw)
        if (direct != null) return direct

        val match = HTTP_URL_PATTERN.find(raw) ?: return null
        return normalizeHttpUrl(stripTrailingUrlPunctuation(match.value))
    }

    private fun normalizeHttpUrl(raw: String): String? {
        var candidate = raw.trim()
        if (candidate.isEmpty()) return null

        if (!candidate.contains("://")) {
            candidate = "https://$candidate"
        }

        val uri = Uri.parse(candidate)
        val scheme = uri.scheme?.lowercase()
        if (scheme != "http" && scheme != "https") return null
        if (uri.host.isNullOrEmpty()) return null

        return uri.toString()
    }

    private fun stripTrailingUrlPunctuation(url: String): String {
        var end = url.length
        while (end > 0 && ",.;)]}".contains(url[end - 1])) {
            end--
        }
        return url.substring(0, end)
    }

    private fun isSupportedShoppingUri(uri: Uri): Boolean {
        val host = uri.host?.lowercase() ?: return false
        return SUPPORTED_SHOPPING_HOST_SUFFIXES.any { suffix ->
            host == suffix || host.endsWith(".$suffix")
        }
    }

    private fun Intent.getStreamUri(): Uri? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            getParcelableExtra(Intent.EXTRA_STREAM)
        }
    }

    private val SUPPORTED_SHOPPING_HOST_SUFFIXES = listOf(
        "musinsa.com",
        "a-bly.com",
        "zigzag.kr",
        "29cm.co.kr",
        "oliveyoung.co.kr",
        "shopping.naver.com",
        "smartstore.naver.com",
        "brand.naver.com",
        "daangn.com",
        "karrotmarket.com",
        "bunjang.co.kr",
    )
}
