/*
 * Flashlight dimming algorithm adapted from:
 * https://github.com/cyb3rko/flashdim
 * Copyright (c) 2022-2024 Cyb3rKo (Apache License 2.0)
 */
package com.kiranembedded.pocketutility

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.kiranembedded.pocketutility/flashlight"
    private var cameraId: String? = null
    private var maxLevel: Int = 1

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            val cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
            
            if (cameraId == null) {
                // Find rear camera with flash
                cameraId = cameraManager.cameraIdList.find { id ->
                    val characteristics = cameraManager.getCameraCharacteristics(id)
                    characteristics.get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
                }
                
                if (cameraId != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    val characteristics = cameraManager.getCameraCharacteristics(cameraId!!)
                    maxLevel = characteristics.get(CameraCharacteristics.FLASH_INFO_STRENGTH_MAXIMUM_LEVEL) ?: 1
                }
            }

            if (cameraId == null) {
                result.error("UNAVAILABLE", "Flashlight not available.", null)
                return@setMethodCallHandler
            }

            when (call.method) {
                "getMaxLevel" -> {
                    result.success(maxLevel)
                }
                "setTorchMode" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    try {
                        cameraManager.setTorchMode(cameraId!!, enabled)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                "setTorchLevel" -> {
                    val level = call.argument<Int>("level") ?: 1
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && maxLevel > 1) {
                            val clampedLevel = level.coerceIn(1, maxLevel)
                            cameraManager.turnOnTorchWithStrengthLevel(cameraId!!, clampedLevel)
                        } else {
                            // Fallback to normal torch if dimming is not supported
                            cameraManager.setTorchMode(cameraId!!, level > 0)
                        }
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("ERROR", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        val HAPTICS_CHANNEL = "com.kiranembedded.pocketutility/haptics"
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HAPTICS_CHANNEL).setMethodCallHandler { call, result ->
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vibratorManager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }

            try {
                when (call.method) {
                    "vibrateTick" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_TICK))
                        } else {
                            @Suppress("DEPRECATION")
                            vibrator.vibrate(20)
                        }
                        result.success(null)
                    }
                    "vibrateClick" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_CLICK))
                        } else {
                            @Suppress("DEPRECATION")
                            vibrator.vibrate(30)
                        }
                        result.success(null)
                    }
                    "vibrateDoubleClick" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            vibrator.vibrate(VibrationEffect.createPredefined(VibrationEffect.EFFECT_DOUBLE_CLICK))
                        } else {
                            @Suppress("DEPRECATION")
                            vibrator.vibrate(longArrayOf(0, 30, 40, 30), -1)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("ERROR", e.message, null)
            }
        }
    }
}
