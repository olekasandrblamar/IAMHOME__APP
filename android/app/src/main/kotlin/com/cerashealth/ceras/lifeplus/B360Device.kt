package com.cerashealth.ceras.lifeplus

import android.content.Context
import android.util.Log
import com.cerashealth.ceras.lifeplus.data.*
import com.google.gson.Gson
import com.inuker.bluetooth.library.Code
import com.inuker.bluetooth.library.Constants.*
import com.inuker.bluetooth.library.search.SearchResult
import com.inuker.bluetooth.library.search.response.SearchResponse
import com.veepoo.protocol.VPOperateManager
import com.veepoo.protocol.listener.base.IABleConnectStatusListener
import com.veepoo.protocol.listener.data.*
import com.veepoo.protocol.model.datas.*
import com.veepoo.protocol.model.enums.*
import com.veepoo.protocol.model.settings.CustomSetting
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
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
        private var lastReading:Date = Calendar.getInstance().time

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
        if(!connectionListenerConfigured){
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
        getManager(context).startScanDevice(this)
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

    override fun getConnectionStatus(
        result: MethodChannel.Result?,
        connectionInfo: ConnectionInfo,
        context: Context
    ) {
        result?.success(getManager(context).isNetworkConnected(context))
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
                Log.d(B360DeviceTag, "Device not connected, reconnecting")
                reConnectDevice(connectionInfo.deviceId, connectionInfo.deviceName) {
                    if (it == Code.REQUEST_SUCCESS) {
                        Log.d(B360DeviceTag, "Device connection success")
                        confirmPasswd {
                            syncUserInfo {
                                connectionInfo.connected = manager.isNetworkConnected(context)
                                Log.d(B360DeviceTag, "Getting battery status")
                                getBatteryInfo(connectionInfo) {
                                    Log.d(
                                        B360DeviceTag,
                                        "Got battery status ${connectionInfo.batteryStatus}"
                                    )
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
                    } else {
                        Log.d(B360DeviceTag, "Device connection failure")
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

            } else {
                Log.d(B360DeviceTag, "Device already connected")
                connectionInfo.connected = manager.isNetworkConnected(context)
                getBatteryInfo(connectionInfo) {
                    Log.d(B360DeviceTag, "Got battery status ${connectionInfo.batteryStatus}")
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
                result?.success(ConnectionInfo.createResponse(deviceName = connectionInfo.deviceName,
                    deviceId = connectionInfo.deviceId,connected = true,deviceType = connectionInfo.deviceType))
            }else{
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
        vManager?.connectDevice(deviceId,deviceName, { code, bleGattProfile, isOadModel ->
            Log.i(B360DeviceTag,"Got code $code oadModel $isOadModel")
        }, {resp->
            Log.i(B360DeviceTag,"Got connect response $resp")
            callBack(resp)
        })
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

            override fun onSleepDataChange(dataChange: SleepData?) {
                Log.i(B360DeviceTag,"Sleep data ${Gson().toJson(dataChange)}")
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

        },3)

    }

    private fun readDataFromDevice(){
        val fiveMinutesAgo = Calendar.getInstance().apply { add(Calendar.MINUTE,-5) }.time
        if(!reading || lastReading.before(fiveMinutesAgo)) {
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

                override fun onReadOriginProgressDetail(
                    day: Int,
                    date: String?,
                    allPackage: Int,
                    currentPackage: Int
                ) {
                    //Log.i(B360DeviceTag,"Day $day Date $date allPackage $allPackage currentPackage $currentPackage")
                }

                override fun onReadOriginProgress(progress: Float) {
                    Log.i(B360DeviceTag, "Origin Progress $progress")
                }

                override fun onReadOriginComplete() {
                    Log.i(B360DeviceTag, "Read complete")
                    reading = false
                    Log.d(B360DeviceTag, "Uploading bp $bpUploads")

                    DataSync.uploadBloodPressure(bpUploads)
                    Log.d(B360DeviceTag, "Uploading Daily steps $dailyStepUploads")
                    DataSync.uploadDailySteps(dailyStepUploads.filter { it.steps > 0 })
                    Log.d(B360DeviceTag, "Uploading steps $stepUploads")
                    DataSync.uploadStepInfo(stepUploads)
                    Log.d(B360DeviceTag, "Uploading HR $heartUploads")
                    DataSync.uploadHeartRate(heartUploads)
                    Log.d(B360DeviceTag, "Uploading o2 $o2Uploads")
                    DataSync.uploadOxygenData(o2Uploads)
                }

                override fun onOriginFiveMinuteListDataChange(originDataList: MutableList<OriginData3>?) {
                    //Log.i(B360DeviceTag,"Five minute data $originDataList")
//                    originDataList?.forEach {
//                        Log.i(B360DeviceTag,"Got data $it")
//                    }
                }

                override fun onOriginHalfHourDataChange(halfHourData: OriginHalfHourData?) {
                    //Log.i(B360DeviceTag,"Half hour data $halfHourData")
                    halfHourData?.halfHourBps?.map {
                        Log.i(
                            B360DeviceTag,
                            "${it.date}, ${it.time} - ${it.highValue} - ${it.lowValue}"
                        )
                        BpUpload(
                            measureTime = convertToDate(it.time),
                            systolic = it.highValue, distolic = it.lowValue,
                            deviceId = connectionInfo?.deviceId!!,
                            userProfile = DataSync.getUserInfo()
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
                            userProfile = DataSync.getUserInfo()
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
                            userProfile = DataSync.getUserInfo(),
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
                                        userProfile = DataSync.getUserInfo()
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
            }, 3)
        }

    }

    private fun syncData(){
        Log.i(B360DeviceTag,"Is network connected")
        readDataFromDevice()
//        readHealthData()
    }

    private fun configureDevice(callBack: () -> Unit = {}){
        vManager?.changeCustomSetting({
        },{
            Log.i(B360DeviceTag,"Custom setting Data ")
            DataSync.sendHeartBeat(HeartBeat(macAddress = connectionInfo?.deviceId, deviceId = connectionInfo?.deviceName))
            syncUserInfo(callBack)
        }, CustomSetting(false,false,false,true,true).apply {
            temperatureUnit = ETemperatureUnit.FAHRENHEIT
        })
    }

    private fun syncUserInfo(callBack: () -> Unit = {}){
        val userInfo = DataSync.getUserInfo()
        if(userInfo!=null){
            vManager?.syncPersonInfo({
                Log.i(B360DeviceTag,"Status response $it")
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
    }

    override fun onDeviceFounded(searchResult: SearchResult?) {
        searchResult?.let {sResult->
            val lastFour = sResult.address.substring(sResult.address.length - 5).replace(":", "")
            Log.i(B360DeviceTag,"Found last found $lastFour compared to $deviceId")
            if(lastFour == deviceId){
                deviceFound = true
                vManager?.stopScanDevice()
                vManager?.connectDevice(sResult.address,sResult.name, { code, bleGattProfile, isOadModel ->
                    Log.i(B360DeviceTag,"Got code $code oadModel $isOadModel")
                }, {resp->
                    Log.i(B360DeviceTag,"Got connect response $resp")
                    if(resp== Code.REQUEST_SUCCESS){
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
        vManager?.confirmDevicePwd({
            Log.i(B360DeviceTag,"Password write response ${Gson().toJson(it)}")

        }, {
            Log.i(B360DeviceTag,"pwd data ${it.deviceNumber} - ${it.deviceVersion} - ${it.getmStatus()}")
            if(it.getmStatus() == EPwdStatus.CHECK_AND_TIME_SUCCESS){
                Thread.sleep(1000)
                callBack()
            }
        },
            {
                Log.i(B360DeviceTag,"Function listener ${it.bp} = ${it.heartDetect} ${it.hrvFunction}")
            },object: ISocialMsgDataListener{
                override fun onSocialMsgSupportDataChange(msgData: FunctionSocailMsgData?) {
                    Log.i(B360DeviceTag,"Message Data $msgData")
                }
                override fun onSocialMsgSupportDataChange2(msgData: FunctionSocailMsgData?) {
                    Log.i(B360DeviceTag,"Message Data 2 $msgData")
                }

            },"0000",false)

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