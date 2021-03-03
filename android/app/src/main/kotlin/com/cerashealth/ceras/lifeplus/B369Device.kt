package com.cerashealth.ceras.lifeplus

import android.content.Context
import android.util.Log
import cn.icomon.icdevicemanager.ICDeviceManager
import cn.icomon.icdevicemanager.callback.ICScanDeviceDelegate
import cn.icomon.icdevicemanager.model.device.ICDevice
import cn.icomon.icdevicemanager.model.device.ICScanDeviceInfo
import cn.icomon.icdevicemanager.model.other.ICConstant
import com.cerashealth.ceras.MainActivity
import com.cerashealth.ceras.lifeplus.data.ConnectionInfo
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class B369InitialConnection: ICScanDeviceDelegate{

    private var context: Context? = null

    private val result: MethodChannel.Result?

    private var deviceId:String? = null

    var deviceFound = false

    var deviceConnected =false

    constructor(context: Context, result: MethodChannel.Result, deviceId: String?) {
        this.context = context
        this.result = result
        this.deviceId = deviceId
    }

    override fun onScanResult(deviceInfo: ICScanDeviceInfo?) {
        Log.d(B369Device.TAG,"Found device ${deviceInfo?.macAddr}")
        deviceInfo?.let {
            val lastFour = it.macAddr.substring(it.macAddr.length - 5).replace(":", "")
            if(lastFour.toLowerCase()== deviceId?.toLowerCase()){
                Log.d(B369Device.TAG, "values matched matched")
                deviceFound = true
                result?.let {
                    val device = ICDevice().apply {
                        macAddr = deviceInfo.macAddr

                    }
                    ICDeviceManager.shared().addDevice(device) { device, code ->
                        try {
                            ICDeviceManager.shared().stopScan()
                            deviceConnected = true
                            B369Device.device = device
                            result.success(ConnectionInfo.createResponse(message = "Connected", connected = true, deviceId = deviceInfo.macAddr, deviceName = deviceInfo.name,
                                    deviceType = BaseDevice.B369_DEVICE, deviceFound = deviceFound))
                        } catch (ex: Exception) {
                            Log.e(B369Device.TAG, "Error while sending response ", ex)
                        }
                    }
                }
            }
        }
    }

}

class B369Device :BaseDevice(){

    companion object{
        val TAG = B369Device::class.java.simpleName
        var device:ICDevice? = null
    }

    override fun connectDevice(context: Context, result: MethodChannel.Result, deviceId: String?) {
        if(ICDeviceManager.shared().isBLEEnable){
            val callBack = B369InitialConnection(context, result, deviceId)
            ICDeviceManager.shared().scanDevice(B369InitialConnection(context, result, deviceId))
            GlobalScope.launch {
                delay(25000)
                Log.d(B369Device.TAG, "Unable to find device ")
                ICDeviceManager.shared().stopScan()
                if(!callBack.deviceConnected)
                    MainActivity.currentActivity?.runOnUiThread {
                        result.success(ConnectionInfo.createResponse(message = "Failed", connected = false, deviceFound = callBack.deviceFound))
                    }
            }
        }
    }

}