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

        fun start(context: Context, number: String) {
            val intent = Intent(context, CallRecorderService::class.java)
            intent.putExtra(EXTRA_NUMBER, number)
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
                    Log.d("CallRecorderService", "CALL_STATE_IDLE → stopping")
                    stopSelf()
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
        // Fallback: if OFFHOOK isn't observed within 5s, start recording anyway
        if (!startFallbackPosted) {
            startFallbackPosted = true
            android.os.Handler(mainLooper).postDelayed({
                if (!isRecording) {
                    try {
                        Log.w("CallRecorderService", "OFFHOOK not seen in time; starting fallback recording")
                        startRecording(number)
                        updateNotif("Recording call: $number")
                    } catch (e: Exception) {
                        Log.e("CallRecorderService", "Fallback startRecording failed: ${e.message}")
                    }
                }
            }, 5000)
        }
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        stopRecording()
        telephonyManager?.listen(phoneStateListener, PhoneStateListener.LISTEN_NONE)
        // restore speaker state if we modified it
        try {
            audioManager?.isSpeakerphoneOn = wasSpeakerOn
        } catch (_: Exception) {}
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

    private fun prepareOutput(number: String) {
        val time = SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(Date())
        val dir = File(getExternalFilesDir(Environment.DIRECTORY_MUSIC), "calls")
        if (!dir.exists()) dir.mkdirs()
        val file = File(dir, "call_${number}_$time.m4a")
        outputPath = file.absolutePath
        lastOutputPath = outputPath
    }

    private fun startRecording(number: String) {
        if (isRecording) return
        if (outputPath == null) prepareOutput(number)
        val r = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) MediaRecorder(this) else MediaRecorder()
        recorder = r
        // route audio to speaker to improve remote-party pickup via mic
        try {
            wasSpeakerOn = audioManager?.isSpeakerphoneOn ?: false
            audioManager?.isSpeakerphoneOn = true
        } catch (_: Exception) {}
        // Prefer VOICE_COMMUNICATION (captures mic with echo cancellation); fallback to MIC
        try {
            r.setAudioSource(MediaRecorder.AudioSource.VOICE_COMMUNICATION)
        } catch (e1: Exception) {
            Log.w("CallRecorderService", "VOICE_COMMUNICATION not available")
            try {
                r.setAudioSource(MediaRecorder.AudioSource.VOICE_RECOGNITION)
            } catch (e2: Exception) {
                Log.w("CallRecorderService", "VOICE_RECOGNITION not available; fallback to MIC")
                r.setAudioSource(MediaRecorder.AudioSource.MIC)
            }
        }
        r.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
        r.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
        r.setAudioSamplingRate(44100)
        r.setAudioEncodingBitRate(96000)
        r.setOutputFile(outputPath)
        r.prepare()
        r.start()
        isRecording = true
        Log.d("CallRecorderService", "Recording started: $outputPath")
    }

    private fun stopRecording() {
        val r = recorder ?: return
        try {
            r.stop()
        } catch (_: Exception) {}
        r.reset()
        r.release()
        recorder = null
        isRecording = false
        // restore speakerphone
        try {
            audioManager?.isSpeakerphoneOn = wasSpeakerOn
        } catch (_: Exception) {}
        // keep lastOutputPath as is for Flutter to fetch
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


