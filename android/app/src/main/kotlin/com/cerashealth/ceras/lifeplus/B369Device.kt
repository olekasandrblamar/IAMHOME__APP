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

class B369InitialConnection: ICScanDeviceDelegate{

    private var context: Context? = null

    private var result: MethodChannel.Result?

    private var deviceId:String? = null

    var deviceFound = false

    var deviceConnected =false

    constructor(context: Context, result: MethodChannel.Result, deviceId: String?) {
        this.context = context
        this.result = result
        this.deviceId = deviceId
    }

    override fun onScanResult(deviceInfo: ICScanDeviceInfo?) {
        Log.i(B369Device.TAG, "Found device ${deviceInfo?.macAddr}")
        deviceInfo?.let {
            val lastFour = it.macAddr.substring(it.macAddr.length - 5).replace(":", "")
            Log.d(B369Device.TAG,"matching $lastFour to $deviceId")
            if(lastFour.equals(deviceId, ignoreCase = true)){
                Log.d(B369Device.TAG, "values matched matched")
                deviceFound = true
                result?.let {
                    val device = ICDevice().apply {
                        macAddr = deviceInfo.macAddr

                    }
                    ICDeviceManager.shared().stopScan()

                    ICDeviceManager.shared().addDevice(device) { device, code ->
                        try {
                            deviceConnected = true
                            B369Device.device = device
                            Log.d(B369Device.TAG,"Setup the device")
                            result?.let {
                                result?.success(ConnectionInfo.createResponse(message = "Connected", connected = true, deviceId = deviceInfo.macAddr, deviceName = deviceInfo.name,
                                        deviceType = BaseDevice.B369_DEVICE, deviceFound = deviceFound))
                                result = null
                            }

                            Log.d(B369Device.TAG,"Ble enabled ${ICDeviceManager.shared().isBLEEnable}")

                            ICDeviceManager.shared().settingManager.configWifi(device,"alapatis","shyamkishore"){
                                Log.i(B369Device.TAG,"Configured wifi $it")
                            }
                        } catch (ex: Exception) {
                            Log.e(B369Device.TAG, "Error while sending response ", ex)
                        }
                    }
                }
            }
        }
    }

}

class DataProcessor: ICDeviceManagerDelegate{

    var result:MethodChannel.Result? = null

    override fun onInitFinish(finished: Boolean) {
        Log.d(B369Device.TAG, "Initialization finished")
    }

    override fun onBleState(state: ICConstant.ICBleState?) {
        Log.d(B369Device.TAG, "BLE state changed ")
        if (state == ICConstant.ICBleState.ICBleStatePoweredOn) {
        }
    }

    override fun onDeviceConnectionChanged(device: ICDevice?, p1: ICConstant.ICDeviceConnectState?) {
        Log.d(B369Device.TAG, "Connection changed $p1")
    }

    override fun onReceiveWeightData(device: ICDevice?, weightData: ICWeightData?) {
        Log.d(B369Device.TAG, "received Weight data ")
        weightData?.let {
            Log.d(B369Device.TAG, "Got weight data at ${weightData.time} weight ${weightData.weight_lb} BMI ${weightData.bmi} " +
                    "bodyfat ${weightData.bodyFatPercent} " +
                    "Musc Percent ${weightData.musclePercent} " +
                    "Viscural Fat ${weightData.visceralFat} " +
                    "Bone Bass ${weightData.boneMass} " +
                    "Body Age ${weightData.physicalAge}" +
                    "Protien ${weightData.proteinPercent}")
        }
    }

    override fun onReceiveKitchenScaleData(device: ICDevice?, p1: ICKitchenScaleData?) {
        Log.d(B369Device.TAG, "Scale data updated ")
    }

    override fun onReceiveKitchenScaleUnitChanged(device: ICDevice?, p1: ICConstant.ICKitchenScaleUnit?) {
        Log.d(B369Device.TAG, "Scale unit changed ")
    }

    override fun onReceiveCoordData(device: ICDevice?, p1: ICCoordData?) {
        Log.d(B369Device.TAG, "Got Cord Data ")
    }

    override fun onReceiveRulerData(device: ICDevice?, p1: ICRulerData?) {
        Log.d(B369Device.TAG, "Got ruler data ")
    }

    override fun onReceiveRulerHistoryData(device: ICDevice?, p1: ICRulerData?) {
        Log.d(B369Device.TAG, "Got ruler history ")
    }

    override fun onReceiveWeightCenterData(device: ICDevice?, p1: ICWeightCenterData?) {
        Log.d(B369Device.TAG, "GOt weigh center data")
    }

    override fun onReceiveWeightUnitChanged(device: ICDevice?, p1: ICWeightUnit?) {
        Log.d(B369Device.TAG, "Weight unit changed ")
    }

    override fun onReceiveRulerUnitChanged(device: ICDevice?, p1: ICConstant.ICRulerUnit?) {
        Log.d(B369Device.TAG, "Ruler unit changed ")
    }

    override fun onReceiveRulerMeasureModeChanged(device: ICDevice?, p1: ICConstant.ICRulerMeasureMode?) {
        Log.d(B369Device.TAG, "Ruler mode changed ")
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
                Log.d(B369Device.TAG, device!!.getMacAddr() + ": start imp... ")
            }
            ICMeasureStep.ICMeasureStepAdcResult -> {
                Log.d(B369Device.TAG, device!!.getMacAddr() + ": imp over")
            }
            ICMeasureStep.ICMeasureStepHrStart -> {
                Log.d(B369Device.TAG, device!!.getMacAddr() + ": start hr")
            }
            ICMeasureStep.ICMeasureStepHrResult -> {
                val hrData = data2 as ICWeightData
                Log.d(B369Device.TAG, device!!.getMacAddr() + ": over hr: " + hrData.hr)
            }
            ICMeasureStep.ICMeasureStepMeasureOver -> {
                val data = data2 as ICWeightData
                Log.d(B369Device.TAG, device!!.getMacAddr() + ": over measure")
                onReceiveWeightData(device, data)
            }
            else -> {
            }
        }

    }

    override fun onReceiveWeightHistoryData(device: ICDevice?, historyData: ICWeightHistoryData?) {
        historyData?.let {
            Log.d(B369Device.TAG, "Got history data ${it.time} ${it.weight_lb} ")
        }
        Log.d(B369Device.TAG, "Weight history data ")
    }

    override fun onReceiveSkipData(device: ICDevice?, p1: ICSkipData?) {
        Log.d(B369Device.TAG, "Skip device ")
    }

    override fun onReceiveHistorySkipData(device: ICDevice?, p1: ICSkipData?) {
        Log.d(B369Device.TAG, "History skip data ")
    }

    override fun onReceiveSkipBattery(device: ICDevice?, p1: Int) {
        Log.d(B369Device.TAG, "Skip dattery ")
    }

    override fun onReceiveUpgradePercent(device: ICDevice?, p1: ICConstant.ICUpgradeStatus?, p2: Int) {
        Log.d(B369Device.TAG, "Device upgrade percent ")
    }

    override fun onReceiveDeviceInfo(device: ICDevice?, deviceInfo: ICDeviceInfo?) {
        Log.d(B369Device.TAG, "Got device info")
    }

    override fun onReceiveDebugData(device: ICDevice?, p1: Int, p2: Any?) {
        Log.d(B369Device.TAG, "Got debug data ")
    }

    override fun onReceiveConfigWifiResult(device: ICDevice?, wifiStatus: ICConstant.ICConfigWifiState?) {
        Log.i(B369Device.TAG,"Got wifi result for ${device?.macAddr} is ${wifiStatus}")
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
                    Log.d(B369Device.TAG,"Connecting ${device?.macAddr}")
                }
            }
            result = null
        }
    }

}



class B369Device :BaseDevice(){

    companion object{
        val TAG = B369Device::class.java.simpleName
        var device:ICDevice? = null
        var dataProcessor:DataProcessor? = null
        var b369Device:B369Device? = null

        fun getInstance():B369Device{
            if(b369Device==null){
                b369Device = B369Device()
            }
            return b369Device!!
        }
    }



    override fun connectDevice(context: Context, result: MethodChannel.Result, deviceId: String?) {
        Log.i(TAG, "Connecting to $deviceId")
        val config = ICDeviceManagerConfig()
        config.is_fill_adc = true
        config.context = context
        val user = ICUserInfo().apply {
            kitchenUnit = ICConstant.ICKitchenScaleUnit.ICKitchenScaleUnitLb
            weightUnit = ICWeightUnit.ICWeightUnitLb
            rulerUnit = ICConstant.ICRulerUnit.ICRulerUnitInch
            age = 37
            weight = 175.0
            sex = ICConstant.ICSexType.ICSexTypeMale
            height = 72
            userIndex = 1
            weightDirection = 1
            targetWeight = 200.0
            peopleType = ICConstant.ICPeopleType.ICPeopleTypeNormal
        }
        if(dataProcessor == null) {
            dataProcessor = DataProcessor()
            ICDeviceManager.shared().delegate = dataProcessor
            ICDeviceManager.shared().setUserList(listOf(user))
            ICDeviceManager.shared().updateUserInfo(user)
            ICDeviceManager.shared().initMgrWithConfig(config)
        }

        Log.d(TAG,"Bluetooth enabled ${ICDeviceManager.shared().isBLEEnable}")

        if(ICDeviceManager.shared().isBLEEnable){
            Log.d(TAG,"Bluetooth enabled")
            Log.d(TAG,"Setting call back")
            val callBack = B369InitialConnection(context, result, deviceId)
            ICDeviceManager.shared().scanDevice(callBack)

            //This is used to wait for 25 seconds and send error back
            GlobalScope.launch {
                delay(25000)
                ICDeviceManager.shared().stopScan()
                Log.d(TAG, "Device connected ${callBack.deviceConnected}")
                //If the device is not connected, then send an error back
                if(!callBack.deviceConnected) {
                    Log.d(TAG, "Unable to find device ")
                    MainActivity.currentActivity?.runOnUiThread {
                        result.success(ConnectionInfo.createResponse(message = "Failed", connected = false, deviceFound = callBack.deviceFound))
                    }
                }else{
                    device?.let {device->
                        ICDeviceManager.shared().settingManager.setScaleUnit(device, ICWeightUnit.ICWeightUnitKg
                        ) { code ->
                            Log.d(TAG, String.format("%s %s", device.getMacAddr(),
                                    "setting callback code :$code"))
                        }
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

}