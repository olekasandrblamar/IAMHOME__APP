package com.cerashealth.ceras.lifeplus

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import android.content.Context
import android.text.TextUtils
import android.util.Log
import com.cerashealth.ceras.MainActivity
import com.cerashealth.ceras.lifeplus.data.*
import com.google.gson.Gson
import com.walnutin.HeartRateAdditional
import com.walnutin.hardsdk.ProductList.sdk.GlobalValue
import com.walnutin.hardsdk.ProductList.sdk.HardSdk
import com.walnutin.hardsdk.ProductList.sdk.TimeUtil
import com.walnutin.hardsdk.ProductNeed.Jinterface.IHardScanCallback
import com.walnutin.hardsdk.ProductNeed.Jinterface.SimpleDeviceCallback
import com.walnutin.hardsdk.ProductNeed.entity.*
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.reactivex.Flowable
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.Disposable
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.io.File
import java.io.FileOutputStream
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit

class ConnectDeviceCallBack : SimpleDeviceCallback {

    private var retries = 1

    companion object{
        var currentCallBack:ConnectDeviceCallBack? = null
        var deviceId:String? = null
    }

    private val result: MethodChannel.Result
    private var deviceId: String? = null

    constructor(result: MethodChannel.Result) {
        this.result = result
    }

    override fun onCallbackResult(flag: Int, state: Boolean, obj: Any?) {
        super.onCallbackResult(flag, state, obj)
        if (flag == GlobalValue.CONNECTED_MSG) {
            Log.d(WatchDevice.TAG, "onCallbackResult: Connected")
            HardSdk.getInstance().stopScan()
//            currentCallBack?.let {
//                HardSdk.getInstance().removeHardSdkCallback(currentCallBack)
//            }
//            HardSdk.getInstance().reset()
            WatchDevice.initializeWatch()
        } else if (flag == GlobalValue.DISCONNECT_MSG) {
            Log.d(WatchDevice.TAG, "onCallbackResult: Disconnected")
            HardSdk.getInstance().startScan()
        } else if (flag == GlobalValue.CONNECT_TIME_OUT_MSG) {
            Log.d(WatchDevice.TAG, "onCallbackResult: Time out")
            //retry 3 times for disconnect
            if (retries < 2) {
                retries++
                Log.i(WatchDevice.TAG, "retrying scan")
                HardSdk.getInstance().stopScan()
                HardSdk.getInstance().startScan()
            } else {
                HardSdk.getInstance().stopScan()
                try {
                    result.success(ConnectionInfo.createResponse(message = "Timeout"))
                }catch (e: java.lang.Exception){
                    Log.e(WatchDevice.TAG, "Error while responding ", e)
                }
            }
        }
    }


}


class DataCallBack : SimpleDeviceCallback {
    private var result: MethodChannel.Result?

    private var batteryResult: MethodChannel.Result? = null

    private var batteryComplete = false
    private var versionComplete = false
    private var batteryPercentage = ""
    private var versionUpdate = false

    companion object{
        var currentVersion:String? = null
    }

    override fun equals(other: Any?): Boolean {
        other?.let {
            return it is DataCallBack
        }
        return false
    }

    override fun hashCode(): Int {
        return 0
    }

    constructor(result: MethodChannel.Result?) {
        this.result = result
    }

    fun updateVersionResult(result: MethodChannel.Result?){
        this.batteryResult = result
    }

    fun updateBatteryResult(result: MethodChannel.Result?){
        this.batteryResult = result
        this.batteryComplete = false
        this.versionComplete = false
        this.batteryPercentage = ""
        this.versionUpdate = false
    }

    fun updateResult(result: MethodChannel.Result?){
        this.result = result
    }

    private fun uploadTemperature(){
        Log.i(WatchDevice.TAG, "Getting temparature ")
        val prevDay = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 2)
        val today = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), -2)
        Log.d(WatchDevice.TAG, "Getting temp $prevDay to $today")
        val tempData = HardSdk.getInstance().getBodyTemperature(prevDay, today)
        val tempTimeFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
        val tempUploads = tempData.map {
            val celsius = it.temps
            val fahrenheit = (celsius*9/5)+32
            val measureTime = tempTimeFormat.parse(it.testMomentTime)
            val tempCal = Calendar.getInstance()
            tempCal.time = measureTime
            if(TimeZone.getDefault().inDaylightTime(tempCal.time))
                tempCal.add(Calendar.HOUR, -1)
//            Log.d(WatchDevice.TAG,"Time ${tempCal}")
            TemperatureUpload(measureTime = tempCal.time, deviceId = MainActivity.deviceId, celsius = celsius.toDouble(),
                fahrenheit = fahrenheit.toDouble(),
                userProfile = DataSync.getUserInfo())
        }
        DataSync.uploadTemperature(tempUploads.filter { it.celsius > 0 && it.measureTime.time > 10000 })
    }

    private fun uploadSteps(){
        val stepList = mutableListOf<StepUpload>()
        val dailySteps = mutableListOf<DailyStepUpload>()
        val calories = mutableListOf<CaloriesUpload>()
        val dateFormat = SimpleDateFormat("yyyy-MM-dd")
        //Last three days data
        (0..2).forEach {
            val beforeTime = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), it)
            val stepInfos = HardSdk.getInstance().queryOneDayStep(beforeTime)
            Log.i(WatchDevice.TAG, "step info ${Gson().toJson(stepInfos)}")
            if(stepInfos.dates!=null) {
                val startOfDate = dateFormat.parse(stepInfos.dates)
                dailySteps.add(DailyStepUpload(measureTime = startOfDate, deviceId = MainActivity.deviceId, steps = stepInfos.step, calories = stepInfos.calories, distance = stepInfos.distance))
                calories.add(CaloriesUpload(measureTime = startOfDate, deviceId = MainActivity.deviceId, calories = stepInfos.calories))
                stepInfos.stepOneHourInfo?.let {
                    stepList.addAll(stepInfos.stepOneHourInfo.map {
                        val measureTime = Calendar.getInstance()
                        measureTime.time = startOfDate
                        measureTime.add(Calendar.MINUTE, it.key)
                        StepUpload(measureTime = measureTime.time, deviceId = MainActivity.deviceId, steps = it.value)
                    })
                }
            }
        }
        if(stepList.isNotEmpty()) {
            //Upload the steps
            DataSync.uploadStepInfo(stepList)
        }
        if(calories.isNotEmpty())
            DataSync.uploadCalories(calories)
        if(dailySteps.isNotEmpty())
            DataSync.uploadDailySteps(dailySteps)

    }

    private fun checkAndSendStatusResponse(){
        if(this.batteryComplete && this.versionComplete) {
            try {
                batteryResult?.success(ConnectionInfo.createResponse(message = "Success", connected = true, deviceId = MainActivity.deviceId,
                        deviceName = "", additionalInfo = mapOf(), deviceType = "", batteryStatus = this.batteryPercentage, versionUpdate = this.versionUpdate))
                this.batteryResult = null
            } catch (ex: Exception) {
                Log.e(WatchDevice.TAG, "Error while sending response ", ex)
            }
        }
    }

    override fun onCallbackResult(flag: Int, state: Boolean, obj: Any?) {
        super.onCallbackResult(flag, state, obj)
        Log.d(WatchDevice.TAG, "onCallbackResult: ${flag}")
        if (flag == GlobalValue.BATTERY) {
            this.batteryComplete = true
            this.batteryPercentage = obj.toString()
            checkAndSendStatusResponse()
        }
        if (flag == GlobalValue.CONNECTED_MSG) {
            Log.d(WatchDevice.TAG, "onCallbackResult from sync: Connected ${HardSdk.getInstance().isDevConnected}")
            WatchDevice.initializeWatch()
            WatchDevice.syncData()
            try {
                result?.success("Load complete")
            }catch (ex:Exception){
                Log.e(WatchDevice.TAG,"Error after connecting")
            }
        } else if (flag == GlobalValue.DISCONNECT_MSG) {
            Log.d(WatchDevice.TAG, "onCallbackResult: Disconnected")
        } else if (flag == GlobalValue.CONNECT_TIME_OUT_MSG) {
            Log.d(WatchDevice.TAG, "onCallbackResult: Timeout")
        } else if (flag == GlobalValue.STEP_FINISH) {
            Log.i(WatchDevice.TAG, "onCallbackResult: Step finish")
            uploadSteps()
        } else if (flag == GlobalValue.OFFLINE_HEART_SYNC_OK) {
            Log.i(WatchDevice.TAG, "onCallbackResult: Offline heart sync")
            uploadBloodPressureInfo()
            //heart rate sync is complete
        } else if (flag == GlobalValue.SLEEP_SYNC_OK) {
            Log.i(WatchDevice.TAG, "onCallbackResult: Sleep Sync")
            val beforeTime = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 0)
            try {
                val sleepModel = HardSdk.getInstance().queryOneDaySleepInfo(beforeTime)
                Log.i(WatchDevice.TAG, "Got sleep info ${Gson().toJson(sleepModel)}")
            }catch (e: Exception){
                Log.e(WatchDevice.TAG, "Error getting sleep information", e)
            }
        } else if (flag == GlobalValue.OFFLINE_EXERCISE_SYNC_OK) {
            Log.d(WatchDevice.TAG, "onCallbackResult: Exercise Sync")
        } else if (flag == GlobalValue.SYNC_FINISH) {
            Log.d(WatchDevice.TAG, "onCallbackResult: Sync complete")

        } else if (flag == GlobalValue.Firmware_Version) {
            val existingVersion = obj as String
            Log.d(WatchDevice.TAG, "version $existingVersion")
            currentVersion = existingVersion
            versionComplete = true
            currentVersion?.let {
                if(it.toLowerCase().startsWith("sw07s_") && it!=WatchDevice.currentFirmwareVersion ){
                    Log.d(WatchDevice.TAG, "version update available")
                    versionUpdate = true
                }else if(it.toLowerCase().startsWith("sw07_") && it!=WatchDevice.sw07FirmwareVersion){
                    Log.d(WatchDevice.TAG, "version update available")
                    versionUpdate = true
                }
            }

            //Check and send response as version is updated
            checkAndSendStatusResponse()
            //HardSdk.getInstance().checkNewFirmware(existingVersion)
        } else if (flag == GlobalValue.Hardware_Version) {
        } else if (flag == GlobalValue.DISCOVERY_DEVICE_SHAKE) {
        } else if (flag == GlobalValue.Firmware_DownFile) {
        } else if (flag == GlobalValue.Firmware_Start_Upgrade) {
            Log.i(WatchDevice.TAG, "Firmware update")
        } else if (flag == GlobalValue.Firmware_Info_Error) {
            Log.i(WatchDevice.TAG, "Firmware info error")
        } else if (flag == GlobalValue.Firmware_Server_Status) {

        } else if (flag == GlobalValue.Firmware_Upgrade_Progress) {
            Log.i(WatchDevice.TAG, "Firmware update progress $obj ")
            //If the progress is complete
            if((obj as Int) == 100){
                WatchDevice.returnUpgradeMessage(BaseDevice.SUCCESS_STATUS,"Upgrade Complete",true)
            }else{
                WatchDevice.returnUpgradeMessage(BaseDevice.SUCCESS_STATUS,"Upgrade progress $obj %")
            }
        } else if (flag == GlobalValue.Firmware_Server_Failed) {
            Log.i(WatchDevice.TAG, "Firmware update failed ${obj as String}")
            WatchDevice.returnUpgradeMessage(BaseDevice.ERROR_STATUS,"Upgrade failed",true)
        } else if (flag == GlobalValue.READ_TEMP_FINISH_2) {
            val tempStatus = obj as TempStatus
            Log.i(WatchDevice.TAG, "temp ${Gson().toJson(tempStatus)}")
            if (tempStatus.downTime == 0) {
                WatchDevice.isTestingTemp = false
                val celsius = tempStatus.bodyTemperature
                val fahrenheit = (celsius*9/5)+32
                val upload = TemperatureUpload(measureTime = Calendar.getInstance().time,
                    deviceId = MainActivity.deviceId,
                    celsius = celsius.toDouble(),
                    fahrenheit = fahrenheit.toDouble(),
                    userProfile = DataSync.getUserInfo())
                DataSync.uploadTemperature(listOf(upload))
                WatchDevice.eventSink?.let {
                    it.success(Gson().toJson(mapOf("celsius" to celsius,"fahrenheit" to fahrenheit,"countDown" to 0)))
                    it.endOfStream()
                    WatchDevice.eventSink = null
                }
            }else{
                WatchDevice.eventSink?.let {
                    it.success(Gson().toJson(mapOf("countDown" to tempStatus.downTime)))
                }
            }
        } else if (flag == GlobalValue.READ_TEMP_FINISH) {
            val tempStatus = obj as TempStatus
            Log.i(WatchDevice.TAG, "temp ${Gson().toJson(tempStatus)}")
            if (tempStatus.downTime == 0) {

            }
        }else if (flag == GlobalValue.TEMP_HIGH) { //
        } else if (flag == GlobalValue.SYNC_BODY_FINISH) { //Body temperature complete
            Log.i(WatchDevice.TAG, "Sync Body finish")
            uploadTemperature()
        } else if (flag == GlobalValue.SYNC_WRIST_FINISH) { //
            Log.i(WatchDevice.TAG, "Wrist sync finished")
            Log.i(WatchDevice.TAG, "Sync Body finish")
            val prevDay = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 1)
            val today = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 0)
            Log.d(WatchDevice.TAG, "Getting wrist temp $prevDay to $today")
            val tempData = HardSdk.getInstance().getWristTemperature(prevDay, today)
            Log.d(WatchDevice.TAG, "Wrist Temperature data ${Gson().toJson(tempData)}")
        } else if (flag == GlobalValue.READ_ArmpitTemp) { // -273.15代表绝对0度 作为无效值
            val yewen = obj as Float
            if (!java.lang.Float.isNaN(yewen) && yewen > -273) {
            }
        } else if (flag == GlobalValue.uiFileListName) {
            if (obj == null) {
            } else {
                val uiList =
                        obj as List<String> // 如果要传ui，将对应缺少的ui集合文件 传给手环，步骤基本同传语言
            }
        } else if (flag == GlobalValue.PIC_TRANSF_FINISH) {
        } else if (flag == GlobalValue.PIC_TRANSF_START) {
        } else if (flag == GlobalValue.PIC_TRANSF_ING) {
        } else if (flag == GlobalValue.BLOODPRESUURE__STATUS){
            if(obj!=null){
                val bpValues = obj.toString()
                var diastolic = Integer.parseInt(bpValues.substring(0,2),16)
                var systolic = Integer.parseInt(bpValues.substring(2,4),16)

                DataSync.getUserInfo()?.let {
                    Log.d(WatchDevice.TAG,"Got profile ${it.offSets}")
                    systolic+=it.getOffsetValue(listOf("systolic"))
                    diastolic+=it.getOffsetValue(listOf("distolic","diastolic"))
                }

                Log.d(WatchDevice.TAG,"Got String $obj systolic  ${ Integer.parseInt(bpValues.substring(2,4),16)} to $systolic diastolic ${Integer.parseInt(bpValues.substring(0,2),16)} $diastolic")
                HardSdk.getInstance().setBloodPressureAndHeart(systolic,diastolic,0)

            }

        }
    }

    private fun uploadBloodPressureInfo(){
        Log.i(WatchDevice.TAG, "Uploading blood pressure")
        val tempTimeFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
        val bloodPressureUpload = mutableListOf<BpUpload>()
        val oxygenLevels = mutableListOf<OxygenLevelUpload>()
        val heartRates = mutableListOf<HeartRateUpload>()
        val userInfo = DataSync.getUserInfo()
        val gender = if(userInfo?.sex?.toLowerCase()=="male") 0 else 1
        (0..2).forEach {
            val beforeTime = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), it)
            Log.i(WatchDevice.TAG, "Loading BP info")
            try {
                HardSdk.getInstance().queryOneDayBP(beforeTime).forEach {
                    try {
                        val heartRateAdditional = HeartRateAdditional(
                                TimeUtil.detaiTimeToStamp(it.testMomentTime) / 1000,
                                it.currentRate,
                                userInfo?.heightInCm ?: 162,
                                userInfo?.weightInKgs?.toInt() ?: 56,
                                gender,
                                userInfo?.age ?: 30
                        )
                        val measureTime = tempTimeFormat.parse(it.testMomentTime)
                        Log.d(WatchDevice.TAG, "Heart Time ${measureTime}")
                        bloodPressureUpload.add(BpUpload(measureTime = measureTime, systolic = heartRateAdditional._systolic_blood_pressure, distolic = heartRateAdditional._diastolic_blood_pressure, deviceId = MainActivity.deviceId))
                        heartRates.add(HeartRateUpload(measureTime = measureTime, deviceId = MainActivity.deviceId, heartRate = it.currentRate))
                        oxygenLevels.add(OxygenLevelUpload(measureTime = measureTime, deviceId = MainActivity.deviceId, oxygenLevel = heartRateAdditional._blood_oxygen))
                    } catch (e: ParseException) {
                        Log.i(WatchDevice.TAG, "Error populating watch ingo")
                    }
                }
            }catch (e: Exception){
                Log.i(WatchDevice.TAG, "Error while  quering BP info", e)
            }
        }
        if(bloodPressureUpload.isNotEmpty())
            DataSync.uploadBloodPressure(bloodPressureUpload.filter { it.distolic != 0 && it.measureTime.time > 10000 })
        if(heartRates.isNotEmpty())
            DataSync.uploadHeartRate(heartRates.filter { it.heartRate > 0 && it.measureTime.time > 1000 })
        if(oxygenLevels.isNotEmpty())
            DataSync.uploadOxygenData(oxygenLevels.filter { it.oxygenLevel > 0 && it.measureTime.time > 10000 })
    }

    override fun onStepChanged(
            step: Int,
            distance: Float,
            calories: Int,
            finish_status: Boolean
    ) {
        Log.d(WatchDevice.TAG, "onStepChanged: step:$step")
    }

    override fun onBloodPressureChanged(p0: Int, p1: Int, p2: Int) {
        Log.d(WatchDevice.TAG,"Blood pressure changed $p0 $p1 $p2")
    }

    override fun onHeartRateChanged(rate: Int, status: Int) {
        super.onHeartRateChanged(rate, status)
        Log.d(WatchDevice.TAG, "onHeartRateChanged: status:$status rate $rate")
        if (WatchDevice.isTestingHeart) {
            if (status == GlobalValue.RATE_TEST_FINISH || status == GlobalValue.RATE_TEST_INTERRUPT) {
                WatchDevice.isTestingHeart = false
                HardSdk.getInstance().stopRateTest()
                val hrUpload = HeartRateUpload(measureTime = Calendar.getInstance().time,heartRate= rate,deviceId = MainActivity.deviceId)
                DataSync.uploadHeartRate(listOf(hrUpload))
                WatchDevice.eventSink?.let {
                    it.success(Gson().toJson(mapOf("heartRate" to rate,"countDown" to 0)))
                    it.endOfStream()
                    WatchDevice.eventSink = null
                }
                Log.d(WatchDevice.TAG, "Heart rate finished")
            }else{
                if(rate!=0) {
                    Log.d(WatchDevice.TAG,"heart rate status $status rate $rate")
                    WatchDevice.eventSink?.let {
                        it.success(Gson().toJson(mapOf("heartRate" to rate, "countDown" to status)))
                    }
                }
            }
        }
            else if (WatchDevice.isTestingOxygen) {
                val userInfo = DataSync.getUserInfo()
                if(userInfo != null) {
                    userInfo?.let { userProfile ->
                        val heartRateAdditional = HeartRateAdditional(
                                System.currentTimeMillis() / 1000,
                                rate,
                                userProfile.heightInCm,
                                userProfile.weightInKgs.toInt(),
                                if (userInfo?.sex?.toLowerCase() == "female") GlobalValue.SEX_GIRL else GlobalValue.SEX_BOY,
                                userProfile.age
                        )
                        val oxygen = heartRateAdditional.get_blood_oxygen()
                        if (status == GlobalValue.RATE_TEST_FINISH || status == GlobalValue.RATE_TEST_INTERRUPT) {
                            WatchDevice.isTestingOxygen = false
                            HardSdk.getInstance().stopOxygenMeasure(oxygen)
                            WatchDevice.eventSink?.let {
                                val oxygenUpload = OxygenLevelUpload(measureTime = Calendar.getInstance().time,deviceId = MainActivity.deviceId,oxygenLevel = oxygen,userProfile = userProfile)
                                DataSync.uploadOxygenData(listOf(oxygenUpload))
                                it.success(Gson().toJson(mapOf("oxygenLevel" to oxygen, "countDown" to status)))
                                it.endOfStream()
                            }
                        }else{
                            Log.d(WatchDevice.TAG,"oxygen status $status rate $rate")
                            WatchDevice.eventSink?.let {
                                it.success(Gson().toJson(mapOf("oxygenLevel" to oxygen, "countDown" to status)))
                            }
                        }
                    }
                }else{
                    WatchDevice.isTestingOxygen = false
                    HardSdk.getInstance().stopOxygenMeasure(0)
                    WatchDevice.eventSink?.let {
                        it.success(Gson().toJson(mapOf("oxygenLevel" to 0, "countDown" to 0)))
                        it.endOfStream()
                    }
                }

            }
          else if (WatchDevice.isTestingBp) {
            //val userInfo = DataSync.getUserInfo()
            val userInfo = UserProfile().apply {
                heightInCm = 180
                weightInKgs = 80.0
                sex = "male"
                age = 37

            }
            if(userInfo != null) {
                val heartRateAdditional = HeartRateAdditional(
                        System.currentTimeMillis() / 1000,
                        rate,
                        userInfo.heightInCm,
                        userInfo.weightInKgs.toInt(),
                        if (userInfo.sex.toLowerCase() == "female") GlobalValue.SEX_GIRL else GlobalValue.SEX_BOY,
                        userInfo.age
                )
                val bloodPressure = BloodPressure()
                bloodPressure.systolicPressure = heartRateAdditional.get_systolic_blood_pressure() - 20
                bloodPressure.diastolicPressure = heartRateAdditional.get_diastolic_blood_pressure() - 5

                Log.i(WatchDevice.TAG,"writing blood pressure systolic ${bloodPressure.systolicPressure} diastolic ${bloodPressure.diastolicPressure}")
                if (status == GlobalValue.RATE_TEST_FINISH || status == GlobalValue.RATE_TEST_INTERRUPT) {
                    val bpUpload = BpUpload(measureTime = Calendar.getInstance().time,systolic = bloodPressure.systolicPressure,
                            distolic = bloodPressure.diastolicPressure,userProfile = userInfo,deviceId = MainActivity.deviceId)
                    DataSync.uploadBloodPressure(listOf(bpUpload))
                    WatchDevice.isTestingBp = false
                    HardSdk.getInstance().stopBpMeasure(bloodPressure)
                    WatchDevice.eventSink?.let {
                        it.success(Gson().toJson(mapOf("systolic" to bpUpload.systolic, "diastolic" to bpUpload.distolic, "countDown" to 0)))
                        it.endOfStream()
                    }
                }else{
                    Log.d(WatchDevice.TAG,"Bp status $status rate $rate")
                    WatchDevice.eventSink?.success(Gson().toJson(mapOf("systolic" to bloodPressure.systolicPressure, "diastolic" to bloodPressure.diastolicPressure, "countDown" to 0)))
                }
            }else{
                WatchDevice.isTestingBp = false
                HardSdk.getInstance().stopBpMeasure(BloodPressure().apply {
                    diastolicPressure = 0
                    systolicPressure = 0
                })
                WatchDevice.eventSink?.let {
                    it.success(Gson().toJson(mapOf("systolic" to 0,"diastolic" to 0, "countDown" to 0)))
                    it.endOfStream()
                }
            }

        }
    }
}

class WatchDevice:BaseDevice()     {

    companion object {
        var isTestingHeart = false
        var isTestingBp = false
        var isTestingOxygen = false
        val TAG = WatchDevice::class.java.simpleName
        var dataCallback: DataCallBack? = null
        var eventSink:EventChannel.EventSink? = null
        var upgradeSink:EventChannel.EventSink? = null
        var isTestingTemp = false
        var tempUpdates:Disposable? = null
        const val currentFirmwareVersion = "SW07s_2.56.00_210423"
        const val sw07FirmwareVersion = "SW07s_2.45.00_200925"

        fun syncProfile(){
            val userInfo = DataSync.getUserInfo()
            val gender = if(userInfo?.sex?.toLowerCase(Locale.ROOT) == "female") GlobalValue.SEX_GIRL else GlobalValue.SEX_BOY
            val age = userInfo?.age?:32
            val weightInKgs = userInfo?.weightInKgs?.toInt()?:80
            val height = userInfo?.heightInCm?:178

            HardSdk.getInstance().setTimeUnitAndUserProfile(true, true, gender, age, weightInKgs, height, 140, 90, 180)
        }

        fun initializeWatch(){
            syncProfile()
            HardSdk.getInstance().setTimeAndClock()
            //Set weather to celsius
            HardSdk.getInstance().setWeatherType(true, GlobalValue.Unit_Fahrenheit)
            //Set the auto health test to true
            HardSdk.getInstance().setAutoHealthTest(true)
            HardSdk.getInstance().bindNotice()
        }

        @Synchronized
        fun syncData(){
            try {
                dataCallback?.let {
                    HardSdk.getInstance().syncLatestBodyTemperature(0)
                    HardSdk.getInstance().syncLatestWristTemperature(0)
                    HardSdk.getInstance().syncHeartRateData(0)
                    HardSdk.getInstance().syncExerciseData(0)
                    HardSdk.getInstance().syncStepData(0)
                    HardSdk.getInstance().syncSleepData(0)
                }
                DataSync.loadWeatherInfo(WATCH_DEVICE)
            }catch (ex: Exception){
                Log.e(TAG, "Error while syncing data", ex)
            }
        }

        fun returnUpgradeMessage(status:String,message:String,isComplete:Boolean = false){
            upgradeSink?.let{
                it.success(Gson().toJson(mapOf("status" to status,"message" to message)))
                if(isComplete)
                    it.endOfStream()
            }
        }

    }

    override fun readDataFromDevice(eventSink: EventChannel.EventSink, readingType: String) {
        when(readingType){
            "TEMPERATURE" -> {
                if (HardSdk.getInstance().isDevConnected) {
                    WatchDevice.eventSink = eventSink
                    Log.d(TAG,"Reading temperature")
                    HardSdk.getInstance().enterTempMeasure()
                    isTestingTemp = true
                    tempUpdates = Flowable.interval(1, 1, TimeUnit.SECONDS).observeOn(AndroidSchedulers.mainThread())
                            .subscribe { v: Long? ->
                                if(isTestingTemp)
                                    HardSdk.getInstance().readTempValue()
                                else {
                                    Log.d(TAG,"Disposing the observable")
                                    tempUpdates?.dispose()
                                }
                                Log.d(TAG,"Inside the temp observable")
                            }

                } else {
                    eventSink.endOfStream()
                }
            }
            "HR" -> {
                if(HardSdk.getInstance().isDevConnected){
                    WatchDevice.eventSink = eventSink
                    isTestingHeart = true
                    Log.d(TAG,"Reading Heart rate")
                    HardSdk.getInstance().startRateTest()
                }else
                    eventSink.endOfStream()
            }
            "BP" -> {
                if(HardSdk.getInstance().isDevConnected){
                    WatchDevice.eventSink = eventSink
                    isTestingBp = true
                    Log.d(TAG,"Reading BP rate")
                    HardSdk.getInstance().startRateTest()
                }else
                    eventSink.endOfStream()
            }
            "O2" -> {
                if(HardSdk.getInstance().isDevConnected){
                    WatchDevice.eventSink = eventSink
                    isTestingOxygen = true
                    Log.d(TAG,"Reading Oxygen rate")
                    HardSdk.getInstance().startRateTest()
                }else
                    eventSink.endOfStream()
            }
            else -> eventSink.endOfStream()
        }
    }

    override fun disconnectDevice(result: MethodChannel.Result?,deviceId:String?) {
        if(HardSdk.getInstance().isDevConnected) {
            Log.i(TAG, "Device is connected and disconnecting it")
            HardSdk.getInstance().restoreFactoryMode()
            HardSdk.getInstance().reset()
            HardSdk.getInstance().disconnect()
        }
        result?.success("Success")
    }

    override fun syncWeather(weatherList: List<WeatherInfo>) {
        if(HardSdk.getInstance().isDevConnected){
            Log.i(TAG, "Sending weather to the watch device")
            var index = 0
            val updatedWeatherList = weatherList.map { weatherInfo ->
                val cal = Calendar.getInstance()
                cal.timeInMillis = weatherInfo.utcMillis*1000
                Weather().apply {
                    high = weatherInfo.maxTemp.toInt().toFloat()
                    low = weatherInfo.minTemp.toInt().toFloat()
                    serial = index++
                    humidity = 10
                    isDaisan = 0
                    type = when(weatherInfo.weatherType){
                        WeatherType.CLOUD -> 2
                        WeatherType.SUNNY -> 1
                        WeatherType.SNOW -> 4
                        WeatherType.RAIN -> 3
                        WeatherType.THUNDER -> 6
                        else -> 0
                    }
                    time = TimeUtil.getformatData(cal.time)
                }
            }.filter { it.serial<5 }.toMutableList()

            updatedWeatherList.forEach{
                Log.d(TAG, "Sending weather for ${it.time} with max ${it.high} and low ${it.low} and type ${it.type}")
            }

            HardSdk.getInstance().setWeatherList(updatedWeatherList)
            HardSdk.getInstance().setWeatherType(true, GlobalValue.Unit_Fahrenheit)
        }
    }


    override fun connectDevice(context: Context, result: MethodChannel.Result, deviceId: String?) {
        HardSdk.getInstance().init(context)
        val watchDataCallBack = WatchDataCallBack(context, result, deviceId)
        WatchDataCallBack.deviceName = null
        WatchDataCallBack.deviceAddr = null
        HardSdk.getInstance().setHardScanCallback(watchDataCallBack)
        ConnectDeviceCallBack.currentCallBack = ConnectDeviceCallBack(result)
        HardSdk.getInstance().setHardSdkCallback(ConnectDeviceCallBack.currentCallBack)
        if (HardSdk.getInstance().isBleEnabled) {
            HardSdk.getInstance().startScan()
            GlobalScope.launch {
                delay(25000)
                Log.d(TAG, "Unable to find device ${watchDataCallBack.deviceConnected}")
                watchDataCallBack.stopScanning()
                if(!watchDataCallBack.deviceConnected)
                    MainActivity.currentActivity?.runOnUiThread {
                        result.success(ConnectionInfo.createResponse(message = "Failed", connected = false, deviceFound = watchDataCallBack.deviceFound))
                    }
            }
        }
    }

    //Sync the data from watch
    //This needs to be called in background from time to time
    override fun syncData(result: MethodChannel.Result?, connectionInfo: ConnectionInfo, context: Context){
        Log.i(TAG, "Calling sync data")
        DataSync.CURRENT_MAC_ADDRESS = connectionInfo.deviceId
        DataSync.sendHeartBeat(HeartBeat(macAddress = connectionInfo.deviceId, deviceId = connectionInfo.deviceName))
        Log.i(TAG, "Is device connected ${HardSdk.getInstance().isDevConnected}")
        if(dataCallback==null) {
            dataCallback = DataCallBack(result)
            //Load the data from device
        }
        var returnValue = true
        //If the device is not connected  try to connect
        if(!HardSdk.getInstance().isDevConnected &&
                !HardSdk.getInstance().isConnecting){
            Log.i(TAG, "Re-Connecting from sync data")
            dataCallback?.updateResult(result)
            HardSdk.getInstance().init(context)
            returnValue = false
            HardSdk.getInstance().setHardSdkCallback(dataCallback)
            HardSdk.getInstance().bindBracelet(
                    connectionInfo.additionalInformation["factoryName"],
                    connectionInfo.deviceName,
                    connectionInfo.deviceId
            )
//            connectDevice(context,result!!,connectionInfo.deviceId);
        }else if(!HardSdk.getInstance().isSyncing && HardSdk.getInstance().isDevConnected){ //If the data is not syncing
            HardSdk.getInstance().setHardSdkCallback(dataCallback)
            Log.i(TAG, "Data sync complete")
            returnValue = false
            result?.success("Load complete")
            syncProfile()
            syncData()
        }
        if(returnValue)
            result?.success("Load complete")
    }

    override fun getConnectionStatus(result: MethodChannel.Result?, connectionInfo: ConnectionInfo, context: Context) {
        result?.success(HardSdk.getInstance().isDevConnected)
    }

    override fun upgradeDevice(eventSink: EventChannel.EventSink?, connectionInfo: ConnectionInfo, context: Context) {
        val connectionStatus = HardSdk.getInstance().isDevConnected
        Log.i(TAG, "Getting device information $connectionStatus")
        try {
            if(connectionStatus){
                upgradeSink = eventSink
                MainActivity.currentActivity?.let {
                    Log.i(TAG,"current version ${DataCallBack.currentVersion}")
                    val fileName = if(DataCallBack.currentVersion!!.toLowerCase().startsWith("sw07s_")) "sw07s_2_56_00_210423" else "sw07s_2_45_00_200925"
                    Log.i(TAG,"Updating with file name $fileName")
                    val binPackage = it.resources.getIdentifier(fileName,"raw",it.packageName)
                    val packageStream = it.resources.openRawResource(binPackage)
                    val tempFile = File.createTempFile(fileName, "bin")
                    val out = FileOutputStream(tempFile)

                    val buffer = ByteArray(1024)
                    var read: Int
                    while (packageStream.read(buffer).also { read = it } != -1) {
                        out.write(buffer, 0, read)
                    }
                    Log.d(TAG , "Got file size ${tempFile.length()}")
                    HardSdk.getInstance().startFirmWareUpgrade(tempFile)
                }
            }else{
                returnUpgradeMessage("error","Error while upgrading. Device not connected")
            }
        }catch(ex:Exception){
            Log.e(TAG,"Error while upgrading device ",ex)
            returnUpgradeMessage("error","Error while upgrading")
        }

    }

    override fun getDeviceInfo(result: MethodChannel.Result?, connectionInfo: ConnectionInfo, context: Context) {
        val connectionStatus = HardSdk.getInstance().isDevConnected
        Log.i(TAG, "Getting device information $connectionStatus")
        if(!connectionStatus && !HardSdk.getInstance().isConnecting){
            DataSync.CURRENT_MAC_ADDRESS = connectionInfo.deviceId
            HardSdk.getInstance().init(context)
            HardSdk.getInstance().bindBracelet(
                    connectionInfo.additionalInformation["factoryName"],
                    connectionInfo.deviceName,
                    connectionInfo.deviceId
            )
        }
        //If the device is connected and not syncing
        if(connectionStatus){
            dataCallback?.updateBatteryResult(result)
            HardSdk.getInstance().findBattery()
            HardSdk.getInstance().queryFirmVesion()
        }else{
            //If it is not connected or it is syncing send the status
            sendConnectionResponse(connectionInfo.deviceId, connectionStatus, result)
        }
    }
}

class WatchDataCallBack : IHardScanCallback {

    private var context: Context? = null

    private val result: MethodChannel.Result?

    private var deviceId:String? = null

    var deviceFound = false

    var deviceConnected = false

    constructor(context: Context, result: MethodChannel.Result) {
        this.context = context
        this.result = result
    }

    constructor(context: Context, result: MethodChannel.Result, deviceId: String?) {
        this.context = context
        this.result = result
        this.deviceId = deviceId
    }

    companion object {
        private val TAG = WatchDataCallBack::class.java.simpleName
        var deviceName: String? = null
        var deviceAddr: String? = null
        var targetDevice: Device? = null

        fun byteArrHexToString(bytes: ByteArray?): String {
            var ret = ""
            bytes?.forEach {
                ret += String.format("%02X", it)
            }
            return ret.toUpperCase()
        }

    }

    private fun byteArrToShort(b: ByteArray, index: Int): Int {
        return (b[index + 0].toInt() shl 8 or b[index + 1].toInt() and 0xff)
    }

    private fun byteArrToShort(b: ByteArray): Int {
        return byteArrToShort(b, 0)
    }

    private fun reverseHexHighTwoLow(value: String): String {
        val sbf = StringBuffer()
        var j = 0
        for (i in 0 until value.length / 2) {
            sbf.insert(0, value.substring(j, j + 2))
            j += 2
        }
        return sbf.toString()
    }

    @Throws(IllegalArgumentException::class)
    fun hex2byte(hex: String): ByteArray {
        require(hex.length % 2 == 0)
        val arr = hex.toCharArray()
        val b = ByteArray(hex.length / 2)
        var i = 0
        var j = 0
        val l = hex.length
        while (i < l) {
            val swap = "" + arr[i++] + arr[i]
            val byteint = swap.toInt(16) and 0xFF
            b[j] = byteint.toByte()
            i++
            j++
        }
        return b
    }

    @SuppressLint("MissingPermission")
    override fun onFindDevice(device: BluetoothDevice, rssi: Int, factoryNameByUUID: String?, scanRecord: ByteArray?) {
        val value: String = byteArrHexToString(scanRecord) //byte转成字符串
        Log.d(TAG, "Found ${device.name}")
        val wan: Int = byteArrToShort(
                hex2byte(
                        reverseHexHighTwoLow(value.substring(22, 26))
                )
        )
        val connState = value.substring(26, 28)
        deviceFound = true
        var connect = true
        deviceId?.let { enteredDeviceId->
            connect = false
            Log.d(TAG, "entered device id $enteredDeviceId with $device.address")
            val lastFour = device.address.substring(device.address.length - 5).replace(":", "")
            Log.d(TAG, "entered device id $enteredDeviceId with $deviceAddr with last four $lastFour")
            if(lastFour.equals(enteredDeviceId, ignoreCase = true)){
                Log.d(TAG, "values matched matched")
                connect = true
            }
        }
        if (!TextUtils.isEmpty(device.name) && deviceName == null && connect) {
            Log.d(TAG, "Found device ${device.name}")
            deviceName = device.name
            deviceAddr = device.address
            targetDevice = Device(
                    factoryNameByUUID,
                    device.name,
                    device.address,
                    rssi
            )
            HardSdk.getInstance().stopScan()
            HardSdk.getInstance().bindBracelet(
                    targetDevice?.factoryName,
                    deviceName!!,
                    deviceAddr!!
            )
            DataSync.CURRENT_MAC_ADDRESS = deviceAddr
            Log.d(TAG, "Got data $factoryNameByUUID device ${device.name} address ${device.address}")
            stopScanning()
            deviceConnected = true
            result?.let {
                try {
                    result.success(ConnectionInfo.createResponse(message = "Connected", connected = true, deviceId = deviceAddr, deviceName = deviceName,
                            additionalInfo = mapOf("factoryName" to targetDevice!!.factoryName), deviceType = BaseDevice.WATCH_DEVICE, deviceFound = deviceFound))
                }catch (ex: Exception){
                    Log.e(TAG, "Error while sending response ", ex)
                }
            }
        }
        if (deviceName != null) {
            HardSdk.getInstance().stopScan()
        }
    }

    fun stopScanning() {
        HardSdk.getInstance().stopScan()
        HardSdk.getInstance().removeHardScanCallback(this)
    }
}