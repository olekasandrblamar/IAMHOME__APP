package com.cerashealth.ceras


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
import com.google.gson.Gson
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

class MainActivity: FlutterActivity() {

    private val CHANNEL = "ceras.iamhome.mobile/device"
    private var watchData:WatchData? = null

    companion object{
        var lastConnected: Calendar = Calendar.getInstance()
        val TAG = MainActivity::class.java.simpleName
        var deviceId = ""
        const val SharedPrefernces = "FlutterSharedPreferences"
        val displayDateFormat = SimpleDateFormat("MM/dd/yyyy hh:mm a")
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

    private fun connectDeviceChannel(flutterEngine: FlutterEngine){
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if(call.method=="connectDevice"){
                //For now connect to watch
                watchData = WatchData()
                watchData?.let {
                    it.connectDevice(this,result)
                }
            } else if(call.method =="loadData"){
                WatchData().loadData(result)
            } else if(call.method =="syncData"){
                lastConnected = Calendar.getInstance()
                context.getSharedPreferences(SharedPrefernces,Context.MODE_PRIVATE).edit()
                        .putString("flutter.last_sync",displayDateFormat.format(lastConnected.time))
                        .commit()
                Log.i(WatchData.TAG,"last Updated ${context.getSharedPreferences(SharedPrefernces,Context.MODE_PRIVATE).all}")
                val deviceDataString = call.argument<String>("connectionInfo")
                Log.i(TAG,"got sync data with arguments $deviceDataString")
                val deviceData = Gson().fromJson<ConnectionInfo>(deviceDataString,ConnectionInfo::class.java)
                deviceId = deviceData.deviceId?:""
                WatchData().syncData(result,deviceData,this)
            }
            else {
                result.notImplemented()
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // requestPermission()
        connectDeviceChannel(flutterEngine)
    }

}

class ConnectionInfo{
    var deviceId:String? = null
    var deviceName:String? = null
    var connected = false
    var message:String? = null
    var additionalInformation = mapOf<String,String>()

    companion object{
        fun createResponse(deviceId:String? = null,deviceName:String? = null,connected:Boolean = false,message:String? = null,additionalInfo: Map<String, String> = mapOf<String,String>()):String{
            val connectionData =  Gson().toJson(ConnectionInfo().apply {
                this.deviceId = deviceId
                this.connected = connected
                this.message = message
                this.deviceName = deviceName
                this.additionalInformation = additionalInfo
            })
            Log.i(MainActivity.TAG,"Sending connection data back $connectionData")
            return connectionData
        }
    }

}