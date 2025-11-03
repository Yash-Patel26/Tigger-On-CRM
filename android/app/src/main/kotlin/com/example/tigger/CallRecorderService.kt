package com.example.tigger

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.MediaRecorder
import android.media.AudioManager
import android.util.Log
import android.os.Build
import android.os.Environment
import android.os.IBinder
import androidx.core.app.NotificationCompat
import android.telephony.PhoneStateListener
import android.telephony.TelephonyManager
import java.io.File
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class CallRecorderService : Service() {
    companion object {
        const val CHANNEL_ID = "call_recorder_channel"
        const val NOTIF_ID = 101
        const val EXTRA_NUMBER = "extra_number"
        @JvmStatic
        var lastOutputPath: String? = null
        @JvmStatic
        var isCallActive: Boolean = false
        @JvmStatic
        var callEnded: Boolean = false
        @JvmStatic
        var recordingFinalized: Boolean = false

        fun start(context: Context, number: String) {
            val intent = Intent(context, CallRecorderService::class.java)
            intent.putExtra(EXTRA_NUMBER, number)
            // Reset call state flags when starting new call
            isCallActive = false
            callEnded = false
            recordingFinalized = false
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, CallRecorderService::class.java))
        }
    }

    private var recorder: MediaRecorder? = null
    private var outputPath: String? = null
    private var telephonyManager: TelephonyManager? = null
    private var isRecording: Boolean = false
    private var startFallbackPosted: Boolean = false
    private var audioManager: AudioManager? = null
    private var wasSpeakerOn: Boolean = false
    private val phoneStateListener: PhoneStateListener = object : PhoneStateListener() {
        override fun onCallStateChanged(state: Int, phoneNumber: String?) {
            super.onCallStateChanged(state, phoneNumber)
            when (state) {
                TelephonyManager.CALL_STATE_OFFHOOK -> {
                    // Call connected (outgoing answered or incoming answered)
                    Log.d("CallRecorderService", "CALL_STATE_OFFHOOK")
                    isCallActive = true
                    callEnded = false
                    if (!isRecording) {
                        val number = lastOutputPath?.let { extractNumberFromPath(it) } ?: "unknown"
                        try {
                            startRecording(number)
                            updateNotif("Recording call: $number")
                        } catch (e: Exception) {
                            Log.e("CallRecorderService", "startRecording failed: ${e.message}")
                        }
                    }
                }
                TelephonyManager.CALL_STATE_IDLE -> {
                    Log.d("CallRecorderService", "CALL_STATE_IDLE → stopping recording and service")
                    isCallActive = false
                    callEnded = true
                    recordingFinalized = false
                    // Stop recording first, then stop service
                    stopRecording()
                    // Mark recording as finalized after file write delay
                    // Give more time to ensure recording is properly finalized and file is written
                    android.os.Handler(mainLooper).postDelayed({
                        // Verify file exists and has content before marking as finalized
                        lastOutputPath?.let { path ->
                            val file = java.io.File(path)
                            if (file.exists() && file.length() > 0) {
                                recordingFinalized = true
                                Log.d("CallRecorderService", "Recording finalized: $path (${file.length()} bytes)")
                            } else {
                                Log.w("CallRecorderService", "Recording file not ready: $path")
                                recordingFinalized = false
                            }
                        } ?: run {
                            Log.w("CallRecorderService", "No recording path available")
                            recordingFinalized = false
                        }
                        Log.d("CallRecorderService", "Stopping service after recording finalized")
                        stopSelf()
                    }, 6000) // 6 seconds delay to ensure file is fully written on slower devices
                }
                TelephonyManager.CALL_STATE_RINGING -> {
                    Log.d("CallRecorderService", "CALL_STATE_RINGING")
                }
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val notification = buildNotification("Waiting for call to connect…")
        startForeground(NOTIF_ID, notification)
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
        telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_CALL_STATE)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val number = intent?.getStringExtra(EXTRA_NUMBER) ?: "unknown"
        // Pre-create output path for consistent file naming; actual recording starts on OFFHOOK
        prepareOutput(number)
        // Remove fallback auto-start recording to ensure we only record during an active call (OFFHOOK)
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("CallRecorderService", "Service destroying, stopping recording...")
        
        // Stop recording first
        stopRecording()
        
        // Unregister phone state listener
        try {
            telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE)
        } catch (e: Exception) {
            Log.e("CallRecorderService", "Error unregistering phone listener: ${e.message}")
        }
        
        // Restore speaker state if we modified it
        try {
            audioManager?.isSpeakerphoneOn = wasSpeakerOn
        } catch (e: Exception) {
            Log.e("CallRecorderService", "Error restoring speaker state: ${e.message}")
        }
        
        Log.d("CallRecorderService", "Service destroyed successfully")
    }

    private fun buildNotification(content: String): Notification {
        val openIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            openIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            else PendingIntent.FLAG_UPDATE_CURRENT
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Call recording")
            .setContentText(content)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val ch = NotificationChannel(CHANNEL_ID, "Call Recorder", NotificationManager.IMPORTANCE_LOW)
            nm.createNotificationChannel(ch)
        }
    }

    private fun prepareOutput(number: String, extension: String = "m4a") {
        val time = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
        val dir = File(getExternalFilesDir(Environment.DIRECTORY_MUSIC), "calls")
        if (!dir.exists()) dir.mkdirs()
        val file = File(dir, "call_${number}_$time.$extension")
        outputPath = file.absolutePath
        lastOutputPath = outputPath
    }

    private fun startRecording(number: String) {
        if (isRecording) return
        if (outputPath == null) prepareOutput(number, "3gp")
        var r = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) MediaRecorder(this) else MediaRecorder()
        recorder = r
        // route audio to speaker to improve remote-party pickup via mic
        try {
            wasSpeakerOn = audioManager?.isSpeakerphoneOn ?: false
            // Set call audio mode for better mic capture during calls
            audioManager?.mode = AudioManager.MODE_IN_COMMUNICATION
            audioManager?.isSpeakerphoneOn = true
        } catch (_: Exception) {}
        // Try VOICE_COMMUNICATION first (some devices route call audio better),
        // then VOICE_RECOGNITION, then MIC; finally CAMCORDER as a last resort.
        var sourceSet = false
        try {
            r.setAudioSource(MediaRecorder.AudioSource.VOICE_COMMUNICATION)
            sourceSet = true
        } catch (e: Exception) {
            Log.w("CallRecorderService", "VOICE_COMMUNICATION source failed: ${e.message}")
        }
        if (!sourceSet) {
            try {
                r.setAudioSource(MediaRecorder.AudioSource.VOICE_RECOGNITION)
                sourceSet = true
            } catch (e: Exception) {
                Log.w("CallRecorderService", "VOICE_RECOGNITION source failed: ${e.message}")
            }
        }
        if (!sourceSet) {
            try {
                r.setAudioSource(MediaRecorder.AudioSource.MIC)
                sourceSet = true
            } catch (e: Exception) {
                Log.w("CallRecorderService", "MIC source failed: ${e.message}")
            }
        }
        if (!sourceSet) {
            try {
                r.setAudioSource(MediaRecorder.AudioSource.CAMCORDER)
                sourceSet = true
            } catch (e: Exception) {
                Log.w("CallRecorderService", "CAMCORDER source failed: ${e.message}")
            }
        }
        // Primary attempt: 3GP/AMR which is often allowed during calls
        try {
            r.setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP)
            r.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_WB)
            try { r.setAudioChannels(1) } catch (_: Exception) {}
            r.setOutputFile(outputPath)

            // Listeners for diagnostics
            try {
                r.setOnErrorListener { _, what, extra ->
                    Log.e("CallRecorderService", "MediaRecorder error: what=$what extra=$extra")
                }
                r.setOnInfoListener { _, what, extra ->
                    Log.w("CallRecorderService", "MediaRecorder info: what=$what extra=$extra")
                }
            } catch (_: Exception) {}

            r.prepare()
            r.start()
            isRecording = true
            Log.d("CallRecorderService", "Recording started (AMR/3GP): $outputPath")
            return
        } catch (amrError: Exception) {
            Log.e("CallRecorderService", "Primary 3GP/AMR failed: ${amrError.message}")
            try { r.reset() } catch (_: Exception) {}
            try { r.release() } catch (_: Exception) {}
            recorder = null

            // Secondary fallback: AAC/M4A
            prepareOutput(number, "m4a")
            r = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) MediaRecorder(this) else MediaRecorder()
            recorder = r
            try {
                try { r.setAudioSource(MediaRecorder.AudioSource.VOICE_RECOGNITION) } catch (_: Exception) {}
                try { r.setAudioSource(MediaRecorder.AudioSource.MIC) } catch (_: Exception) {}
                r.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                r.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                try { r.setAudioSamplingRate(44100) } catch (_: Exception) {}
                try { r.setAudioEncodingBitRate(96000) } catch (_: Exception) {}
                try { r.setAudioChannels(1) } catch (_: Exception) {}
                r.setOutputFile(outputPath)
                r.prepare()
                r.start()
                isRecording = true
                Log.d("CallRecorderService", "Recording started (AAC/M4A fallback): $outputPath")
                return
            } catch (fallbackError: Exception) {
                Log.e("CallRecorderService", "Secondary AAC/M4A failed: ${fallbackError.message}")
                try { r.reset() } catch (_: Exception) {}
                try { r.release() } catch (_: Exception) {}
                recorder = null
                isRecording = false
            }
        }
    }

    private fun stopRecording() {
        val r = recorder ?: return
        try {
            if (isRecording) {
                r.stop()
                Log.d("CallRecorderService", "Recording stopped successfully")
                
                // Verify file was written properly
                outputPath?.let { path ->
                    val file = java.io.File(path)
                    if (file.exists() && file.length() > 0) {
                        Log.d("CallRecorderService", "Recording file verified: $path (${file.length()} bytes)")
                    } else {
                        Log.w("CallRecorderService", "Recording file not ready: $path")
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("CallRecorderService", "Error stopping recording: ${e.message}")
        } finally {
            try {
                r.reset()
                r.release()
            } catch (e: Exception) {
                Log.e("CallRecorderService", "Error releasing recorder: ${e.message}")
            }
            recorder = null
            isRecording = false
        }
        
        // restore audio mode and speakerphone
        try {
            audioManager?.isSpeakerphoneOn = wasSpeakerOn
            audioManager?.mode = AudioManager.MODE_NORMAL
        } catch (e: Exception) {
            Log.e("CallRecorderService", "Error restoring audio mode: ${e.message}")
        }
        
        // keep lastOutputPath as is for Flutter to fetch
        Log.d("CallRecorderService", "Recording cleanup completed, file available at: $outputPath")
    }

    private fun updateNotif(content: String) {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIF_ID, buildNotification(content))
    }

    private fun extractNumberFromPath(path: String): String {
        // filename pattern: call_<number>_yyyyMMdd_HHmmss.m4a
        return try {
            val name = File(path).nameWithoutExtension
            val parts = name.split("_")
            if (parts.size >= 2) parts[1] else "unknown"
        } catch (_: Exception) {
            "unknown"
        }
    }
}


