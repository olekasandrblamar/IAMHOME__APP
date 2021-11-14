package com.cerashealth.ceras


import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.view.WindowManager.LayoutParams
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
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.text.SimpleDateFormat
import java.util.*

class MainActivity: FlutterFragmentActivity()  {

    private val CHANNEL = "ceras.iamhome.mobile/device"
    private val DEVICE_EVENTS = "ceras.iamhome.mobile/device_events"
    private val DEVICE_UPGRADE_EVENTS = "ceras.iamhome.mobile/device_upgrade"
    private var sycnDevice: BaseDevice? = null

    companion object{
        var lastConnected: Calendar = Calendar.getInstance()
        var currentContext:Context? = null
        var currentActivity:MainActivity? = null
        val TAG = MainActivity::class.java.simpleName
        const val SERVER_BASE_URL = "flutter.apiBaseUrl"
        private const val BACKGROUND_JOB = "background_bluetooth"
        var deviceId = ""
        const val SharedPrefernces = "FlutterSharedPreferences"
        private val displayDateFormat = SimpleDateFormat("MM/dd/yyyy hh:mm a")
        private const val MY_PERMISSIONS_REQUEST_BLUETOOTH:Int = 0x55

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
        if (checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
                != PackageManager.PERMISSION_GRANTED ||
            checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED
            || checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
                ) {
            // Should we show an explanation?
            if (shouldShowRequestPermissionRationale(Manifest.permission.ACCESS_FINE_LOCATION)) {
                Log.i(TAG,"requestPermission,shouldShowRequestPermissionRationale")
            } else {
                Log.i(TAG,"requestPermission,shouldShowRequestPermissionRationale else")
                requestPermissions(arrayOf(Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION,Manifest.permission.WRITE_EXTERNAL_STORAGE),
                        MY_PERMISSIONS_REQUEST_BLUETOOTH)
            }
        } else {
            B369Device.getInstance().initSDK(this)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when(requestCode){
            MY_PERMISSIONS_REQUEST_BLUETOOTH->{
                B369Device.getInstance().initSDK(this)
            }else->{

        }
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
            updateCurrentActivity()
            BaseDevice.isBackground = false
            if(call.method=="connectDevice"){
                val deviceType = call.argument<String>("deviceType")
                val deviceId = call.argument<String>("deviceId")
                //For now connect to watch
                sycnDevice = BaseDevice.getDeviceImpl(deviceType)
                sycnDevice?.let {
                    it.connectDevice(applicationContext,result,deviceId)
                    //Update the device type
                    applicationContext.getSharedPreferences(SharedPrefernces, MODE_PRIVATE).edit().putString("flutter.deviceType",deviceType).commit()
                }
            } else if(call.method =="syncData"){
                val deviceDataString = call.argument<String>("connectionInfo")
                updateLastConnected()
                Log.i(TAG,"last Updated ${getSharedPreferences(SharedPrefernces, MODE_PRIVATE).all}")
                Log.i(TAG,"got sync data with arguments $deviceDataString")
                val deviceData = Gson().fromJson(deviceDataString,ConnectionInfo::class.java)
                val deviceType = getSharedPreferences(SharedPrefernces, MODE_PRIVATE).getString("flutter.deviceType",null)
                deviceId = deviceData.deviceId?:""
                Log.i(TAG,"Device type ${deviceData.deviceType} with ${Gson().toJson(deviceData)}")
                BaseDevice.getDeviceImpl(deviceData.deviceType).syncData(result,deviceData,this)
            }else if(call.method =="deviceStatus"){
                val deviceDataString = call.argument<String>("connectionInfo")
                Log.i(TAG,"got device status data with arguments $deviceDataString")
                val deviceData = Gson().fromJson(deviceDataString,ConnectionInfo::class.java)
                deviceId = deviceData.deviceId?:""
                BaseDevice.getDeviceImpl(deviceData.deviceType).getDeviceInfo(result,deviceData,this)
            }else if(call.method =="connectionStatus"){
                val deviceDataString = call.argument<String>("connectionInfo")
                Log.i(TAG,"got device status data with arguments $deviceDataString")
                val deviceData = Gson().fromJson(deviceDataString,ConnectionInfo::class.java)
                val deviceType = getSharedPreferences(SharedPrefernces, MODE_PRIVATE).getString("flutter.deviceType",null)
                deviceId = deviceData.deviceId?:""
                BaseDevice.getDeviceImpl(deviceData.deviceType).getConnectionStatus(result,deviceData,this)
            }else if(call.method =="disconnect"){
                val deviceDataString = call.argument<String>("connectionInfo")
                Log.i(TAG,"got disconnect with arguments $deviceDataString")
                val deviceData = Gson().fromJson(deviceDataString,ConnectionInfo::class.java)
                BaseDevice.getDeviceImpl(deviceData.deviceType).disconnectDevice(result,deviceData.deviceId)
            }
            else if(call.method == "readLineData"){
            }else if(call.method == "upgradeDevice"){
//                val deviceDataString = call.argument<String>("connectionInfo")
//                Log.i(TAG,"got upgrade device data with arguments $deviceDataString")
//                val deviceData = Gson().fromJson(deviceDataString,ConnectionInfo::class.java)
//                deviceId = deviceData.deviceId?:""
//                BaseDevice.getDeviceImpl(deviceData.deviceType).upgradeDevice(result,deviceData,this)
            }else if(call.method == "connectWifi"){
                val deviceDataString = call.argument<String>("connectionInfo")
                val deviceData = Gson().fromJson(deviceDataString,ConnectionInfo::class.java)
                val network = call.argument<String>("network")
                val password = call.argument<String>("password")
                BaseDevice.getDeviceImpl(deviceData.deviceType).connectWifi(result,deviceData,baseContext,network,password)
            }
            else if(call.method == "readLineData"){
                val deviceDataString = call.argument<String>("connectionInfo")

            }
            else {
                result.notImplemented()
            }
        }
    }

    private fun updateCurrentActivity(){
        currentContext = currentContext?:this
        currentActivity = currentActivity?:this
    }

    private fun readDataFromDevice(eventSink:EventChannel.EventSink,readingRequest: ReadingRequest){
        updateCurrentActivity()
        BaseDevice.isBackground = false

        //fire the reading on the device
        BaseDevice.getDeviceImpl(readingRequest.deviceType).readDataFromDevice(eventSink,readingRequest.readingType)

    }

    private fun connectEventChannel(flutterEngine: FlutterEngine){
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_EVENTS)
                .setStreamHandler(object: StreamHandler{
                    var eventSink:EventChannel.EventSink? = null
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        eventSink = events
                        val args = arguments as Map<String, String>
                        Log.d(TAG,"arguments $args ")
                        val deviceType = args["deviceType"]
                        val readingType = args["readingType"]?.toUpperCase()
                        readDataFromDevice(eventSink!!,ReadingRequest().apply {
                            this.deviceType = deviceType!!
                            this.readingType = readingType!!
                        })
                    }

                    override fun onCancel(arguments: Any?) {
                        eventSink?.let {
                            it.endOfStream()
                        }
                    }
                })

    }

    private fun connectUpgradeChannel(flutterEngine: FlutterEngine){
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_UPGRADE_EVENTS)
            .setStreamHandler(object: StreamHandler{
                var eventSink:EventChannel.EventSink? = null
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    val args = arguments as Map<String, String>
                    val deviceDataString = args["connectionInfo"]
                    Log.i(TAG,"got upgrade device data with arguments $deviceDataString")
                    val deviceData = Gson().fromJson(deviceDataString,ConnectionInfo::class.java)
                    deviceId = deviceData.deviceId?:""
                    BaseDevice.getDeviceImpl(deviceData.deviceType).upgradeDevice(eventSink,deviceData,MainActivity.currentContext!!)
                }

                override fun onCancel(arguments: Any?) {
                    eventSink?.let {
                        it.endOfStream()
                    }
                }
            })
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        //GeneratedPluginRegistrant.registerWith(flutterEngine);
        requestPermission()
        scheduleBackgroundTasks()
        connectEventChannel(flutterEngine)
        connectDeviceChannel(flutterEngine)
        connectUpgradeChannel(flutterEngine)
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
class ReadingRequest{
    lateinit var deviceType: String
    lateinit var readingType: String
}

class CerasBluetoothSync{

    companion object{
        val TAG = CerasBluetoothSync::class.java.simpleName
    }

    constructor(applicationContext: Context,taskId:String){
        MainActivity.currentContext = MainActivity.currentContext?:applicationContext
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
                //val deviceDataString = applicationContext.getSharedPreferences(MainActivity.SharedPrefernces, Context.MODE_PRIVATE).getString("flutter.watchInfo", "")
                //val deviceData = Gson().fromJson(deviceDataString, ConnectionInfo::class.java)
                val devicesListString = applicationContext.getSharedPreferences(MainActivity.SharedPrefernces, Context.MODE_PRIVATE).getString("flutter.deviceData", "")
                val devicesList = Gson().fromJson(devicesListString, List::class.java) as List<DevicesModel>
                devicesList.forEach {
                    it.watchInfo?.let {
                        BaseDevice.getDeviceImpl(it.deviceType)?.syncData(null, it, applicationContext)
                    }

                }
//                deviceData?.deviceType?.let {
//                    val deviceType = applicationContext.getSharedPreferences(MainActivity.SharedPrefernces, Context.MODE_PRIVATE).getString("flutter.deviceType", null)
//                    MainActivity.deviceId = deviceData?.deviceId ?: ""
//                    BaseDevice.getDeviceImpl(deviceData.deviceType)?.syncData(null, deviceData, applicationContext)
//                }
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

        //getWindow().addFlags(LayoutParams.FLAG_SECURE);
        super.onCreate()
    }
}