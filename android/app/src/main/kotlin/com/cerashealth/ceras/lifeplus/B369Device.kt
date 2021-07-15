package com.cerashealth.ceras.lifeplus

import android.content.Context
import android.util.Log
import cn.icomon.icdevicemanager.ICDeviceManager
import cn.icomon.icdevicemanager.ICDeviceManagerDelegate
import cn.icomon.icdevicemanager.callback.ICScanDeviceDelegate
import cn.icomon.icdevicemanager.common.ICConfigManager
import cn.icomon.icdevicemanager.model.data.*
import cn.icomon.icdevicemanager.model.device.ICDevice
import cn.icomon.icdevicemanager.model.device.ICDeviceInfo
import cn.icomon.icdevicemanager.model.device.ICScanDeviceInfo
import cn.icomon.icdevicemanager.model.device.ICUserInfo
import cn.icomon.icdevicemanager.model.other.ICConstant
import cn.icomon.icdevicemanager.model.other.ICConstant.ICMeasureStep
import cn.icomon.icdevicemanager.model.other.ICConstant.ICWeightUnit
import cn.icomon.icdevicemanager.model.other.ICDeviceManagerConfig
import com.cerashealth.ceras.MainActivity
import com.cerashealth.ceras.lifeplus.data.ConnectionInfo
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch


class B369Device :BaseDevice(), ICDeviceManagerDelegate{

    companion object{
        val TAG = B369Device::class.java.simpleName
        var device:ICDevice? = null
        var b369Device:B369Device? = null
        var deviceConnected = false
        var initComplete = false
        var deviceFound = false
        var deviceId:String? = null
        var result:MethodChannel.Result? = null

        fun getInstance():B369Device{
            if(b369Device==null){
                b369Device = B369Device()
            }
            return b369Device!!
        }
    }

    private fun initSDK(context: Context)
    {
        val config = ICDeviceManagerConfig()
        config.context = context
        val userInfo = ICUserInfo()
        userInfo.kitchenUnit = ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitOz
        userInfo.rulerUnit = ICConstant.ICRulerUnit.ICRulerUnitInch
        userInfo.weightUnit = ICConstant.ICWeightUnit.ICWeightUnitLb
        userInfo.age = 31
        userInfo.weight = 180.0
        userInfo.height = 170
        userInfo.userIndex = 1
        userInfo.sex = ICConstant.ICSexType.ICSexTypeMale
        userInfo.weightDirection = 1
        userInfo.targetWeight = 160.0


        config.is_fill_adc = true
        ICDeviceManager.shared().delegate = this
        ICDeviceManager.shared().setUserList(listOf(userInfo))
        ICDeviceManager.shared().updateUserInfo(userInfo)
        ICDeviceManager.shared().initMgrWithConfig(config)

    }



    override fun connectDevice(context: Context, result: MethodChannel.Result, deviceId: String?) {

        Log.i(TAG, "Connecting to $deviceId")
        if(!initComplete) {
            if(ICDeviceManager.checkBlePermission(context)) {
                initSDK(context)
            }
        }
        Log.d(TAG,"Bluetooth enabled ${ICDeviceManager.shared().isBLEEnable}")

        if(ICDeviceManager.shared().isBLEEnable){
            Log.d(TAG,"Bluetooth enabled")
            Log.d(TAG,"Setting call back")

            //Scan the device and update
            ICDeviceManager.shared().scanDevice{
                onScanResult(it,result,deviceId)
            }

            //This is used to wait for 30 seconds and send error back
            GlobalScope.launch {
                delay(30000)
                ICDeviceManager.shared().stopScan()
                Log.d(TAG, "Device connected $deviceConnected")
                //If the device is not connected, then send an error back
                if(!deviceConnected) {
                    Log.d(TAG, "Device found $deviceFound and Device connected $deviceConnected")
                    MainActivity.currentActivity?.runOnUiThread {
                        result.success(ConnectionInfo.createResponse(message = "Failed", connected = false, deviceFound = deviceFound))
                    }
                }
            }
        }
    }

    override fun connectWifi(result: MethodChannel.Result?, connectionInfo: ConnectionInfo, context: Context, network: String?, password: String?) {
        Log.d(TAG,"Connecting to $network with $password with device id ${device?.macAddr}")
        Log.d(TAG,"Bluetooth enabled ${ICDeviceManager.shared().isBLEEnable}")
        Log.i(TAG,"Context ${ICConfigManager.shared().context}")

        ICDeviceManager.shared().settingManager.configWifi(device,network!!,password!!) {
            Log.d(TAG,"Got status $it")
            when(it){
                ICConstant.ICSettingCallBackCode.ICSettingCallBackCodeSuccess ->{
                    Log.d(TAG,"Connection success")
                    //result?.success(ConnectionInfo.createResponse(message = "Success",connected = true))
                }
                else -> {
                    Log.d(TAG,"Connection failure")
                    result?.success(ConnectionInfo.createResponse(message = "Failure ${it}",connected = true))
                }
            }
        }

        ICDeviceManager.shared().settingManager.setServerUrl(device,"https://device.alpha.myceras.com"){
            Log.d(TAG,"Got server url status $it")
        }
    }

    override fun syncData(result: MethodChannel.Result?, connectionInfo: ConnectionInfo, context: Context) {

    }

    override fun onInitFinish(finished: Boolean) {
        Log.d(TAG, "Initialization finished with status $finished")
        initComplete = finished
    }

    override fun onBleState(state: ICConstant.ICBleState?) {
        Log.d(TAG, "BLE state changed $state")
        if (state == ICConstant.ICBleState.ICBleStatePoweredOn) {
        }
    }

    override fun onDeviceConnectionChanged(device: ICDevice?, p1: ICConstant.ICDeviceConnectState?) {
        Log.d(TAG, "Connection changed $p1")
    }

    override fun onReceiveWeightData(device: ICDevice?, weightData: ICWeightData?) {
        Log.d(TAG, "received Weight data ")
        weightData?.let {
            Log.d(TAG, "Got weight data at ${weightData.time} weight ${weightData.weight_lb} BMI ${weightData.bmi} " +
                    "bodyfat ${weightData.bodyFatPercent} " +
                    "Musc Percent ${weightData.musclePercent} " +
                    "Viscural Fat ${weightData.visceralFat} " +
                    "Bone Bass ${weightData.boneMass} " +
                    "Body Age ${weightData.physicalAge}" +
                    "Protien ${weightData.proteinPercent}")
        }
    }

    override fun onReceiveKitchenScaleData(device: ICDevice?, p1: ICKitchenScaleData?) {
        Log.d(TAG, "Scale data updated ")
    }

    override fun onReceiveKitchenScaleUnitChanged(device: ICDevice?, p1: ICConstant.ICKitchenScaleUnit?) {
        Log.d(TAG, "Scale unit changed ")
    }

    override fun onReceiveCoordData(device: ICDevice?, p1: ICCoordData?) {
        Log.d(TAG, "Got Cord Data ")
    }

    override fun onReceiveRulerData(device: ICDevice?, p1: ICRulerData?) {
        Log.d(TAG, "Got ruler data ")
    }

    override fun onReceiveRulerHistoryData(device: ICDevice?, p1: ICRulerData?) {
        Log.d(TAG, "Got ruler history ")
    }

    override fun onReceiveWeightCenterData(device: ICDevice?, p1: ICWeightCenterData?) {
        Log.d(TAG, "GOt weigh center data")
    }

    override fun onReceiveWeightUnitChanged(device: ICDevice?, p1: ICWeightUnit?) {
        Log.d(TAG, "Weight unit changed ")
    }

    override fun onReceiveRulerUnitChanged(device: ICDevice?, p1: ICConstant.ICRulerUnit?) {
        Log.d(TAG, "Ruler unit changed ")
    }

    override fun onReceiveRulerMeasureModeChanged(device: ICDevice?, p1: ICConstant.ICRulerMeasureMode?) {
        Log.d(TAG, "Ruler mode changed ")
    }

    override fun onReceiveMeasureStepData(device: ICDevice?, step: ICMeasureStep?, data2: Any?) {
        when (step) {
            ICMeasureStep.ICMeasureStepMeasureWeightData -> {
                val data = data2 as ICWeightData
//                onReceiveWeightData(device, data)
            }
            ICMeasureStep.ICMeasureStepMeasureCenterData -> {
                val data = data2 as ICWeightCenterData
                onReceiveWeightCenterData(device, data)
            }
            ICMeasureStep.ICMeasureStepAdcStart -> {
                Log.d(TAG, device!!.getMacAddr() + ": start imp... ")
            }
            ICMeasureStep.ICMeasureStepAdcResult -> {
                Log.d(TAG, device!!.getMacAddr() + ": imp over")
            }
            ICMeasureStep.ICMeasureStepHrStart -> {
                Log.d(TAG, device!!.getMacAddr() + ": start hr")
            }
            ICMeasureStep.ICMeasureStepHrResult -> {
                val hrData = data2 as ICWeightData
                Log.d(TAG, device!!.getMacAddr() + ": over hr: " + hrData.hr)
            }
            ICMeasureStep.ICMeasureStepMeasureOver -> {
                val data = data2 as ICWeightData
                Log.d(TAG, device!!.getMacAddr() + ": over measure")
                onReceiveWeightData(device, data)
            }
            else -> {
            }
        }

    }

    override fun onReceiveWeightHistoryData(device: ICDevice?, historyData: ICWeightHistoryData?) {
        historyData?.let {
            Log.d(TAG, "Got history data ${it.time} ${it.weight_lb} ")
        }
        Log.d(TAG, "Weight history data ")
    }

    override fun onReceiveSkipData(device: ICDevice?, p1: ICSkipData?) {
        Log.d(TAG, "Skip device ")
    }

    override fun onReceiveHistorySkipData(device: ICDevice?, p1: ICSkipData?) {
        Log.d(TAG, "History skip data ")
    }

    override fun onReceiveSkipBattery(device: ICDevice?, p1: Int) {
        Log.d(TAG, "Skip dattery ")
    }

    override fun onReceiveUpgradePercent(device: ICDevice?, p1: ICConstant.ICUpgradeStatus?, p2: Int) {
        Log.d(TAG, "Device upgrade percent ")
    }

    override fun onReceiveDeviceInfo(device: ICDevice?, deviceInfo: ICDeviceInfo?) {
        Log.d(TAG, "Got device info")
    }

    override fun onReceiveDebugData(device: ICDevice?, p1: Int, p2: Any?) {
        Log.d(TAG, "Got debug data ")
    }

    override fun onReceiveConfigWifiResult(device: ICDevice?, wifiStatus: ICConstant.ICConfigWifiState?) {
        Log.i(TAG,"Got wifi result for ${device?.macAddr} is ${wifiStatus}")
        result?.let {
            when(wifiStatus){
                ICConstant.ICConfigWifiState.ICConfigWifiStateSuccess ->{
                    result?.success(ConnectionInfo.createResponse(message = "Wifi Connected",connected = true))
                }
                ICConstant.ICConfigWifiState.ICConfigWifiStateFail -> {
                    result?.success(ConnectionInfo.createResponse(message = "Config failed",connected = true))
                }
                ICConstant.ICConfigWifiState.ICConfigWifiStatePasswordFail -> {
                    result?.success(ConnectionInfo.createResponse(message = "Invalid Password",connected = true))
                }
                ICConstant.ICConfigWifiState.ICConfigWifiStateWifiConnecting -> {
                    Log.d(TAG,"Connecting ${device?.macAddr}")
                }
            }
            result = null
        }
    }

    /**
     * This method takes the scan result and validates if it matches the deviceId
     */
    private fun onScanResult(deviceInfo: ICScanDeviceInfo?,scanResult: MethodChannel.Result?,requestedDeviceId:String?) {
        Log.i(TAG, "Found device ${deviceInfo?.macAddr}")
        deviceInfo?.let {
            //Capture the last 5 charecters of the mac address and remove the ":" to get the last four
            val lastFour = it.macAddr.substring(it.macAddr.length - 5).replace(":", "")

            Log.d(TAG,"matching $lastFour to $requestedDeviceId")
            //If the last Four characters matches the requested device id
            if(lastFour.equals(requestedDeviceId, ignoreCase = true)){
                Log.d(TAG, "values matched matched")
                deviceFound = true
                scanResult?.let {
                    val device = ICDevice().apply {
                        macAddr = deviceInfo.macAddr

                    }
                    //Device is found, stop the scan
                    ICDeviceManager.shared().stopScan()
                    //Add the device to the devices
                    ICDeviceManager.shared().addDevice(device) { device, code ->
                        try {
                            B369Device.device = device
                            Log.d(TAG,"Setup the device with device connected $deviceConnected")
                            scanResult?.let {
                                scanResult?.success(ConnectionInfo.createResponse(message = "Connected", connected = true, deviceId = deviceInfo.macAddr, deviceName = deviceInfo.name,
                                    deviceType = BaseDevice.B369_DEVICE, deviceFound = deviceFound))
                            }

                            deviceConnected = true

                            //Set the scale to pounds, this has to be configurable based on the user preference
                            ICDeviceManager.shared().settingManager.setScaleUnit(device, ICWeightUnit.ICWeightUnitLb) { code ->
                                Log.d(TAG, String.format("%s %s", device.getMacAddr(),"setting callback code :$code"))
                            }
                        } catch (ex: Exception) {
                            //If there is an exception, let the timeout catch this.
                            Log.e(TAG, "Error while sending response ", ex)
                        }
                    }
                }
            }
        }
    }

}