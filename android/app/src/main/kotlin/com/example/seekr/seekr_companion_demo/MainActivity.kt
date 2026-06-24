package com.example.seekr.seekr_companion_demo

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.os.BatteryManager
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.Timer
import java.util.TimerTask

class MainActivity : FlutterActivity() {
    private val DEVICE_CHANNEL = "seekr/device"
    private val DISTANCE_CHANNEL = "seekr/distance_stream"

    private var distanceTimer: Timer? = null

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)

        // MethodChannel
        MethodChannel(engine.dartExecutor.binaryMessenger, DEVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryLevel" -> {
                        val bm = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                        val level = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                        result.success(level)
                    }
                    "bindToCellular" -> {
                        bindProcessToCellularNetwork(result)
                    }
                    else -> result.notImplemented()
                }
            }

        // EventChannel
        EventChannel(engine.dartExecutor.binaryMessenger, DISTANCE_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    startDistanceStreaming(events)
                }

                override fun onCancel(arguments: Any?) {
                    stopDistanceStreaming()
                }
            })
    }

    private fun bindProcessToCellularNetwork(result: MethodChannel.Result) {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val request = NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_CELLULAR)
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()

        cm.requestNetwork(request, object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                super.onAvailable(network)
                // bindProcessToNetwork requires API 23+ (Marshmallow).
                // Our minSdk is 24 (Nougat), so this is always available.
                val bound = cm.bindProcessToNetwork(network)
                Handler(Looper.getMainLooper()).post {
                    if (bound) {
                        result.success(true)
                    } else {
                        result.error("BIND_FAILED", "Failed to bind process to network", null)
                    }
                }
                cm.unregisterNetworkCallback(this)
            }

            override fun onUnavailable() {
                super.onUnavailable()
                Handler(Looper.getMainLooper()).post {
                    result.error("UNAVAILABLE", "Cellular network unavailable", null)
                }
            }
        })
    }

    private fun startDistanceStreaming(events: EventChannel.EventSink?) {
        distanceTimer?.cancel()
        distanceTimer = Timer()
        var lastDistance = 4.0
        distanceTimer?.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                val delta = (Math.random() - 0.5) * 1.6
                lastDistance = (lastDistance + delta).coerceIn(0.4, 5.0)
                val rounded = Math.round(lastDistance * 10.0) / 10.0
                Handler(Looper.getMainLooper()).post {
                    events?.success(rounded)
                }
            }
        }, 0, 800)
    }

    private fun stopDistanceStreaming() {
        distanceTimer?.cancel()
        distanceTimer = null
    }
}
