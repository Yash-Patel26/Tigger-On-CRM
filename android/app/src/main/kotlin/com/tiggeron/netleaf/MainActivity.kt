package com.tiggeron.netleaf

import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "tigger/recorder"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "startCall" -> {
                    val number = call.argument<String>("number") ?: return@setMethodCallHandler result.error("ARG", "number required", null)
                    try {
                        // start foreground recording service
                        CallRecorderService.start(this, number)
                        // place phone call via ACTION_CALL (requires CALL_PHONE)
                        val intent = Intent(Intent.ACTION_CALL, Uri.parse("tel:$number"))
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CALL_START_FAIL", e.message, null)
                    }
                }
                "endCall" -> {
                    try {
                        CallRecorderService.stop(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("CALL_END_FAIL", e.message, null)
                    }
                }
                "getLastRecordingPath" -> {
                    try {
                        result.success(CallRecorderService.lastOutputPath)
                    } catch (e: Exception) {
                        result.error("REC_PATH_FAIL", e.message, null)
                    }
                }
                "isCallActive" -> {
                    try {
                        result.success(CallRecorderService.isCallActive)
                    } catch (e: Exception) {
                        result.error("CALL_STATE_FAIL", e.message, null)
                    }
                }
                "hasCallEnded" -> {
                    try {
                        result.success(CallRecorderService.callEnded)
                    } catch (e: Exception) {
                        result.error("CALL_ENDED_FAIL", e.message, null)
                    }
                }
                "isRecordingFinalized" -> {
                    try {
                        result.success(CallRecorderService.recordingFinalized)
                    } catch (e: Exception) {
                        result.error("REC_FINALIZED_FAIL", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

}

