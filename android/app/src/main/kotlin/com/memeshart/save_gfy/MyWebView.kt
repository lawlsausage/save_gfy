package com.memeshart.save_gfy

import android.content.Context
import android.graphics.Bitmap
import android.os.Build
import android.os.Handler
import android.util.Log
import android.view.View
import android.webkit.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView


class MyWebView internal constructor(context: Context, messenger: BinaryMessenger, id: Int) : PlatformView, MethodChannel.MethodCallHandler, WebViewClient() {
    private val context: Context = context;
    private val webView: WebView = WebView(context)
    private val methodChannel: MethodChannel
    private var loadingFinished: Boolean
    private var redirect: Boolean

    override fun getView(): View {
        return webView
    }

    init {
        webView.webViewClient = this
        webView.webChromeClient = object : WebChromeClient() {
            override fun onProgressChanged(view: WebView?, newProgress: Int) {
                super.onProgressChanged(view, newProgress)
                notifyProgressChange(newProgress)
            }
        }
        webView.addJavascriptInterface(this, "android")
        webView.settings.javaScriptEnabled = true
        webView.settings.domStorageEnabled = true
        webView.settings.setAppCacheEnabled(true)
        webView.settings.setAppCachePath(context.filesDir.absolutePath + "/cache")
        webView.settings.databaseEnabled = true

        methodChannel = MethodChannel(messenger, "${MainActivity.CHANNEL_NAME}/webview$id")
        methodChannel.setMethodCallHandler(this)

        loadingFinished = true
        redirect = false
    }

    override fun onFlutterViewDetached() {
//        super.onFlutterViewDetached()

        Log.d("save_gfy", "MyWebView detached")
        webView.clearCache(true)
        webView.clearHistory()

        clearCookies(context)
    }

    override fun dispose() {
        Log.d("save_gfy", "MyWebView disposed")
        webView.clearCache(true)
        webView.clearHistory()

        clearCookies(context)
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "loadUrl" -> loadUrl(methodCall, result)
            "execJavascript" -> execJavascript(methodCall, result)
            else -> result.notImplemented()
        }
    }

    override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {
        redirect = !loadingFinished

        if (request?.isRedirect == true) {
            methodChannel.invokeMethod("onRedirect", request?.url.toString())
        }

        loadingFinished = false
        webView.loadUrl(request?.url.toString())
        return true
    }

    override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
        super.onPageStarted(view, url, favicon)
        loadingFinished = false
        methodChannel.invokeMethod("onPageStarted", url)
    }

    override fun onPageFinished(view: WebView?, url: String?) {
        super.onPageFinished(view, url)
        if (!redirect) {
            loadingFinished = true
            methodChannel.invokeMethod("onPageFinished", url)
        } else {
            redirect = false
        }
    }

    @JavascriptInterface
    @Suppress("unused")
    fun onData(value: String) {
        val mainHandler = Handler(context.mainLooper)
        val runnable = Runnable {
            methodChannel.invokeMethod("onJavascriptResult", value)
        }
        when {
            value.isNotBlank() -> mainHandler.post(runnable)
        }
    }

    private fun loadUrl(methodCall: MethodCall?, result: MethodChannel.Result?) {
        val url = methodCall?.arguments as String
        webView.loadUrl(url)
        result?.success(null)
    }

    private fun execJavascript(methodCall: MethodCall?, result: MethodChannel.Result?) {
        val script = methodCall?.arguments as String
        webView.loadUrl("javascript:try { android.onData($script); } catch (err) { android.onData(JSON.stringify({})); }")
        result?.success(null)
    }

    private fun notifyProgressChange(newProgress: Int) {
        methodChannel.invokeMethod("progressChanged", newProgress)
    }

    @Suppress("deprecation")
    private fun clearCookies(context: Context?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            Log.d("save_gfy", "Using clearCookies code for API >=" + Build.VERSION_CODES.LOLLIPOP_MR1.toString())
            CookieManager.getInstance().removeAllCookies(null)
            CookieManager.getInstance().flush()
        } else {
            Log.d("save_gfy", "Using clearCookies code for API <" + Build.VERSION_CODES.LOLLIPOP_MR1.toString())
            val cookieSyncMngr = CookieSyncManager.createInstance(context)
            cookieSyncMngr.startSync()
            val cookieManager = CookieManager.getInstance()
            cookieManager.removeAllCookie()
            cookieManager.removeSessionCookie()
            cookieSyncMngr.stopSync()
            cookieSyncMngr.sync()
        }
    }
}