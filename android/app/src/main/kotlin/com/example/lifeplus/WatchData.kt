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
                result.success("Timeout")
            }
        }
    }

}

class DataCallBack : SimpleDeviceCallback {
    private val result: MethodChannel.Result?

    constructor(result: MethodChannel.Result?) {
        this.result = result
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
            Log.d(WatchData.TAG, "onCallbackResult: Step finish")
        } else if (flag == GlobalValue.OFFLINE_HEART_SYNC_OK) {
            Log.d(WatchData.TAG, "onCallbackResult: Offline heart sync")
        } else if (flag == GlobalValue.SLEEP_SYNC_OK) {
            Log.d(WatchData.TAG, "onCallbackResult: Sleep Sync")
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
        } else if (flag == GlobalValue.SYNC_BODY_FINISH) { //
            Log.i(WatchData.TAG, "Sync Body finish")
        } else if (flag == GlobalValue.SYNC_WRIST_FINISH) { //
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
        HardSdk.getInstance().setHardSdkCallback(DataCallBack(result))
        val beforeTime = TimeUtil.getBeforeDay(TimeUtil.getCurrentDate(), 0);

        val sleepModel = HardSdk.getInstance().queryOneDaySleepInfo(beforeTime)
        val stepInfos = HardSdk.getInstance().queryOneDayStep(beforeTime)
        Log.i(WatchData.TAG,"Got sleep info ${Gson().toJson(sleepModel)}")
        Log.i(WatchData.TAG,"Got step info ${Gson().toJson(stepInfos)}")
        result.success("Got data")
    }

    //Sync the data from watch
    //This needs to be called in background from time to time
    fun syncData(){
        //Load the data from device
        HardSdk.getInstance().setHardSdkCallback(DataCallBack(null))
        HardSdk.getInstance().syncLatestBodyTemperature(0)
        HardSdk.getInstance().syncLatestWristTemperature(0)
        HardSdk.getInstance().syncHeartRateData(0)
        HardSdk.getInstance().syncStepData(0)
        HardSdk.getInstance().syncSleepData(0)
        MainActivity.lastConnected = Calendar.getInstance()
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
            result.success("Connected to $deviceName with address $deviceAddr ")
        }
        if (deviceName != null) {
            HardSdk.getInstance().stopScan();
        }
    }

    private fun stopScanning() {
        HardSdk.getInstance().stopScan()
        HardSdk.getInstance().removeHardScanCallback(this)
    }
}