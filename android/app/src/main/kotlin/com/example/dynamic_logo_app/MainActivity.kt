package com.example.dynamic_logo_app

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.dynamic_logo_app/icon"

    // List of all icon aliases
    private val iconAliases = listOf(
        "tet_icon",
        "christmas_icon"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setIcon" -> {
                    val iconName = call.argument<String?>("iconName")
                    setAppIcon(iconName)
                    result.success(true)
                }
                "getIcon" -> {
                    result.success(getCurrentIcon())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun setAppIcon(iconName: String?) {
        val pm = packageManager
        val packageName = packageName

        // Disable all alternate icons first
        for (alias in iconAliases) {
            val componentName = ComponentName(packageName, "$packageName.$alias")
            pm.setComponentEnabledSetting(
                componentName,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
        }

        if (iconName == null || iconName.isEmpty()) {
            // Enable MainActivity (default icon)
            val mainComponent = ComponentName(packageName, "$packageName.MainActivity")
            pm.setComponentEnabledSetting(
                mainComponent,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
        } else {
            // Disable MainActivity
            val mainComponent = ComponentName(packageName, "$packageName.MainActivity")
            pm.setComponentEnabledSetting(
                mainComponent,
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP
            )
            
            // Enable the selected icon alias
            val selectedComponent = ComponentName(packageName, "$packageName.$iconName")
            pm.setComponentEnabledSetting(
                selectedComponent,
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                PackageManager.DONT_KILL_APP
            )
        }
    }

    private fun getCurrentIcon(): String? {
        val pm = packageManager
        val packageName = packageName

        for (alias in iconAliases) {
            val componentName = ComponentName(packageName, "$packageName.$alias")
            val state = pm.getComponentEnabledSetting(componentName)
            if (state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED) {
                return alias
            }
        }
        return null // Default icon
    }
}
