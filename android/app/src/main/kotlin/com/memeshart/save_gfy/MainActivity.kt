package com.memeshart.save_gfy

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.os.Environment
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "memeshart.com/save_gfy"
        const val SAVE_GFY_PERMISSIONS_REQUEST_WRITE_STORAGE = 100
    }

    private lateinit var channel: MethodChannel
    private val requiredStoragePermissions = arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE)
    private var isFlutterReady = false
    private val actionQueue = emptyList<() -> Unit>().toMutableList()
    private val downloadDirectory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).absolutePath

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        WebViewPlugin.registerWith((this.registrarFor("com.memeshart.save_gfy")))
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)

        channel = MethodChannel(flutterView, CHANNEL_NAME)
        channel.setMethodCallHandler(this)

        listenForActionSend(intent)

        checkPermissions()
    }

//    override fun onResume() {
//        super.onResume()
//
//        listenForActionSend(intent)
//    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "downloadsPath" -> sendDownloadsPath(result)
            "ready" -> {
                isFlutterReady = true
                runActionsInQueue()
            }
            "openDirectory" -> openDirectory()
        }
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)

        listenForActionSend(intent)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        when (requestCode) {
            SAVE_GFY_PERMISSIONS_REQUEST_WRITE_STORAGE -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    // permission had been granted
                }
            }
        }
    }

    private fun checkPermissions() {
        if (ContextCompat.checkSelfPermission(this,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    requiredStoragePermissions, SAVE_GFY_PERMISSIONS_REQUEST_WRITE_STORAGE)
        }
    }

    private fun listenForActionSend(intent: Intent?) {
        var action = fun() {}
        when (intent?.action) {
            Intent.ACTION_SEND -> {
                when (intent.type) {
                    "text/plain" -> action = fun() {
                        sendText(intent.getStringExtra(Intent.EXTRA_TEXT))
                    }
                }
            }
            Intent.ACTION_VIEW -> {
//                when {
//                    intent.dataString.contains("gfycat") -> action = fun() {
//                        sendText(intent.dataString)
//                    }
//                }
                sendText(intent.dataString)
            }
        }

        if (!isFlutterReady) {
            actionQueue += action
        } else {
            action.invoke()
        }
    }

    private fun sendText(text: String) {
        channel.invokeMethod("sharedText", text);
    }

    private fun runActionsInQueue() {
        actionQueue.forEach {
            it.invoke()
        }
        actionQueue.clear()
    }

    private fun sendDownloadsPath(result: MethodChannel.Result) {
        result.success(downloadDirectory)
    }

    private fun openDirectory() {
        val uri = Uri.parse(downloadDirectory)
        val intent = Intent(Intent.ACTION_VIEW)
        intent.setDataAndType(uri, "resource/folder")

        when {
            intent.resolveActivityInfo(packageManager, 0) != null -> {
                startActivity(intent)
            }
        }
    }
}
