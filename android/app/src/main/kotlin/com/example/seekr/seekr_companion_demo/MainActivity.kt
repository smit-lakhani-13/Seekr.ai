package com.example.seekr.seekr_companion_demo

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.wifi.WifiNetworkSpecifier
import android.os.BatteryManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL

class MainActivity : FlutterActivity() {
    private val DEVICE_CHANNEL = "seekr/device"
    private val NETWORK_CHANNEL = "seekr/network"
    private val NETWORK_LOST_CHANNEL = "seekr/network_lost"

    // Hold network requests instead of binding the whole process. The wearable AP is
    // local-only; cloud traffic should continue to use the default internet route.
    private var deviceWifiNetwork: Network? = null
    private var deviceWifiCallback: ConnectivityManager.NetworkCallback? = null
    private var cellularNetwork: Network? = null
    private var cellularCallback: ConnectivityManager.NetworkCallback? = null
    private var networkLostSink: EventChannel.EventSink? = null

    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)

        // ── Device channel: battery ──────────────────────────────────────────
        MethodChannel(engine.dartExecutor.binaryMessenger, DEVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryLevel" -> {
                        val bm = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                        result.success(bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY))
                    }
                    else -> result.notImplemented()
                }
            }

        // ── Network channel: device AP connect + cellular binding ──────────────
        MethodChannel(engine.dartExecutor.binaryMessenger, NETWORK_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Connects to the wearable's local AP without changing the default internet route.
                    // Uses WifiNetworkSpecifier (Android 10+) so the device WiFi is app-scoped and
                    // cellular remains the default route for all other (cloud) traffic.
                    "connectToDeviceAP" -> connectToDeviceAP(call.argument("ssid"), call.argument("bssid"), result)
                    // Requests and holds a cellular Network object. After connectToDeviceAP claims the
                    // device WiFi as a local-only network, cellular is already the default route.
                    "requestCellularNetwork" -> requestCellularNetwork(result)
                    "postJsonViaCellular" -> postJsonViaCellular(
                        call.argument("url"),
                        call.argument("body"),
                        result
                    )
                    "releaseDeviceAP" -> {
                        releaseDeviceAP()
                        result.success(null)
                    }
                    "releaseCellularNetwork" -> {
                        releaseCellularNetwork()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // ── Network lost event channel: Dart listens for cellular drop ─────────
        EventChannel(engine.dartExecutor.binaryMessenger, NETWORK_LOST_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    networkLostSink = events
                }
                override fun onCancel(arguments: Any?) {
                    networkLostSink = null
                }
            })
    }

    private fun connectToDeviceAP(ssid: String?, bssid: String?, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            // Android < 10: WifiNetworkSpecifier not available; Dart side degrades gracefully.
            result.error("UNSUPPORTED", "WifiNetworkSpecifier requires Android 10+", null)
            return
        }
        if (ssid == null) {
            result.error("INVALID_ARG", "ssid required", null)
            return
        }

        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        releaseDeviceAP()
        val specifierBuilder = WifiNetworkSpecifier.Builder().setSsid(ssid)
        if (bssid != null) specifierBuilder.setBssid(android.net.MacAddress.fromString(bssid))

        val request = NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
            .setNetworkSpecifier(specifierBuilder.build())
            .build()

        var completed = false
        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                deviceWifiNetwork = network
                mainHandler.post {
                    if (!completed) {
                        completed = true
                        result.success(true)
                    }
                }
            }
            override fun onUnavailable() {
                deviceWifiCallback = null
                mainHandler.post {
                    if (!completed) {
                        completed = true
                        result.error("UNAVAILABLE", "Device AP not found", null)
                    }
                }
            }
            override fun onLost(network: Network) {
                if (deviceWifiNetwork == network) {
                    deviceWifiNetwork = null
                }
            }
        }
        deviceWifiCallback = callback
        cm.requestNetwork(request, callback)
    }

    private fun requestCellularNetwork(result: MethodChannel.Result) {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val request = NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_CELLULAR)
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()

        cellularCallback?.let { cm.unregisterNetworkCallback(it) }

        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                cellularNetwork = network
                mainHandler.post { result.success(true) }
            }
            override fun onUnavailable() {
                cellularNetwork = null
                mainHandler.post {
                    result.error("UNAVAILABLE", "Cellular network unavailable", null)
                }
            }
            override fun onLost(network: Network) {
                cellularNetwork = null
                mainHandler.post { networkLostSink?.success("cellular_lost") }
            }
        }
        cellularCallback = callback
        cm.requestNetwork(request, callback)
    }

    private fun postJsonViaCellular(url: String?, body: String?, result: MethodChannel.Result) {
        val network = cellularNetwork
        if (network == null) {
            result.error("NO_CELLULAR", "No cellular network is currently held", null)
            return
        }
        if (url == null || body == null) {
            result.error("INVALID_ARG", "url and body are required", null)
            return
        }

        Thread {
            var conn: HttpURLConnection? = null
            try {
                conn = network.openConnection(URL(url)) as HttpURLConnection
                conn.requestMethod = "POST"
                conn.connectTimeout = 15000
                conn.readTimeout = 30000
                conn.doOutput = true
                conn.setRequestProperty("Content-Type", "application/json")
                conn.outputStream.use { it.write(body.toByteArray(Charsets.UTF_8)) }

                val code = conn.responseCode
                val stream = if (code in 200..399) conn.inputStream else conn.errorStream
                val responseBody = stream?.use { input ->
                    BufferedReader(InputStreamReader(input)).readText()
                } ?: ""

                mainHandler.post {
                    result.success(mapOf("statusCode" to code, "body" to responseBody))
                }
            } catch (e: Exception) {
                mainHandler.post {
                    result.error("CELLULAR_HTTP_FAILED", e.message, null)
                }
            } finally {
                conn?.disconnect()
            }
        }.start()
    }

    private fun releaseCellularNetwork() {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        cellularCallback?.let { cm.unregisterNetworkCallback(it) }
        cellularCallback = null
        cellularNetwork = null
    }

    private fun releaseDeviceAP() {
        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        deviceWifiCallback?.let { cm.unregisterNetworkCallback(it) }
        deviceWifiCallback = null
        deviceWifiNetwork = null
    }

    override fun onDestroy() {
        releaseDeviceAP()
        releaseCellularNetwork()
        super.onDestroy()
    }
}
