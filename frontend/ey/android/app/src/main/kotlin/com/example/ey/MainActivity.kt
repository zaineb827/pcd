package com.example.ey

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import android.view.accessibility.AccessibilityManager
import android.accessibilityservice.AccessibilityServiceInfo
import android.util.Log
class MainActivity : FlutterActivity() {
    private val channel = "com.example.ey/sensor"
    private lateinit var methodChannel: MethodChannel

    //second channel
    private val stressChannelName = "com.example.ey/stress_channel"
    private lateinit var stressChannel: MethodChannel
    private lateinit var flutterEngineInstance: FlutterEngine


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor, channel)

        //le2eme stress
        stressChannel = MethodChannel(flutterEngine.dartExecutor, stressChannelName)
        FlutterEngineSingleton.flutterEngine = flutterEngine




        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    if (isAccessibilityServiceEnabled()) {
                        try {
                            startService(Intent(this, MyAccessibilityService::class.java))
                            result.success(true)

                            // Notifier Flutter que le service a été activé
                            methodChannel.invokeMethod("serviceEnabled", null)

                        } catch (e: Exception) {
                            Log.e("ServiceError", "Échec du démarrage du service : ${e.message}")
                            result.error("SERVICE_START_FAILED", "Échec du démarrage du service : ${e.message}", null)
                        }
                    } else {
                        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                        startActivity(intent)

                        // Ici on attend que l'utilisateur revienne dans l'application
                        result.error("SERVICE_DISABLED", "Le service d'accessibilité n'est pas activé.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }





   //teb3in stress
    private fun notifyFlutterAboutStress() {
        // Exemple : Si stress détecté, envoyer une notification via le canal
        stressChannel.invokeMethod("stressDetected", 1)
    }




    // Vérifie si le service d'accessibilité est activé
    private fun isAccessibilityServiceEnabled(): Boolean {
        val am = getSystemService(Context.ACCESSIBILITY_SERVICE) as AccessibilityManager
        val enabledServices = am.getEnabledAccessibilityServiceList(AccessibilityServiceInfo.FEEDBACK_ALL_MASK)

        return enabledServices.any { serviceInfo ->
            val componentName = serviceInfo.resolveInfo.serviceInfo.packageName + "/" +
                    serviceInfo.resolveInfo.serviceInfo.name
            componentName == "${packageName}/${MyAccessibilityService::class.java.name}"
        }
    }

    // Vérifier à chaque reprise de l'application si le service est activé
    override fun onResume() {
        super.onResume()

        if (isAccessibilityServiceEnabled()) {
            methodChannel.invokeMethod("serviceEnabled", null)
        }
    }
}
