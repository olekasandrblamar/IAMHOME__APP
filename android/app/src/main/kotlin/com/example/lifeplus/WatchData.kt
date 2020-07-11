package com.example.lifeplus

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import android.content.Context
import android.text.TextUtils
import android.util.Log
import com.google.gson.Gson
import com.walnutin.HeartRateAdditional
import com.walnutin.hardsdk.ProductList.sdk.GlobalValue
import com.walnutin.hardsdk.ProductList.sdk.HardSdk
import com.walnutin.hardsdk.ProductList.sdk.TimeUtil
import com.walnutin.hardsdk.ProductNeed.Jinterface.IHardScanCallback
import com.walnutin.hardsdk.ProductNeed.Jinterface.SimpleDeviceCallback
import com.walnutin.hardsdk.ProductNeed.entity.*
import io.flutter.plugin.common.MethodChannel
import java.text.ParseException
import java.text.SimpleDateFormat
import java.util.*

class ConnectDeviceCallBack : SimpleDeviceCallback {

    private var retries = 1;

    private val result: MethodChannel.Result

    constructor(result: MethodChannel.Result) {
        this.result = result
    }

    override fun onCallbackResult(flag: Int, state: Boolean, obj: Any?) {
        super.onCallbackResult(flag, state, obj)
        if (flag == GlobalValue.CONNECTED_MSG) {
            Log.d(WatchData.TAG, "onCallbackResult: Connected")
            HardSdk.getInstance().stopScan()
        } else if (flag == GlobalValue.DISCONNECT_MSG) {
            Log.d(WatchData.TAG, "onCallbackResult: Disconnected")
            HardSdk.getInstance().startScan()
        } else if (flag == GlobalValue.CONNECT_TIME_OUT_MSG) {
            Log.d(WatchData.TAG, "onCallbackResult: Time out")
            //retry 3 times for disconnect
            if (retries < 3) {
                retries++
                Log.i(WatchData.TAG,"retrying scan")
                HardSdk.getInstance().stopScan()
                HardSdk.getInstance().startScan()
            } else {
                result.success(ConnectionInfo.createResponse(message = "Timeout"))
            }
        }
    }

}

class DataCallBack : SimpleDeviceCallback {
    private val result: MethodChannel.Result?

    @get:Synchronized @set:Synchronized
    var callCount = 0;

    constructor(result: MethodChannel.Result?) {
        this.result = result
    }

    private fun uploadTemperature(){
        val prevDay = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 2)
        val today = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), -2)
        Log.d(WatchData.TAG,"Getting temp $prevDay to $today")
        val tempData = HardSdk.getInstance().getBodyTemperature(prevDay,today)
        val tempTimeFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
        val tempUploads = tempData.map {
            val celsius = it.temps
            val fahrenheit = (celsius*9/5)+32
            TemperatureUpload(measureTime = tempTimeFormat.parse(it.testMomentTime),deviceId = MainActivity.deviceId,celsius = celsius.toDouble(),fahrenheit = fahrenheit.toDouble())
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
            Log.i(WatchData.TAG,"step info ${Gson().toJson(stepInfos)}")
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
        if (flag == GlobalValue.BATTERY) {
        }
        if (flag == GlobalValue.CONNECTED_MSG) {
            Log.d(WatchData.TAG, "onCallbackResult: Connected")
        } else if (flag == GlobalValue.DISCONNECT_MSG) {
            Log.d(WatchData.TAG, "onCallbackResult: Disconnected")
        } else if (flag == GlobalValue.CONNECT_TIME_OUT_MSG) {
            Log.d(WatchData.TAG, "onCallbackResult: Timeout")
        } else if (flag == GlobalValue.STEP_FINISH) {
            Log.i(WatchData.TAG, "onCallbackResult: Step finish")
            uploadSteps()
        } else if (flag == GlobalValue.OFFLINE_HEART_SYNC_OK) {
            Log.i(WatchData.TAG, "onCallbackResult: Offline heart sync")
            sendBloodPressureInfo()
            sendHeartRateInfo()
            sendOxygenInfo()
            //heart rate sync is complete
        } else if (flag == GlobalValue.SLEEP_SYNC_OK) {
            Log.i(WatchData.TAG, "onCallbackResult: Sleep Sync")
            val beforeTime = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 0);
            val sleepModel = HardSdk.getInstance().queryOneDaySleepInfo(beforeTime)
            Log.i(WatchData.TAG,"Got sleep info ${Gson().toJson(sleepModel)}")
        } else if (flag == GlobalValue.OFFLINE_EXERCISE_SYNC_OK) {
            Log.d(WatchData.TAG, "onCallbackResult: Exercise Sync")
        } else if (flag == GlobalValue.SYNC_FINISH) {
            Log.d(WatchData.TAG, "onCallbackResult: Sync complete")

        } else if (flag == GlobalValue.Firmware_Version) {
            Log.d(WatchData.TAG, "version ${obj as String}")
        } else if (flag == GlobalValue.Hardware_Version) {
        } else if (flag == GlobalValue.DISCOVERY_DEVICE_SHAKE) {
        } else if (flag == GlobalValue.Firmware_DownFile) {
        } else if (flag == GlobalValue.Firmware_Start_Upgrade) {
        } else if (flag == GlobalValue.Firmware_Info_Error) {
        } else if (flag == GlobalValue.Firmware_Server_Status) {
            Log.i(WatchData.TAG, "Server status: $obj \n")
            if (obj != null) {
                val serverVersion = obj as Version
                Log.i(WatchData.TAG, "Version：" + Gson().toJson(serverVersion))
            }
        } else if (flag == GlobalValue.Firmware_Upgrade_Progress) {
        } else if (flag == GlobalValue.Firmware_Server_Failed) {
        } else if (flag == GlobalValue.READ_TEMP_FINISH_2) { // -273.15代表绝对0度作为无效值
            val tempStatus = obj as TempStatus
            Log.i(WatchData.TAG, "temp ${Gson().toJson(tempStatus)}")
            if (tempStatus.downTime == 0) {
            }
        } else if (flag == GlobalValue.TEMP_HIGH) { //
        } else if (flag == GlobalValue.SYNC_BODY_FINISH) { //Body temperature complete
            Log.i(WatchData.TAG, "Sync Body finish")
            uploadTemperature()
        } else if (flag == GlobalValue.SYNC_WRIST_FINISH) { //
            Log.i(WatchData.TAG,"Wrist sync finished")
            Log.i(WatchData.TAG, "Sync Body finish")
            val prevDay = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 1)
            val today = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 0)
            Log.d(WatchData.TAG,"Getting wrist temp $prevDay to $today")
            val tempData = HardSdk.getInstance().getWristTemperature(prevDay,today)
            Log.d(WatchData.TAG,"Wrist Temperature data ${Gson().toJson(tempData)}")
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

    fun sendOxygenInfo(){
        val beforeTime = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 0);
        HardSdk.getInstance().queryOneDayBP(beforeTime).forEach {
            try {
                val heartRateAdditional = HeartRateAdditional(
                        TimeUtil.detaiTimeToStamp(it.testMomentTime) / 1000,
                        it.currentRate,
                        170,
                        160,
                        0,
                        30
                )
                val bloodOxygen = BloodOxygen();
                bloodOxygen.testMomentTime = it.testMomentTime;
                bloodOxygen.oxygen = (heartRateAdditional.get_blood_oxygen());
                Log.i(WatchData.TAG, "GOT O2 ${Gson().toJson(bloodOxygen)}")
            } catch (e: ParseException) {
                e.printStackTrace()
            }
        }
    }

    fun sendHeartRateInfo(){
        val beforeTime = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), -1);
        val heartRate = HardSdk.getInstance().queryOneDayHeartRate(beforeTime)
        Log.i(WatchData.TAG,"got HR "+Gson().toJson(heartRate))
        heartRate.forEach{
            Log.i(WatchData.TAG,"GOT HR ${Gson().toJson(it)}")
        }
    }

    fun sendBloodPressureInfo(){
        val beforeTime = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 0);
        HardSdk.getInstance().queryOneDayBP(beforeTime).forEach {
            try {
                val heartRateAdditional = HeartRateAdditional(
                        TimeUtil.detaiTimeToStamp(it.testMomentTime) / 1000,
                        it.currentRate,
                        170,
                        160,
                        0,
                        30
                )
                val bloodPressure = BloodPressure()
                bloodPressure.testMomentTime = it.testMomentTime
                bloodPressure.setSystolicPressure(heartRateAdditional.get_systolic_blood_pressure())
                bloodPressure.setDiastolicPressure(heartRateAdditional.get_diastolic_blood_pressure())
                Log.i(WatchData.TAG,"GOT BP ${Gson().toJson(bloodPressure)}")
            } catch (e: ParseException) {
                e.printStackTrace()
            }
        }
    }

    override fun onStepChanged(
            step: Int,
            distance: Float,
            calories: Int,
            finish_status: Boolean
    ) {
        Log.d(WatchData.TAG, "onStepChanged: step:$step")
    }

    override fun onHeartRateChanged(rate: Int, status: Int) {
        super.onHeartRateChanged(rate, status)
        Log.d(WatchData.TAG, "onHeartRateChanged: status:$status")
        if (WatchData.isTestingHeart) {
            WatchData.isTestingHeart = true
            if (status == GlobalValue.RATE_TEST_FINISH) {
                WatchData.isTestingHeart = false
                Log.i(WatchData.TAG,"Heart rate finished")
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

class WatchData {

    companion object {
        var isTestingHeart = false;
        val TAG = WatchData::class.java.simpleName
        var dataCallback: DataCallBack? = null
    }

    fun connectDevice(context: Context, result: MethodChannel.Result) {
        HardSdk.getInstance().init(context)
        val watchDataCallBack = WatchDataCallBack(context, result)
        HardSdk.getInstance().setHardScanCallback(watchDataCallBack)
        HardSdk.getInstance().setHardSdkCallback(ConnectDeviceCallBack(result))
        if (HardSdk.getInstance().isBleEnabled)
            HardSdk.getInstance().startScan()
    }


    //Load the data
    fun loadData(result: MethodChannel.Result) {
        result.success("Got data")
    }

    //Sync the data from watch
    //This needs to be called in background from time to time
    fun syncData(result: MethodChannel.Result,connectionInfo: ConnectionInfo,context: Context){
        Log.i(TAG,"Calling sync data")

        Log.i(TAG,"Is device connected ${HardSdk.getInstance().isDevConnected}")
        //If the device is not connected  try to connect
        if(!HardSdk.getInstance().isDevConnected &&
                !HardSdk.getInstance().isConnecting){
            HardSdk.getInstance().init(context)
            HardSdk.getInstance().bindBracelet(
                    connectionInfo.additionalInformation["factoryName"],
                    connectionInfo.deviceName,
                    connectionInfo.deviceId
            )
        }else if(!HardSdk.getInstance().isSyncing && HardSdk.getInstance().isDevConnected){ //If the data is not syncing
            if(dataCallback==null) {
                dataCallback = DataCallBack(result)
                //Load the data from device
                HardSdk.getInstance().setHardSdkCallback(dataCallback)
            }
            dataCallback?.let {
                HardSdk.getInstance().syncLatestBodyTemperature(2)
                HardSdk.getInstance().syncLatestWristTemperature(2)
                HardSdk.getInstance().syncHeartRateData(2)
                HardSdk.getInstance().syncExerciseData(2)
                HardSdk.getInstance().syncStepData(2)
                HardSdk.getInstance().syncSleepData(2)
            }

            MainActivity.lastConnected = Calendar.getInstance()
            context.getSharedPreferences(MainActivity.SharedPrefernces,Context.MODE_PRIVATE).edit().putString("flutter.last_sync",MainActivity.displayDateFormat.format(MainActivity.lastConnected.time)).commit()
            Log.i(TAG,"last Updated ${context.getSharedPreferences(MainActivity.SharedPrefernces,Context.MODE_PRIVATE).all}")
            Log.i(TAG, "Data sync complete")
            result.success("Load complete")
        }
    }

}

class WatchDataCallBack : IHardScanCallback {

    private var context: Context? = null

    private val result: MethodChannel.Result

    constructor(context: Context, result: MethodChannel.Result) {
        this.context = context
        this.result = result
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
        if (!TextUtils.isEmpty(device.name) && deviceName == null) {
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
            Log.d(TAG, "Got data $factoryNameByUUID device ${device.name} address ${device.address}")
            stopScanning()
            result.success(ConnectionInfo.createResponse(message = "Connected",connected = true,deviceId = deviceAddr,deviceName = deviceName,additionalInfo = mapOf("factoryName" to targetDevice!!.factoryName)))
        }
        if (deviceName != null) {
            HardSdk.getInstance().stopScan();
        }
    }

    private fun connectDevice(factoryNameByUUID: String?,deviceName:String,deviceAddress:String){


    }

    private fun stopScanning() {
        HardSdk.getInstance().stopScan()
        HardSdk.getInstance().removeHardScanCallback(this)
    }
}