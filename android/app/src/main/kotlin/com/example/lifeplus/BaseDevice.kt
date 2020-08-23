package com.example.lifeplus

import android.content.Context
import com.cerashealth.ceras.ConnectionInfo
import com.cerashealth.ceras.WatchDevice
import io.flutter.plugin.common.MethodChannel

open class BaseDevice{
    open fun connectDevice(context: Context, result: MethodChannel.Result){

    }
    open fun syncData(result: MethodChannel.Result?, connectionInfo: ConnectionInfo, context: Context){

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