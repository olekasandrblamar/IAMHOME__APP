package com.cerashealth.ceras


import android.Manifest
import android.content.Context
import android.content.pm.PackageManager

import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.lifeplus.BaseDevice
import com.google.gson.Gson
import com.transistorsoft.tsbackgroundfetch.BackgroundFetch
import com.transistorsoft.tsbackgroundfetch.BackgroundFetchConfig
import io.flutter.app.FlutterApplication
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

class MainActivity: FlutterActivity()  {

    private val CHANNEL = "ceras.iamhome.mobile/device"
    private var sycnDevice:BaseDevice? = null

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
            Log.i(TAG,"requestPermission,shouldShowRequestPermissionRationale ")
        }
    }
    
    private fun scheduleBackgroundTasks(){
        val config = BackgroundFetchConfig.Builder()
                .setPeriodic(true)
                .setStartOnBoot(true)
//                .setDelay(5)//Delay by 5 minutes
                .setIsFetchTask(true)
                .setMinimumFetchInterval(15)// Every five minutes
                .setTaskId("background_bluetooth")
                .setStopOnTerminate(false)
                .setJobService(CerasBluetoothSync::class.java.name)
                .build()
        BackgroundFetch.getInstance(context).configure(config) {
            Log.d(TAG, "Completed $it")
        }

    }

    private fun connectDeviceChannel(flutterEngine: FlutterEngine){
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if(call.method=="connectDevice"){
                val deviceType = call.argument<String>("deviceType")
                //For now connect to watch
                sycnDevice = BaseDevice.getDeviceImpl(deviceType)
                sycnDevice?.let {
                    it.connectDevice(this,result)
                }
            } else if(call.method =="syncData"){

                BaseDevice.isBackground = false
                val deviceDataString = call.argument<String>("connectionInfo")
                lastConnected = Calendar.getInstance()
                context.getSharedPreferences(SharedPrefernces,Context.MODE_PRIVATE).edit()
                        .putString("flutter.last_sync",displayDateFormat.format(lastConnected.time))
                        .commit()
                Log.i(MainActivity.TAG,"last Updated ${context.getSharedPreferences(SharedPrefernces,Context.MODE_PRIVATE).all}")
                Log.i(TAG,"got sync data with arguments $deviceDataString")
                val deviceData = Gson().fromJson<ConnectionInfo>(deviceDataString,ConnectionInfo::class.java)
                val deviceType = context.getSharedPreferences(SharedPrefernces,Context.MODE_PRIVATE).getString("flutter.deviceType",null)
                deviceId = deviceData.deviceId?:""
                BaseDevice.getDeviceImpl(deviceType?.toUpperCase()).syncData(result,deviceData,this)
            }
            else {
                result.notImplemented()
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        //GeneratedPluginRegistrant.registerWith(flutterEngine);
        // requestPermission()
        scheduleBackgroundTasks()
        connectDeviceChannel(flutterEngine)
    }

}

class ConnectionInfo{
    var deviceId:String? = null
    var deviceName:String? = null
    var connected = false
    var message:String? = null
    var additionalInformation = mapOf<String,String>()
    var deviceType:String? = null

    companion object{
        fun createResponse(deviceId:String? = null,deviceName:String? = null,connected:Boolean = false,message:String? = null
                           ,additionalInfo: Map<String, String> = mapOf<String,String>(),deviceType:String? = null):String{
            val connectionData =  Gson().toJson(ConnectionInfo().apply {
                this.deviceId = deviceId
                this.connected = connected
                this.message = message
                this.deviceName = deviceName
                this.additionalInformation = additionalInfo
                this.deviceType = deviceType
            })
            Log.i(MainActivity.TAG,"Sending connection data back $connectionData")
            return connectionData
        }
    }

}

//class BackgroundWork(appContext:Context,workerParams: WorkerParameters):Worker(appContext,workerParams){
//
//    companion object{
//        val TAG = BackgroundWork::class.java.simpleName
//    }
//
//    override fun doWork(): Result {
//        Log.i(TAG,"Doing background work")
//        val deviceDataString = applicationContext.getSharedPreferences(MainActivity.SharedPrefernces,Context.MODE_PRIVATE).getString("flutter.watchInfo","")
//        val deviceData = Gson().fromJson<ConnectionInfo>(deviceDataString,ConnectionInfo::class.java)
//        val deviceType = applicationContext.getSharedPreferences(MainActivity.SharedPrefernces,Context.MODE_PRIVATE).getString("flutter.deviceType",null)
//        MainActivity.deviceId = deviceData.deviceId?:""
//        BaseDevice.getDeviceImpl(deviceType?.toUpperCase()).syncData(null,deviceData,applicationContext)
//        return Result.success()
//    }
//
//
//}

class CerasBluetoothSync{

    companion object{
        val TAG = CerasBluetoothSync::class.java.simpleName
    }

    constructor(applicationContext: Context,taskId:String){
        Log.i(TAG,"constructor background")
        onFetch(applicationContext,taskId)
    }

    fun onFetch(applicationContext: Context,taskId:String){
        if(ContextCompat.checkSelfPermission(applicationContext,
                Manifest.permission.ACCESS_COARSE_LOCATION)==PackageManager.PERMISSION_GRANTED) {
            BaseDevice.isBackground = true
            Log.i(TAG, "Doing background work")
            val deviceDataString = applicationContext.getSharedPreferences(MainActivity.SharedPrefernces, Context.MODE_PRIVATE).getString("flutter.watchInfo", "")
            val deviceData = Gson().fromJson<ConnectionInfo>(deviceDataString, ConnectionInfo::class.java)
            val deviceType = applicationContext.getSharedPreferences(MainActivity.SharedPrefernces, Context.MODE_PRIVATE).getString("flutter.deviceType", null)
            MainActivity.deviceId = deviceData.deviceId ?: ""
            BaseDevice.getDeviceImpl(deviceType?.toUpperCase()).syncData(null, deviceData, applicationContext)
        }else{
            Log.e(TAG,"No location permission")
        }
    }
}


class Application:FlutterApplication(){
    override fun onCreate() {
//        StrictMode.setThreadPolicy(StrictMode.ThreadPolicy.Builder()
//                .detectDiskReads()
//                .detectDiskWrites()
//                .detectAll()
//                .penaltyLog()
//                .build())
//
//        StrictMode.setVmPolicy(StrictMode.VmPolicy.Builder()
//                .detectLeakedSqlLiteObjects()
//                .detectLeakedClosableObjects()
//                .penaltyLog()
////                .penaltyDeath()
//                .build())
        super.onCreate()
    }
}