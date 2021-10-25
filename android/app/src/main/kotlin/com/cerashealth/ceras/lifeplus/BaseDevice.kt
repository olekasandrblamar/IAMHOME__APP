package com.cerashealth.ceras.lifeplus

import android.content.Context
import android.util.Log
import com.cerashealth.ceras.*
import com.cerashealth.ceras.lifeplus.data.*
import com.walnutin.hardsdk.ProductList.sdk.HardSdk
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

open class BaseDevice{
    open fun connectDevice(context: Context, result: MethodChannel.Result,deviceId: String?){

    }
    open fun syncData(result: MethodChannel.Result?, connectionInfo: ConnectionInfo, context: Context){
        Log.i(TAG,"Calling default sync data")
    }

    open fun getDeviceInfo(result: MethodChannel.Result?,connectionInfo: ConnectionInfo,context: Context) {
        Log.i(TAG, "Calling default device Info")
        sendConnectionResponse(connectionInfo.deviceId, true, result)
    }

    open fun getConnectionStatus(result: MethodChannel.Result?,connectionInfo: ConnectionInfo,context: Context){
        Log.i(TAG,"Calling default device Info")
        result?.success(false)
    }

    open fun checkForUpdate(result: MethodChannel.Result?,connectionInfo: ConnectionInfo,context: Context){
        Log.i(TAG,"Calling default Update")
        result?.success("{status:'Success'}")
    }

    open fun upgradeDevice(eventSink: EventChannel.EventSink?, connectionInfo: ConnectionInfo, context: Context){
        Log.i(TAG,"Calling default upgrade")
        eventSink?.success("{status:'Success'}")
        eventSink!!.endOfStream()
    }

    open fun readDataFromDevice(eventSink: EventChannel.EventSink,readingType:String){
        eventSink.endOfStream()
    }

    open fun disconnectDevice(result: MethodChannel.Result?,deviceId:String? = null){
        Log.i(TAG,"Calling default disconnect device")
    }

    open fun connectWifi(result: MethodChannel.Result?,connectionInfo: ConnectionInfo,context: Context,network:String?,password:String?){
        Log.i(TAG,"Calling default wifi connection")
    }

    open fun syncWeather(weatherList:List<WeatherInfo>){
        Log.i(TAG,"Calling default sync weather device")
    }

    fun sendConnectionResponse(deviceId:String?,status:Boolean,result: MethodChannel.Result?,batteryStatus:String? = ""){
        try {
            result?.success(ConnectionInfo.createResponse(message = "Success", connected = status, deviceId = deviceId,
                    deviceName = "", additionalInfo = mapOf(), deviceType = "",batteryStatus = batteryStatus))
        }catch (ex:Exception){
           Log.e(MainActivity.TAG,"Error while sending response",ex)
        }
    }

    companion object{

        const val WATCH_DEVICE = "BWELL"
        const val B300_PLUS = "B300+"
        const val BAND_DEVICE = "BACTIVE"
        const val B369_DEVICE = "B500"
        const val B360_DEVICE = "B330"
        var isBackground = false
        val TAG = WatchDevice::class.java.simpleName
        const val SUCCESS_STATUS = "Success"
        const val ERROR_STATUS = "Error"

        const val HEARTRATE = "HEART RATE"
        const val BP = "BP"
        const val TEMPERATURE = "TEMPERATURE"
        const val O2 = "BLOOD OXYGEN"

        fun getDeviceImpl(deviceName:String?): BaseDevice {
            Log.i(TAG,"Getting implementation for $deviceName")
            return when(deviceName?.toUpperCase()){
                WATCH_DEVICE-> WatchDevice()
                B300_PLUS-> WatchDevice()
                BAND_DEVICE->BandDevice()
                B369_DEVICE->B369Device.getInstance()
                B360_DEVICE ->B360Device.getInstance()
                else -> BaseDevice()
            }
        }
    }
}