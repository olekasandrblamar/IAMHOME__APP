package com.cerashealth.ceras.lifeplus

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import android.content.Context
import android.text.TextUtils
import android.util.Log
import com.cerashealth.ceras.*
import com.cerashealth.ceras.lifeplus.data.*
import com.google.gson.Gson
import com.walnutin.HeartRateAdditional
import com.walnutin.hardsdk.ProductList.sdk.GlobalValue
import com.walnutin.hardsdk.ProductList.sdk.HardSdk
import com.walnutin.hardsdk.ProductList.sdk.TimeUtil
import com.walnutin.hardsdk.ProductNeed.Jinterface.IHardScanCallback
import com.walnutin.hardsdk.ProductNeed.Jinterface.SimpleDeviceCallback
import com.walnutin.hardsdk.ProductNeed.entity.*
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*

class ConnectDeviceCallBack : SimpleDeviceCallback {

    private var retries = 1;

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
            currentCallBack?.let {
                HardSdk.getInstance().removeHardSdkCallback(currentCallBack)
            }
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
                Log.i(WatchDevice.TAG,"retrying scan")
                HardSdk.getInstance().stopScan()
                HardSdk.getInstance().startScan()
            } else {
                HardSdk.getInstance().stopScan()
                result.success(ConnectionInfo.createResponse(message = "Timeout"))
            }
        }
    }


}

class DataCallBack : SimpleDeviceCallback {
    private var result: MethodChannel.Result?

    @get:Synchronized @set:Synchronized
    var callCount = 0;

    constructor(result: MethodChannel.Result?) {
        this.result = result
    }

    fun updateResult(result: MethodChannel.Result?){
        this.result = result
    }

    private fun uploadTemperature(){
        Log.i(WatchDevice.TAG,"Getting temparature ")
        val prevDay = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 2)
        val today = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), -2)
        Log.d(WatchDevice.TAG,"Getting temp $prevDay to $today")
        val tempData = HardSdk.getInstance().getBodyTemperature(prevDay,today)
        val tempTimeFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
        val tempUploads = tempData.map {
            val celsius = it.temps
            val fahrenheit = (celsius*9/5)+32
            val measureTime = tempTimeFormat.parse(it.testMomentTime)
            val tempCal = Calendar.getInstance()
            tempCal.time = measureTime
            if(TimeZone.getDefault().inDaylightTime(tempCal.time))
                tempCal.add(Calendar.HOUR,-1)
//            Log.d(WatchDevice.TAG,"Time ${tempCal}")
            TemperatureUpload(measureTime = tempCal.time,deviceId = MainActivity.deviceId,celsius = celsius.toDouble(),fahrenheit = fahrenheit.toDouble())
        }
        DataSync.uploadTemperature(tempUploads)
    }

    private fun uploadSteps(){
        val stepList = mutableListOf<StepUpload>()
        val dailySteps = mutableListOf<DailyStepUpload>()
        val calories = mutableListOf<CaloriesUpload>()
        val dateFormat = SimpleDateFormat("yyyy-MM-dd")
        //Last three days data
        (0..2).forEach {
            val beforeTime = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), it);
            val stepInfos = HardSdk.getInstance().queryOneDayStep(beforeTime)
            Log.i(WatchDevice.TAG,"step info ${Gson().toJson(stepInfos)}")
            if(stepInfos.dates!=null) {
                val startOfDate = dateFormat.parse(stepInfos.dates)
                dailySteps.add(DailyStepUpload(measureTime = startOfDate,deviceId = MainActivity.deviceId,steps = stepInfos.step))
                calories.add(CaloriesUpload(measureTime = startOfDate,deviceId = MainActivity.deviceId,calories = stepInfos.calories))
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

    override fun onCallbackResult(flag: Int, state: Boolean, obj: Any?) {
        super.onCallbackResult(flag, state, obj)
        Log.d(WatchDevice.TAG, "onCallbackResult: ${flag}")
        if (flag == GlobalValue.BATTERY) {
        }
        if (flag == GlobalValue.CONNECTED_MSG) {
            Log.d(WatchDevice.TAG, "onCallbackResult: Connected")
            WatchDevice.initializeWatch()
            WatchDevice.syncData()
            result?.success("Load complete")
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
            val beforeTime = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 0);
            val sleepModel = HardSdk.getInstance().queryOneDaySleepInfo(beforeTime)
            Log.i(WatchDevice.TAG,"Got sleep info ${Gson().toJson(sleepModel)}")
        } else if (flag == GlobalValue.OFFLINE_EXERCISE_SYNC_OK) {
            Log.d(WatchDevice.TAG, "onCallbackResult: Exercise Sync")
        } else if (flag == GlobalValue.SYNC_FINISH) {
            Log.d(WatchDevice.TAG, "onCallbackResult: Sync complete")

        } else if (flag == GlobalValue.Firmware_Version) {
            Log.d(WatchDevice.TAG, "version ${obj as String}")
        } else if (flag == GlobalValue.Hardware_Version) {
        } else if (flag == GlobalValue.DISCOVERY_DEVICE_SHAKE) {
        } else if (flag == GlobalValue.Firmware_DownFile) {
        } else if (flag == GlobalValue.Firmware_Start_Upgrade) {
        } else if (flag == GlobalValue.Firmware_Info_Error) {
        } else if (flag == GlobalValue.Firmware_Server_Status) {
            Log.i(WatchDevice.TAG, "Server status: $obj \n")
            if (obj != null) {
                val serverVersion = obj as Version
                Log.i(WatchDevice.TAG, "Version：" + Gson().toJson(serverVersion))
            }
        } else if (flag == GlobalValue.Firmware_Upgrade_Progress) {
        } else if (flag == GlobalValue.Firmware_Server_Failed) {
        } else if (flag == GlobalValue.READ_TEMP_FINISH_2) { // -273.15代表绝对0度作为无效值
            val tempStatus = obj as TempStatus
            Log.i(WatchDevice.TAG, "temp ${Gson().toJson(tempStatus)}")
            if (tempStatus.downTime == 0) {
            }
        } else if (flag == GlobalValue.TEMP_HIGH) { //
        } else if (flag == GlobalValue.SYNC_BODY_FINISH) { //Body temperature complete
            Log.i(WatchDevice.TAG, "Sync Body finish")
            uploadTemperature()
        } else if (flag == GlobalValue.SYNC_WRIST_FINISH) { //
            Log.i(WatchDevice.TAG,"Wrist sync finished")
            Log.i(WatchDevice.TAG, "Sync Body finish")
            val prevDay = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 1)
            val today = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 0)
            Log.d(WatchDevice.TAG,"Getting wrist temp $prevDay to $today")
            val tempData = HardSdk.getInstance().getWristTemperature(prevDay,today)
            Log.d(WatchDevice.TAG,"Wrist Temperature data ${Gson().toJson(tempData)}")
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
        }
    }

    private fun uploadBloodPressureInfo(){

        val tempTimeFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
        val bloodPressureUpload = mutableListOf<BpUpload>()
        val oxygenLevels = mutableListOf<OxygenLevelUpload>()
        val heartRates = mutableListOf<HeartRateUpload>()
        val userInfo = DataSync.getUserInfo()
        val gender = if(userInfo?.sex?.toLowerCase()=="male") 0 else 1
        (0..2).forEach {
            val beforeTime = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), it);
            HardSdk.getInstance().queryOneDayBP(beforeTime).forEach {
                try {
                    val heartRateAdditional = HeartRateAdditional(
                            TimeUtil.detaiTimeToStamp(it.testMomentTime) / 1000,
                            it.currentRate,
                            userInfo?.heightInCm ?: 162,
                            userInfo?.weightInKgs?.toInt() ?: 56,
                            gender,
                            userInfo?.age?:30
                    )
                    val measureTime = tempTimeFormat.parse(it.testMomentTime)
                    Log.d(WatchDevice.TAG, "Heart Time ${measureTime}")
                    bloodPressureUpload.add(BpUpload(measureTime = measureTime, systolic = heartRateAdditional._systolic_blood_pressure, distolic = heartRateAdditional._diastolic_blood_pressure, deviceId = MainActivity.deviceId))
                    heartRates.add(HeartRateUpload(measureTime = measureTime, deviceId = MainActivity.deviceId, heartRate = it.currentRate))
                    oxygenLevels.add(OxygenLevelUpload(measureTime = measureTime, deviceId = MainActivity.deviceId, oxygenLevel = heartRateAdditional._blood_oxygen))
                } catch (e: ParseException) {
                    e.printStackTrace()
                }
            }
        }
        if(bloodPressureUpload.isNotEmpty())
            DataSync.uploadBloodPressure(bloodPressureUpload)
        if(heartRates.isNotEmpty())
            DataSync.uploadHeartRate(heartRates)
        if(oxygenLevels.isNotEmpty())
            DataSync.uploadOxygenData(oxygenLevels)
    }

    override fun onStepChanged(
            step: Int,
            distance: Float,
            calories: Int,
            finish_status: Boolean
    ) {
        Log.d(WatchDevice.TAG, "onStepChanged: step:$step")
    }

    override fun onHeartRateChanged(rate: Int, status: Int) {
        super.onHeartRateChanged(rate, status)
        Log.d(WatchDevice.TAG, "onHeartRateChanged: status:$status")
        if (WatchDevice.isTestingHeart) {
            WatchDevice.isTestingHeart = true
            if (status == GlobalValue.RATE_TEST_FINISH) {
                WatchDevice.isTestingHeart = false
                Log.i(WatchDevice.TAG,"Heart rate finished")
            }
        }
//            else if (isTestingOxygen == true) {
//                val heartRateAdditional = HeartRateAdditional(
//                    System.currentTimeMillis() / 1000,
//                    rate,
//                    height,
//                    weight,
//                    sex,
//                    yearOld
//                )
//                oxygen = heartRateAdditional.get_blood_oxygen()
//                contentInfo.append("实时血氧值：$oxygen\n")
//                if (status == GlobalValue.RATE_TEST_FINISH) {
//                    contentInfo.append(
//                        """
//                            测量血氧结束
//
//                            """.trimIndent()
//                    )
//                    isTestingOxygen = false
//                }
//            } else if (isTestingBp) {
//                val heartRateAdditional = HeartRateAdditional(
//                    System.currentTimeMillis() / 1000,
//                    rate,
//                    height,
//                    weight,
//                    sex,
//                    yearOld
//                )
//                bloodPressure = BloodPressure()
//                bloodPressure.systolicPressure = heartRateAdditional.get_systolic_blood_pressure()
//                bloodPressure.diastolicPressure = heartRateAdditional.get_diastolic_blood_pressure()
//                contentInfo.append(
//                    """
//                        实时血压值：${bloodPressure.getDiastolicPressure()}/${bloodPressure.getSystolicPressure()}
//
//                        """.trimIndent()
//                )
//                if (status == GlobalValue.RATE_TEST_FINISH) {
//                    isTestingBp = false
//                }
//            }
    }
}

class WatchDevice:BaseDevice()     {

    companion object {
        var isTestingHeart = false;
        val TAG = BaseDevice::class.java.simpleName
        var dataCallback: DataCallBack? = null

        fun initializeWatch(){
            HardSdk.getInstance().setTimeUnitAndUserProfile(true,true,GlobalValue.SEX_BOY,32,80,178,140, 90, 180)
            HardSdk.getInstance().setTimeAndClock()
            //Set weather to celsius
            HardSdk.getInstance().setWeatherType(true,GlobalValue.Unit_Fahrenheit)
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
            }catch (ex:Exception){
                Log.e(TAG,"Error while syncing data",ex)
            }
        }
    }

    override fun disconnectDevice(result: MethodChannel.Result?) {
        if(HardSdk.getInstance().isDevConnected) {
            HardSdk.getInstance().restoreFactoryMode()
            HardSdk.getInstance().disconnect()
        }
        result?.success("Success")
    }



    override fun connectDevice(context: Context, result: MethodChannel.Result,deviceId:String?) {
        HardSdk.getInstance().init(context)
        val watchDataCallBack = WatchDataCallBack(context, result,deviceId)
        WatchDataCallBack.deviceName = null
        WatchDataCallBack.deviceAddr = null
        HardSdk.getInstance().setHardScanCallback(watchDataCallBack)
        ConnectDeviceCallBack.currentCallBack = ConnectDeviceCallBack(result)
        HardSdk.getInstance().setHardSdkCallback(ConnectDeviceCallBack.currentCallBack)
        if (HardSdk.getInstance().isBleEnabled) {
            HardSdk.getInstance().startScan()
            GlobalScope.launch {
                delay(25000)
                Log.d(TAG,"Unable to find device ${watchDataCallBack.deviceConnected}")
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
    override fun syncData(result: MethodChannel.Result?,connectionInfo: ConnectionInfo,context: Context){
        Log.i(TAG,"Calling sync data")
        DataSync.CURRENT_MAC_ADDRESS = connectionInfo.deviceId
        DataSync.sendHeartBeat(HeartBeat(macAddress = connectionInfo.deviceId,deviceId = connectionInfo.deviceName))
        Log.i(TAG,"Is device connected ${HardSdk.getInstance().isDevConnected}")
        if(dataCallback==null) {
            dataCallback = DataCallBack(result)
            //Load the data from device
        }
        var returnValue = true
        //If the device is not connected  try to connect
        if(!HardSdk.getInstance().isDevConnected &&
                !HardSdk.getInstance().isConnecting){
            dataCallback?.updateResult(result)
            HardSdk.getInstance().init(context)
            returnValue = false
            HardSdk.getInstance().setHardSdkCallback(dataCallback)
            HardSdk.getInstance().bindBracelet(
                    connectionInfo.additionalInformation["factoryName"],
                    connectionInfo.deviceName,
                    connectionInfo.deviceId
            )
        }else if(!HardSdk.getInstance().isSyncing && HardSdk.getInstance().isDevConnected){ //If the data is not syncing
            HardSdk.getInstance().setHardSdkCallback(dataCallback)
            Log.i(TAG, "Data sync complete")
            returnValue = false
            result?.success("Load complete")
            syncData()
        }
        if(returnValue)
            result?.success("Load complete")
    }


    override fun getDeviceInfo(result: MethodChannel.Result?, connectionInfo: ConnectionInfo, context: Context) {
        val connectionStatus = HardSdk.getInstance().isDevConnected
        if(!connectionStatus){
            DataSync.CURRENT_MAC_ADDRESS = connectionInfo.deviceId
            HardSdk.getInstance().init(context)
            HardSdk.getInstance().bindBracelet(
                    connectionInfo.additionalInformation["factoryName"],
                    connectionInfo.deviceName,
                    connectionInfo.deviceId
            )
        }
        sendConnectionResponse(connectionInfo.deviceId,connectionStatus,result)
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

    constructor(context: Context, result: MethodChannel.Result,deviceId:String?) {
        this.context = context
        this.result = result
        this.deviceId = deviceId
    }

    companion object {
        private val TAG = WatchDataCallBack::class.java.simpleName
        var deviceName: String? = null
        var deviceAddr: String? = null
        var targetDevice: Device? = null
    }

    private fun byteArrHexToString(bytes: ByteArray?): String {
        var ret = ""
        bytes?.forEach {
            ret += String.format("%02X", it)
        }
        return ret.toUpperCase()
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
        deviceId?.let {enteredDeviceId->
            connect = false
            Log.d(TAG,"entered device id $enteredDeviceId with $device.address")
            val lastFour = device.address.substring(device.address.length - 5).replace(":","")
            Log.d(TAG,"entered device id $enteredDeviceId with $deviceAddr with last four $lastFour")
            if(lastFour.toLowerCase()==enteredDeviceId.toLowerCase()){
                Log.d(TAG,"values matched matched")
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
                result.success(ConnectionInfo.createResponse(message = "Connected", connected = true, deviceId = deviceAddr, deviceName = deviceName,
                        additionalInfo = mapOf("factoryName" to targetDevice!!.factoryName), deviceType = BaseDevice.WATCH_DEVICE, deviceFound = deviceFound))
            }
        }
        if (deviceName != null) {
            HardSdk.getInstance().stopScan();
        }
    }

    private fun connectDevice(factoryNameByUUID: String?,deviceName:String,deviceAddress:String){


    }

    fun stopScanning() {
        HardSdk.getInstance().stopScan()
        HardSdk.getInstance().removeHardScanCallback(this)
    }
}