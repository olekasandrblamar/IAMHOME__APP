package com.cerashealth.ceras.lifeplus

import android.content.Context
import android.os.Bundle
import android.util.Log
import com.cerashealth.ceras.MainActivity
import com.cerashealth.ceras.lifeplus.data.*
import com.google.gson.Gson
import com.inuker.bluetooth.library.Code
import com.inuker.bluetooth.library.Constants.*
import com.inuker.bluetooth.library.search.SearchResult
import com.inuker.bluetooth.library.search.response.SearchResponse
import com.veepoo.protocol.VPOperateManager
import com.veepoo.protocol.listener.base.IABleConnectStatusListener
import com.veepoo.protocol.listener.base.IBleWriteResponse
import com.veepoo.protocol.listener.data.*
import com.veepoo.protocol.model.datas.*
import com.veepoo.protocol.model.enums.*
import com.veepoo.protocol.model.settings.*
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.text.SimpleDateFormat
import java.util.*

class B360Device:BaseDevice(),SearchResponse {

    companion object{
        private const val B360DeviceTag = "B360Device"
        private var connectResult: MethodChannel.Result? = null
        private var deviceId:String? = ""
        private var device:B360Device? = null
        private var connected = false
        private var connectionListenerConfigured = false
        private var reading = false
        private var lastConfirmPassword = 0L
        private var lastReading:Date = Calendar.getInstance().apply {
            add(Calendar.MINUTE,-10)
        }.time

        fun getInstance():B360Device{
            if(device ==null){
                device = B360Device()
            }
            return device!!
        }
    }

    private var vManager:VPOperateManager? = null
    private var connectionInfo:ConnectionInfo? = null
    private var deviceFound = false


    private fun getManager(context: Context):VPOperateManager{
       return vManager?:VPOperateManager.getMangerInstance(context).apply {
            vManager = this
        }
    }

    private fun checkAndConfigureConnectionListener(connectionInfo: ConnectionInfo,context: Context,callBack: () -> Unit){
        Log.d(B360DeviceTag,"Checking and configuring connection listener")
        if(!connectionListenerConfigured){
            Log.d(B360DeviceTag,"Configuring connection listener")
            getManager(context).registerConnectStatusListener(connectionInfo.deviceId,object: IABleConnectStatusListener() {
                    override fun onConnectStatusChanged(macAddress: String?, connectionStatus: Int) {
                        when(connectionStatus){
                            STATUS_CONNECTED -> {
                                connected = true
                            }
                            STATUS_DISCONNECTED -> {
                                connected = false
                            }
                        }
                    }
                }
            )
            connectionListenerConfigured = true
        }
        callBack()
    }

    override fun connectDevice(context: Context, result: MethodChannel.Result, deviceId: String?) {
        B360Device.deviceId = deviceId
        connectResult = result
        deviceFound = false
        //Scan for the device
        getManager(context).startScanDevice(this)
        //Wait for 25 seconds and if the device is not connected send an error response back
        GlobalScope.launch {
            delay(30000)
            Log.d(B360DeviceTag, "Unable to find device $connected")
            getManager(context).stopScanDevice()
            if(!connected)
                MainActivity.currentActivity?.runOnUiThread {
                    result.success(ConnectionInfo.createResponse(message = "Failed", connected = false, deviceFound = deviceFound))
                }
        }
    }

    override fun onSearchStarted() {
        Log.i(B360DeviceTag,"Search started")
    }

    override fun disconnectDevice(result: MethodChannel.Result?, deviceId: String?) {
        vManager?.let {manager->
            manager.disconnectWatch {
                Log.i(B360DeviceTag,"Disconnect response $it")
                if(it == Code.REQUEST_SUCCESS){
                    manager.clearDeviceData {
                        if(it == Code.REQUEST_SUCCESS)
                            result?.success("Success")
                        else
                            result?.success("Failure")
                    }
                }else{
                    result?.success("Failure")
                }
            }
        }
    }

    private fun sendResponse(callBack: ()->Unit = {}){
        MainActivity.currentActivity?.runOnUiThread(callBack)
    }

    override fun getConnectionStatus(
        result: MethodChannel.Result?,
        connectionInfo: ConnectionInfo,
        context: Context
    ) {
//        result?.success(getManager(context).isNetworkConnected(context))
        //If the device is not connected, try to connect and send a response
        if(!connected){
            reConnectDevice(connectionInfo.deviceId, connectionInfo.deviceName) {
                if (it == Code.REQUEST_SUCCESS) {
                    Log.d(B360DeviceTag, "Device connection success from Connection status")
                    confirmPasswd {
                        sendResponse {
                            result?.success(getManager(context).isNetworkConnected(context))
                        }
                    }
                }else{
                    sendResponse {
                        result?.success(false)
                    }
                }
            }
            //Wait for 20 seconds and send an invalid response
            GlobalScope.launch {
                delay(20000)
                Log.d(B360DeviceTag, "Unable to find device $connected")
                getManager(context).stopScanDevice()
                if(!connected) {
                    sendResponse {
                        result?.success(false)
                    }
                }
            }

        }else{
            confirmPasswd {
                sendResponse {
                    result?.success(getManager(context).isNetworkConnected(context))
                }
            }
        }
    }

    override fun getDeviceInfo(
        result: MethodChannel.Result?,
        connectionInfo: ConnectionInfo,
        context: Context
    ) {
        val manager = getManager(context)
        checkAndConfigureConnectionListener(connectionInfo,context) {
            Log.d(B360DeviceTag, "Getting device info")
            if (!connected) {
                Log.d(B360DeviceTag, "Device not connected from device info, reconnecting")
                reConnectDevice(connectionInfo.deviceId, connectionInfo.deviceName) {
                    if (it == Code.REQUEST_SUCCESS) {
                        Log.d(B360DeviceTag, "Device connection success from device info")
                        confirmPasswd {
                            syncUserInfo {
                                connectionInfo.connected = manager.isNetworkConnected(context)
                                Log.d(B360DeviceTag, "Getting battery status")
                                getBatteryInfo(connectionInfo) {
                                    Log.d(
                                        B360DeviceTag,
                                        "Got battery status ${connectionInfo.batteryStatus}"
                                    )
                                    sendResponse {
                                        result?.success(
                                            ConnectionInfo.createResponse(
                                                deviceId = connectionInfo.deviceId,
                                                connected = connectionInfo.connected,
                                                deviceType = connectionInfo.deviceType,
                                                deviceName = connectionInfo.deviceName,
                                                batteryStatus = connectionInfo.batteryStatus,
                                                additionalInfo = connectionInfo.additionalInformation
                                            )
                                        )
                                    }

                                }
                            }
                        }
                    } else {
                        Log.d(B360DeviceTag, "Device connection failure")
                        sendResponse {
                            result?.success(
                                ConnectionInfo.createResponse(
                                    deviceId = connectionInfo.deviceId,
                                    connected = false,
                                    deviceType = connectionInfo.deviceType,
                                    deviceName = connectionInfo.deviceName,
                                    message = "Connection Failed"
                                )
                            )
                        }

                    }
                }
            } else {
                Log.d(B360DeviceTag, "Device already connected from get device info")
                connectionInfo.connected = manager.isNetworkConnected(context)
                getBatteryInfo(connectionInfo) {
                    Log.d(B360DeviceTag, "Got battery status ${connectionInfo.batteryStatus}")
                    sendResponse {
                        result?.success(
                            ConnectionInfo.createResponse(
                                deviceId = connectionInfo.deviceId,
                                connected = connectionInfo.connected,
                                deviceType = connectionInfo.deviceType,
                                deviceName = connectionInfo.deviceName,
                                batteryStatus = connectionInfo.batteryStatus,
                                additionalInfo = connectionInfo.additionalInformation
                            )
                        )
                    }

                }

            }
        }
    }

    private fun logFirebaseEvent(action:String,params:MutableMap<String,String?>){
        DataSync.sendLog(params.apply {
            put("deviceId", connectionInfo?.deviceId)
            put("action",action)
        })
    }

    override fun readDataFromDevice(eventSink: EventChannel.EventSink, readingType: String) {
        when(readingType){
            HEARTRATE -> {
                startHeartRateDetection(eventSink)
//                var heartRateStart = false
//                var startDate = Calendar.getInstance().timeInMillis
//                vManager?.startDetectHeart({
//                    Log.d(B360DeviceTag,"Got Heart Response $it")
//                }, {
//                    Log.d(B360DeviceTag,"Got heart rate ${it.data} with status ${it.heartStatus}")
//                    if(!heartRateStart && it.heartStatus == EHeartStatus.STATE_HEART_NORMAL){
//                        startDate = Calendar.getInstance().timeInMillis
//                        heartRateStart = true
//                    }
//                    if(it.heartStatus == EHeartStatus.STATE_HEART_NORMAL)
//                        eventSink.success(Gson().toJson(mapOf("data" to it.data,"measureTime" to getTimeInUtcString())))
//                    val timeDiff = (Calendar.getInstance().timeInMillis - startDate)/1000
//                    Log.d(B360DeviceTag,"Time difference $timeDiff")
//                    if( (heartRateStart && timeDiff > 10) || timeDiff > 60){
//                        vManager?.stopDetectHeart {
//                            eventSink.endOfStream()
//                        }
//                        DataSync.uploadHeartRate(
//                            listOf(HeartRateUpload(
//                            measureTime = Calendar.getInstance().time,
//                            heartRate = it.data,
//                            deviceId = connectionInfo?.deviceId!!,
//                            userProfile = DataSync.getUserInfo()
//                        )))
//                    }
//                })
            }
            BP -> {
//                vManager?.startDetectBP({
//                    Log.d(B360DeviceTag,"Got BP Response $it")
//                },{
//                    Log.d(B360DeviceTag,"Got BP data ${it.highPressure}/${it.lowPressure} with progress ${it.progress} and status ${it.status}")
//                    if(it.progress == 100){
//                        eventSink.success(Gson().toJson(mapOf("data1" to it.highPressure,"data2" to it.lowPressure,"measureTime" to getTimeInUtcString())))
//                        eventSink.endOfStream()
//                        DataSync.uploadBloodPressure(listOf(BpUpload(
//                            measureTime = Calendar.getInstance().time,
//                            distolic = it.lowPressure,
//                            systolic = it.highPressure,
//                            userProfile = DataSync.getUserInfo(),
//                            deviceId = connectionInfo?.deviceId!!
//                            )))
//                    }
//                },EBPDetectModel.DETECT_MODEL_PUBLIC)
                startBpDetection(eventSink)
            }
            O2 -> {
                var o2Start = false
                var startDate = Calendar.getInstance().timeInMillis
                vManager?.startDetectSPO2H({
                    Log.d(B360DeviceTag,"Got O2 Response $it")
                },{
                    Log.d(B360DeviceTag,"Got o2 data ${it.value} with state ${it.spState} and progress ${it.checkingProgress}")
                    if(it.value>0){
                        if(!o2Start) {
                            o2Start = true
                            startDate = Calendar.getInstance().timeInMillis
                        }
                        eventSink.success(Gson().toJson(mapOf("data" to it.value,"measureTime" to getTimeInUtcString())))
                    }
                    val timeDiff = (Calendar.getInstance().timeInMillis - startDate)/1000
                    if((!o2Start && timeDiff> 45)||(o2Start && timeDiff>10)){
                        if(it.value>0) {
                            DataSync.uploadOxygenData(
                                listOf(
                                    OxygenLevelUpload(
                                        measureTime = Calendar.getInstance().time,
                                        deviceId = connectionInfo?.deviceId!!,
                                        userProfile = DataSync.getUserInfo(),
                                        oxygenLevel = it.value
                                    )
                                )
                            )
                        }
                        vManager?.stopDetectSPO2H({
                            if(!o2Start){
                                eventSink.success(Gson().toJson(mapOf("data" to 0,"measureTime" to getTimeInUtcString())))
                            }
                            eventSink.endOfStream()
                            Log.d(B360DeviceTag,"Got O2 stop Response $it")
                        },{

                            Log.d(B360DeviceTag,"Sending end of stream")

                        })
                    }
                },{
                    Log.d(B360DeviceTag,"Got readings $it")
                })
            }
        }
    }

    private fun startHeartRateDetection(eventSink: EventChannel.EventSink? = null){
        var heartRateStart = false
        var startDate = Calendar.getInstance().timeInMillis
        vManager?.startDetectHeart({
            Log.d(B360DeviceTag,"Got Heart Response $it")
        }, {
            Log.d(B360DeviceTag,"Got heart rate ${it.data} with status ${it.heartStatus}")
            if(!heartRateStart && it.heartStatus == EHeartStatus.STATE_HEART_NORMAL){
                startDate = Calendar.getInstance().timeInMillis
                heartRateStart = true
            }
            eventSink?.let{eventSink->
                if(it.heartStatus == EHeartStatus.STATE_HEART_NORMAL)
                    eventSink.success(Gson().toJson(mapOf("data" to it.data,"measureTime" to getTimeInUtcString())))
            }

            val timeDiff = (Calendar.getInstance().timeInMillis - startDate)/1000
            Log.d(B360DeviceTag,"Time difference $timeDiff")
            if( (heartRateStart && timeDiff > 10) || timeDiff > 60){
                vManager?.stopDetectHeart {
                    eventSink?.endOfStream()
                }
                if(eventSink==null)
                    startBpDetection()
                DataSync.uploadHeartRate(
                    listOf(HeartRateUpload(
                        measureTime = Calendar.getInstance().time,
                        heartRate = it.data,
                        deviceId = connectionInfo?.deviceId!!,
                        userProfile = DataSync.getUserInfo()
                    )))
            }
        })
    }

    private fun startBpDetection(eventSink: EventChannel.EventSink? = null){
        vManager?.startDetectBP({
            Log.d(B360DeviceTag,"Got BP Response $it")
        },{
            Log.d(B360DeviceTag,"Got BP data ${it.highPressure}/${it.lowPressure} with progress ${it.progress} and status ${it.status}")
            if(it.progress == 100){
                eventSink?.let {eventSink->
                    eventSink.success(Gson().toJson(mapOf("data1" to it.highPressure,"data2" to it.lowPressure,"measureTime" to getTimeInUtcString())))
                    eventSink.endOfStream()
                }
                DataSync.uploadBloodPressure(listOf(BpUpload(
                    measureTime = Calendar.getInstance().time,
                    distolic = it.lowPressure,
                    systolic = it.highPressure,
                    userProfile = DataSync.getUserInfo(),
                    deviceId = connectionInfo?.deviceId!!
                )))
            }
        },EBPDetectModel.DETECT_MODEL_PUBLIC)
    }

    private fun startO2SatsDetection(){
        var o2Start = false
        var startDate = Calendar.getInstance().timeInMillis
        vManager?.startDetectSPO2H({
            Log.d(B360DeviceTag,"Got O2 Response $it")
        },{
            Log.d(B360DeviceTag,"Got o2 data ${it.value} with state ${it.spState} and progress ${it.checkingProgress}")
            if(it.value>0){
                if(!o2Start) {
                    o2Start = true
                    startDate = Calendar.getInstance().timeInMillis
                }
            }
            val timeDiff = (Calendar.getInstance().timeInMillis - startDate)/1000
            if((!o2Start && timeDiff> 45)||(o2Start && timeDiff>10)){
                if(it.value>0) {
                    DataSync.uploadOxygenData(
                        listOf(
                            OxygenLevelUpload(
                                measureTime = Calendar.getInstance().time,
                                deviceId = connectionInfo?.deviceId!!,
                                userProfile = DataSync.getUserInfo(),
                                oxygenLevel = it.value
                            )
                        )
                    )
                }
                vManager?.stopDetectSPO2H({
                    Log.d(B360DeviceTag,"Got O2 stop Response $it")
                },{
                    //startHeartRateDetection()
                    Log.d(B360DeviceTag,"Sending end of stream")

                })
            }
        },{
            Log.d(B360DeviceTag,"Got readings $it")
        })
    }

    private fun getTimeInUtcString():String{
        val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS")
        sdf.timeZone = TimeZone.getTimeZone("UTC")
        return sdf.format(Calendar.getInstance().time)+"+00:00"
    }

    private fun getBatteryInfo(connectionInfo: ConnectionInfo,callBack: () -> Unit = {}){
        vManager?.readBattery({
            Log.d(B360DeviceTag,"Got batery Response $it")
        }, {
            Log.d(B360DeviceTag,"Got Battery data $it")
            connectionInfo.batteryStatus = (it.batteryLevel*25).toString()
            callBack()
        })

    }

    override fun syncData(result: MethodChannel.Result?, connectionInfo: ConnectionInfo, context: Context) {
        this.connectionInfo = connectionInfo
        checkAndConfigureConnectionListener(connectionInfo,context) {
            if(connected){
                Log.d(B360DeviceTag,"Device is connected. Syncing password")
                checkPasswordAndSync()
                sendResponse {
                    result?.success(ConnectionInfo.createResponse(deviceName = connectionInfo.deviceName,
                        deviceId = connectionInfo.deviceId,connected = true,deviceType = connectionInfo.deviceType))
                }
            }else{
                Log.d(B360DeviceTag,"Device is not connected. Reconnecting device")
                reConnectDevice(connectionInfo.deviceId,connectionInfo.deviceName){resp->
                    if(resp== Code.REQUEST_SUCCESS){
                        result?.success(ConnectionInfo.createResponse(deviceName = connectionInfo.deviceName,
                            deviceId = connectionInfo.deviceId,connected = true,deviceType = connectionInfo.deviceType))
                        checkPasswordAndSync()
                    }else{
                        result?.success(ConnectionInfo.createResponse(deviceName = connectionInfo.deviceName,
                            deviceId = connectionInfo.deviceId,connected = false,deviceType = connectionInfo.deviceType))
                    }
                }
            }
        }
    }

    private fun reConnectDevice(deviceId:String?,deviceName:String?,callBack: (connectionStatus:Int) -> Unit = {}){
        Log.d(B360DeviceTag,"Reconnecting device with deviceId $deviceId and deviceName $deviceName")

        getManager(MainActivity.currentContext!!).startScanDevice(object: SearchResponse{
            override fun onSearchStarted() {
                Log.i(B360DeviceTag,"Search Started")
            }

            override fun onDeviceFounded(result: SearchResult?) {
                result?.let {
                    Log.d(B360DeviceTag,"Got search result ${it.address} and name ${it.name}")
                    if(it.address == deviceId){
                        vManager?.stopScanDevice()
                        vManager?.connectDevice(it.address,it.name, { code, bleGattProfile, isOadModel ->
                            Log.i(B360DeviceTag,"Got code $code oadModel $isOadModel")
                        }, {resp->
                            lastConfirmPassword = 0L
                            connected = true
                            Log.i(B360DeviceTag,"Got connect response $resp")
                            callBack(resp)
                        })
                    }
                }
            }

            override fun onSearchStopped() {
                Log.i(B360DeviceTag,"Search Stopped")
            }

            override fun onSearchCanceled() {
                Log.i(B360DeviceTag,"Search Cancelled")
            }

        })

//        vManager?.connectDevice(deviceId,deviceName, { code, bleGattProfile, isOadModel ->
//            Log.i(B360DeviceTag,"Got code $code oadModel $isOadModel")
//            lastConfirmPassword = 0L
//        }, {resp->
//            connected = true
//            Log.i(B360DeviceTag,"Got connect response $resp")
//            callBack(resp)
//        })

        //Wait for 25 seconds and stop the search
        GlobalScope.launch {
            delay(25000)
            if(!connected) {
                Log.d(B360DeviceTag, "Unable to find device $connected")
                getManager(MainActivity.currentContext!!).stopScanDevice()
            }
        }
    }

    private fun checkPasswordAndSync(){
        DataSync.sendHeartBeat(HeartBeat(macAddress = connectionInfo?.deviceId, deviceId = connectionInfo?.deviceName))
        confirmPasswd{
            syncUserInfo{
                syncData()
            }
        }
    }

    private fun readHealthData(){
        vManager?.readAllHealthData(object:IAllHealthDataListener{
            override fun onProgress(progress: Float) {
                Log.i(B360DeviceTag,"All health progress $progress")
            }

            override fun onSleepDataChange(sleepChange: String?, sleepData: SleepData?) {
                Log.i(B360DeviceTag,"Sleep data ${Gson().toJson(sleepData)} and sleep change $sleepChange")
            }

            override fun onReadSleepComplete() {
                Log.i(B360DeviceTag,"Sleep Complete")
            }

            override fun onOringinFiveMinuteDataChange(originData: OriginData?) {
                Log.i(B360DeviceTag,"Five minute change ${Gson().toJson(originData)}")
            }

            override fun onOringinHalfHourDataChange(halfHourData: OriginHalfHourData?) {
                Log.i(B360DeviceTag,"Five minute change ${Gson().toJson(halfHourData)}")
            }

            override fun onReadOriginComplete() {
                Log.i(B360DeviceTag,"Origin complete")
            }

        },getSyncDays())

    }

    //Update the last reading time for B330
    private fun updateLastSyncTime(){
        MainActivity.currentContext?.let {currentContext->
            currentContext.getSharedPreferences(MainActivity
                .SharedPrefernces, Context.MODE_PRIVATE).edit()
                .putLong("B330_LASTUPDATE", Calendar.getInstance().timeInMillis).apply()
        }
    }

    //Get the last sync time
    private fun lastSyncTime():Long{
        MainActivity.currentContext?.let { currentContext ->
            return currentContext.getSharedPreferences(MainActivity.SharedPrefernces,Context.MODE_PRIVATE)
                .getLong("B330_LASTUPDATE",0L)
        }
        return 0L
    }

    private fun getSyncDays():Int{
        val daysDiff = (Calendar.getInstance().timeInMillis - lastSyncTime())/(1000*60*60*24)

        return when{
            daysDiff>2 -> 3
            daysDiff>1 -> 2
            else -> 1
        }
    }

    private fun readDataFromDevice(){
        val fiveMinutesAgo = Calendar.getInstance().apply { add(Calendar.MINUTE,-5) }.time
        Log.d(B360DeviceTag," Is reading $reading with lastReading $lastReading")
        if(lastReading.before(fiveMinutesAgo)) {
            Log.i(B360DeviceTag,"syncing data from B360")
            reading = true
            lastReading = Calendar.getInstance().time

            vManager?.readOriginData({
                Log.i(B360DeviceTag, "Got response $it")
            }, object : IOriginData3Listener {

                val heartUploads = mutableListOf<HeartRateUpload>()
                val bpUploads = mutableListOf<BpUpload>()
                val o2Uploads = mutableListOf<OxygenLevelUpload>()
                val dailyStepUploads = mutableListOf<DailyStepUpload>()
                val stepUploads = mutableListOf<StepUpload>()
                val dailyCaloriesUpload = mutableListOf<CaloriesUpload>()

                override fun onReadOriginProgressDetail(
                    day: Int,
                    date: String?,
                    allPackage: Int,
                    currentPackage: Int
                ) {
                    Log.i(B360DeviceTag,"Day $day Date $date allPackage $allPackage currentPackage $currentPackage")
                }

                override fun onReadOriginProgress(progress: Float) {
                    Log.i(B360DeviceTag, "Origin Progress $progress")
                }

                override fun onReadOriginComplete() {
                    Log.i(B360DeviceTag, "Read complete")
                    reading = false
                    Log.d(B360DeviceTag, "Uploading bp $bpUploads")
                    DataSync.uploadBloodPressure(bpUploads)
                    Log.d(B360DeviceTag, "Uploading HR $heartUploads")
                    DataSync.uploadHeartRate(heartUploads)
                    logFirebaseEvent("Data UPLOAD",
                        mutableMapOf("message" to "Data uploaded",
                            "HR" to "${heartUploads.size}",
                            "BP" to "${bpUploads.size}",
                            "O2" to "${o2Uploads.size}"))
                    Log.d(B360DeviceTag, "Uploading o2 $o2Uploads")
                    DataSync.uploadOxygenData(o2Uploads)
                    Log.d(B360DeviceTag,"Uploading calories $dailyCaloriesUpload")
                    DataSync.uploadCalories(dailyCaloriesUpload)
                    logFirebaseEvent("CALORY UPLOAD", mutableMapOf("message" to "Calories uploaded with size ${dailyCaloriesUpload.size}"))
                    Log.d(B360DeviceTag, "Uploading Daily steps $dailyStepUploads")
                    DataSync.uploadDailySteps(dailyStepUploads.filter { it.steps > 0 })
                    Log.d(B360DeviceTag, "Uploading steps $stepUploads")
                    DataSync.uploadStepInfo(stepUploads)
                    logFirebaseEvent("STEP UPLOAD", mutableMapOf("message" to "Steps uploaded with size ${stepUploads.size}"))
                    //readSleepData()
                    updateLastSyncTime()
                }

                override fun onOriginFiveMinuteListDataChange(originDataList: MutableList<OriginData3>?) {
                    Log.i(B360DeviceTag,"Five minute data $originDataList")
                    originDataList?.forEach {
                        Log.i(B360DeviceTag,"Got data $it")
                    }
                }

                override fun onOriginHalfHourDataChange(halfHourData: OriginHalfHourData?) {
                    //Log.i(B360DeviceTag,"Half hour data $halfHourData")
                    val userInfo = DataSync.getUserInfo()
                    halfHourData?.halfHourBps?.map {
                        Log.i(
                            B360DeviceTag,
                            "${it.date}, ${it.time} - ${it.highValue} - ${it.lowValue}"
                        )
                        BpUpload(
                            measureTime = convertToDate(it.time),
                            systolic = it.highValue, distolic = it.lowValue,
                            deviceId = connectionInfo?.deviceId!!,
                            userProfile = userInfo
                        )
                    }?.apply {
                        bpUploads.addAll(this)
                    }
                    Log.i(B360DeviceTag, "All step ${halfHourData?.allStep}")
                    halfHourData?.halfHourRateDatas?.map {
                        Log.i(
                            B360DeviceTag,
                            "Heart rate ${it.time} - ${it.rateValue} - ${it.ecgCount}"
                        )
                        HeartRateUpload(
                            measureTime = convertToDate(it.time),
                            heartRate = it.rateValue,
                            deviceId = connectionInfo?.deviceId!!,
                            userProfile = userInfo
                        )
                    }?.apply {
                        heartUploads.addAll(this)
                    }

                    halfHourData?.halfHourSportDatas?.filter { it.stepValue > 0 }?.map {
                        StepUpload(
                            measureTime = convertToDate(it.time),
                            steps = it.stepValue,
                            calories = it.calValue.toInt(),
                            distance = it.disValue.toFloat(),
                            userProfile = userInfo,
                            deviceId = connectionInfo?.deviceId!!
                        )
                    }?.apply {
                        if (isNotEmpty()) {
                            val totalCalories = sumOf { it.calories }
                            val totalDistance = sumOf { it.distance.toDouble() }
                            halfHourData.halfHourSportDatas.first()?.let {
                                dailyStepUploads.add(
                                    DailyStepUpload(
                                        measureTime = getDateFromString(it.date),
                                        steps = halfHourData.allStep,
                                        calories = totalCalories,
                                        distance = totalDistance.toFloat(),
                                        deviceId = connectionInfo?.deviceId!!,
                                        userProfile = userInfo
                                    )
                                )
                                dailyCaloriesUpload.add(
                                    CaloriesUpload(
                                        measureTime = getDateFromString(it.date),
                                        calories = totalCalories,
                                        deviceId = connectionInfo?.deviceId!!,
                                        userProfile = userInfo

                                    )
                                )
                            }
                            stepUploads.addAll(this)
                        }
                    }
                }

                override fun onOriginHRVOriginListDataChange(hrvDataList: MutableList<HRVOriginData>?) {
                    Log.i(B360DeviceTag, "Hrv data $hrvDataList")
                    hrvDataList?.forEach {
                        Log.i(B360DeviceTag, "Hrv value ${Gson().toJson(it)}")
                    }
                }

                override fun onOriginSpo2OriginListDataChange(spo2Data: MutableList<Spo2hOriginData>?) {
                    //Log.i(B360DeviceTag,"SPO2 data $spo2Data")
                    spo2Data?.filter { it.oxygenValue > 0 }?.map {
                        OxygenLevelUpload(
                            measureTime = convertToDate(it.getmTime()),
                            oxygenLevel = it.oxygenValue,
                            deviceId = connectionInfo?.deviceId!!,
                            userProfile = DataSync.getUserInfo()
                        )
                    }?.apply {
                        o2Uploads.addAll(this)
                    }
                }
            }, getSyncDays())
        }

    }

    private fun readSleepData(){
        vManager?.readSleepData({

        },object:ISleepDataListener{
            override fun onSleepDataChange(p0: String?, sleepData: SleepData?) {
                Log.d(TAG,"Got sleep data ${sleepData?.sleepDown}")
            }

            override fun onSleepProgress(p0: Float) {
                //TODO("Not yet implemented")
            }

            override fun onSleepProgressDetail(p0: String?, p1: Int) {
                //TODO("Not yet implemented")
            }

            override fun onReadSleepComplete() {
                //TODO("Not yet implemented")
                Log.d(TAG,"Sleep complete")
            }

        },getSyncDays())
    }

    private fun syncData(){
        Log.i(B360DeviceTag,"Is network connected")
        readDataFromDevice()

        readHealthData()
        //Sync o2 sats from device
        startO2SatsDetection()
    }

    private fun readCustomSetting(){
        configureDevice {
            vManager?.readCustomSetting({
                Log.d(B360DeviceTag,"Read custom setting response $it")
            },{
                Log.d(B360DeviceTag,"Got custom data BP:${it.autoBpDetect} HR:${it.autoHeartDetect} ${it.status}")
            })
        }
    }

    private fun configureDevice(callBack: () -> Unit = {}){
        vManager?.changeCustomSetting({
        },{
            Log.i(B360DeviceTag,"Got Custom setting Data with status ${it.status}")
            DataSync.sendHeartBeat(HeartBeat(macAddress = connectionInfo?.deviceId, deviceId = connectionInfo?.deviceName))
            vManager?.settingSpo2hAutoDetect({
                Log.d(B360DeviceTag,"Got SPO02 auto detect response $it")
            },{
                Log.d(B360DeviceTag,"Got setting spo2 data")
            }, AllSetSetting(EAllSetType.SPO2H_NIGHT_AUTO_DETECT,0,0,23,59,1,1))
            syncUserInfo(callBack)
        }, CustomSetting(false,false,false,true,true))
    }

    private fun syncUserInfo(callBack: () -> Unit = {}){
        val userInfo = DataSync.getUserInfo()
        if(userInfo!=null){
            vManager?.syncPersonInfo({
                Log.i(B360DeviceTag,"Status response $it")
                //updateTime(callBack)
                callBack()
            },{
                if(it == EOprateStauts.OPRATE_SUCCESS){
                    Log.i(B360DeviceTag,"Status Success")
                }else{
                    Log.i(B360DeviceTag,"Status $it")
                }
            },PersonInfoData(
                if(userInfo.sex.toLowerCase(Locale.getDefault())=="male") ESex.MAN else ESex.WOMEN,
                userInfo.heightInCm,
                userInfo.weightInKgs.toInt(),
                userInfo.age,
                5000
            ))
        }else{
            callBack()
        }
        configureAutoDetection()
    }
    private fun configureAutoDetection(){
        updateTime()
        vManager?.changeCustomSetting({

        },{

        },CustomSetting(false,false,false,true,true))
//        vManager?.settingDetectBP({
//            Log.d(B360DeviceTag,"Got detection write response $it")
//        },{
//            Log.d(B360DeviceTag,"Got detection response ${it.model}")
//        }, BpSetting(false,120,300))
    }

    private fun configureAutoCapture(){
        //vManager?.
    }


    private fun updateTime(callBack: () -> Unit = {}){
        val cal = Calendar.getInstance()
        val currentTime = DeviceTimeSetting(cal.get(Calendar.YEAR),
            cal.get(Calendar.MONTH)+1,
            cal.get(Calendar.DAY_OF_MONTH),
            cal.get(Calendar.HOUR_OF_DAY),
            cal.get(Calendar.MINUTE),
            Calendar.SECOND,
            ETimeMode.MODE_12)
        vManager?.settingTime({
            Log.i(B360DeviceTag,"Time setting write response $it")
            callBack()
        },{
            Log.i(B360DeviceTag,"Time setting response $it")
        },currentTime)
    }

    override fun onDeviceFounded(searchResult: SearchResult?) {
        searchResult?.let {sResult->
            val lastFour = sResult.address.substring(sResult.address.length - 5).replace(":", "")
            Log.i(B360DeviceTag,"Found last four $lastFour compared to $deviceId")
            if(lastFour == deviceId){
                deviceFound = true
                vManager?.stopScanDevice()
                vManager?.connectDevice(sResult.address,sResult.name, { code, bleGattProfile, isOadModel ->
                    Log.i(B360DeviceTag,"Got code $code oadModel $isOadModel")
                }, {resp->
                    Log.i(B360DeviceTag,"Got connect response $resp")
                    if(resp== Code.REQUEST_SUCCESS){
                        connected = true
                        DataSync.sendHeartBeat(HeartBeat(macAddress = searchResult.address, deviceId = searchResult.name))
                        configureDevice()
                        connectResult?.success(ConnectionInfo.createResponse(deviceId = searchResult.address,deviceType = B360_DEVICE,
                            connected = true,deviceFound = true,additionalInfo = mapOf("deviceName" to searchResult.name),
                            deviceName = searchResult.name, versionUpdate = false))
                        confirmPasswd{
                            syncUserInfo()
                        }
                    }else{
                        connectResult?.success(ConnectionInfo.createResponse(deviceId = searchResult.address,deviceType = B360_DEVICE,
                            connected = false,deviceFound = true,additionalInfo = mapOf("deviceName" to searchResult.name),
                            deviceName = searchResult.name, versionUpdate = false))
                    }
                })
            }
        }
    }

    private fun confirmPasswd(callBack: ()->Unit = {}){
        val curTime = Calendar.getInstance().timeInMillis
        if(curTime - lastConfirmPassword > 30000) {
            vManager?.confirmDevicePwd({
                Log.i(B360DeviceTag, "Password write response ${Gson().toJson(it)}")

            }, {
                Log.i(
                    B360DeviceTag,
                    "pwd data ${it.deviceNumber} - ${it.deviceVersion} - ${it.getmStatus()}"
                )
                if (it.getmStatus() == EPwdStatus.CHECK_AND_TIME_SUCCESS) {
                    lastConfirmPassword = Calendar.getInstance().timeInMillis
                    Thread.sleep(1000)
                    callBack()
                }
            },
                {
                    Log.i(
                        B360DeviceTag,
                        "Function listener ${it.bp} = ${it.heartDetect} ${it.hrvFunction}"
                    )
                }, object : ISocialMsgDataListener {
                    override fun onSocialMsgSupportDataChange(msgData: FunctionSocailMsgData?) {
                        Log.i(B360DeviceTag, "Message Data $msgData")
                    }

                    override fun onSocialMsgSupportDataChange2(msgData: FunctionSocailMsgData?) {
                        Log.i(B360DeviceTag, "Message Data 2 $msgData")
                    }
                }, "0000", false
            )
        }else{
            callBack()
        }

    }

    override fun onSearchStopped() {
        Log.i(B360DeviceTag,"Search stopped")
    }

    override fun onSearchCanceled() {
        Log.i(B360DeviceTag,"Search cancelled")
    }

    private fun getDateFromString(date:String):Date{
        return SimpleDateFormat("yyyy-MM-dd").parse(date)
    }

    private fun convertToDate(time:TimeData):Date{
        return Calendar.getInstance().apply {
            set(Calendar.YEAR,time.year)
            set(Calendar.MONTH,time.month-1)
            set(Calendar.DAY_OF_MONTH,time.day)
            set(Calendar.HOUR_OF_DAY,time.hour)
            set(Calendar.MINUTE,time.minute)
            set(Calendar.SECOND,time.second)
            set(Calendar.MILLISECOND,0)
        }.time
    }

}

class SingleRecord(val data: String, val measureTime: Date)