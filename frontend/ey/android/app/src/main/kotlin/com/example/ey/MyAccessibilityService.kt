package com.example.ey

import android.accessibilityservice.AccessibilityService
import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.hardware.camera2.CameraDevice
import android.hardware.camera2.CameraManager
import android.hardware.camera2.CameraCaptureSession
import android.hardware.camera2.CameraCharacteristics
import android.media.Image
import android.media.ImageReader
import android.media.MediaRecorder
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import okhttp3.Call
import okhttp3.Callback
import okhttp3.MediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import okhttp3.Response
import org.json.JSONObject
import java.io.File
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.TimeUnit
import kotlin.math.sqrt
import kotlin.math.pow
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody.Companion.asRequestBody
import android.annotation.SuppressLint
import java.nio.ByteBuffer
import kotlin.experimental.and
import android.hardware.camera2.TotalCaptureResult;
import android.hardware.camera2.CaptureRequest;
import java.io.FileOutputStream;
import android.graphics.ImageFormat;
import android.util.Size;
import androidx.core.content.ContextCompat.checkSelfPermission

import io.flutter.plugin.common.MethodChannel
import android.accessibilityservice.AccessibilityServiceInfo
import android.widget.Toast
import android.widget.RemoteViews
import io.flutter.embedding.android.FlutterActivity

import android.graphics.Color


class MyAccessibilityService : AccessibilityService(), SensorEventListener {

    private lateinit var stressChannel: MethodChannel



    private val userAge: Int = 20
    private val userGender: String = "Female"

    private lateinit var sensorManager: SensorManager
    private val samplingIntervalUs = 20_000 // 20ms
    private val collectionDuration = 6_000L // 6 seconds

    private var isCollecting = false
    private var isKeyboardOpened = false
    private var collectionStartTime = 0L

    private var currentSessionFile: File? = null
    private var sessionSensorFiles: MutableList<File> = mutableListOf()
    //
    private var audioFile: File? = null
    private var imageFile: File? = null
    //
    private lateinit var cameraManager: CameraManager
    private lateinit var mediaRecorder: MediaRecorder
    private var permissionReceiver: PermissionReceiver? = null

    // Constantes pour les notifications
    private val NOTIFICATION_ID_PERMISSION = 1
    private val NOTIFICATION_ID_CAPTURE = 2
    private val NOTIFICATION_ID_RESULT = 3
    private val CHANNEL_ID_PERMISSION = "permission_channel"
    private val CHANNEL_ID_CAPTURE = "capture_channel"
    private val CHANNEL_ID_RESULT = "result_channel"

    private lateinit var scheduledExecutorService: ScheduledExecutorService
    private var scheduledFuture: ScheduledFuture<*>? = null



    private val keyboardPackages = setOf(
        "com.google.android.inputmethod.latin", // Gboard
        "com.touchtype.swiftkey", // SwiftKey
        "com.samsung.android.honeyboard", // Samsung Keyboard
        "com.baidu.input" // Baidu Input
    )

    private val sensorTypes = listOf(
        Sensor.TYPE_GRAVITY,
        Sensor.TYPE_LINEAR_ACCELERATION,
        Sensor.TYPE_GYROSCOPE
    )

    private val latestValues = mutableMapOf<Int, FloatArray>().apply {
        sensorTypes.forEach { type ->
            put(type, FloatArray(3))
        }
    }



    private val dataCollector = object : Runnable {
        override fun run() {
            if (isCollecting) {
                writeCombinedData()
            }
        }
    }

    override fun onServiceConnected() {
        super.onServiceConnected()

        //ajouté
        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        startActivity(intent)
        //*//

        // notif
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Créer un canal de notification avec une priorité élevée
            val resultChannel = NotificationChannel(
                CHANNEL_ID_RESULT,
                "Résultats",
                NotificationManager.IMPORTANCE_HIGH // Priorité élevée
            ).apply {
                description = "Notifications de résultats"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 300, 200, 300)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(resultChannel)
        }

        //
        Log.d("SERVICE", "Service connecté !")
        sensorManager = getSystemService(SensorManager::class.java)
        cameraManager = getSystemService(CameraManager::class.java)
        mediaRecorder = MediaRecorder()

    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        Log.d("ACCESSIBILITY_EVENT", "Event: ${event?.eventType}")
        val keyboardOpen = isKeyboardOpen(event)
        if (keyboardOpen != isKeyboardOpened) { // changement d'état
            isKeyboardOpened = keyboardOpen
            Log.d("SENSOR_DEBUG", "État clavier changé: $isKeyboardOpened")

            if (isKeyboardOpened && !isCollecting) {
                startContinuousCollection()
            } else if (!isKeyboardOpened) {
                stopContinuousCollection()
            }
        }
    }

    private fun startContinuousCollection() {
        if (isCollecting) return

        sessionSensorFiles.clear()
        Log.d("CLEANUP", "Liste vidée en début de session")
        isCollecting = true
        startNewSession()
    }

    private fun startNewSession() {
        if (!isCollecting) return

        Log.d("SENSOR_DEBUG", "Début nouvelle session de collecte")

        collectionStartTime = System.currentTimeMillis()

        currentSessionFile = File(filesDir, "sensor_${SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(Date())}.csv").apply {
            appendText("Age,Gender," +
                    "Gravity X,Gravity Y,Gravity Z,Gravity Magnitude," +
                    "Linear Acceleration X,Linear Acceleration Y,Linear Acceleration Z,Linear Acceleration Magnitude," +
                    "Gyroscope X,Gyroscope Y,Gyroscope Z,Gyroscope Magnitude\n")
             // Écrit les valeurs fixes
        }

        sensorTypes.forEach { type ->
            sensorManager.getDefaultSensor(type)?.let {
                Log.d("SENSOR_CHECK", "Gravity sensor ok")
                sensorManager.registerListener(this, it, samplingIntervalUs)
            } ?: Log.w("SENSOR", "Capteur $type indisponible")
        }

        // Planification de la collecte des données avec un ScheduledExecutorService
        scheduledExecutorService = Executors.newSingleThreadScheduledExecutor()
        scheduledFuture = scheduledExecutorService.scheduleAtFixedRate(dataCollector, 0, 20, TimeUnit.MILLISECONDS)

        // Fin de session après la durée spécifiée
        scheduledExecutorService.schedule({
            endCurrentSession()

            if (isKeyboardOpened) {
                startNewSession()
            }
        }, collectionDuration, TimeUnit.MILLISECONDS)
    }

    private fun calculateMagnitude(x: Float, y: Float, z: Float): Float {
        return sqrt(x * x + y * y + z * z)
    }

    private fun writeCombinedData() {
        latestValues[Sensor.TYPE_GRAVITY]?.let { gravity ->
            latestValues[Sensor.TYPE_LINEAR_ACCELERATION]?.let { linear ->
                latestValues[Sensor.TYPE_GYROSCOPE]?.let { gyro ->
                    currentSessionFile?.appendText(
                             "$userAge,$userGender," +
                                "${gravity[0]},${gravity[1]},${gravity[2]}," +
                                "${calculateMagnitude(gravity[0], gravity[1], gravity[2])}," +
                                "${linear[0]},${linear[1]},${linear[2]}," +
                                "${calculateMagnitude(linear[0], linear[1], linear[2])}," +
                                "${gyro[0]},${gyro[1]},${gyro[2]}," +
                                "${calculateMagnitude(gyro[0], gyro[1], gyro[2])}\n"
                    )
                }
            }
        }
    }

    private fun endCurrentSession() {
        Log.d("SENSOR_DEBUG", "Fin de la petite session")

        sensorTypes.forEach { type ->
            sensorManager.getDefaultSensor(type)?.let {
                sensorManager.unregisterListener(this, it)
            }
        }

        // Annulation de la tâche planifiée
        scheduledFuture?.cancel(true)
        scheduledExecutorService.shutdownNow()

        val sessionDuration = System.currentTimeMillis() - collectionStartTime
        if (sessionDuration < collectionDuration) {
            currentSessionFile?.delete()
            Log.d("SENSOR_DEBUG", "Session supprimée (moins de 15 secondes)")
        } else {
            currentSessionFile?.let { file ->
                sessionSensorFiles.add(file)
            }
            Log.d("SENSOR_DEBUG", "Session sauvegardée")
        }

        currentSessionFile = null
    }

    private fun stopContinuousCollection() {
        if (!isCollecting) return

        isCollecting = false

        Log.d("SENSOR_DEBUG", "Arrêt de la grande collecte ")

        endCurrentSession()

        val filesToSend = sessionSensorFiles.toList()
        Log.d("SENSOR_DEBUG", " juste 9bal el fonction ")

        sendFilesToFlask(filesToSend)


    }

    override fun onSensorChanged(event: SensorEvent) {
        if (isCollecting) {
            System.arraycopy(event.values, 0, latestValues[event.sensor.type]!!, 0, 3)
        }
    }

    private fun sendFilesToFlask(sensorFiles: List<File>) {
        Log.d("SENSOR DEBUG", "d5alna lel fonction")

        Log.d("UPLOAD", "Tentative d'envoi de ${sensorFiles.size} fichiers")

        if (sensorFiles.isEmpty()) {
            Log.d("SENSOR_DEBUG", "Aucun fichier à envoyer")
            return
        }

        val client = OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .build()

        val serverUrl = "http://192.168.100.6:5000/predict"  // ip de mon pc
        Log.d("SERVER_CONN", "URL du serveur: $serverUrl")
        try {
            val requestBody = MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .apply {
                    sensorFiles.forEach { file ->
                        addFormDataPart(
                            "files",
                            file.name,
                            file.asRequestBody("text/csv".toMediaType())
                        )
                        Log.d("FILE_UPLOAD", "Fichier prêt: ${file.name} (${file.length()} bytes)")
                    }
                }
                .build()

            val request = Request.Builder()
                .url(serverUrl)
                .post(requestBody)
                .header("Connection", "close")
                .build()

            client.newCall(request).enqueue(object : Callback {
                override fun onResponse(call: Call, response: Response) {
                    response.use {
                        if (it.isSuccessful) {
                            val responseBody = it.body?.string()
                            Log.d("FLASK_RESPONSE", "Succès: $responseBody")
                            if(responseBody?.contains("\"final_prediction\":1") == true) {
                                val flutterEngine = FlutterEngineSingleton.flutterEngine
                                if (flutterEngine != null) {
                                    val stressChannel = MethodChannel(flutterEngine.dartExecutor, "com.example.ey/stress_channel")

                                    Handler(Looper.getMainLooper()).post {
                                        stressChannel.invokeMethod("stressDetected", 1)
                                    }
                                }
                                askPermissionsAndCapture()
                               }
                             else {
                            Log.d("FLASK_RESPONSE", "Prediction non déclenchée")
                            }
                        } else {
                            Log.e("FLASK_ERROR", "Erreur ${it.code}: ${it.message}")
                        }
                    }
                }

                override fun onFailure(call: Call, e: IOException) {
                    Log.e("NETWORK_FAILURE", "Échec de connexion: ${e.message}")
                }
            })


        } catch (e: Exception) {
            Log.e("UPLOAD_EXCEPTION", "Erreur lors de l'envoi: ${e.localizedMessage}")
        }
    }



    // BroadcastReceiver pour les permissions
    inner class PermissionReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent.action) {
                "ACCEPT_ACTION" -> {
                    // Demander les permissions pour la caméra et le micro
                    requestPermissions()
                    cancelPermissionNotification()
                }
                "DECLINE_ACTION" -> {
                    // Annuler la notification de permission
                    cancelPermissionNotification()

                }
            }
        }
    }

    // Méthode pour demander les permissions
    private fun requestPermissions() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {

            // Demande les permissions pour la caméra et le micro
            val intent = Intent(this, PermissionRequestActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)
        } else {
            // Si les permissions sont déjà accordées, commencer le processus
            startCaptureProcess()
        }
    }




    // ask

    private fun askPermissionsAndCapture() {
        createNotificationChannels()
        showPermissionNotification()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)

            val permissionChannel = NotificationChannel(
                CHANNEL_ID_PERMISSION,
                "Permission Requests",
                NotificationManager.IMPORTANCE_HIGH
            )

            val captureChannel = NotificationChannel(
                CHANNEL_ID_CAPTURE,
                "Capture Status",
                NotificationManager.IMPORTANCE_LOW
            )

            val resultChannel = NotificationChannel(
                CHANNEL_ID_RESULT,
                "Results",
                NotificationManager.IMPORTANCE_DEFAULT
            )

            notificationManager.createNotificationChannel(permissionChannel)
            notificationManager.createNotificationChannel(captureChannel)
            notificationManager.createNotificationChannel(resultChannel)
        }
    }
 
    private fun showPermissionNotification() {
        permissionReceiver = PermissionReceiver()
        val filter = IntentFilter().apply {
            addAction("ACCEPT_ACTION")
            addAction("DECLINE_ACTION")
        }

        try {
            // Enregistrement sécurisé du receiver (Android 8+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    Context.RECEIVER_NOT_EXPORTED  // Android 13+
                } else {
                    Context.RECEIVER_EXPORTED     // Android 8-12
                }
                registerReceiver(permissionReceiver, filter, flags)
            }
            // Intent explicites avec package name
            fun createIntent(action: String): Intent {
                return Intent(action).apply {
                    `package` = this@MyAccessibilityService.packageName
                }
            }

            // Configuration des PendingIntent
            val pendingFlags = PendingIntent.FLAG_UPDATE_CURRENT or
                    (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        PendingIntent.FLAG_IMMUTABLE
                    } else {
                        0
                    })

            val acceptIntent = PendingIntent.getBroadcast(
                this,
                0,
                createIntent("ACCEPT_ACTION"),
                pendingFlags
            )

            val declineIntent = PendingIntent.getBroadcast(
                this,
                1,
                createIntent("DECLINE_ACTION"),
                pendingFlags
            )
            val customView = RemoteViews(packageName, R.layout.custom_notification)

            // Construction de la notification
            val notification = NotificationCompat.Builder(this, CHANNEL_ID_PERMISSION)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setStyle(NotificationCompat.DecoratedCustomViewStyle())
                .setCustomContentView(customView)
                .addAction(
                    android.R.drawable.ic_menu_camera,
                    "Accepter",
                    acceptIntent
                )
                .addAction(
                    android.R.drawable.ic_menu_close_clear_cancel,
                    "Refuser",
                    declineIntent
                )
                .build()

            // Affichage de la notification
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).notify(
                NOTIFICATION_ID_PERMISSION,
                notification
            )

        } catch (e: Exception) {
            Log.e("NOTIFICATION", "Erreur lors de l'affichage", e)
        }
    }


    private fun startCaptureProcess() {
        Log.e("NOTIFICATION", "dans la fonct startcaptureprocess")

            showCaptureNotification("Capture en cours...")
            captureImage()
            startAudioRecording()

            Handler(Looper.getMainLooper()).postDelayed({
                try {
                    stopAudioRecording()
                    sendMediaToFlask()
                } catch (e: Exception) {
                    Log.e("CAPTURE", "Erreur lors de l'arrêt de la capture", e)
                }
            }, 60000)

    }





    private lateinit var imageReader: ImageReader
    private var cameraDevice: CameraDevice? = null
    private var captureSession: CameraCaptureSession? = null

    @SuppressLint("MissingPermission")
    private fun captureImage() {
        Log.e("CAMERA", "dans fonction captureimage")


        Log.e("CAMERA", "on va prendre une seule image")

        val cameraId = cameraManager.cameraIdList.firstOrNull { id ->
            val characteristics = cameraManager.getCameraCharacteristics(id)
            val cameraDirection = characteristics.get(CameraCharacteristics.LENS_FACING)
            cameraDirection == CameraCharacteristics.LENS_FACING_FRONT
        } ?: cameraManager.cameraIdList[0]
        // fallback sur la caméra arrière si frontale non trouvée
        val characteristics = cameraManager.getCameraCharacteristics(cameraId)
        val streamConfigurationMap = characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP)

        val imageSize = streamConfigurationMap?.getOutputSizes(ImageFormat.JPEG)?.firstOrNull()
            ?: Size(640, 480) // Fallback

        imageReader = ImageReader.newInstance(imageSize.width, imageSize.height, ImageFormat.JPEG, 1)
        imageReader.setOnImageAvailableListener({ reader ->
            val image = reader.acquireLatestImage()
            image?.let {
                val buffer = image.planes[0].buffer
                val bytes = ByteArray(buffer.remaining())
                buffer.get(bytes)
                image.close()

                // Enregistrer l'image dans le fichier
                try {
                    imageFile = File(filesDir, "capture_${System.currentTimeMillis()}.jpg")
                    FileOutputStream(imageFile).use { it.write(bytes) }
                    Log.d("CAPTURE", "Image enregistrée dans ${imageFile?.absolutePath}")
                } catch (e: Exception) {
                    Log.e("CAPTURE", "Erreur lors de la sauvegarde", e)
                }
            }
        }, Handler(Looper.getMainLooper()))

        cameraManager.openCamera(cameraId, object : CameraDevice.StateCallback() {
            override fun onOpened(camera: CameraDevice) {
                cameraDevice = camera
                try {
                    val captureRequestBuilder = camera.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE)
                    captureRequestBuilder.addTarget(imageReader.surface)

                    camera.createCaptureSession(listOf(imageReader.surface),
                        object : CameraCaptureSession.StateCallback() {
                            override fun onConfigured(session: CameraCaptureSession) {
                                captureSession = session
                                session.capture(captureRequestBuilder.build(), object : CameraCaptureSession.CaptureCallback() {
                                    override fun onCaptureCompleted(
                                        session: CameraCaptureSession,
                                        request: CaptureRequest,
                                        result: TotalCaptureResult
                                    ) {
                                        super.onCaptureCompleted(session, request, result)
                                        Log.d("CAMERA", "Capture terminée")
                                        cameraDevice?.close()
                                        captureSession?.close()
                                    }
                                }, Handler(Looper.getMainLooper()))
                            }

                            override fun onConfigureFailed(session: CameraCaptureSession) {
                                Log.e("CAMERA", "Échec de la configuration de la session")
                            }
                        }, Handler(Looper.getMainLooper()))
                } catch (e: Exception) {
                    Log.e("CAMERA", "Erreur lors de la capture", e)
                    camera.close()
                }
            }

            override fun onDisconnected(camera: CameraDevice) {
                camera.close()
            }

            override fun onError(camera: CameraDevice, error: Int) {
                Log.e("CAMERA", "Erreur caméra: $error")
                camera.close()
            }
        }, Handler(Looper.getMainLooper()))
    }







    private fun startAudioRecording() {
        try {
            audioFile = File(filesDir, "audio_${System.currentTimeMillis()}.3gp")
            Log.d("AUDIO_RECORD", "Début enregistrement - Path: ${audioFile?.absolutePath}")
            mediaRecorder = MediaRecorder() // À ajouter avant le apply

            mediaRecorder.apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP)
                setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB)
                setOutputFile(audioFile?.absolutePath)
                prepare()
                start()
                Log.d("AUDIO_RECORD", "Enregistrement démarré avec succès")

            }
        } catch (e: Exception) {
            Log.e("AUDIO", "Erreur enregistrement audio: ${e.message}")
        }
    }

    private fun stopAudioRecording() {
        try {
            mediaRecorder.stop()
            mediaRecorder.reset()
            Log.d("AUDIO_RECORD", "Enregistrement stoppé - Taille fichier: ${audioFile?.length()} bytes")
        } catch (e: Exception) {
            Log.e("AUDIO", "Erreur arrêt enregistrement: ${e.message}")
        }
    }

    private fun sendMediaToFlask() {
        val client = OkHttpClient()
        val serverUrl = "http://192.168.100.6:5000/final_prediction"

        try {

            val requestBody = MultipartBody.Builder()
                .setType(MultipartBody.FORM)
                .apply {
                    imageFile?.let {
                        addFormDataPart(
                            "image",
                            it.name,
                            it.asRequestBody("image/jpeg".toMediaType())
                        )
                    }
                    audioFile?.let {
                        addFormDataPart(
                            "audio",
                            it.name,
                            it.asRequestBody("audio/3gpp".toMediaType())
                        )
                    }
                }
                .build()

            val request = Request.Builder()
                .url(serverUrl)
                .post(requestBody)
                .build()

            client.newCall(request).enqueue(object : Callback {
                override fun onResponse(call: Call, response: Response) {
                    response.use {
                        if (it.isSuccessful) {
                            val responseBody = it.body?.string()
                            showResultNotification(responseBody)
                            Log.e("FLASK", "wsol lel flask")

                        }
                    }
                }

                override fun onFailure(call: Call, e: IOException) {
                    Log.e("FINAL_UPLOAD", "Échec envoi final: ${e.message}")
                }
            })
        } catch (e: Exception) {
            Log.e("FINAL_UPLOAD", "Erreur préparation envoi: ${e.message}")
        }
    }


    private fun showCaptureNotification(text: String) {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID_CAPTURE)
            .setContentTitle("Analyse en cours")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_menu_camera)
            .build()

        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(NOTIFICATION_ID_CAPTURE, notification)
    }


    private fun showResultNotification(response: String?) {
        try {
            val json = JSONObject(response)
            val prediction = json.getString("fused_emotion")
            val message = if (prediction == "angry") "Je sens que tu traverses un moment difficile... Le yoga pourrait t'aider à apaiser ton cœur et retrouver de la sérénité. Et si on essayait une courte séance ensemble ? ✨" else "Résultat négatif"

            if (prediction == "angry") {
                val flutterEngine = FlutterEngineSingleton.flutterEngine
                if (flutterEngine != null) {
                    val stressChannel = MethodChannel(flutterEngine.dartExecutor, "com.example.ey/stress_channel")
                    Handler(Looper.getMainLooper()).post {
                        stressChannel.invokeMethod("stressDetected", 2)
                    }
                }
            }
            if (prediction == "sad") {
                val flutterEngine = FlutterEngineSingleton.flutterEngine
                if (flutterEngine != null) {
                    val stressChannel = MethodChannel(flutterEngine.dartExecutor, "com.example.ey/stress_channel")
                    Handler(Looper.getMainLooper()).post {
                        stressChannel.invokeMethod("stressDetected", 4)
                    }
                }
            }
            if (prediction == "happy") {
                val flutterEngine = FlutterEngineSingleton.flutterEngine
                if (flutterEngine != null) {
                    val stressChannel = MethodChannel(flutterEngine.dartExecutor, "com.example.ey/stress_channel")
                    Handler(Looper.getMainLooper()).post {
                        stressChannel.invokeMethod("stressDetected", 3)
                    }
                }
            }
            if (prediction == "fear") {
                val flutterEngine = FlutterEngineSingleton.flutterEngine
                if (flutterEngine != null) {
                    val stressChannel = MethodChannel(flutterEngine.dartExecutor, "com.example.ey/stress_channel")
                    Handler(Looper.getMainLooper()).post {
                        stressChannel.invokeMethod("stressDetected", 5)
                    }
                }
            }


           Notif() ;

        } catch (e: Exception) {
            Log.e("NOTIFICATION", "Erreur affichage résultat", e)
        }
    }



    private fun Notif() {
        permissionReceiver = PermissionReceiver()
        val filter = IntentFilter().apply {
            addAction("ACCEPT_ACTION")
        }

        try {
            // Enregistrement sécurisé du receiver (Android 8+)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    Context.RECEIVER_NOT_EXPORTED  // Android 13+
                } else {
                    Context.RECEIVER_EXPORTED     // Android 8-12
                }
                registerReceiver(permissionReceiver, filter, flags)
            }
            // Intent explicites avec package name
            fun createIntent(action: String): Intent {
                return Intent(action).apply {
                    `package` = this@MyAccessibilityService.packageName
                }
            }

            // Configuration des PendingIntent
            val pendingFlags = PendingIntent.FLAG_UPDATE_CURRENT or
                    (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        PendingIntent.FLAG_IMMUTABLE
                    } else {
                        0
                    })

            val acceptIntent = PendingIntent.getBroadcast(
                this,
                0,
                createIntent("ACCEPT_ACTION"),
                pendingFlags
            )

            val customView = RemoteViews(packageName, R.layout.custom_result)

            // Construction de la notification
            val notification = NotificationCompat.Builder(this, CHANNEL_ID_PERMISSION)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setStyle(NotificationCompat.DecoratedCustomViewStyle())
                .setCustomContentView(customView)
                .addAction(
                    android.R.drawable.ic_menu_camera,
                    "Essayer une session de 2 minutes",
                    acceptIntent
                )

                .build()

            // Affichage de la notification
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).notify(
                NOTIFICATION_ID_PERMISSION,
                notification
            )

        } catch (e: Exception) {
            Log.e("NOTIFICATION", "Erreur lors de l'affichage", e)
        }
    }




    //la 1ere notif
    private fun cancelPermissionNotification() {
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(NOTIFICATION_ID_PERMISSION)
        permissionReceiver?.let { unregisterReceiver(it) }
    }




    private fun isKeyboardOpen(event: AccessibilityEvent): Boolean {
        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED -> {
                if (event.className?.contains("InputMethodService", ignoreCase = true) == true) {
                    return true
                }
                if (event.packageName in keyboardPackages) {
                    return true
                }
                return false
            }
            AccessibilityEvent.TYPE_VIEW_FOCUSED, AccessibilityEvent.TYPE_VIEW_CLICKED -> {
                val isEditText = event.className?.contains("EditText", ignoreCase = true) == true ||
                        event.className?.contains("TextInput", ignoreCase = true) == true
                if (isEditText) {
                    return true
                }
            }
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
            }
        }
        return isKeyboardOpened
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onInterrupt() {
        Log.w("SENSOR_DEBUG", "Service interrompu")
    }

    override fun onDestroy() {
        stopContinuousCollection()
        permissionReceiver?.let { unregisterReceiver(it) }


    }
}
