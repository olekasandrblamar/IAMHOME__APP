package com.cerashealth.ceras.lifeplus

import android.content.Context
import android.util.Log
import com.cerashealth.ceras.*
import com.cerashealth.ceras.lifeplus.data.*
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

open class BaseDevice{
    open fun connectDevice(context: Context, result: MethodChannel.Result,deviceId: String?){

    }
    open fun syncData(result: MethodChannel.Result?, connectionInfo: ConnectionInfo, context: Context){
        Log.i(TAG,"Calling default sync data")
    }

    open fun getDeviceInfo(result: MethodChannel.Result?,connectionInfo: ConnectionInfo,context: Context){
        Log.i(TAG,"Calling default device Info")
    }

    open fun getConnectionStatus(result: MethodChannel.Result?,connectionInfo: ConnectionInfo,context: Context){
        Log.i(TAG,"Calling default device Info")
    }

    open fun checkForUpdate(result: MethodChannel.Result?,connectionInfo: ConnectionInfo,context: Context){
        Log.i(TAG,"Calling default Update")
        result?.success("{status:'Success'}")
    }

    open fun upgradeDevice(result: MethodChannel.Result?,connectionInfo: ConnectionInfo,context: Context){
        Log.i(TAG,"Calling default upgrade")
        result?.success("Success")
    }

    open fun readDataFromDevice(eventSink: EventChannel.EventSink,readingType:String){
        eventSink.endOfStream()
    }

    open fun disconnectDevice(result: MethodChannel.Result?){
        Log.i(TAG,"Calling default disconnect device")
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

        const val WATCH_DEVICE:String = "WATCH"
        const val BAND_DEVICE:String = "BAND"
        const val B369_DEVICE:String = "B369"
        var isBackground = false
        val TAG = WatchDevice::class.java.simpleName

        fun getDeviceImpl(deviceName:String?): BaseDevice {
            Log.i(TAG,"Getting implementation for $deviceName")
            return when(deviceName){
                WATCH_DEVICE-> WatchDevice()
                BAND_DEVICE->BandDevice()
                B369_DEVICE->B369Device()
                else -> BaseDevice()
            }
        }
    }
}