package com.example.lifeplus


import android.Manifest
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager

import android.os.BatteryManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "samples.flutter.dev/battery"


    private var watchData:WatchData? = null

    companion object{
        private val TAG = MainActivity::class.java.simpleName
        private var deviceId = ""
        private const val MY_PERMISSIONS_REQUEST_BLUETOOTH:Int = 0x55;
    }

    private fun requestPermission() {
        if (ContextCompat.checkSelfPermission(this,
                        Manifest.permission.ACCESS_COARSE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {
            // Should we show an explanation?
            if (ActivityCompat.shouldShowRequestPermissionRationale(this@MainActivity,
                            Manifest.permission.ACCESS_COARSE_LOCATION)) {
                Log.i(TAG,"requestPermission,shouldShowRequestPermissionRationale")
            } else {
                Log.i(TAG,"requestPermission,shouldShowRequestPermissionRationale else")
                ActivityCompat.requestPermissions(this@MainActivity, arrayOf(Manifest.permission.ACCESS_COARSE_LOCATION),
                        MainActivity.MY_PERMISSIONS_REQUEST_BLUETOOTH)
            }
        } else {
            Log.i(TAG,"requestPermission,shouldShowRequestPermissionRationale hehe")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        requestPermission()
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else if(call.method=="connectDevice"){
                //For now connect to watch
                watchData = WatchData()
                watchData?.let {
                    it.connectDevice(this,result)
                }
            }
            else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        return batteryLevel
    }

}
