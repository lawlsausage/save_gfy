package com.memeshart.save_gfy

import io.flutter.plugin.common.PluginRegistry.Registrar

object WebViewPlugin {
    fun registerWith(registrar: Registrar) {
        registrar
                .platformViewRegistry()
                .registerViewFactory(
                        "webview", WebViewFactory(registrar.messenger()))
    }
}