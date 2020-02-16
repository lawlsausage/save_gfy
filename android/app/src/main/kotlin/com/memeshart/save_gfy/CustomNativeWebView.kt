package com.memeshart.save_gfy

import android.content.Context
import android.webkit.WebView

class CustomNativeWebView internal constructor(context: Context) : WebView(context) {
    override fun hasWindowFocus(): Boolean {
        return true
    }
}