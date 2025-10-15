package com.example.tigger

import android.Manifest
import android.content.Intent
import android.net.Uri
import android.media.MediaRecorder
import android.os.Build
import android.os.Environment
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val channelName = "tigger/recorder"
    private var recorder: MediaRecorder? = null
    private var outputPath: String? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "startRecording" -> {
                    val number = call.argument<String>("number") ?: "unknown"
                    try {
                        startRecording(number)
                        result.success(outputPath)
                    } catch (e: Exception) {
                        result.error("REC_START_FAIL", e.message, null)
                    }
                }
                "stopRecording" -> {
                    try {
                        val path = stopRecording()
                        result.success(path)
                    } catch (e: Exception) {
                        result.error("REC_STOP_FAIL", e.message, null)
                    }
                }
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
                else -> result.notImplemented()
            }
        }
    }

    private fun startRecording(number: String) {
        stopIfRunning()
        val time = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
        val dir = File(getExternalFilesDir(Environment.DIRECTORY_MUSIC), "calls")
        if (!dir.exists()) dir.mkdirs()
        val file = File(dir, "call_${number}_$time.m4a")
        outputPath = file.absolutePath

        val r = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) MediaRecorder(this) else MediaRecorder()
        recorder = r
        r.setAudioSource(MediaRecorder.AudioSource.MIC)
        r.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
        r.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
        r.setAudioSamplingRate(44100)
        r.setAudioEncodingBitRate(96000)
        r.setOutputFile(outputPath)
        r.prepare()
        r.start()
    }

    private fun stopRecording(): String? {
        val r = recorder ?: return outputPath
        try {
            r.stop()
        } catch (_: Exception) { }
        r.reset()
        r.release()
        recorder = null
        return outputPath
    }

    private fun stopIfRunning() {
        if (recorder != null) {
            try { recorder?.stop() } catch (_: Exception) {}
            recorder?.reset()
            recorder?.release()
            recorder = null
        }
    }
}
