package com.cerashealth.ceras.lifeplus

import android.content.Context
import android.util.Log
import com.cerashealth.ceras.*
import com.cerashealth.ceras.lifeplus.data.*
import io.flutter.plugin.common.MethodChannel

open class BaseDevice{
    open fun connectDevice(context: Context, result: MethodChannel.Result,deviceId: String?){

    }
    open fun syncData(result: MethodChannel.Result?, connectionInfo: ConnectionInfo, context: Context){

    }

    open fun getDeviceInfo(result: MethodChannel.Result?,connectionInfo: ConnectionInfo,context: Context){

    }

    open fun disconnectDevice(result: MethodChannel.Result?){
        
    }

    fun sendConnectionResponse(deviceId:String?,status:Boolean,result: MethodChannel.Result?){
        try {
            result?.success(ConnectionInfo.createResponse(message = "Success", connected = status, deviceId = deviceId,
                    deviceName = "", additionalInfo = mapOf(), deviceType = ""))
        }catch (ex:Exception){
           Log.e(MainActivity.TAG,"Error while sending response",ex)
        }
    }

    companion object{

        const val WATCH_DEVICE:String = "WATCH"
        const val BAND_DEVICE:String = "BAND"
        var isBackground = false

        fun getDeviceImpl(deviceName:String?): BaseDevice {
            return when(deviceName){
                WATCH_DEVICE-> WatchDevice()
                BAND_DEVICE->BandDevice()
                else -> BaseDevice()
            }
        }
    }
}