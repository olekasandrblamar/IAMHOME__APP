package com.cerashealth.ceras


import android.Manifest
import android.content.Context
import android.content.pm.PackageManager

import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.cerashealth.ceras.lifeplus.*
import com.cerashealth.ceras.lifeplus.data.*
import com.google.gson.Gson
import com.transistorsoft.tsbackgroundfetch.BackgroundFetch
import com.transistorsoft.tsbackgroundfetch.BackgroundFetchConfig
import io.flutter.app.FlutterApplication
import io.flutter.embedding.android.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

class MainActivity: FlutterFragmentActivity()  {

    private val CHANNEL = "ceras.iamhome.mobile/device"
    private var sycnDevice: BaseDevice? = null

    companion object{
        var lastConnected: Calendar = Calendar.getInstance()
        var currentContext:Context? = null
        var currentActivity:MainActivity? = null
        val TAG = MainActivity::class.java.simpleName
        private const val BACKGROUND_JOB = "background_bluetooth"
        var deviceId = ""
        const val SharedPrefernces = "FlutterSharedPreferences"
        private val displayDateFormat = SimpleDateFormat("MM/dd/yyyy hh:mm a")
        private const val MY_PERMISSIONS_REQUEST_BLUETOOTH:Int = 0x55;

        fun updateLastConnected(){
            lastConnected = Calendar.getInstance()
            Log.i(TAG,"Current context is null ${currentContext == null}")
            currentContext?.let {
                Log.i(TAG,"Updating last connected")
                it.getSharedPreferences(SharedPrefernces,Context.MODE_PRIVATE).edit()
                        .putString("flutter.last_sync",displayDateFormat.format(lastConnected.time))
                        .commit()
            }
        }
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
                .setTaskId(BACKGROUND_JOB)
                .setStopOnTerminate(false)
                .setJobService(CerasBluetoothSync::class.java.name)
                .build()
        BackgroundFetch.getInstance(this).configure(config) {
            Log.i(TAG,"Executing background job")
            CerasBluetoothSync(this, BACKGROUND_JOB)
        }

    }

    private fun connectDeviceChannel(flutterEngine: FlutterEngine){
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            currentContext = this
            currentActivity = this
            BaseDevice.isBackground = false
            if(call.method=="connectDevice"){
                val deviceType = call.argument<String>("deviceType")
                val deviceId = call.argument<String>("deviceId")
                //For now connect to watch
                sycnDevice = BaseDevice.getDeviceImpl(deviceType)
                sycnDevice?.let {
                    it.connectDevice(this,result,deviceId)
                }
            } else if(call.method =="syncData"){
                val deviceDataString = call.argument<String>("connectionInfo")
                updateLastConnected()
                Log.i(TAG,"last Updated ${getSharedPreferences(SharedPrefernces,Context.MODE_PRIVATE).all}")
                Log.i(TAG,"got sync data with arguments $deviceDataString")
                val deviceData = Gson().fromJson<ConnectionInfo>(deviceDataString,ConnectionInfo::class.java)
                val deviceType = getSharedPreferences(SharedPrefernces,Context.MODE_PRIVATE).getString("flutter.deviceType",null)
                deviceId = deviceData.deviceId?:""
                BaseDevice.getDeviceImpl(deviceType?.toUpperCase()).syncData(result,deviceData,this)
            }else if(call.method =="deviceStatus"){
                val deviceDataString = call.argument<String>("connectionInfo")
                Log.i(TAG,"got device status data with arguments $deviceDataString")
                val deviceData = Gson().fromJson<ConnectionInfo>(deviceDataString,ConnectionInfo::class.java)
                val deviceType = getSharedPreferences(SharedPrefernces,Context.MODE_PRIVATE).getString("flutter.deviceType",null)
                deviceId = deviceData.deviceId?:""
                BaseDevice.getDeviceImpl(deviceType?.toUpperCase()).getDeviceInfo(result,deviceData,this)
            }else if(call.method =="disconnect"){
                val deviceType = call.argument<String>("deviceType")
                BaseDevice.getDeviceImpl(deviceType).disconnectDevice(result)
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
        MainActivity.currentContext = applicationContext
        Log.i(TAG,"constructor background")
        MainActivity
        onFetch(applicationContext,taskId)
    }

    private fun onFetch(applicationContext: Context, taskId:String){
        try {
            if (ContextCompat.checkSelfPermission(applicationContext,
                            Manifest.permission.ACCESS_BACKGROUND_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                BaseDevice.isBackground = true
                Log.i(TAG, "Doing background work")
                val deviceDataString = applicationContext.getSharedPreferences(MainActivity.SharedPrefernces, Context.MODE_PRIVATE).getString("flutter.watchInfo", "")
                val deviceData = Gson().fromJson<ConnectionInfo>(deviceDataString, ConnectionInfo::class.java)
                val deviceType = applicationContext.getSharedPreferences(MainActivity.SharedPrefernces, Context.MODE_PRIVATE).getString("flutter.deviceType", null)
                MainActivity.deviceId = deviceData?.deviceId ?: ""
                BaseDevice.getDeviceImpl(deviceType?.toUpperCase())?.syncData(null, deviceData, applicationContext)
            } else {
                Log.e(TAG, "No location permission")
            }
        }catch(ex:Exception){
            Log.e(TAG,"Error syncing health data",ex)
        }
        BackgroundFetch.getInstance(applicationContext).finish(taskId)

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